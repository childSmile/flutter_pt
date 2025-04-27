import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:production_tool_app/app/common/blue_data_manager.dart';
import 'package:production_tool_app/app/models/device_data_model/device_data_model.dart';
import '../extesion.dart';

class MrkData {
  static const int packageHeaderDataLength = 1;
  static const int packageEndDataLength = 1;
  static const int packagLengthDataLength = 1;
  static const int packageFcsDataLength = 1;
  static const int packageDataTypeDataLength = 1;

  static DeviceDataModel? convertModel(Uint8List data, String char) {
    if (checkPackage(data, char) == false) {
      return null;
    }
    //解析
    int dataType = DataTool.numFromBytes(
        data, packageHeaderDataLength + packagLengthDataLength, 1);

    switch (dataType) {
      case 0x00:
        {
          //设备信息
        }
        break;
      case 0x01:
        {
          //运动数据
          return _dealData(data);
        }
      case 0x02:
        {
          //控制请求
          _deviceControl(data);
        }
        break;
      default:
    }

    return null;
  }

  static bool? _deviceControl(Uint8List data) {
    int start = packageHeaderDataLength +
        packagLengthDataLength +
        packageDataTypeDataLength;
    var i = start;
    while (i < data.length - packageEndDataLength - packageFcsDataLength) {
      int code = DataTool.numFromBytes(data, i, 1) & 0x7f;
      i += 1;
      int controlStatus = DataTool.numFromBytes(data, i, 1);
      i += 1;
      if (controlStatus == 0x01) {
        debugPrint("操作${code.toRadixString(16).toUpperCase()}:成功");
      } else if (controlStatus == 0x04) {
        debugPrint("操作${code.toRadixString(16).toUpperCase()}:失败");
      }
    }
    return null;
  }

  static DeviceDataModel? _dealData(Uint8List data) {
    if (data.isEmpty) {
      debugPrint("_deal_data_isempty}");
      return null;
    }
    var buffter = packageHeaderDataLength +
        packagLengthDataLength +
        packageDataTypeDataLength;
    // "AA2B01
    // 0103
    // 0200
    // 032604
    // 063C00
    // 0C3A00
    // 0F64120000
    // 101E030000
    // 170A00
    // 081500
    // 0E1400
    // 124400
    // 1E2E06
    // 1600
    // 1F55"
    DeviceDataModel model = DeviceDataModel();
    var index = 0;
    for (var i = buffter;
        i < data.length - packageFcsDataLength - packageEndDataLength;) {
      int code = DataTool.numFromBytes(data, i, 1);
      i += 1;
      // debugPrint("code==$code");
      int dataLength = _getFieldLength(code);
      index = i;
      i += dataLength;
      switch (code) {
        case 0x00:
          {
            Uint8List uint8list = data.sublist(index, index + dataLength);
            if (uint8list.first == 1) {
              model.electric =
                  DataTool.numFromBytes(data, index, dataLength) & 0x79;
            } else {
              model.electric = DataTool.numFromBytes(data, index, dataLength);
            }
          }
          break;
        case 0x01:
        case 0x02:
        case 0x0A:
        case 0x14:
        case 0x15:
        case 0x24:
        case 0x26:
        case 0x27:
        case 0x29:
        case 0x2A:
        case 0x2B:
        case 0x2F:
        case 0x30:
        case 0x31:
        case 0x33:
        case 0x34:
        case 0x35:
        case 0x3B:
        case 0x3F:
        case 0x40:
          {
            // i += dataLength;
          }
          break;
        case 0x16:
          {
            model.rate = DataTool.numFromBytes(data, index, dataLength);
          }
          break;
        case 0x07:
          {
            model.spm = DataTool.numFromBytes(data, index, dataLength);
          }
          break;
        case 0x04:
          {
            model.speed = DataTool.numFromBytes(data, index, dataLength);
          }
          break;
        case 0x0D:
          {
            model.avgSpm = DataTool.numFromBytes(data, index, dataLength) / 2;
          }
          break;

        case 0x05:
        case 0x0B:
        case 0x0C:
        case 0x13:
        case 0x19:
        case 0x1A:
        case 0x1B:
        case 0x1D:
        case 0x1F:
        case 0x20:
        case 0x21:
        case 0x22:
        case 0x23:
        case 0x25:
        case 0x28:
        case 0x2C:
        case 0x2D:
        case 0x2E:
        case 0x36:
        case 0x38:
        case 0x39:
        case 0x3A:
        case 0x3C:
        case 0x3E:
        case 0x41:
          {}
          break;
        case 0x11:
          {
            model.count = DataTool.numFromBytes(data, index, dataLength);
          }
          break;
        case 0x12:
          {
            model.enery = DataTool.numFromBytes(data, index, dataLength);
          }
          break;
        case 0x06:
          {
            model.spm = DataTool.numFromBytes(data, index, dataLength) / 2;
          }
          break;
        case 0x03:
          {
            model.speed = DataTool.numFromBytes(data, index, dataLength) * 0.01;
          }
          break;
        case 0x08:
          {
            model.power = DataTool.numFromBytes(data, index, dataLength);
          }
          break;
        case 0x09:
          {
            model.avgSpeed =
                DataTool.numFromBytes(data, index, dataLength) * 0.01;
          }
          break;
        case 0x0E:
          {
            model.avgPower = DataTool.numFromBytes(data, index, dataLength);
          }
          break;
        case 0x1C:
          {
            model.avgSpm = DataTool.numFromBytes(data, index, dataLength) / 2;
          }
          break;
        case 0x17:
          {
            model.drag =
                DataTool.numFromBytes(data, index, dataLength, sInt: true) *
                    0.1;
          }
          break;
        case 0x18:
          {
            model.slope =
                DataTool.numFromBytes(data, index, dataLength, sInt: true) *
                    0.1;
          }
          break;
        case 0x1E:
          {
            //运动时间
            model.time = DataTool.numFromBytes(data, index, dataLength);
          }

          break;
        case 0x0F:
          {
            model.distance = DataTool.numFromBytes(data, index, dataLength);
          }
          break;
        case 0x10:
          {
            model.count = DataTool.numFromBytes(data, index, dataLength);
          }
          break;
        case 0x32:
        case 0x37:
        case 0x3D:
          {}
          break;

        default:
          debugPrint(
              "⚠️ 未知字段 code=0x${code.toRadixString(16).padLeft(2, '0')}");
          // // 安全策略：根据协议定义跳过未知字段，或抛出异常
          // final fieldLength = _getFieldLength(code); // 需要实现字段长度映射
          // i += fieldLength;
          break;
      }
    }
    // debugPrint("mrkmodel:$model");
    return model;
  }

