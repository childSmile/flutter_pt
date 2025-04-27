import 'package:flutter/foundation.dart';
import 'package:production_tool_app/app/common/extesion.dart';
import 'package:production_tool_app/app/common/blue_data_manager.dart';
import 'package:production_tool_app/app/models/device_data_model/device_data_model.dart';

class FTMSData {
  static DeviceDataModel? convertModel(Uint8List data, String char) {
    // print("FTMS_convertModel==$data==$char");
    final flag = flagsFromData(data);
    switch (char) {
      case "2ACE":
        //椭圆机
        return _crossModel(flag, data);
      case "2AD2":
        //单车
        return _bicycleModel(flag, data);
      case "2AD1":
        //划船机
        return _boatModel(flag, data);
      case "2ACD":
        //跑步机、走步机
        return _treamillModel(flag, data);
      case "2ACC":
        //设备支持的能力 -- 所有设备
        return null;
      case "2AD3":
        // 上报设备状态数据 -- 所有状态
        _trainStatus(flag, data);
        return null;
      case "2AD4":
        //支持的速度范围 --- 跑步机、走步机、单车
        return null;
      case "2AD5":
        // 支持的坡度范围  --- 跑步机、走步机
        return null;
      case "2AD6":
        // 支持的阻力范围 -- 椭圆机
        return null;
      case "2AD7":
        // 支持的心率范围 -- 所有设备
        return null;
      case "2AD8":
        // 支持的功率范围
        return null;
      case "2AD9":
        // 控制健身设备的状态暂停、恢复等 --- 所有设备
        return null;
      case "2ADA":
        // 设备运动状态变更-- 所有设备
        _fitnessMachineStatus(flag, data);
        return null;

      default:
    }

    return null;
  }

  static _fitnessMachineStatus(List<int> flag, Uint8List data) {}

  static _trainStatus(List<int> flag, Uint8List data) {
    if (flag[0] == 1) {
      //存在training status参数
      var buffer = 2;
      int status = DataTool.numFromBytes(data, buffer, 1);
      String statusString = "";
      switch (status) {
        case 0x00:
          statusString = "未知状态";
          break;
        case 0x01:
          statusString = "IDLE状态";
          break;
        case 0x0d:
          statusString = "正在跑步是的状态";
          break;
        case 0x0e:
          statusString = "Pre-workout";
          break;
        case 0x0f:
          statusString = "Post-workout";
          break;
        default:
      }
      debugPrint("_trainStatus状态====$statusString");
    }
  }

  static DeviceDataModel _boatModel(List<int> flag, Uint8List data) {
    final model = DeviceDataModel();
    final dataArray = [
      0x0001,
      /* 其他数据 - 桨频 */
      0x0002,
      /* 平均桨频 */
      0x0004,
      /* 总距离 */
      0x0008,
      /* 瞬时速度 */
      0x0010,
      /* 平均速度 */
      0x0020,
      /* 瞬时功率 */
      0x0040,
      /* 平均功率 */
      0x0080,
      /* 阻力登记 */
      0x0100,
      /* 消耗 */
      0x0200,
      /* 心率 */
      0x0400,
      /* 代谢当量 */
      0x0800,
      /* 运动时间 */
      0x1000,
      /* 剩余时间 */
    ];
    var buffer = 2; //flags
    for (var i = 0; i < dataArray.length; i++) {
      if ((dataArray[i] == 0x0001 && flag[i] == 0) ||
          (dataArray[i] != 0x0001 && flag[i] == 1)) {
        switch (dataArray[i]) {
          case 0x0001:
            {
              model.spm = (DataTool.numFromBytes(data, buffer, 1) / 2);
              buffer = buffer + 1;
            }
            break;
          case 0x0002:
            {
              //Stroke Count:2 ,Average Stroke Rate:1
              model.count = DataTool.numFromBytes(data, buffer, 2);
              buffer += 2;
              model.avgSpm = (DataTool.numFromBytes(data, buffer, 1) / 2);
              buffer += 1;
            }
            break;
          case 0x0004:
            {
              model.distance = DataTool.numFromBytes(data, buffer, 3);
              buffer = buffer + 3;
            }
            break;
          case 0x0008:
            {
              model.speed = (DataTool.numFromBytes(data, buffer, 2));
              buffer = buffer + 2;
            }
            break;
          case 0x0010:
            {
              model.avgSpeed = (DataTool.numFromBytes(data, buffer, 2));
              buffer = buffer + 2;
            }
            break;
          case 0x0020:
            {
              model.power =
                  (DataTool.numFromBytes(data, buffer, 2, sInt: true));
              buffer = buffer + 2;
            }
            break;
          case 0x0040:
            {
              model.avgPower =
                  (DataTool.numFromBytes(data, buffer, 2, sInt: true));
              buffer = buffer + 2;
            }
            break;
          case 0x0080:
            {
              model.drag = (DataTool.numFromBytes(data, buffer, 2, sInt: true));
              buffer = buffer + 2;
            }
            break;
          case 0x0100:
            {
              //Total Energy:2;Energy Per Hour:2;Energy Per Minute:1
              model.enery = (DataTool.numFromBytes(data, buffer, 2));
              buffer = buffer + 2 + 2 + 1;
            }
            break;
          case 0x0200:
            {
              model.rate = (DataTool.numFromBytes(data, buffer, 1));
              buffer = buffer + 1;
            }
            break;
          case 0x0400:
            {
              //代谢当量
              buffer = buffer + 1;
            }
            break;
          case 0x0800:
            {
              model.time = (DataTool.numFromBytes(data, buffer, 2));
              buffer = buffer + 2;
            }
            break;
          case 0x1000:
            {
              //剩余时间
              buffer = buffer + 2;
            }
            break;
          default:
        }
      }
    }

    return model;
  }

