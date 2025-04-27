import 'dart:async';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:production_tool_app/app/common/blue_data_manager.dart';
import 'package:production_tool_app/app/common/blue_plus_manager.dart';
import 'extesion.dart';
import 'package:ffi/ffi.dart';

class OTAManager {
  // 预生成所有数据包 (减少循环内计算)
  static List<Uint8List> _generateOTAPackets(
    Uint8List otaFile,
    int packageSize,
  ) {
    final total = (otaFile.length / packageSize).ceil();
    return List.generate(total, (index) {
      final start = index * packageSize;
      final end =
          (index == total - 1) ? otaFile.length : (index + 1) * packageSize;
      var chunk = otaFile.sublist(start, end);

      // 自动填充剩余空间
      if (chunk.length < packageSize) {
        chunk = Uint8List.fromList(
            [...chunk, ...List.filled(packageSize - chunk.length, 0xff)]);
      }

      // 添加包头和CRC
      final header = index.toBytes(2, Endian.little);
      final crc = Uint8List.fromList([...header, ...chunk]).crc16();
      final crcBytes = crc.toBytes(2, Endian.little);

      return Uint8List.fromList([...header, ...chunk, ...crcBytes]);
    });
  }

  // 预生成所有数据包 (减少循环内计算)
  static List<Uint8List> _generatefrkOTAPackets(
    Uint8List otaFile,
    int packageSize,
  ) {
    final total = (otaFile.length / packageSize).ceil();
    return List.generate(total, (index) {
      final start = index * packageSize;
      final end =
          (index == total - 1) ? otaFile.length : (index + 1) * packageSize;
      var chunk = otaFile.sublist(start, end);

      // 自动填充剩余空间
      if (chunk.length < packageSize) {
        chunk = Uint8List.fromList(
            [...chunk, ...List.filled(packageSize - chunk.length, 0x00)]);
      }

      return Uint8List.fromList([...chunk]);
    });
  }

  static Future<void> telinkOTA(
    BluetoothCharacteristic? otaWriteCharacteristic,
    Uint8List? otaFile, {
    required void Function(double progress) otaProgress,
    required void Function(bool otaRes, {String? error}) otaResult,
  }) async {
    if (otaWriteCharacteristic == null || otaFile == null) {
      otaResult(false,
          error: "otaWriteCharacteristic == null|| otaFile == null");
    }
    BluePlusManager bluePlusManager = Get.find();
    final device = otaWriteCharacteristic!.device;
    var subscription = device.connectionState.listen((state) {
      if ((state != BluetoothConnectionState.connected)) {
        otaResult(false, error: "设备已断开连接");
        throw Exception('设备连接已丢失');
      }
    });
    try {
      //start ota
      List<int> data = [0x01, 0xff];
      await bluePlusManager.write(otaWriteCharacteristic, data);

      //send data
      int packageSize = 16;
      int total = (otaFile!.length / packageSize).ceil();
      var index = 0;

      final packets = _generateOTAPackets(
        otaFile,
        packageSize,
      );
      await Future.forEach(packets, (packet) async {
        await bluePlusManager.write(otaWriteCharacteristic, packet);
        // debugPrint("Telink==${DataTool.stringWithNumList(packet)}}");
        index = packets.indexOf(packet);
        otaProgress((index * 1.0) / total);
      });

      //send end
      data = [0x02, 0xff];
      await bluePlusManager.write(otaWriteCharacteristic, data);
      //progress
      otaProgress(1);
      //res
      otaResult(true);
      //cancel
      subscription.cancel();
    } catch (exception) {
      subscription.cancel();
      debugPrint("ota_error==$exception");
      otaResult(false);
      // final errorMsg = (exception is FlutterBluePlusException)
      //     ? "蓝牙通信失败 (${exception.code})"
      //     : exception.toString();
      Fluttertoast.showToast(
        msg: "OTA_error:$exception",
      );
    }
  }

/*
  static StreamSubscription<List<int>> listenCharacteristicNotifications({
    required BluetoothDevice device,
    required Guid serviceUuid,
    required Guid characteristicUuid,
    required void Function(List<int>) onData,
    void Function(dynamic)? onError,
  }) {
    StreamSubscription<List<int>>? subscription;

    Future<void> startListen() async {
      try {
        final characteristic = await device.discoverServices().then((s) => s
            .firstWhere((s) => s.uuid == serviceUuid)
            .characteristics
            .firstWhere((c) => c.uuid == characteristicUuid));

        subscription =
            characteristic.onValueReceived.listen(onData, onError: onError);
        await characteristic.setNotifyValue(true);

        // 添加断连自动取消
        device.connectionState
            .where((s) => s == BluetoothConnectionState.disconnected)
            .first
            .then((_) => subscription?.cancel());
      } catch (e) {
        onError?.call(e);
      }
    }

    startListen();
    return subscription!;
  }
  */