  static bool checkPackage(Uint8List data, String char) {
    //length
    var buffer = packageHeaderDataLength;
    int length = DataTool.numFromBytes(data, buffer, packagLengthDataLength);
    if (length !=
        data.length - packageHeaderDataLength - packageEndDataLength) {
      Fluttertoast.showToast(msg: "长度校验不通过");
      return false;
    }

    //crc
    buffer = data.length - packageEndDataLength - packageFcsDataLength;
    int fcs = DataTool.numFromBytes(data, buffer, packageFcsDataLength);
    int end = data.length - packageEndDataLength - packageFcsDataLength;
    int xor = (data.sublist(packageHeaderDataLength, end)).xor();
    if (xor != fcs) {
      Fluttertoast.showToast(msg: "fcs校验不通过");
      return false;
    }

    return true;
  }

  // 新增字段长度映射方法
  static int _getFieldLength(int code) {
    final lengthMap = {
      0x00: 1,
      0x01: 1,
      0x02: 1,
      0x03: 2,
      0x04: 1,
      0x05: 2,
      0x06: 2,
      0x07: 1,
      0x08: 2,
      0x09: 2,
      0x0A: 1,
      0x0B: 2,
      0x0C: 2,
      0x0D: 1,
      0x0E: 2,
      0x0F: 4,
      0x10: 4,
      0x11: 2,
      0x12: 2,
      0x13: 2,
      0x14: 1,
      0x15: 1,
      0x16: 1,
      0x17: 2,
      0x18: 2,
      0x19: 2,
      0x1A: 2,
      0x1B: 2,
      0x1C: 2,
      0x1D: 2,
      0x1E: 2,
      0x1F: 2,
      0x20: 2,
      0x21: 2,
      0x22: 2,
      0x23: 2,
      0x24: 1,
      0x25: 2,
      0x26: 1,
      0x27: 1,
      0x28: 2,
      0x29: 1,
      0x2A: 1,
      0x2B: 1,
      0x2C: 2,
      0x2D: 2,
      0x2E: 2,
      0x2F: 1,
      0x30: 1,
      0x31: 1,
      0x32: 4,
      0x33: 1,
      0x34: 1,
      0x35: 1,
      0x36: 2,
      0x37: 4,
      0x38: 2,
      0x39: 2,
      0x3A: 2,
      0x3B: 1,
      0x3C: 2,
      0x3D: 4,
      0x3E: 2,
      0x3F: 11,
      0x40: 1,
      0x41: 2,
    };
    return lengthMap[code] ?? 0;
  }
}

class MRKCommandData {
  static List<int> startSportCommand() {
    List<int> command = [0x02];
    command.add(COMMCTLReqType.ctlReqStart.value);

    return _resultCommad(command);
  }

