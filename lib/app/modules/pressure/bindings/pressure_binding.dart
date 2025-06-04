import 'package:get/get.dart';

import '../controllers/pressure_controller.dart';

class PressureBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PressureController>(
      () => PressureController(),
    );
  }
}
