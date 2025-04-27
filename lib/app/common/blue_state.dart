class BlueDeviceConnectStatus {
  static const int DisConnect = 0;
  static const int Connected = 1;
  static const int ConnectFailed = 2;
}

class DeviceType {
  static const int Bicycle = 1;
  static const int Cross = 2;
  static const int Rower = 3;
  static const int Treamill = 4;
}

class BlueDataProtocol {
  static const int MRKProtocol = 1;
  static const int FTMSProtocol = 2;
  static const int ZJProtocol = 3;
  static const int BQProtocol = 4;
  static const int HeartRateProtocol = 100;
}
