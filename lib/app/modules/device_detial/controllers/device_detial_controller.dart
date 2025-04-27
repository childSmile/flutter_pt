import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:production_tool_app/app/common/log_util.dart';
import 'package:production_tool_app/app/common/parase/BQData.dart';

import 'package:production_tool_app/app/common/blue_data_manager.dart';
import 'package:production_tool_app/app/common/blue_plus_manager.dart';
import 'package:production_tool_app/app/common/event_bus.dart';
import 'package:production_tool_app/app/common/file_save.dart';
import 'package:production_tool_app/app/common/ota.dart';
import 'package:production_tool_app/app/models/device_data_model/device_data_model.dart';
import 'package:production_tool_app/app/models/log_model/log_model.dart';
import 'package:production_tool_app/app/routes/app_pages.dart';
import '../views/scanner_widget.dart';
import '../../../common/extesion.dart';

class BlueCharacteristicModel {
  BluetoothCharacteristic? char;
  bool? isSelected;
}

class DeviceDetialController extends GetxController {
  //TODO: Implement DeviceDetialController

  String deviceName = Get.arguments;
  final isConnect = true.obs;
  final logList = [].obs;
  final PageController pageController = PageController(initialPage: 0);
  final dataModel = DeviceDataModel().obs;
  final BluePlusManager _bluePlusManager = Get.find();
  RxList<BluetoothService> serviceList = <BluetoothService>[].obs;
  final protocol = 1.obs;
  final ScrollController scrollController = ScrollController();
  final autoScroll = true.obs;
  BluetoothCharacteristic? writeCharacteristic;
  String writeCharRemoteId = "";
  List<BluetoothCharacteristic> notifyList = [];
  //指令textcontroller
  final TextEditingController textEditingController = TextEditingController();
  RxList<String> commandList = <String>[].obs;
  //设备连接状态监听
  StreamSubscription<BluetoothConnectionState>? _streamSubscription;
  //蓝牙数据监听
  StreamSubscription<BasicEvent>? _dataStreamSubscription;
  Timer? _timer;
  //下发指令下标
  int sendcommandIndex = 0;
  // bool isLoop = false;
  List<DeviceDataModel> models = [];

  final readValueCharacteristicMap = {}.obs;

  //固件升级
  final titleList = ["泰凌微", "富芮坤"];
  var otaTypeIndex = -1;
  final fileName = "".obs;
  BluetoothCharacteristic? otaWriteCharacteristic;
  BluetoothCharacteristic? otaNotifyCharacteristic;
  Uint8List? otaFile;
  final otaProgress = 0.0.obs;
  // 0:未开始； 1：成功； 2：失败
  final otaResult = 0.obs;

  List<int> baseAddress = [];
  var totalPackage = 0;
  var currentPackage = 0;
  var totalCleanPackage = 0;
  var currentCleanPackage = 0;
  var packageSize = 0;

  @override
  void onInit() {
    super.onInit();

    pageController.addListener(() {
      if (pageController.page == 2) {
        _scrollToBottomAnimated();
      }
    });

    _streamSubscription =
        _bluePlusManager.streamController.stream.listen((state) {
      isConnect.value = state == BluetoothConnectionState.connected;
      if (isConnect.value == false) {
        _timer?.cancel();
        otaProgress.value = 0.0;
      }
      if (isConnect.value == true) {
        //连接成功后获取服务
        getService();
      }
    });

    //初始话蓝牙事件监听
    _initBlueEvent();
    // 初始化数据
    _initData();
    //获取服务
    getService();
  }

  void _initData() async {
    // 获取本地保存命令
    String? res = await FileHelper.readData();
    final list = res?.split("\n").toList().where((e) => e.isNotEmpty).toList();
    debugPrint("commandList:$list");
    if (list == null) {
      return;
    }
    commandList.value = list;
  }

