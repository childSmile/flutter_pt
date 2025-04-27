import 'dart:typed_data';

import 'package:production_tool_app/app/common/blue_data_manager.dart';
import 'package:production_tool_app/app/models/device_data_model/device_data_model.dart';
import '../extesion.dart';

class ZJData {
  static DeviceDataModel? convertModel(Uint8List data, String char) {
    // debugPrint("ZJ_convertModel==$data==$char");
    if (data.length < 2) {
      return null;
    }
    final prefix = data.sublist(1, 2).desString();

    switch (prefix) {
      case "42":
        // debugPrint("车表类瞬时数据");
        return _instantaneousData(data, char);
      case "43":
        // debugPrint("车表类累计数据");
        return _accumulatedData(data, char);
      case "51":
        // debugPrint("跑步机数据");
        return _treamillData(data, char);
      case "41":
        // debugPrint("获取设备参数指令");
        break;
    }

    // if (prefix == [0x42].desString()) {
    //   // debugPrint("车表类瞬时数据");
    //   return _instantaneousData(data, char);
    // } else if (prefix == [0x43].desString()) {
    //   // debugPrint("车表类累计数据");
    //   return _accumulatedData(data, char);
    // } else if (prefix == [0x51].desString()) {
    //   // debugPrint("跑步机数据");
    //   return _treamillData(data, char);
    // } else if (prefix == [0x41].desString()) {
    //   // debugPrint("获取设备参数指令");
    // }
    return null;
  }

  static _deviceInfo(Uint8List data) {}

  static DeviceDataModel? _instantaneousData(Uint8List data, String char) {
    if (data.length < 4) {
      return null;
    }
    DeviceDataModel model = DeviceDataModel();
    var buffer = 2;
    model.state = DataTool.numFromBytes(data, buffer, 1);
    buffer += 1;
    if (model.state == 0x02 || model.state == 0x03) {
      //运行中 & 暂停
      model.speed = DataTool.numFromBytes(data, buffer, 2) / 100;
      buffer += 2;
      model.drag = DataTool.numFromBytes(data, buffer, 1);
      buffer += 1;
      model.spm = DataTool.numFromBytes(data, buffer, 2);
      buffer += 2;
      model.rate = DataTool.numFromBytes(data, buffer, 1);
      buffer += 1;
      model.power = DataTool.numFromBytes(data, buffer, 2) / 10;
      buffer += 2;
      model.slope = DataTool.numFromBytes(data, buffer, 1);
      buffer += 1;
    }
    // debugPrint("zjmodel=$model");
    return model;
  }

  static DeviceDataModel? _accumulatedData(Uint8List data, String char) {
    if (data.length == 13) {
      DeviceDataModel model = DeviceDataModel();
      var buffer = 3; //[0x02,0x43,0x01]
      model.time = DataTool.numFromBytes(data, buffer, 2);
      buffer += 2;
      model.distance = realDistance(DataTool.numFromBytes(data, buffer, 2));
      buffer += 2;
      model.enery = DataTool.numFromBytes(data, buffer, 2) / 10;
      buffer += 2;
      model.count = DataTool.numFromBytes(data, buffer, 2);
      buffer += 2;
      return model;
    }
    return null;
  }

  static DeviceDataModel? _treamillData(Uint8List data, String char) {
    if (data.length < 4) {
      return null;
    }
    DeviceDataModel model = DeviceDataModel();
    var buffer = 2;
    model.state = DataTool.numFromBytes(data, buffer, 1);
    buffer += 1;
    if (model.state == 0x03 || model.state == 0x04 || model.state == 0x0a) {
      //运行中 & 减速中 & 暂停
      model.speed = DataTool.numFromBytes(data, buffer, 1) / 10;
      buffer += 1;
      model.slope = DataTool.numFromBytes(data, buffer, 1, sInt: true);
      buffer += 1;
      model.time = DataTool.numFromBytes(data, buffer, 2);
      buffer += 2;
      model.distance = realDistance(DataTool.numFromBytes(data, buffer, 2));
      buffer += 2;
      model.enery = DataTool.numFromBytes(data, buffer, 2) / 10;
      buffer += 2;
      model.count = DataTool.numFromBytes(data, buffer, 2);
      buffer += 2;
      model.rate = DataTool.numFromBytes(data, buffer, 1);
      buffer += 1;
    }
    return model;
  }

//计算距离算法，最高位是单位
  static int realDistance(int distance) {
    int realDistance = 0;

    if ((distance & 0x8000) != 0x8000) {
      realDistance = distance;
    } else {
      // 根据注释，如果最高位是1，表示距离单位是10，需要乘以10
      realDistance = (distance & 0x7FFF) * 10;
    }

    return realDistance;
  }
}

class ZJCommand {
  // 车表类
  static List<int> readySport() {
    List<int> command = [0x44, 0x01];
    return _resultCommand(command);
  }

  static List<int> startSport() {
    List<int> command = [0x44, 0x02];
    return _resultCommand(command);
  }

  static List<int> stopSport() {
    List<int> command = [0x44, 0x04];
    return _resultCommand(command);
  }

  static List<int> pauseSport() {
    List<int> command = [0x44, 0x03];
    return _resultCommand(command);
  }

  static List<int> getDeviceInfoCmd() {
    List<int> command = [0x41, 0x02];
    return _resultCommand(command);
  }

  //跑步机
  //ready
  static List<int> treamillReadySportCommand() {
    List<int> command = [0x53, 0x01];
    return _resultCommand(command);
  }

  // 开始or继续
  static List<int> treamillStartSportCommand() {
    List<int> command = [0x53, 0x09];
    return _resultCommand(command);
  }

  //stop
  static List<int> treamillStopSportCommand() {
    List<int> command = [0x53, 0x03];
    return _resultCommand(command);
  }

  //pause
  static List<int> treamillPauseSportCommand() {
    List<int> command = [0x53, 0x0a];
    return _resultCommand(command);
  }

  //获取设备模式
  static List<int> treamillGetModeCommand() {
    List<int> command = [0x50, 0x05];
    return _resultCommand(command);
  }

  //通用
  static List<int> getIdCmd() {
    List<int> command = [0x50, 0x00];
    return _resultCommand(command);
  }

  static List<int> deviceControlCommand({
    String? type,
    int? drag,
    int? slope,
    int? gear,
    int? speed,
    int? mode,
  }) {
    if (drag != null || slope != null) {
      List<int> command = [0x44, 0x05];
      command.add((drag ?? 0));
      command.add(slope ?? 0);
      return _resultCommand(command);
    }

    if (speed != null || slope != null) {
      List<int> command = [0x53, 0x02];
      command.add((speed ?? 0));
      command.add(slope ?? 0);
      return _resultCommand(command);
    }

    return [];
  }

  // add: header fcs end
  static List<int> _resultCommand(List<int> command) {
    final fcs = (Uint8List.fromList(command)).xor();
    command.insert(0, 0x02);
    command.add(fcs);
    command.add(0x03);
    return command;
  }
}
