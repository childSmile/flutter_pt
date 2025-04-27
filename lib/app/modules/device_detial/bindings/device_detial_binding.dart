import 'package:get/get.dart';

import '../controllers/device_detial_controller.dart';

class DeviceDetialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeviceDetialController>(
      () => DeviceDetialController(),
    );
  }
}