  void _initBlueEvent() {
    _dataStreamSubscription = eventBus.on<BasicEvent>().listen((event) {
      // print("method:${event.method} , arguments:${event.arguments}");
      switch (event.method) {
        case "blueData":
          {
            final map = event.arguments;
            _dealBlueData(map["ch"], map["data"]);
          }

          break;

        default:
      }
    });
  }

  void _dealBlueData(BluetoothCharacteristic ch, List<int> data) {
    printInfo(info: "获取到蓝牙数据：${ch.uuid.str},value:$data");

    if (ch.uuid.toString().toUpperCase() ==
        "02F00000-0000-0000-0000-00000000FF02") {
      // frkDealData(data);
      return;
    }

    final model = BlueDataManager.dealBlueData(data, ch);
    var showValue = "";

    if (model != null) {
      if (model is String) {
        showValue = model;
      } else if (model is DeviceDataModel) {
        showValue = model.toString();
        DeviceDataModel temp = _updateDataModel(model);
        temp.timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        dataModel.value = temp;
        showValue = temp.toString();
        models.add(temp);
      }
    }

    readValueCharacteristicMap[ch] = showValue;

    print("showValue===${readValueCharacteristicMap[ch]}");

    printInfo(
        info: "model===${models.length} == ${dataModel.value.toString()}");

    // 获取当前时间
    DateTime now = DateTime.now();
    logList.add(
        LogModel(char: ch, value: data, time: "$now", showValue: showValue));

    _scrollToBottomAnimated();
  }

  DeviceDataModel _updateDataModel(DeviceDataModel model) {
    DeviceDataModel temp = DeviceDataModel();
    temp.distance = model.distance ?? dataModel.value.distance;
    temp.time = model.time ?? dataModel.value.time;
    temp.enery = model.enery ?? dataModel.value.enery;
    temp.count = model.count ?? dataModel.value.count;
    temp.spm = model.spm ?? dataModel.value.spm;
    temp.speed = model.speed ?? dataModel.value.speed;
    temp.slope = model.slope ?? dataModel.value.slope;
    temp.drag = model.drag ?? dataModel.value.drag;
    temp.power = model.power ?? dataModel.value.power;
    // print("temp==${temp.toString()}");
    return temp;
  }