  static DeviceDataModel _treamillModel(List<int> flag, Uint8List data) {
    final model = DeviceDataModel();
    final dataArray = [
      0x0001,
      /* 其他数据 - 瞬时速度 */
      0x0002,
      /* 平均速度 */
      0x0004,
      /* 总距离 */
      0x0008,
      /* 坡度 */
      0x0010,
      /* 坡度增益 */
      0x0020,
      /* 瞬时步速 */
      0x0040,
      /* 平均步速 */
      0x0080,
      /* 消耗 */
      0x0100,
      /* 心率 */
      0x0200,
      /* 代谢当量 */
      0x0400,
      /* 运动时间 */
      0x0800,
      /* 剩余时间 */
      0x1000,
      /* 皮带动力输出的力和功率输出 */
      0x2000,
      /* 步数 */
    ];
    var buffer = 2; //flags
    for (var i = 0; i < dataArray.length; i++) {
      if ((dataArray[i] == 0x0001 && flag[i] == 0) ||
          (dataArray[i] != 0x0001 && flag[i] == 1)) {
        switch (dataArray[i]) {
          case 0x0001:
            {
              model.speed = (DataTool.numFromBytes(data, buffer, 2) / 100);
              buffer = buffer + 2;
            }
            break;
          case 0x0002:
            {
              model.avgSpeed = (DataTool.numFromBytes(data, buffer, 2) / 100);
              buffer = buffer + 2;
            }
            break;
          case 0x0004:
            {
              model.distance = DataTool.numFromBytes(data, buffer, 3);
              buffer = buffer + 3;
            }
            break;
          case 0x0008:
            {
              //（分为 坡度 和  Ramp Angle Setting两个指标） //S16
              model.slope =
                  (DataTool.numFromBytes(data, buffer, 2, sInt: true) / 10);
              buffer = buffer + 2 + 2;
            }
            break;
          case 0x0010:
            {
              ///坡度增益 代表海拔增益 （分为 正负增益两个指标） U16  单位0.1
              // Positive Elevation Gain:2;Negative Elevation Gain:2
              buffer = buffer + 2 + 2;
            }
            break;
          case 0x0020:
            {
              model.spm = (DataTool.numFromBytes(data, buffer, 1) / 10);
              buffer = buffer + 1;
            }
            break;
          case 0x0040:
            {
              model.avgSpm = (DataTool.numFromBytes(data, buffer, 1) / 10);
              buffer = buffer + 1;
            }
            break;
          case 0x0080:
            {
              //Total Energy:2;Energy Per Hour:2;Energy Per Minute:1
              model.enery = (DataTool.numFromBytes(data, buffer, 2));
              buffer = buffer + 2 + 2 + 1;
            }
            break;
          case 0x0100:
            {
              model.rate = (DataTool.numFromBytes(data, buffer, 1));
              buffer = buffer + 1;
            }
            break;
          case 0x0200:
            {
              //代当 0.1
              buffer = buffer + 1;
            }
            break;
          case 0x0400:
            {
              model.time = (DataTool.numFromBytes(data, buffer, 2));
              buffer = buffer + 2;
            }
            break;
          case 0x0800:
            {
              //剩余时间
              buffer = buffer + 2;
            }
            break;
          case 0x1000:
            {
              //皮带动力输出的力和功率输出
              buffer = buffer + 2;
              model.power = DataTool.numFromBytes(data, buffer, 2, sInt: true);
              buffer = buffer + 2;
            }
            break;
          case 0x2000:
            {
              model.count = DataTool.numFromBytes(data, buffer, 3);
              buffer = buffer + 3;
            }
            break;
          default:
        }
      }
    }

    print(model.toString());
    return model;
  }

