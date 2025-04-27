import 'package:get/get.dart';
import 'package:production_tool_app/app/common/blue_plus_manager.dart';
import '../controllers/ble_controller.dart';

class BleBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BluePlusManager());
    Get.lazyPut<BleController>(
      () => BleController(),
    );
  }
}