  static List<int> endSportCommand() {
    List<int> command = [0x02];
    command.add(COMMCTLReqType.ctlReqStop.value);
    return _resultCommad(command);
  }

  static List<int> pauseSportCommand() {
    List<int> command = [0x02];
    command.add(COMMCTLReqType.ctlReqPaus.value);
    return _resultCommad(command);
  }

  static List<int> deviceControlCommand({
    String? type,
    int? drag,
    int? slope,
    int? gear,
    int? speed,
    int? mode,
  }) {
    List<int> command = [0x02];
    var temp = 0;
    Uint8List tempList;
    if (drag != null) {
      command.add(COMMCTLReqType.ctlReqSetTargetReslevel.value);
      temp = drag * 10;
      tempList = temp.toBytes(2, Endian.little);
      //DataTool.padToFixedLengthOptimized(temp, 2);
      command.addAll(tempList.map((e) => e).toList());
    }
    if (slope != null) {
      command.add(COMMCTLReqType.ctlReqSetTargetInclination.value);
      temp = slope * 10;
      tempList = temp.toBytes(2, Endian.little);
      // DataTool.padToFixedLengthOptimized(temp, 2);
      command.addAll(tempList.map((e) => e).toList());
    }
    if (gear != null) {
      command.add(COMMCTLReqType.ctlReqSetTargetGearlevel.value);
      temp = gear;
      tempList = temp.toBytes(2, Endian.little);
      //DataTool.padToFixedLengthOptimized(temp, 1);
      command.addAll(tempList.map((e) => e).toList());
    }
    if (speed != null) {
      command.add(COMMCTLReqType.ctlReqSetTargetInclination.value);
      temp = speed;
      tempList = temp.toBytes(2, Endian.little);
      //DataTool.padToFixedLengthOptimized(temp, 2);
      command.addAll(tempList.map((e) => e).toList());
    }
    if (mode != null) {
      command.add(COMMCTLReqType.ctlSetDeviceMode.value);
      temp = mode;
      tempList = temp.toBytes(1, Endian.little);

      command.addAll(tempList.map((e) => e).toList());
    }

    return command.length == 1 ? [] : _resultCommad(command);
  }

  //insert: heder length fcs end
  static List<int> _resultCommad(List<int> command) {
    int length = command.length +
        MrkData.packageFcsDataLength +
        MrkData.packageFcsDataLength;
    command.insert(0, length);
    int fcs = (Uint8List.fromList(command)).xor();
    command.add(fcs);
    command.insert(0, COMMCTLReqType.packageHeader.value);
    command.add(COMMCTLReqType.packageEnd.value);
    return command;
  }
}

enum COMMCTLReqType {
  ctlReqGetDevInfo, // 0x00
  ctlReqGetRealData, // 0x01
  ctlReqCtl, // 0x02
  ctlReqStart, // 0x03
  ctlReqPaus, // 0x04
  ctlReqStop, // 0x05
  ctlReqReset, // 0x06
  ctlReqSetTargetSpeed, // 0x07
  ctlReqSetTargetInclination, // 0x08
  ctlReqSetTargetReslevel, // 0x09
  ctlReqSetTargetPower, // 0x0A
  ctlReqSetTargetHeartrate, // 0x0B
  ctlReqSetTargetEnergy, // 0x0C
  ctlReqSetTargetStep, // 0x0D
  ctlReqSetTargetStride, // 0x0E
  ctlReqSetTargetDistance, // 0x0F
  ctlReqSetTargetTurns, // 0x10
  ctlReqSetTargetElapsedTime, // 0x11
  ctlReqSetTargetGearlevel, // 0x12
  ctlReqSetPasscode, // 0x13
  ctlReqGetElectric, // 0x14
  ctlNotifyBleState, // 0x15
  ctlMeasureHeartSwitch, // 0x16
  ctlSetDeviceMode, // 0x17
  ctlSync, // 0x18
  ctlGetDataMessage, // 0x19
  ctlSetTargetRadius, // 0x1A
  ctlSetTargetWheeldiaratio, // 0x1B
  ctlSetTargetHallnum, // 0x1C
  ctlSetTargetFrictionMax, // 0x1D
  ctlSetTargetUnit, // 0x1E
  ctlSetTargetVrMax, // 0x1F
  ctlSetTargetVrMin, // 0x20
  ctlSetTargetVrDir, // 0x21
  ctlSetSwingAngleRange, // 0x22
  ctlSyncHeartrate, // 0x28
  ctlSyncEnergy, // 0x29
  ctlSyncDistance, // 0x2A
  ctlSyncInstantaneousspeed, // 0x2B
  ctlSyncElapsedtime, // 0x2C
  ctlSetContvalue, // 0x23
  ctlSetElastcoeffvalue, // 0x24
  ctlSetPullrecycoeffvalue, // 0x25
  ctlSetResistcoeffvalue, // 0x26
  ctlSetShakelevel, // 0x2D
  ctlSetShaketime, // 0x2E
  ctlSetShakehandlenum, // 0x2F
  ctlSetWeighttotalnum, // 0x30
  ctlSetSingleweight, // 0x31
  ctlSetUpthreshold, // 0x32
  ctlSetDownthreshold, // 0x33
  ctlSetInitialheightoffset, // 0x34