  static Future<void> frkOTA(
    BluetoothCharacteristic? otaWriteCharacteristic,
    BluetoothCharacteristic? otaNotifyCharacteristic,
    Uint8List? otaFile, {
    required void Function(double progress) otaProgress,
    required void Function(bool otaRes, {String? error}) otaResult,
  }) async {
    try {
      if (otaWriteCharacteristic == null ||
          otaFile == null ||
          otaNotifyCharacteristic == null) {
        debugPrint(
            "otaWriteCharacteristic == null || otaFile == null  || otaNotifyCharacteristic == null");
        throw "otaWriteCharacteristic == null || otaFile == null || otaNotifyCharacteristic == null";
      }

      BluePlusManager bluePlusManager = Get.find();
      final device = otaWriteCharacteristic.device;
      bool otares = false;
      var subscription = device.connectionState.listen((state) {
        if ((state != BluetoothConnectionState.connected)) {
          otaResult(false, error: "设备已断开连接");
          if (otares) {
            return;
          }
          throw Exception('设备连接已丢失');
        }
      });
      // Subcribe NOTIFY
      bluePlusManager.notify(
        otaNotifyCharacteristic,
        true,
        notifyData: (res) {
          // debugPrint("frk_notify:${DataTool.stringWithNumList(res)}");
        },
      );

      // init data
      int packageSize = 116;
      int totalPackage = (otaFile.length / packageSize).ceil();
      int size = (4 * 1024);
      int totalCleanPackage = (otaFile.length / size).ceil();
      int currentCleanPackage = 0;
      int currentPackage = 0;
      Uint8List baseAddress = Uint8List(4);
      Uint8List address = Uint8List(4);
      final packets = _generatefrkOTAPackets(otaFile, packageSize);
      debugPrint(
          "total==$totalPackage , totalClean:$totalCleanPackage , bin:${otaFile.length}");

      StreamSubscription<List<int>>? notifySubscription;
      Future<void> startListen() async {
        try {
          notifySubscription =
              otaNotifyCharacteristic.onValueReceived.listen((data) {
            Uint8List uint8list = Uint8List.fromList(data);
            debugPrint("frk_notify==${uint8list.desString()}}");
            int opCode = DataTool.numFromBytes(uint8list, 1, 1);
            int res = DataTool.numFromBytes(uint8list, 0, 1);
            debugPrint("opCode:$opCode ,res:${res == 0 ? "success" : "fail"}");
            if (res == 1) {
              notifySubscription?.cancel();
            }

            switch (opCode) {
              case 0x01:
                {
                  // base address response
                  baseAddress =
                      uint8list.sublist(uint8list.length - 4, uint8list.length);
                  address = baseAddress;
                  debugPrint("baseAddress==${baseAddress.desString()}");
                  //send clean
                  _sendCleanData(otaWriteCharacteristic, address);
                }

                break;
              case 0x03:
                {
                  //clean response
                  currentCleanPackage += 1;
                  if (currentCleanPackage >= totalCleanPackage) {
                    //end clean,send data
                    _sendSectionData(otaWriteCharacteristic, baseAddress,
                        packets[currentPackage]);

                    return;
                  }
                  address =
                      uint8list.sublist(uint8list.length - 4, uint8list.length);
                  address = _addressOffsetBytes(address, size);
                  _sendCleanData(otaWriteCharacteristic, address);
                }
                break;
              case 0x05:
                {
                  // send data response
                  currentPackage += 1;
                  otaProgress((currentPackage * 1.0) / totalPackage);
                  if (currentPackage >= totalPackage) {
                    // send reset
                    _sendOTAData(
                        otaWriteCharacteristic, _frkResetCommand(otaFile));
                    otares = true;
                    notifySubscription?.cancel();
                    subscription.cancel();
                    otaResult(true);
                    return;
                  }
                  address = uint8list.sublist(
                      uint8list.length - 6, uint8list.length - 2);
                  address = _addressOffsetBytes(address, packageSize);
                  _sendSectionData(
                      otaWriteCharacteristic, address, packets[currentPackage]);
                }
                break;
              default:
            }
          }, onError: (error) {
            debugPrint("frk_notify_error==$error");
          });
          await otaWriteCharacteristic.setNotifyValue(true);
        } catch (e) {
          // onError?.call(e);
          debugPrint("ota_frk_fail==$e");
          notifySubscription?.cancel();
          subscription.cancel();
          otaResult(false, error: e.toString());
        }
      }

      startListen();

      //1.get base address
      _sendOTAData(otaWriteCharacteristic, _frkStartCommand());
    } catch (e) {
      debugPrint("ota_fail_error:$e");
    }
  }

