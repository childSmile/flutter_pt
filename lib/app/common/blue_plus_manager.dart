import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:production_tool_app/app/common/log_util.dart';
import 'package:production_tool_app/app/common/parase/BQData.dart';
import 'package:production_tool_app/app/common/parase/FTMS.dart';
import 'package:production_tool_app/app/common/parase/MRKData.dart';
import 'package:production_tool_app/app/common/parase/ZJData.dart';
import 'package:production_tool_app/app/common/blue_data_manager.dart';
import 'package:production_tool_app/app/common/blue_state.dart';
import 'package:production_tool_app/app/common/event_bus.dart';

class BluePlusManager extends GetxController {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;
  List<ScanResult> devices = [];

  //连接状态
  final StreamController<BluetoothConnectionState> streamController =
      StreamController<BluetoothConnectionState>.broadcast();

  // 广播数据监听
  final Map<String, StreamSubscription> _nofityStreamSubscriptionMap = {};
  StreamSubscription? _writeStreamSubscription;
  // 写入数据回调监听
  // static final _instance = BluePlusManager._internal();
  // factory BluePlusManager() {
  //   return _instance;
  // }

  // BluePlusManager._internal();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    initBLE();
  }

  void initBLE() {
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      LogUtil().i("蓝牙状态===$state");
      _adapterState = state;
    });
  }

  void startScan() {
    if (_adapterState != BluetoothAdapterState.on) {
      Fluttertoast.showToast(msg: "蓝牙未打开");
      return;
    }
    FlutterBluePlus.scanResults.listen((res) {
      // print("scan==$res");
      // filterDevice(res);
      if (res.isNotEmpty) {
        devices = res;
        ScanResult r = res.last;
        if (r.advertisementData.advName.isNotEmpty) {
          eventBus.fire(BasicEvent('discoverDevice', {
            "name": r.advertisementData.advName,
            "result": r,
          }));
        }
      }
    }, onError: (e) => LogUtil().e("scan_error:$e"));

    FlutterBluePlus.startScan();
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  void connectDevice2(String name) async {
    BluetoothDevice? device = _deviceFromName(name);
    if (device == null) {
      LogUtil().e("暂无设备");
      return;
    }
    try {
      // 连接设备
      await device.connect(timeout: const Duration(seconds: 10));

      // 监听连接状态变化
      StreamSubscription<BluetoothConnectionState>? connectionSubscription;

      connectionSubscription =
          device.connectionState.listen((BluetoothConnectionState state) {
        LogUtil().i("$name 连接状态: $state");

        streamController.sink.add(state);
        // 如果断开连接，取消订阅
        if (state == BluetoothConnectionState.disconnected) {
          connectionSubscription?.cancel();
          _writeStreamSubscription?.cancel();
          _nofityStreamSubscriptionMap.values.toList().forEach((e) {
            e.cancel();
          });
          _nofityStreamSubscriptionMap.clear();
        }
      });
    } catch (e) {
      LogUtil().e("连接失败: $e");
    }
  }

/*
  Future<BluetoothConnectionState> connectDevice(String name) async {
    BluetoothDevice? device = _deviceFromName(name);
    if (device == null) {
      LogUtil().e( "暂无设备");
      return BluetoothConnectionState.disconnected;
    }
    try {
      // 连接设备
      await device.connect();

      // 监听连接状态变化
      StreamSubscription<BluetoothConnectionState>? connectionSubscription;

      connectionSubscription =
          device.connectionState.listen((BluetoothConnectionState state) {
        LogUtil().i( "$name 连接状态: $state");

        streamController.sink.add(state);
        // 如果断开连接，取消订阅
        if (state == BluetoothConnectionState.disconnected) {
          connectionSubscription?.cancel();
        }
      });

      // 等待一段时间以确保连接状态稳定
      await Future.delayed(const Duration(seconds: 2));
      // 返回当前连接状态
      return await device.connectionState.first;
    } catch (e) {
      LogUtil().e( "连接失败: $e");
      return BluetoothConnectionState.disconnected;
    }
  }
*/
  Future<void> disconnectDevice(String name) async {
    BluetoothDevice? device = _deviceFromName(name);
    if (device == null) {
      LogUtil().e("disconnectDevice暂无设备");
      return;
    }
    await device.disconnect();
  }

  Future<List<BluetoothService>> getServices(String name) async {
    BluetoothDevice? device = _deviceFromName(name);
    if (device == null) {
      LogUtil().e("getServices暂无设备");
      return [];
    }

    return await device.discoverServices();
  }

  void startSport() {
    // FTMSCommandManager.startSport();
    // BlueCommandManager.startSport("name", 1, 1);
  }

  void deviceControl(String name, int prototcol, dynamic param,
      BluetoothCharacteristic writeChar,
      {String? type}) async {
    LogUtil().i("deviceControl==$param");
    BluetoothDevice? device = _deviceFromName(name);
    if (device == null) {
      LogUtil().e("deviceControl=暂无设备");
      return;
    }
    List<int> command = [];
    int drag = 0;
    if (param.keys.contains("drag")) {
      drag = int.parse(param["drag"]!);
    }

    switch (prototcol) {
      case BlueDataProtocol.ZJProtocol:
        {
          //阻力
          command = ZJCommand.deviceControlCommand(type: type, drag: drag);
        }
        break;
      case BlueDataProtocol.FTMSProtocol:
        {
          //阻力
          command = FTMSCommand.deviceControlCommand(type: type, drag: drag);
        }
        break;
      case BlueDataProtocol.BQProtocol:
        {
          command = BQCommand.controlDevice(drag).map((e) => e).toList();
        }
        break;
      case BlueDataProtocol.MRKProtocol:
        {
          command = MRKCommandData.deviceControlCommand(type: type, drag: drag);
        }
        break;
    }

    await write(writeChar, command, name: name);
  }

  Future<void> write(BluetoothCharacteristic char, List<int> data,
      {String? name}) async {
    try {
      _writeStreamSubscription = char.onValueReceived.listen((res) {
        LogUtil().i("write_onValueReceived==$res");
      });
      await char.write(data,
          withoutResponse: char.properties.writeWithoutResponse);
      LogUtil().d("write_data_success");
    } on PlatformException catch (exception) {
      PlatformException platformException = exception;
      // 根据错误信息进行处理
      if (platformException.code == 'device_disconnected' ||
          platformException.message!.contains('device is disconnected')) {
        print("设备已断开连接：${platformException.message}");
        // 这里可以添加重新连接设备的逻辑，或者提示用户
        // throw exception;
        // rethrow;
      } else {
        // 处理其他类型的 PlatformException
        print("平台异常：${platformException.code}, ${platformException.message}");
      }
    } catch (exception) {
      // 检查异常是否为 PlatformException
      // if (exception is PlatformException) {
      //   PlatformException platformException = exception;
      //   // 根据错误信息进行处理
      //   if (platformException.code == 'device_disconnected' ||
      //       platformException.message!.contains('device is disconnected')) {
      //     print("设备已断开连接：${platformException.message}");
      //     // 这里可以添加重新连接设备的逻辑，或者提示用户
      //     throw exception;
      //     // rethrow;
      //   } else {
      //     // 处理其他类型的 PlatformException
      //     print("平台异常：${platformException.code}, ${platformException.message}");
      //   }
      // } else {
      //   // 处理非 PlatformException 类型的异常
      //   print("发生异常：$exception");
      // }

      LogUtil().e("发生异常：$exception");
    }
  }

  void notify(
    BluetoothCharacteristic char,
    bool isNotify, {
    Function(List<int> res)? notifyData,
  }) async {
    try {
      final res = await char.setNotifyValue(isNotify);
      LogUtil().i("notify:$isNotify===${res ? "success" : "fail"}");
      String name = char.device.advName;
      if (isNotify) {
        StreamSubscription streamSubscription;
        if (_nofityStreamSubscriptionMap.keys
            .toList()
            .contains(char.characteristicUuid.str)) {
          streamSubscription =
              _nofityStreamSubscriptionMap[char.characteristicUuid.str]!;
        } else {
          streamSubscription = char.onValueReceived.listen((res) {
            LogUtil().i(
                "notify_onValueReceived==${DataTool.stringWithNumList(res)}}");
            if (notifyData != null) {
              notifyData(res);
              return;
            }
            eventBus.fire(BasicEvent(
                "blueData", {"data": res, "ch": char, "name": name}));
          });
          _nofityStreamSubscriptionMap[char.characteristicUuid.str] =
              streamSubscription;
        }
      }
    } catch (e) {
      LogUtil().e("notify_error:$e");
    }
  }

  Future<List<int>> readCharacteristic(BluetoothCharacteristic char) async {
    return await char.read();
  }

  BluetoothDevice? _deviceFromName(String name) {
    for (var sc in devices) {
      if (sc.advertisementData.advName == name) {
        return sc.device;
      }
    }
    return null;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _adapterStateSubscription.cancel();
    super.dispose();
  }
}
