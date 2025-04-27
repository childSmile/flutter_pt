import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:production_tool_app/app/common/blue_data_manager.dart';
import 'package:production_tool_app/app/common/blue_plus_manager.dart';
import 'package:production_tool_app/app/common/blue_state.dart';
import 'package:production_tool_app/app/common/event_bus.dart';

import 'package:production_tool_app/app/routes/app_pages.dart';

class BleController extends GetxController {
  //TODO: Implement BleController

  late BluePlusManager _bluePlusManager;
  late StreamSubscription _streamSubscription;
  late StreamSubscription _connectStreamSubscription;

  late List<String> btnList;

  final devices = [].obs;
  var deviceResults = <String, ScanResult>{};
  @override
  void onInit() {
    super.onInit();

    _bluePlusManager = Get.find();

    _streamSubscription = eventBus.on<BasicEvent>().listen((event) {
      switch (event.method) {
        case "discoverDevice":
          {
            discoverDevice(event.arguments);
          }
          break;
        default:
      }
    });

    btnList = [
      "startSearch",
      "stopSearch",
    ];
  }

  void startSearch() async {
    printInfo(info: "startSearch===");

    final cmds = [
      // "MRK-Start:${(MRKCommandData.startSportCommand()).desString()}",
      // "MRK-End:${(MRKCommandData.endSportCommand()).desString()}",
      // "MRK-Pause:${(MRKCommandData.pauseSportCommand()).desString()}",
      // "ZJ-Ready:${(ZJCommand.readySport()).desString()}",
      // "ZJ-Start:${(ZJCommand.startSport()).desString()}",
      // "ZJ-End:${(ZJCommand.stopSport()).desString()}",
      // "ZJ-Pause:${(ZJCommand.pauseSport()).desString()}",
      // "ZJ-GetID:${(ZJCommand.getIdCmd()).desString()}",
      // "ZJ-DeviceInfo:${(ZJCommand.getDeviceInfoCmd()).desString()}",
      // "ZJ-跑-Ready:${(ZJCommand.treamillReadySportCommand()).desString()}",
      // "ZJ-跑-Start:${(ZJCommand.treamillStartSportCommand()).desString()}",
      // "ZJ-跑-End:${(ZJCommand.treamillStopSportCommand()).desString()}",
      // "ZJ-跑-Pause:${(ZJCommand.treamillPauseSportCommand()).desString()}",
      // "ZJ-跑-Mode:${(ZJCommand.treamillGetModeCommand()).desString()}",
      // "FTMS-Start:${(FTMSCommand.startSport()).desString()}",
      // "FTMS-End:${(FTMSCommand.stopSport()).desString()}",
      // "FTMS-Pause:${(FTMSCommand.pauseSport()).desString()}",
    ];
    // '0xf0b20101010a010101010101010101490101020207'
    final model = BlueDataManager.convertData(
        '0xf0b20101010a010101010101010101490101020207',
        BlueDataProtocol.BQProtocol,
        'FFF1');

    _bluePlusManager.startScan();
  }

  void stopSearch() async {
    _bluePlusManager.stopScan();
    // _bluePlugin.stopBluetoothSearch();
    // await _subscription?.cancel();
  }

  void discoverDevice(dynamic arguments) {
    // String uuid = arguments;
    // String uuid = arguments['uuid'];
    String name = arguments["name"];
    ScanResult result = arguments["result"];

    if (!devices.contains(name)) {
      devices.add(name);
    }

    deviceResults[name] = result;
  }

  void _alert(BluetoothConnectionState status, String name) async {
    await Fluttertoast.showToast(
        msg: status == BluetoothConnectionState.connected ? "连接成功" : "连接失败",
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        // backgroundColor: const Color.fromARGB(255, 119, 0, 255),
        // textColor: const Color(0xff00ff00),
        // fontAsset: 'assets/path/to/some-font.ttf,
        // webShowClose: true,
        fontSize: 16.0);

    if (status == BluetoothConnectionState.connected) {
      _streamSubscription.cancel();
      _connectStreamSubscription.cancel();
      Get.toNamed(Routes.DEVICE_DETIAL, arguments: name);
    }
  }

  void connectDevice(String name) async {
    // _channel.invokeMethod("connectDevice", name);
    _bluePlusManager.stopScan();

    _connectStreamSubscription =
        _bluePlusManager.streamController.stream.listen((state) {
      _alert(state, name);
    });

    _bluePlusManager.connectDevice2(name);
  }

  void filterDevice(String name) {
    if (name.isEmpty) {
      devices.value = deviceResults.keys.toList();
      return;
    }
    RegExp regExp = RegExp(name, caseSensitive: false);
    var filerDevices = devices.where((name) => regExp.hasMatch(name)).toList();
    devices.value = filerDevices;
  }

  void back() {
    Get.back();
  }

  @override
  void onClose() {
    stopSearch();
    debugPrint("close");
    super.onClose();
  }

// 将十六进制字符串转换为 Uint8List
  // Uint8List hexStringToBytes(String hexString) {
  //   hexString = hexString.replaceAll(RegExp(r'\s+'), '');

  //   if (hexString.length % 2 != 0) {
  //     throw ArgumentError('Hex string must have an even number of characters');
  //   }

  //   final bytes = Uint8List(hexString.length ~/ 2);
  //   for (int i = 0; i < hexString.length; i += 2) {
  //     bytes[i ~/ 2] = int.parse(hexString.substring(i, i + 2), radix: 16);
  //   }

  //   return bytes;
  // }
}