  void _scrollToBottomAnimated() {
    if (autoScroll.value == false) {
      return;
    }
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void sendCtlCommand(dynamic para) {
    if (para.isEmpty || writeCharacteristic == null) {
      print("请输入指令或者设备写入特征值");
      return;
    }

    _bluePlusManager.deviceControl(
        deviceName, protocol.value, para, writeCharacteristic!);
  }

  @override
  void onClose() async {
    debugPrint("HHHHHH===close");
    _bluePlusManager.disconnectDevice(deviceName);
    _streamSubscription?.cancel();
    _dataStreamSubscription?.cancel();
    _timer?.cancel();
    scrollController.dispose();
    pageController.dispose();
    textEditingController.dispose();
    super.onClose();
  }

  // 连接设备 or 断开设备
  void connectAction() async {
    if (isConnect.value) {
      printInfo(info: "断开设备");
      _bluePlusManager.disconnectDevice(deviceName);
    } else {
      printInfo(info: "连接设备");
      _bluePlusManager.connectDevice2(deviceName);
    }
  }

  void toDataAnalysis() {
    printInfo(info: "toDataAnalysis");
    Get.toNamed(Routes.DATA_ANALYSIS, arguments: models);
  }

  // 获取服务&特征值
  void getService() async {
    printInfo(info: "getService");
    List<BluetoothService> services =
        await _bluePlusManager.getServices(deviceName);
    serviceList.value = services;
    // await _bluePlugin.discoverService(deviceName);

    // _generateCommand();
  }

  // 生成智健调阻指令
  void _generateCommand() async {
    String cm = "";
    String res = "";
    for (int i = 0; i < 32; i++) {
      List<int> command = BQCommand.controlDevice((i + 1)).toList();
      cm = command
          .map((e) => e.toRadixString(16).padLeft(2, "0"))
          .toList()
          .join("");
      res = "$res\nBQ阻${i + 1}:$cm";
      // debugPrint("command:$cm");
    }
    // debugPrint("hahahh:$res");
    await FileHelper.writeData(res);
  }

  void toCharDetial(BluetoothCharacteristic char) {
    printInfo(info: "toCharDetial");
    Get.toNamed(Routes.CHAR_DETIAL, arguments: char);
  }

  void read(BluetoothCharacteristic char) async {
    printInfo(info: "读取数据==");
    final res = await _bluePlusManager.readCharacteristic(char);
    _dealBlueData(char, res);
  }

  void nofity(BluetoothCharacteristic char) {
    printInfo(info: "notifyCh==${char.isNotifying}");
    _bluePlusManager.notify(char, !char.isNotifying);
    if (notifyList.contains(char)) {
      notifyList.remove(char);
    } else {
      notifyList.add(char);
    }
  }

  void write({String? command}) {
    try {
      DateTime now = DateTime.now();
      debugPrint("$now :write : $command");
      if (writeCharacteristic == null) {
        printError(info: "writeChar==null");
        return;
      }
      String commandStr = "";
      if (command != null) {
        commandStr = command;
      } else {
        commandStr = textEditingController.text;
      }
      if (commandStr.isEmpty) {
        printError(info: "写入命令为空");
        return;
      }
      printInfo(info: "write:$commandStr");

      List<int> data = DataTool.hexStringToBytes(commandStr);
      _bluePlusManager.write(writeCharacteristic!, data);
    } catch (e) {
      LogUtil().e(e.toString());
    }
  }

  void saveControlData({String? data, String? name}) async {
    if (data == null || name == null) {
      return;
    }
    final command = "\n$name:$data";
    commandList.add(command);
    await FileHelper.writeData(command);
    _initData();
  }

  void importCommand() async {
    debugPrint("导入指令");
    final res = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (res != null) {
      final platformFile = res.files.single;
      File file = File(platformFile.path ?? "");
      // print("path==$file");
      // 读取文件内容
      String content = await file.readAsString();
      if (content.isNotEmpty) {
        // print("content==${content}");
        // Get.toNamed(Routes.DATA_ANALYSIS);
        // initData(content);
        await FileHelper.deleteCacheFiles();
      }
      await FileHelper.writeData("\n$content");

      Fluttertoast.showToast(msg: "导入成功");
      _initData();
    }
  }

  void deleteCommand(String command) async {
    debugPrint("删除指令");
    await FileHelper.deleteFileContent(command);
    _initData();
  }

  void loopSendCommand(List commands, int time) {
    debugPrint("循环发送指令==$commands , 时间间隔$time ms");

    _timer = Timer.periodic(Duration(milliseconds: time), (interval) {
      for (String comm in commands) {
        final data = comm.split(":").last;
        write(command: data);
        sleep(const Duration(milliseconds: 200));
      }
    });
  }

  Future<void> _startDelay(
      int time, Map<String, String?> map, bool loop) async {
    final Completer<void> completer = Completer();
    _timer = Timer(Duration(milliseconds: time), () {
      sendCommand(map, loop);
      completer.complete();
    });
    await completer.future;
  }

  Future<void> sendCommand(Map<String, String?> map, bool loop) async {
    if (isConnect.value == false) {
      printError(info: "已断开连接");
      return;
    }

    String key = map.keys.toList()[sendcommandIndex];
    String time = map[key] ?? "200";
    write(command: key.split(":").last);

    sendcommandIndex += 1;
    if (sendcommandIndex >= map.length) {
      if (loop) {
        debugPrint("循环发送，下一条从第一条重新开始");
        sendcommandIndex = 0;
      } else {
        debugPrint("发送完了");
        return;
      }
    }
    debugPrint("我要延迟发送下一条指令了");
    await _startDelay(int.parse(time), map, loop);

    // await Future.delayed(Duration(seconds: int.parse(time)), () {
    //   sendCommand(map, loop);
    // });
  }

  // 当重新选择循环发送弹窗时 ，其他循环发送取消
  void clearLoopSendData() {
    sendcommandIndex = 0;
    _timer?.cancel();
  }

  void setWriteChar(BluetoothCharacteristic char) {
    writeCharacteristic = char;
    writeCharRemoteId = char.uuid.str;
  }

  void selectOTAMethod(String? ota) {
    if (ota == null) {
      return;
    }
    print("选择OTA方式==$ota");
    otaTypeIndex = titleList.indexOf(ota);
    if (otaTypeIndex == 0) {
      //泰凌微
      for (var service in serviceList) {
        if (service.serviceUuid.toString().toUpperCase() ==
            "00010203-0405-0607-0809-0A0B0C0D1912") {
          for (var char in service.characteristics) {
            if (char.characteristicUuid.toString().toUpperCase() ==
                "00010203-0405-0607-0809-0A0B0C0D2B12") {
              otaWriteCharacteristic = char;
              break;
            }
          }
          break;
        }
      }
    } else if (otaTypeIndex == 1) {
      //富芮坤
      for (var service in serviceList) {
        if (service.serviceUuid.toString().toUpperCase() ==
            "02F00000-0000-0000-0000-00000000FE00") {
          for (var char in service.characteristics) {
            if (char.characteristicUuid.toString().toUpperCase() ==
                "02F00000-0000-0000-0000-00000000FF01") {
              otaWriteCharacteristic = char;
            } else if (char.characteristicUuid.toString().toUpperCase() ==
                "02F00000-0000-0000-0000-00000000FF02") {
              otaNotifyCharacteristic = char;
            }
          }
          break;
        }
      }
    }

    if (otaWriteCharacteristic == null) {
      Fluttertoast.showToast(msg: "请选择正确的OTA方式");
      return;
    }
    printInfo(
        info:
            "ota_char==${otaWriteCharacteristic?.characteristicUuid.toString()}");
  }

  void scanQRCode() {
    print("scanQRCode");
    Get.to(const ScannerPage())?.then((res) {
      debugPrint("扫描结果===$res");
    });
  }

  Future<void> uploadFile() async {
    print("OTA_upload_file");
    final res = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (res != null) {
      final platformFile = res.files.single;
      File file = File(platformFile.path ?? "");
      // print("path==$file");
      // 读取文件内容
      Uint8List content = await file.readAsBytes();
      if (content.isNotEmpty) {
        // print("OTA_content==${content}");
        fileName.value = platformFile.path!.split('/').last;
        otaFile = content;
      }
    }
  }

  void startOTA() async {
    print("START_OTA");

    if (otaWriteCharacteristic == null || otaFile == null || !isConnect.value) {
      printError(
          info:
              "otaWriteCharacteristic == null || otaFile == null || is not connect");
      return;
    }
    if (otaTypeIndex == 0) {
      await telinkOTA();
    } else if (otaTypeIndex == 1) {
      await frkOTA();
    }
  }

  Future<void> frkOTA() async {
    OTAManager.frkOTA(otaWriteCharacteristic, otaNotifyCharacteristic, otaFile,
        otaProgress: (progress) {
      otaProgress.value = progress;
    }, otaResult: (res, {error}) async {
      debugPrint("otaResult==$res");
      otaResult.value = res ? 1 : 2;
      if (res == false) {
        // 主动断开防止残留连接
        await _bluePlusManager.disconnectDevice(deviceName);
      }
    });
  }

  Future<void> telinkOTA() async {
    OTAManager.telinkOTA(otaWriteCharacteristic, otaFile,
        otaProgress: (progress) {
      otaProgress.value = progress;
    }, otaResult: (res, {error}) async {
      debugPrint("otaResult==$res");
      otaResult.value = res ? 1 : 2;
      if (res == false) {
        // 主动断开防止残留连接
        await _bluePlusManager.disconnectDevice(deviceName);
      }
    });
  }

  @override
  void dispose() {
    debugPrint("device_close");
    super.dispose();
  }
}
