import 'package:get/get.dart';

import '../controllers/data_convert_controller.dart';

class DataConvertBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DataConvertController>(
      () => DataConvertController(),
    );
  }
}
