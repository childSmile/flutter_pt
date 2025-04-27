import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:production_tool_app/app/common/parase/HeartRate.dart';
import 'package:production_tool_app/app/common/parase/MRKData.dart';
import 'package:production_tool_app/app/common/blue_state.dart';
import 'package:production_tool_app/app/common/extesion.dart';
import 'package:production_tool_app/app/models/device_data_model/device_data_model.dart';
import 'package:production_tool_app/app/common/parase/ZJData.dart';
import 'package:production_tool_app/app/common/parase/BQData.dart';
import 'package:production_tool_app/app/common/parase/FTMS.dart';
import 'blue_char_extension.dart';

class BlueDataManager {
  static dynamic dealBlueData(List<int> data, BluetoothCharacteristic char) {
    // print("deal_blue_data:$char");
    Uint8List uint8list = Uint8List.fromList(data);
    String? value = deviceInfo(data, char);
    if (value != null) {
      return value;
    }
    switch (char.serviceUuid.str.toUpperCase()) {
      // case "180A":
      // case "F8C0":
      //   {
      //     return deviceInfo(data, char) ?? data.desString();
      //   }
      case "1826":
        {
          // if (data.length < 10) {
          //   return deviceInfo(data, char) ?? data.desString();
          // }
          return dealFTMSData(uint8list, char) ?? data.desString();
        }
      case "FFF0":
        {
          return dealFFF0Data(uint8list, char) ?? data.desString();
        }
      case "59554C55-8000-6666-8888-4D4552414348":
        {
          return dealMRKData(uint8list, char) ?? data.desString();
        }

      case "2A19":
      case "2A37":
        {
          DeviceDataModel? model = Heartrate.convertModel(
              uint8list, char.characteristicUuid.str.toUpperCase());
          return model ?? data.desString();
        }

      default:
    }
    return data.desString();
  }

  static DeviceDataModel? convertData(
    String data,
    int protocol,
    String char,
  ) {
    // print("convert==$data");
    List<int> datas = DataTool.hexStringToBytes(data);
    Uint8List uint8list = Uint8List.fromList(datas);
    // print("ll==$datas");

    switch (protocol) {
      case BlueDataProtocol.ZJProtocol:
        {
          final model = ZJData.convertModel(uint8list, char);
          return model;
        }
      case BlueDataProtocol.HeartRateProtocol:
        {
          return Heartrate.convertModel(uint8list, char);
        }
      case BlueDataProtocol.MRKProtocol:
        {
          return MrkData.convertModel(uint8list, char);
        }

      case BlueDataProtocol.FTMSProtocol:
        {
          return FTMSData.convertModel(uint8list, char);
        }
      case BlueDataProtocol.BQProtocol:
        {
          return BQData.convertModel(uint8list, char);
        }
      default:
        return null;
    }
  }

  static DeviceDataModel? dealMRKData(
      Uint8List data, BluetoothCharacteristic char) {
    if (char.characteristicUuid.str.toUpperCase() ==
        "59554c55-0000-6666-8888-4d4552414348".toUpperCase()) {
      debugPrint("心跳包回应");
      return null;
    }
    final model =
        MrkData.convertModel(data, char.characteristicUuid.str.toUpperCase());
    return model;
  }

  static DeviceDataModel? dealFFF0Data(
      Uint8List data, BluetoothCharacteristic char) {
    if (data.length < 5) {
      return null;
    }

    // print("rrrrr===${data.first} ====${data.first == 0xf0}");
    if (data.first == 0xf0) {
      final model = BQData.convertModel(data, char.uuidUpperStr,
          cmdDataBlock: (List<int> sendData) {
        Uint8List command = Uint8List.fromList(sendData);
        //send data
        BlueCommandManager.sendCommand(char, command);
      });
      return model;
    }

    final model = ZJData.convertModel(data, char.uuidUpperStr);
    return model;
  }

  static DeviceDataModel? dealFTMSData(
      Uint8List data, BluetoothCharacteristic char) {
    if (data.length < 5) {
      return null;
    }
    final model = FTMSData.convertModel(data, char.uuidUpperStr);
    return model;
  }

