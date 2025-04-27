import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:production_tool_app/app/common/blue_data_manager.dart';
import 'package:production_tool_app/app/common/extesion.dart';
import 'package:production_tool_app/app/models/device_data_model/device_data_model.dart';

class BQData {
  static DeviceDataModel? convertModel(
    Uint8List data,
    String char, {
    void Function(List<int>)? cmdDataBlock,
  }) {
    print("BQ_convertModel==${data.desString()}");
    final cmd = (data.sublist(1, 2)).desString();
    // print("cmd==$cmd");
    switch (cmd) {
      case "B7":
        {
          debugPrint("cmd错误===${(data.sublist(2, 4)).desString()} , 重新发送A0");
          if (cmdDataBlock != null) {
            List<int> sendData =
                BQCommand.bqSendCommand(0xA0, data.sublist(2, 4));
            cmdDataBlock(sendData);
          }
        }
        break;
      case "B0":
        {
          debugPrint("可以发送A5了");
          if (cmdDataBlock != null) {
            /**
             0x01：Start
             0x02：Stop
             0x03：Total Reset
             默认 + 1
             */
            Uint8List paraList = Uint8List.fromList([(0x01 + 1)]);
            List<int> sendData = BQCommand.bqSendCommand(
                0xA5, data.sublist(2, 4),
                paraList: paraList);
            cmdDataBlock(sendData);
          }
        }
        break;
      case "B5":
        {
          debugPrint("可以发送A2了");
          if (cmdDataBlock != null) {
            List<int> sendData = BQCommand.bqSendCommand(
              0xA2,
              data.sublist(2, 4),
            );
            cmdDataBlock(sendData);
          }
        }
        break;
      case "B2":
        {
          debugPrint("解析数据==继续发送A2");
          // if (cmdDataBlock != null) {
          //   Uint8List sendData = bqCommand(
          //     0xA2,
          //     data.sublist(2, 4),
          //   );
          //   cmdDataBlock(sendData);
          // }
          final index = DataTool.numFromBytes(data, 3, 1);
          debugPrint("index==$index");
          if (index == 0x01) {
            debugPrint("crosser");
            return _crosserData(data, char);
          } else if (index == 0xE7 || index == 0xE8) {
            debugPrint("boat");
            return _boatData(data, char);
          }
        }

        break;
      default:
    }

    return null;
  }

  static DeviceDataModel? _boatData(Uint8List data, String char) {
    if (data.length < 4) {
      return null;
    }
    DeviceDataModel model = DeviceDataModel();
    var buffer = 4;
    model.time = DataTool.numFromBytes(data, buffer, 1, defaultV: 1) * 60 +
        DataTool.numFromBytes(data, buffer + 1, 1, defaultV: 1);
    buffer += 2;
    model.count = DataTool.numFromBytes(data, buffer, 1, defaultV: 1) * 100 +
        DataTool.numFromBytes(data, buffer + 1, 1, defaultV: 1);
    buffer += 2;
    model.spm = DataTool.numFromBytes(data, buffer, 1, defaultV: 1) * 100 +
        DataTool.numFromBytes(data, buffer + 1, 1, defaultV: 1);
    buffer += 2;
    model.distance = DataTool.numFromBytes(data, buffer, 1, defaultV: 1) * 100 +
        DataTool.numFromBytes(data, buffer + 1, 1, defaultV: 1);
    buffer += 2;
    model.enery = DataTool.numFromBytes(data, buffer, 1, defaultV: 1) * 100 +
        DataTool.numFromBytes(data, buffer + 1, 1, defaultV: 1);
    buffer += 2;
    model.rate = DataTool.numFromBytes(data, buffer, 1, defaultV: 1) * 100 +
        DataTool.numFromBytes(data, buffer + 1, 1, defaultV: 1);
    buffer += 2;
    model.power = DataTool.numFromBytes(data, buffer, 1, defaultV: 1) * 10 +
        DataTool.numFromBytes(data, buffer + 1, 1, defaultV: 1) / 10.0;
    buffer += 2;
    model.drag = DataTool.numFromBytes(data, buffer, 1, defaultV: 1);
    buffer += 1;
    buffer += 2; //Time 500 Minute + Time 500 Second
    model.state = DataTool.numFromBytes(data, buffer, 1, defaultV: 1);
    buffer += 1;
    debugPrint("boatData==${model.toString()}}");
    return model;
  }

  static DeviceDataModel? _crosserData(Uint8List data, String char) {
    if (data.length < 4) {
      return null;
    }
    DeviceDataModel model = DeviceDataModel();
    var buffer = 4;
    model.time = DataTool.numFromBytes(data, buffer, 1, defaultV: 1) * 60 +
        DataTool.numFromBytes(data, buffer + 1, 1, defaultV: 1);
    buffer += 2;
    model.speed = DataTool.numFromBytes(data, buffer, 1, defaultV: 1) * 10 +
        DataTool.numFromBytes(data, buffer + 1, 1, defaultV: 1) / 10.0;
    buffer += 2;
    model.spm = DataTool.numFromBytes(data, buffer, 1, defaultV: 1) * 100 +
        DataTool.numFromBytes(data, buffer + 1, 1, defaultV: 1);
    buffer += 2;
    model.distance = (DataTool.numFromBytes(data, buffer, 1, defaultV: 1) * 10 +
            DataTool.numFromBytes(data, buffer + 1, 1, defaultV: 1) / 10.0) *
        1000;
    buffer += 2;
    model.enery = DataTool.numFromBytes(data, buffer, 1, defaultV: 1) * 100 +
        DataTool.numFromBytes(data, buffer + 1, 1, defaultV: 1);
    buffer += 2;
    model.rate = DataTool.numFromBytes(data, buffer, 1, defaultV: 1) * 100 +
        DataTool.numFromBytes(data, buffer + 1, 1, defaultV: 1);
    buffer += 2;
    model.power = DataTool.numFromBytes(data, buffer, 1, defaultV: 1) * 10 +
        DataTool.numFromBytes(data, buffer + 1, 1, defaultV: 1) / 10.0;
    buffer += 2;
    model.drag = DataTool.numFromBytes(data, buffer, 1, defaultV: 1);
    buffer += 1;
    model.state = DataTool.numFromBytes(data, buffer, 1, defaultV: 1);
    buffer += 1;
    return model;
  }
}

class BQCommand {
  static List<int> bqSendCommand(int cmd, Uint8List midList,
      {Uint8List? paraList}) {
    Uint8List prefixList = Uint8List.fromList([0xF0, cmd]);
    Uint8List crcList;
    if (paraList != null) {
      crcList = Uint8List.fromList([...prefixList, ...midList, ...paraList]);
    } else {
      crcList = Uint8List.fromList([...prefixList, ...midList]);
    }

    Uint8List sendData = Uint8List.fromList([...crcList, crcList.sum()]);
    debugPrint("BQSendData: $sendData");
    return List.from(sendData);
  }

  static List<int> controlDevice(int drag) {
    List<int> sendData = bqSendCommand(0xA6, Uint8List.fromList([0x44, 0x01]),
        paraList: Uint8List.fromList([drag + 1]));
    return sendData;
  }
}