  static DeviceDataModel _bicycleModel(List<int> flag, Uint8List data) {
    final model = DeviceDataModel();
    final dataArray = [
      0x0001,
      /* 其他数据 - 瞬时速度 */
      0x0002,
      /* 平均速度 */
      0x0004,
      /* 瞬时踏频 */
      0x0008,
      /* 平均踏频 */
      0x0010,
      /* 总距离 */
      0x0020,
      /* 阻力档位 */
      0x0040,
      /* 瞬时功率 */
      0x0080,
      /* 平均功率 */
      0x0100,
      /* 消耗 */
      0x0200,
      /* 心率 */
      0x0400,
      /* 代谢当量 */
      0x0800,
      /* 运动时间 */
      0x1000,
      /* 剩余时间 */
    ];
    var buffer = 2; //flags
    for (var i = 0; i < dataArray.length; i++) {
      if ((dataArray[i] == 0x0001 && flag[i] == 0) ||
          (dataArray[i] != 0x0001 && flag[i] == 1)) {
        switch (dataArray[i]) {
          case 0x0001:
            {
              model.speed = (DataTool.numFromBytes(data, buffer, 2) / 100);
              buffer = buffer + 2;
            }
            break;
          case 0x0002:
            {
              model.avgSpeed = (DataTool.numFromBytes(data, buffer, 2) / 100);
              buffer = buffer + 2;
            }
            break;
          case 0x0004:
            {
              model.spm = DataTool.numFromBytes(data, buffer, 2) / 2;
              buffer = buffer + 2;
            }
            break;
          case 0x0008:
            {
              /**
               U16    wStepPerMinute;            /* [可选] ---- 每分钟踏频 */
               U16    wAverageStepRate;        /* [可选] ---- 平均踏频 */
               */

              model.avgSpm = (DataTool.numFromBytes(data, buffer, 2));
              buffer = buffer + 2;
            }
            break;
          case 0x0010:
            {
              model.distance = (DataTool.numFromBytes(data, buffer, 3));
              buffer = buffer + 3;
            }
            break;
          case 0x0020:
            {
              model.drag = (DataTool.numFromBytes(data, buffer, 2, sInt: true));
              buffer = buffer + 2;
            }
            break;
          case 0x0040:
            {
              /**
               S16 
               */
              model.power =
                  (DataTool.numFromBytes(data, buffer, 2, sInt: true));
              buffer = buffer + 2;
            }
            break;
          case 0x0080:
            {
              model.avgPower =
                  (DataTool.numFromBytes(data, buffer, 2, sInt: true));
              buffer = buffer + 2;
            }
            break;
          case 0x0100:
            {
              //多两个数据位（Energy Per Hour：2；Energy Per Minute：1）
              model.enery = (DataTool.numFromBytes(data, buffer, 2));
              buffer = buffer + 2 + 2 + 1;
            }
            break;
          case 0x0200:
            {
              model.rate = (DataTool.numFromBytes(data, buffer, 1));
              buffer = buffer + 1;
            }
            break;
          case 0x0400:
            {
              buffer = buffer + 2;
            }
            break;
          case 0x0800:
            {
              model.time = (DataTool.numFromBytes(data, buffer, 2));
              buffer = buffer + 2;
            }
            break;
          case 0x1000:
            {
              buffer = buffer + 2;
            }
            break;
          default:
        }
      }
    }

    print(model.toString());
    return model;
  }