  static String? deviceInfo(List<int> data, BluetoothCharacteristic char) {
    String? value;
    switch (char.uuidUpperStr) {
      case "2A24":
      case "2A26":
      case "2A27":
      case "2A25":
      case "2A28":
      case "F8C4":
        {
          // 删除编码为0的字符
          List<int> list = data.where((code) => code != 0).toList();
          //1. utf8.decode
          // final utf8Decoder = utf8.decoder;
          // final decodedBytes = utf8Decoder.convert(list);
          // 2. String.fromCharCodes
          value = String.fromCharCodes(list);
          break;
        }
      case "2A23":
        {
          value = data.desString();
          break;
        }
      case "2AD3":
        {
          //STATUS
          final status = DataTool.numFromBytes(data.toUint8List(), 1, 1);
          var statusStr = "Unknow";
          switch (status) {
            case 0x01:
              statusStr = "IDLE";
              break;
            case 0x0D:
              statusStr = "Running";
              break;
            case 0x0E:
              statusStr = "Pre-workout";
              break;
            case 0x0F:
              statusStr = "Post-workout";
              break;
            default:
          }
          value = "${data.desString()} \n Status:$statusStr";
          break;
        }
      case "2AD4":
      case "2AD5":
        {
          //speed & slope
          var buffer = 0;
          final min =
              DataTool.numFromBytes(data.toUint8List(), buffer, 2) * 0.01;
          buffer += 2;
          final max =
              DataTool.numFromBytes(data.toUint8List(), buffer, 2) * 0.01;
          buffer += 2;
          final inc =
              DataTool.numFromBytes(data.toUint8List(), buffer, 2) * 0.01;

          value = "${data.desString()} \n Min:$min , Max:$max , inc:$inc";
          break;
        }
      case "2AD6":
        {
          //SPEED
          var buffer = 0;
          final min =
              DataTool.numFromBytes(data.toUint8List(), buffer, 2, sInt: true) *
                  0.1;
          buffer += 2;
          final max =
              DataTool.numFromBytes(data.toUint8List(), buffer, 2, sInt: true) *
                  0.1;
          buffer += 2;
          final inc =
              DataTool.numFromBytes(data.toUint8List(), buffer, 2) * 0.1;

          value = "${data.desString()} \n Min:$min , Max:$max , inc:$inc";
          break;
        }
      case "2AD9":
        {
          //Control Point
          var buffer = 0;
          final opCode = DataTool.numFromBytes(data.toUint8List(), buffer, 1);
          buffer += 1;
          final parameter =
              DataTool.numFromBytes(data.toUint8List(), buffer, 1);
          buffer += 1;
          final res = opCode == 0x80
              ? DataTool.numFromBytes(data.toUint8List(), buffer, 1)
              : -1;

          value =
              "${data.desString()} \n ${parameter.ftmsOpCodeString} : ${res.ftmsOpResultString}";
          break;
        }
      case "2ACC":
        {
          value = data.desString();
          break;
        }
      case "2ADA":
        {
          final opCode = DataTool.numFromBytes(data.toUint8List(), 0, 1);
          value = "${data.desString()} \n ${opCode.ftmsMachineOpString}";
          break;
        }

      default:
    }

    print("para:${char.uuidUpperStr} : $value");
    return value;
  }
}

class DataTool {
  // 十六进制字符串转list<int>
  static List<int> hexStringToBytes(String hexString) {
    // 去除前缀 "0x" 如果存在
    if (hexString.startsWith("0x")) {
      hexString = hexString.substring(2);
    }

    // 移除所有非十六进制字符（例如空格）
    hexString = hexString.replaceAll(RegExp(r'\s'), '');

    // 确保字符串长度是偶数，如果不是则添加前置零
    if (hexString.length % 2 != 0) {
      hexString = '0$hexString';
    }

    List<int> bytes = [];
    for (int i = 0; i < hexString.length; i += 2) {
      String byteString = hexString.substring(i, i + 2);
      int byte = int.parse(byteString, radix: 16);
      bytes.add(byte);
    }
    // print("bytes ==$bytes");
    return bytes;
  }

