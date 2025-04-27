import 'dart:typed_data';

import 'package:production_tool_app/app/common/blue_data_manager.dart';
import 'package:production_tool_app/app/models/device_data_model/device_data_model.dart';

class Heartrate {
  static DeviceDataModel? convertModel(Uint8List data, String char) {
    switch (char) {
      case "2A37":
        {
          DeviceDataModel model = DeviceDataModel();
          int flag = DataTool.numFromBytes(data, 0, 1);
          if (flag & 0x01 == 0) {
            model.rate = DataTool.numFromBytes(data, 1, 1);
          } else {
            model.rate = DataTool.numFromBytes(data, 1, 2);
          }
          return model;
        }
      case "2A19":
        {
          DeviceDataModel model = DeviceDataModel();
          model.electric = DataTool.numFromBytes(data, 0, 1);
          return model;
        }
    }
    return null;
  }
}