  static Uint8List _addressOffsetBytes(
    Uint8List addressBytes,
    int length,
  ) {
    // 验证输入有效性
    if (addressBytes.length < 4) {
      throw ArgumentError('地址字节长度不足4字节');
    }

    // 步骤1：字节转整型（小端模式）
    final byteData = ByteData.view(addressBytes.buffer);
    int addressValue = byteData.getUint32(0, Endian.little);

    // 步骤2：执行4字节偏移
    addressValue += length; // 注意这里是4KB

    // 步骤3：整型转字节（小端模式）
    final result = Uint8List(4);
    final resultData = ByteData.view(result.buffer);
    resultData.setUint32(0, addressValue, Endian.little);

    return result;
  }

  static Future<void> _sendOTAData(
      BluetoothCharacteristic otaWriteCharacteristic,
      List<int> sendData) async {
    BluePlusManager bluePlusManager = Get.find();
    debugPrint("ota_senddata:${DataTool.stringWithNumList(sendData)}}");
    return await bluePlusManager.write(otaWriteCharacteristic, sendData);
  }

  static List<int> _frkStartCommand() {
    Uint8List cmdList = 0x01.toBytes(1, Endian.little);
    Uint8List indexList = 0x00.toBytes(2, Endian.little);

    List<int> sendData =
        Uint8List.fromList([...cmdList, ...indexList]).map((e) => e).toList();

    return sendData;
  }

  static List<int> _frkResetCommand(
    Uint8List otaFile,
  ) {
    Uint8List cmdList = 0x09.toBytes(1, Endian.little);
    Uint8List indexList = 0xA0.toBytes(2, Endian.little);
    Uint8List lengthList = otaFile.length.toBytes(4, Endian.little);
    int crc = FRKCrc.calculateCrc32(otaFile);
    Uint8List crcList = crc.toBytes(4, Endian.little);

    List<int> sendData = Uint8List.fromList(
            [...cmdList, ...indexList, ...lengthList, ...crcList])
        .map((e) => e)
        .toList();

    return sendData;
  }

  static int crcData(Uint8List otaFile) {
    int crc = 0;
    // int packageSize = 256;
    // int total = (otaFile.length / packageSize).ceil();
    // List<List<int>> packages = List.generate(total, (index) {
    //   final start = index * packageSize;
    //   final end =
    //       (index == total - 1) ? otaFile.length : (index + 1) * packageSize;
    //   var chunk = otaFile.sublist(start, end);
    //   return chunk;

    //   return Uint8List.fromList([
    //     ...chunk,
    //   ]);
    // });
    // Future.forEach(packages, (pack) {
    //   crc = Crc32().convert(pack).toRadixString(16);
    // });

    return crc;
  }

  static Future<void> _sendCleanData(
    BluetoothCharacteristic otaWriteCharacteristic,
    Uint8List address,
  ) async {
    BluePlusManager bluePlusManager = Get.find();
    Uint8List cmdList = 0x03.toBytes(1, Endian.little);
    Uint8List lengthList = 0x06.toBytes(2, Endian.little);

    List<int> sendData =
        Uint8List.fromList([...cmdList, ...lengthList, ...address])
            .map((e) => e)
            .toList();

    debugPrint("ota_cleandata:${DataTool.stringWithNumList(sendData)}}");
    return await bluePlusManager.write(otaWriteCharacteristic, sendData);
  }

  static Future<void> _sendSectionData(
    BluetoothCharacteristic otaWriteCharacteristic,
    Uint8List address,
    Uint8List data,
  ) async {
    BluePlusManager bluePlusManager = Get.find();
    Uint8List cmdList = 0x05.toBytes(1, Endian.little);
    Uint8List lengthList = 0x09.toBytes(2, Endian.little);
    Uint8List dataLengthList = data.length.toBytes(2, Endian.little);
    List<int> sendData = Uint8List.fromList(
            [...cmdList, ...lengthList, ...address, ...dataLengthList, ...data])
        .map((e) => e)
        .toList();

    debugPrint("ota_sectionData:${DataTool.stringWithNumList(sendData)}}");
    return await bluePlusManager.write(otaWriteCharacteristic, sendData);
  }
}