  static int numFromBytes(Uint8List data, int buffer, int count,
      {bool sInt = false, int defaultV = 0}) {
    // print("numFromBytes:$data , $buffer , $count");
    try {
      Uint8List bytes = data.safeSublist(
          buffer, buffer + count); //data.sublist(buffer, buffer + count);
      // print("bytes:$bytes");
      //小端
      int res = 0;
      switch (count) {
        case 1:
          res = bytes[0];
          break;
        case 2:
          res = (bytes[1] << 8) | bytes[0];
          break;
        case 3:
          res = (bytes[2] << 16) | (bytes[1] << 8) | bytes[0];
          break;
        case 4:
          res =
              (bytes[3] << 24) | (bytes[2] << 16) | (bytes[1] << 8) | bytes[0];
          break;

        default:
      }

      if (sInt == true) {
        // 检查最高位是否为1（表示负数）
        if ((res & 0x800000) != 0) {
          // 如果是负数，进行符号扩展
          res |= 0xFF000000;
        }
      }
      res = res - defaultV;
      return res;
    } catch (e) {
      debugPrint("numFromBytes error:$e");
      return 0;
    }
  }

  // static Uint8List padToFixedLengthOptimized2(int value, int length,
  //     {bool isSmall = true}) {
  //   Uint8List byteArray = Uint8List(length);
  //   for (int i = 0; i < length; i++) {
  //     if (!isSmall) {
  //       byteArray[length - 1 - i] = (value >> (i * 8)) & 0xFF;
  //     } else {
  //       byteArray[i] = (value >> (i * 8)) & 0xFF;
  //     }

  //     // 如果已经处理完整数的所有有效字节，则退出循环
  //     if ((value & (0xFF << (i * 8 + 8))) == 0) {
  //       break;
  //     }
  //   }
  //   return byteArray;
  // }

  // static Uint8List padToFixedLengthOptimized(int value, int length,
  //     {bool isSmall = true}) {
  //   if (length <= 0)
  //     throw ArgumentError.value(length, 'length', 'Must be greater than 0');
  //   Uint8List result = Uint8List(length);
  //   int byteCount = (value.bitLength + 7) ~/ 8;
  //   if (byteCount > length)
  //     throw ArgumentError.value(
  //         value, 'value', 'Too large to fit in specified length');
  //   // return DataTool.padToFixedLengthOptimized2(value, length,
  //   //     isSmall: !isSmall);

  //   for (int i = 0; i < byteCount; i++) {
  //     int index = isSmall ? i : (length - byteCount + i);
  //     result[index] = (value >> (i * 8)) & 0xFF;
  //   }
  //   return result;

  //   // int byteSize = length ~/ 8; // 计算字节大小
  //   // Uint8List uint8List = Uint8List(byteSize);

  //   // for (int i = 0; i < byteSize; i++) {
  //   //   int byteOffset = isSmall ? i : (byteSize - 1 - i);
  //   //   uint8List[byteOffset] = (value >> (i * 8)) & 0xFF;
  //   // }

  //   // return uint8List;
  // }

  // 十六进制 打印
  static String stringWithNumList(List<int> list) {
    return list
        .map((e) => e.toRadixString(16).padLeft(2, '0').toString())
        .join("")
        .toUpperCase();
  }
}

class BlueCommandManager {
  static sendCommand(BluetoothCharacteristic char, Uint8List sendData) async {
    BluetoothDevice device = char.device;
    for (var sv in device.servicesList) {
      if (sv.uuid.str.toUpperCase() == char.serviceUuid.str.toUpperCase()) {
        for (var ch in sv.characteristics) {
          if (ch.properties.write || ch.properties.writeWithoutResponse) {
            print("bq_write_ch==$ch");
            await ch.write(sendData,
                withoutResponse: ch.properties.writeWithoutResponse);
            break;
          }
        }
      }
    }
  }
}
