import 'package:get/get.dart';

import '../controllers/char_detial_controller.dart';

class CharDetialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CharDetialController>(
      () => CharDetialController(),
    );
  }
}