class FRKCrc {
  static List<int> crcTable = [
    0x00000000,
    0x77073096,
    0xee0e612c,
    0x990951ba,
    0x076dc419,
    0x706af48f,
    0xe963a535,
    0x9e6495a3,
    0x0edb8832,
    0x79dcb8a4,
    0xe0d5e91e,
    0x97d2d988,
    0x09b64c2b,
    0x7eb17cbd,
    0xe7b82d07,
    0x90bf1d91,
    0x1db71064,
    0x6ab020f2,
    0xf3b97148,
    0x84be41de,
    0x1adad47d,
    0x6ddde4eb,
    0xf4d4b551,
    0x83d385c7,
    0x136c9856,
    0x646ba8c0,
    0xfd62f97a,
    0x8a65c9ec,
    0x14015c4f,
    0x63066cd9,
    0xfa0f3d63,
    0x8d080df5,
    0x3b6e20c8,
    0x4c69105e,
    0xd56041e4,
    0xa2677172,
    0x3c03e4d1,
    0x4b04d447,
    0xd20d85fd,
    0xa50ab56b,
    0x35b5a8fa,
    0x42b2986c,
    0xdbbbc9d6,
    0xacbcf940,
    0x32d86ce3,
    0x45df5c75,
    0xdcd60dcf,
    0xabd13d59,
    0x26d930ac,
    0x51de003a,
    0xc8d75180,
    0xbfd06116,
    0x21b4f4b5,
    0x56b3c423,
    0xcfba9599,
    0xb8bda50f,
    0x2802b89e,
    0x5f058808,
    0xc60cd9b2,
    0xb10be924,
    0x2f6f7c87,
    0x58684c11,
    0xc1611dab,
    0xb6662d3d,
    0x76dc4190,
    0x01db7106,
    0x98d220bc,
    0xefd5102a,
    0x71b18589,
    0x06b6b51f,
    0x9fbfe4a5,
    0xe8b8d433,
    0x7807c9a2,
    0x0f00f934,
    0x9609a88e,
    0xe10e9818,
    0x7f6a0dbb,
    0x086d3d2d,
    0x91646c97,
    0xe6635c01,
    0x6b6b51f4,
    0x1c6c6162,
    0x856530d8,
    0xf262004e,
    0x6c0695ed,
    0x1b01a57b,
    0x8208f4c1,
    0xf50fc457,
    0x65b0d9c6,
    0x12b7e950,
    0x8bbeb8ea,
    0xfcb9887c,
    0x62dd1ddf,
    0x15da2d49,
    0x8cd37cf3,
    0xfbd44c65,
    0x4db26158,
    0x3ab551ce,
    0xa3bc0074,
    0xd4bb30e2,
    0x4adfa541,
    0x3dd895d7,
    0xa4d1c46d,
    0xd3d6f4fb,
    0x4369e96a,
    0x346ed9fc,
    0xad678846,
    0xda60b8d0,
    0x44042d73,
    0x33031de5,
    0xaa0a4c5f,
    0xdd0d7cc9,
    0x5005713c,
    0x270241aa,
    0xbe0b1010,
    0xc90c2086,
    0x5768b525,
    0x206f85b3,
    0xb966d409,
    0xce61e49f,
    0x5edef90e,
    0x29d9c998,
    0xb0d09822,
    0xc7d7a8b4,
    0x59b33d17,
    0x2eb40d81,
    0xb7bd5c3b,
    0xc0ba6cad,
    0xedb88320,
    0x9abfb3b6,
    0x03b6e20c,
    0x74b1d29a,
    0xead54739,
    0x9dd277af,
    0x04db2615,
    0x73dc1683,
    0xe3630b12,
    0x94643b84,
    0x0d6d6a3e,
    0x7a6a5aa8,
    0xe40ecf0b,
    0x9309ff9d,
    0x0a00ae27,
    0x7d079eb1,
    0xf00f9344,
    0x8708a3d2,
    0x1e01f268,
    0x6906c2fe,
    0xf762575d,
    0x806567cb,
    0x196c3671,
    0x6e6b06e7,
    0xfed41b76,
    0x89d32be0,
    0x10da7a5a,
    0x67dd4acc,
    0xf9b9df6f,
    0x8ebeeff9,
    0x17b7be43,
    0x60b08ed5,
    0xd6d6a3e8,
    0xa1d1937e,
    0x38d8c2c4,
    0x4fdff252,
    0xd1bb67f1,
    0xa6bc5767,
    0x3fb506dd,
    0x48b2364b,
    0xd80d2bda,
    0xaf0a1b4c,
    0x36034af6,
    0x41047a60,
    0xdf60efc3,
    0xa867df55,
    0x316e8eef,
    0x4669be79,
    0xcb61b38c,
    0xbc66831a,
    0x256fd2a0,
    0x5268e236,
    0xcc0c7795,
    0xbb0b4703,
    0x220216b9,
    0x5505262f,
    0xc5ba3bbe,
    0xb2bd0b28,
    0x2bb45a92,
    0x5cb36a04,
    0xc2d7ffa7,
    0xb5d0cf31,
    0x2cd99e8b,
    0x5bdeae1d,
    0x9b64c2b0,
    0xec63f226,
    0x756aa39c,
    0x026d930a,
    0x9c0906a9,
    0xeb0e363f,
    0x72076785,
    0x05005713,
    0x95bf4a82,
    0xe2b87a14,
    0x7bb12bae,
    0x0cb61b38,
    0x92d28e9b,
    0xe5d5be0d,
    0x7cdcefb7,
    0x0bdbdf21,
    0x86d3d2d4,
    0xf1d4e242,
    0x68ddb3f8,
    0x1fda836e,
    0x81be16cd,
    0xf6b9265b,
    0x6fb077e1,
    0x18b74777,
    0x88085ae6,
    0xff0f6a70,
    0x66063bca,
    0x11010b5c,
    0x8f659eff,
    0xf862ae69,
    0x616bffd3,
    0x166ccf45,
    0xa00ae278,
    0xd70dd2ee,
    0x4e048354,
    0x3903b3c2,
    0xa7672661,
    0xd06016f7,
    0x4969474d,
    0x3e6e77db,
    0xaed16a4a,
    0xd9d65adc,
    0x40df0b66,
    0x37d83bf0,
    0xa9bcae53,
    0xdebb9ec5,
    0x47b2cf7f,
    0x30b5ffe9,
    0xbdbdf21c,
    0xcabac28a,
    0x53b39330,
    0x24b4a3a6,
    0xbad03605,
    0xcdd70693,
    0x54de5729,
    0x23d967bf,
    0xb3667a2e,
    0xc4614ab8,
    0x5d681b02,
    0x2a6f2b94,
    0xb40bbe37,
    0xc30c8ea1,
    0x5a05df1b,
    0x2d02ef8d,
  ];

