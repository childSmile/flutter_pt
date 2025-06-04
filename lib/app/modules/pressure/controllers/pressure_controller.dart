import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:production_tool_app/app/common/blue_plus_manager.dart';

class PressureController extends GetxController {
  //TODO: Implement PressureController

  final count = 10.obs;
  final connectTime = 100.obs;
  final disconnectTime = 100.obs;
  final BluePlusManager _bluePlusManager = Get.find();
  int currentCount = 0;
  final name = Get.arguments;
  final textList = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint("PressureController name: $name");
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void startPressure() {
    print("startPressure");
    textList.clear();
    currentCount = 0;
    Future.delayed(Duration(milliseconds: connectTime.value), () {
      // 延迟连接时间后 断开设备连接
      disconnect();
    });
  }

  void disconnect() async {
    debugPrint("disconnect==${DateTime.now()}");
    int time_before = DateTime.now().millisecondsSinceEpoch;
    await _bluePlusManager.disconnectDevice(name);
    debugPrint("disconnect_after==${DateTime.now()}");
    int time_after = DateTime.now().millisecondsSinceEpoch;

    textList.add("第${currentCount + 1}次断开连接：耗时:${time_after - time_before}ms");

    if (currentCount < count.value) {
      currentCount++;
      Future.delayed(Duration(milliseconds: disconnectTime.value), () {
        // 延迟断开时间后 重新连接
        connect();
      });
    } else {
      textList.add("测试结束");
    }
  }

  void connect() async {
    int time_before = DateTime.now().millisecondsSinceEpoch;
    // debugPrint("connect==${DateTime.now()}");
    await _bluePlusManager.connectDevice(name);
    int time_after = DateTime.now().millisecondsSinceEpoch;
    // debugPrint("connect_after==${DateTime.now()}");
    textList.add("第${currentCount}次连接：耗时:${time_after - time_before}ms");

    if (currentCount < count.value) {
      Future.delayed(Duration(milliseconds: connectTime.value), () {
        // 延迟连接时间后 断开设备连接
        disconnect();
      });
    } else {
      textList.add("测试结束");
    }
  }
}
