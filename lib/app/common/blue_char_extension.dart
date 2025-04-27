import 'package:flutter_blue_plus/flutter_blue_plus.dart';

extension BluetoothCharacteristicExt on BluetoothCharacteristic {
  bool get isNotify {
    bool isnotify = properties.indicate || properties.notify;
    return isnotify;
  }

  bool get isWrite {
    bool isWrite = properties.write || properties.writeWithoutResponse;
    return isWrite;
  }

  bool get isRead {
    bool isRead = properties.read;
    return isRead;
  }

  String get uuidUpperStr {
    return characteristicUuid.str.toUpperCase();
  }

  String get charShowName {
    String showName =
        "Unknow Characteristic"; //characteristicUuid.str.toUpperCase();

    switch (characteristicUuid.str.toUpperCase()) {
      case "2A29":
        showName = "Manufacturer Name";
        break;
      case "2A24":
        showName = "Model Number";
        break;
      case "2A25":
        showName = "Serial Number";
        break;
      case "2A26":
        showName = "Firmware Revision";
        break;
      case "2A27":
        showName = "Hardware Revision";
        break;
      case "2A28":
        showName = "Software Revision";
        break;
      case "2A19":
        showName = "Battery Level";
        break;
      case "2A37":
        showName = "Heart Rate Measurement";
        break;
      case "2ACC":
        showName = "Fitness Machine Feature";
        break;
      case "2ACD":
        showName = "Treadmill Data";
        break;
      case "2ACE":
        showName = "Cross Trainer Data";
        break;
      case "2AD1":
        showName = "Rower Data";
        break;
      case "2AD2":
        showName = "Indoor Bike Data";
        break;
      case "2AD3":
        showName = "Training Status";
        break;
      case "2AD4":
        showName = "Supported Speed Range";
        break;
      case "2AD5":
        showName = "Supported Inclination Range";
        break;
      case "2AD6":
        showName = "Supported Resistance Level Range";
        break;
      case "2AD7":
        showName = "Supported Heart Rate Range";
        break;
      case "2AD8":
        showName = "Supported Power Range";
        break;
      case "2AD9":
        showName = "Fitness Machine Control Point";
        break;
      case "2ADA":
        showName = "Fitness Machine Status";
        break;
      case "59554c55-0000-6666-8888-4d4552414348":
        showName = "MRK Ping";
        break;

      default:
        break;
    }

    return showName;
  }
}

extension BluetoothServiceExt on BluetoothService {
  String get serviceShowName {
    String showName = "Unknown Service";
    //serviceUuid.str.toUpperCase();
    switch (serviceUuid.str.toUpperCase()) {
      case "180A":
        showName = "Device Information";
        break;
      case "180D":
        showName = "Heart Rate";
        break;
      case "1826":
        showName = "Fitness Machine";
        break;
      case "180F":
        showName = "Battery Service";
        break;
      case "59554C55-8000-6666-8888-4D4552414348":
        showName = "MRK Service";
        break;
      case "02F00000-0000-0000-0000-00000000FE00":
        showName = "FRK Service";
        break;

      default:
    }

    return showName;
  }

  String get uuidUpperStr {
    return serviceUuid.str.toUpperCase();
  }
}