  static int calculateCrc32(Uint8List data) {
    // print("length==${data.length}");
    const chunkSize = 256;
    int crc = 0;

    for (var i = 0; i < data.length; i += chunkSize) {
      final end = min(i + chunkSize, data.length);
      final chunk = data.sublist(i, end);
      if (i != 0) {
        // 保留原逻辑的分块处理特性
        crc = crc32CalByByte(chunk, crc);
        //getCrc32(list, crc);
        // Crc32().convert(chunk.map((e) => e).toList()); ////
        // crc = crc32CalByByte(crc, chunk);
        // crc = crc32CalByByte(crc, chunk.map((e) => e).toList(), chunk.length);
        // crc = crc32CalByByte(crc, chunk);
      }
    }
    // crc = 3015712315;
    //3189994501;
    print('crc_res====${crc}');
    return crc;
  }

  static int crc32CalByByte(List<int> data, [int crc = 0xFFFFFFFF]) {
    DynamicLibrary dylib = DynamicLibrary.executable();

    final DartCrc32CalByByteFunc crc32CalByByteFunc = dylib
        .lookup<NativeFunction<Crc32CalByByteFunc>>('Crc32CalByByte')
        .asFunction();

    final pointer = calloc<Uint8>(data.length);

    pointer.asTypedList(data.length).setAll(0, data);

    crc = crc32CalByByteFunc(crc, pointer, data.length);
    calloc.free(pointer);
    return crc;
  }
}

// 定义C函数的签名
typedef Crc32CalByByteFunc = Uint32 Function(
    Uint32 crc, Pointer<Uint8> ptr, Int32 len);
typedef DartCrc32CalByByteFunc = int Function(
    int crc, Pointer<Uint8> ptr, int len);