  packageHeader, //0xaa
  packageEnd, //0x55
  ctlDefault,
}

extension COMMCTLReqTypeExtension on COMMCTLReqType {
  static const values = {
    COMMCTLReqType.ctlReqGetDevInfo: 0x00,
    COMMCTLReqType.ctlReqGetRealData: 0x01,
    COMMCTLReqType.ctlReqCtl: 0x02,
    COMMCTLReqType.ctlReqStart: 0x03,
    COMMCTLReqType.ctlReqPaus: 0x04,
    COMMCTLReqType.ctlReqStop: 0x05,
    COMMCTLReqType.ctlReqReset: 0x06,
    COMMCTLReqType.ctlReqSetTargetSpeed: 0x07,
    COMMCTLReqType.ctlReqSetTargetInclination: 0x08,
    COMMCTLReqType.ctlReqSetTargetReslevel: 0x09,
    COMMCTLReqType.ctlReqSetTargetPower: 0x0A,
    COMMCTLReqType.ctlReqSetTargetHeartrate: 0x0B,
    COMMCTLReqType.ctlReqSetTargetEnergy: 0x0C,
    COMMCTLReqType.ctlReqSetTargetStep: 0x0D,
    COMMCTLReqType.ctlReqSetTargetStride: 0x0E,
    COMMCTLReqType.ctlReqSetTargetDistance: 0x0F,
    COMMCTLReqType.ctlReqSetTargetTurns: 0x10,
    COMMCTLReqType.ctlReqSetTargetElapsedTime: 0x11,
    COMMCTLReqType.ctlReqSetTargetGearlevel: 0x12,
    COMMCTLReqType.ctlReqSetPasscode: 0x13,
    COMMCTLReqType.ctlReqGetElectric: 0x14,
    COMMCTLReqType.ctlNotifyBleState: 0x15,
    COMMCTLReqType.ctlMeasureHeartSwitch: 0x16,
    COMMCTLReqType.ctlSetDeviceMode: 0x17,
    COMMCTLReqType.ctlSync: 0x18,
    COMMCTLReqType.ctlGetDataMessage: 0x19,
    COMMCTLReqType.ctlSetTargetRadius: 0x1A,
    COMMCTLReqType.ctlSetTargetWheeldiaratio: 0x1B,
    COMMCTLReqType.ctlSetTargetHallnum: 0x1C,
    COMMCTLReqType.ctlSetTargetFrictionMax: 0x1D,
    COMMCTLReqType.ctlSetTargetUnit: 0x1E,
    COMMCTLReqType.ctlSetTargetVrMax: 0x1F,
    COMMCTLReqType.ctlSetTargetVrMin: 0x20,
    COMMCTLReqType.ctlSetTargetVrDir: 0x21,
    COMMCTLReqType.ctlSetSwingAngleRange: 0x22,
    COMMCTLReqType.ctlSyncHeartrate: 0x28,
    COMMCTLReqType.ctlSyncEnergy: 0x29,
    COMMCTLReqType.ctlSyncDistance: 0x2A,
    COMMCTLReqType.ctlSyncInstantaneousspeed: 0x2B,
    COMMCTLReqType.ctlSyncElapsedtime: 0x2C,
    COMMCTLReqType.ctlSetContvalue: 0x23,
    COMMCTLReqType.ctlSetElastcoeffvalue: 0x24,
    COMMCTLReqType.ctlSetPullrecycoeffvalue: 0x25,
    COMMCTLReqType.ctlSetResistcoeffvalue: 0x26,
    COMMCTLReqType.ctlSetShakelevel: 0x2D,
    COMMCTLReqType.ctlSetShaketime: 0x2E,
    COMMCTLReqType.ctlSetShakehandlenum: 0x2F,
    COMMCTLReqType.ctlSetWeighttotalnum: 0x30,
    COMMCTLReqType.ctlSetSingleweight: 0x31,
    COMMCTLReqType.ctlSetUpthreshold: 0x32,
    COMMCTLReqType.ctlSetDownthreshold: 0x33,
    COMMCTLReqType.ctlSetInitialheightoffset: 0x34,
    COMMCTLReqType.packageHeader: 0xaa,
    COMMCTLReqType.packageEnd: 0x55,
    COMMCTLReqType.ctlDefault: 0xff,
  };
  int get value {
    return values[this] ?? -1;
  }
}