  static DeviceDataModel _crossModel(List<int> flag, Uint8List data) {
    final model = DeviceDataModel();
    final crossArray = [
      0x0001,
      /* 其他数据 - 瞬时速度 */
      0x0002,
      /* 平均速度 */
      0x0004,
      /* 总距离 */
      0x0008,
      /* 总步数 */
      0x0010,
      /* 总大步数（两个Step是一个Stride） */
      0x0020,
      /* 坡度增益 */
      0x0040,
      /* 坡度 */
      0x0080,
      /* 阻力等级 */
      0x0100,
      /* 瞬时功率 */
      0x0200,
      /* 平均功率 */
      0x0400,
      /* 消耗能量 */
      0x0800,
      /* 心率 */
      0x1000,
      /* 代谢当量 */
      0x2000,
      /* 运动时间 */
      0x4000,
      /* 剩余时间 */
      0x8000, /* 运行方向 00H：向前    01H：向后 */
    ];
    var buffer = 2; //flags
    buffer += 1; //运行方向
    for (var i = 0; i < crossArray.length; i++) {
      if ((crossArray[i] == 0x0001 && flag[i] == 0) ||
          (crossArray[i] != 0x0001 && flag[i] == 1)) {
        switch (crossArray[i]) {
          case 0x0001:
            {
              model.speed = (DataTool.numFromBytes(data, buffer, 2) / 100);
              buffer = buffer + 2;
            }
            break;
          case 0x0002:
            {
              model.avgSpeed = (DataTool.numFromBytes(data, buffer, 2) / 100);
              buffer = buffer + 2;
            }
            break;
          case 0x0004:
            {
              model.distance = DataTool.numFromBytes(data, buffer, 3);
              buffer = buffer + 3;
            }
            break;
          case 0x0008:
            {
              /**
               U16    wStepPerMinute;            /* [可选] ---- 每分钟踏频 */
               U16    wAverageStepRate;        /* [可选] ---- 平均踏频 */
               */
              model.spm = (DataTool.numFromBytes(data, buffer, 2));
              buffer = buffer + 2;
              model.avgSpm = (DataTool.numFromBytes(data, buffer, 2));
              buffer = buffer + 2;
            }
            break;
          case 0x0010:
            {
              model.count = (DataTool.numFromBytes(data, buffer, 2) / 10);
              buffer = buffer + 2;
            }
            break;
          case 0x0020:
            {
              buffer = buffer + 2 + 2;
            }
            break;
          case 0x0040:
            {
              /**
               S16 nInclination;            /* [可选] ---- 坡度 */
               S16 nRampAngleSetting;        /* [可选] ---- 坡度设置 */
               */
              model.slope =
                  (DataTool.numFromBytes(data, buffer, 2, sInt: true) / 10);
              buffer = buffer + 2 + 2;
            }
            break;
          case 0x0080:
            {
              model.drag =
                  (DataTool.numFromBytes(data, buffer, 2, sInt: true) / 10);
              buffer = buffer + 2;
            }
            break;
          case 0x0100:
            {
              model.power = (DataTool.numFromBytes(data, buffer, 2));
              buffer = buffer + 2;
            }
            break;
          case 0x0200:
            {
              model.avgPower = (DataTool.numFromBytes(data, buffer, 2));
              buffer = buffer + 2;
            }
            break;
          case 0x0400:
            {
              model.enery = (DataTool.numFromBytes(data, buffer, 2));
              buffer = buffer + 2 + 2 + 1;
            }
            break;
          case 0x0800:
            {
              model.rate = (DataTool.numFromBytes(data, buffer, 1));
              buffer = buffer + 1;
            }
            break;
          case 0x1000:
            {
              buffer = buffer + 1;
            }
            break;
          case 0x2000:
            {
              model.time = (DataTool.numFromBytes(data, buffer, 2));
              buffer = buffer + 2;
            }
            break;
          case 0x4000:
            {
              buffer = buffer + 2;
            }
            break;
          case 0x8000:
            {
              buffer = buffer + 1;
            }
            break;
          default:
        }
      }
    }

    return model;
  }

