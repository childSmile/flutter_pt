import 'package:get/get.dart';

import '../modules/ble/bindings/ble_binding.dart';
import '../modules/ble/views/ble_view.dart';
import '../modules/char_detial/bindings/char_detial_binding.dart';
import '../modules/char_detial/views/char_detial_view.dart';
import '../modules/data_analysis/bindings/data_analysis_binding.dart';
import '../modules/data_analysis/views/data_analysis_view.dart';
import '../modules/data_convert/bindings/data_convert_binding.dart';
import '../modules/data_convert/views/data_convert_view.dart';
import '../modules/device_detial/bindings/device_detial_binding.dart';
import '../modules/device_detial/views/device_detial_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.BLE,
      page: () => const BleView(),
      binding: BleBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.DEVICE_DETIAL,
      page: () => const DeviceDetialView(),
      binding: DeviceDetialBinding(),
    ),
    GetPage(
      name: _Paths.DATA_ANALYSIS,
      page: () => const DataAnalysisView(),
      binding: DataAnalysisBinding(),
    ),
    GetPage(
      name: _Paths.DATA_CONVERT,
      page: () => const DataConvertView(),
      binding: DataConvertBinding(),
    ),
    GetPage(
      name: _Paths.CHAR_DETIAL,
      page: () => const CharDetialView(),
      binding: CharDetialBinding(),
    ),
  ];
}
