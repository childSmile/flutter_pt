import 'package:get/get.dart';

class DataConvertController extends GetxController {
  //TODO: Implement DataConvertController

  final count = 0.obs;

  Future<String> loadData() async {
    await Future.delayed(const Duration(seconds: 3));
    print("getData");
    return "Load Data success";
  }

  void increment() => count.value++;
}
