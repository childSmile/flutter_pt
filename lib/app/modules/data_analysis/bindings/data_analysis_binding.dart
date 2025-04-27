import 'package:get/get.dart';

import '../controllers/data_analysis_controller.dart';

class DataAnalysisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DataAnalysisController>(
      () => DataAnalysisController(),
    );
  }
}