  static List<int> flagsFromData(Uint8List data) {
    String res = "";
    for (var i = 1; i >= 0; i--) {
      int num = data[i];
      res += num.toRadixString(2).padLeft(8, '0');
    }
    final list = res
        .split('')
        .reversed
        .toList()
        .map((toElement) => int.parse(toElement))
        .toList();
    // print("res=$res,=$list");
    return list;
  }
}

/**
 
 // 对于小端序
int valueLittleEndian = (bytes[2] << 16) | (bytes[1] << 8) | bytes[0];
// 对于大端序
int valueBigEndian = (bytes[0] << 16) | (bytes[1] << 8) | bytes[2];

 */

class FTMSCommand {
  static List<int> reqCtl() {
    List<int> command = [0x00];
    return command;
  }

  static List<int> startSport() {
    List<int> command = [0x07];
    return command;
  }

  static List<int> stopSport() {
    List<int> command = [0x08, 0x01];
    return command;
  }

  static List<int> pauseSport() {
    List<int> command = [0x08, 0x02];
    return command;
  }

  static List<int> deviceControlCommand({
    String? type,
    int? drag,
    int? slope,
    int? gear,
    int? speed,
    int? mode,
  }) {
    if (drag != null) {
      List<int> command = [0x04];
      command.add((drag));
      return command;
    }
    if (slope != null) {
      List<int> command = [0x03];
      Uint8List uint8list = slope.toBytes(2, Endian.little);
      command.addAll(List.from(uint8list));
      return command;
    }

    if (speed != null) {
      List<int> command = [0x02];
      Uint8List uint8list = speed.toBytes(2, Endian.little);
      command.addAll(List.from(uint8list));
      return command;
    }

    return [];
  }
}

extension FTMSExt on int {
  String? get ftmsOpCodeString {
    String? opCodeStr;
    switch (this) {
      case 0x00:
        opCodeStr = "Request Control";
        break;
      case 0x01:
        opCodeStr = "Reset";
        break;
      case 0x02:
        opCodeStr = "Set Target Speed";
        break;
      case 0x03:
        opCodeStr = "Set Target Inclination";
        break;
      case 0x04:
        opCodeStr = "Set Target Resistance Level";
        break;
      case 0x05:
        opCodeStr = "Set Target Power";
        break;
      case 0x06:
        opCodeStr = "Set Target Heart Rate";
        break;
      case 0x07:
        opCodeStr = "Start or Resume";
        break;
      case 0x08:
        opCodeStr = "Stop or Pause";
        break;
      case 0x80:
        opCodeStr = "Response Code";

        break;
      default:
    }
    return opCodeStr;
  }

  String? get ftmsOpResultString {
    String? opResultStr;
    switch (this) {
      case 0x01:
        opResultStr = "Success";
        break;
      case 0x02:
        opResultStr = "Op Code Not Supported";
        break;
      case 0x03:
        opResultStr = "Invalid Parameter";
        break;
      case 0x04:
        opResultStr = "Operation Failed";
        break;
      case 0x05:
        opResultStr = "Control Not Permitted";
        break;
      default:
    }
    return opResultStr;
  }

  String? get ftmsMachineOpString {
    String? opResultStr;
    switch (this) {
      case 0x01:
        opResultStr = "Reset";
        break;
      case 0x02:
        opResultStr = "Stopped or Paused by the User";
        break;
      case 0x03:
        opResultStr = "Stopped by Safety Key";
        break;
      case 0x04:
        opResultStr = "Started or Resumed by the User";
        break;
      case 0x05:
        opResultStr = "Target Speed Changed";
        break;
      case 0x06:
        opResultStr = "Target Incline Changed";
        break;
      case 0x07:
        opResultStr = "Target Resistance Level Changed";
        break;
    }

    return opResultStr;
  }
}
