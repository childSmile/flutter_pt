import 'package:get/get.dart';
import 'package:production_tool_app/app/routes/app_pages.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  final count = 0.obs;
  var btnMap = {};

  @override
  void onInit() {
    super.onInit();
    btnMap = {
      "ble": Routes.BLE,
      'data_analysis': Routes.DATA_ANALYSIS,
      'data_convert': Routes.DATA_CONVERT,
    };
  }

  void btnAction(String key) {
    print("btnAction:$key");
    Get.toNamed(btnMap[key]);
  }



  void increment() => count.value++;
}
