import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:production_tool_app/app/common/blue_data_manager.dart';
import 'package:production_tool_app/app/common/blue_state.dart';
import 'package:production_tool_app/app/models/device_data_model/device_data_model.dart';
import 'package:intl/intl.dart';

enum DataProprety {
  time,
  distance,
  enery,
  spm,
  count,
}

class DataAnalysisController extends GetxController {
  RxList<DeviceDataModel> models = <DeviceDataModel>[].obs;
  Map<String, DataProprety> items = {
    "时间": DataProprety.time,
    "距离": DataProprety.distance,
    "消耗": DataProprety.enery,
    "踏频": DataProprety.spm,
    "踏数/个数": DataProprety.count
  };
  String? selectedValue;
  final selectedIndex = DataProprety.time.obs;
  late StreamController<String> streamController;
  final page = 0.obs;
  final pageCount = 1000;
  var total = 0;
  List<String> seperateList = [];
  String analysisContent = "";
  String seperateString = "";

  @override
  void onInit() {
    super.onInit();

    seperateList = chs();
    seperateString = seperateList.first;

    streamController = StreamController<String>();

    print("arguments==${Get.arguments}");
    final arguments = Get.arguments;
    if (arguments != null) {
      if (arguments is List<DeviceDataModel>) {
        updateChartUI(arguments);
      } else if (arguments is String) {
        analysisContent = Get.arguments;
        convertModel();
      }
    } else {
      streamController.sink.addError(Exception("暂无文件,先选择文件"));
      // streamParseData();
    }
  }

  Future<void> uploadFile() async {
    print("upload file");
    final res = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (res != null) {
      final platformFile = res.files.single;
      File file = File(platformFile.path ?? "");
      // print("path==$file");
      // 读取文件内容
      analysisContent = await file.readAsString();
      if (analysisContent.isNotEmpty) {
        // print("content==${content}");
        // Get.toNamed(Routes.DATA_ANALYSIS);
        convertModel();
      }
    }
  }

  void nextPage() {
    print("下一页");
    if (page.value == total - 1) {
      Fluttertoast.showToast(msg: "已经是最后一页了");
      return;
    }
    if (page.value < total - 1) {
      page.value = page.value + 1;
    }
    // print("testData_end==$page , $pageCount , $total");
  }

  void previousPage() {
    print("上一页");
    if (page.value == 0) {
      Fluttertoast.showToast(msg: "已经是第一页了");
      return;
    }
    page.value = page.value - 1;

    // print("testData_end==$page , $pageCount , $total");
  }

  void updateProperty(String? newValue) {
    if (newValue == null) {
      return;
    }
    selectedValue = newValue;
    selectedIndex.value = items[newValue] ?? DataProprety.time;
  }

  void convertModel() {
    // if (streamController.isClosed) {
    //   streamController = StreamController();
    // }
    // print("convertModel ==$analysisContent");
    List<String> lines = analysisContent.split('\n');
    List<DeviceDataModel> list = [];
    for (var line in lines) {
      if (line.contains("$seperateString:")) {
        final dataString = line.split("$seperateString:").last;
        // printInfo(info: dataString);
        DeviceDataModel? model = BlueDataManager.convertData(dataString,
            _getProtocolFromCharacteristic(seperateString), seperateString);
        String time = line.split("[Info]").first;
        DateFormat dateFormat = DateFormat("yyyy.MM.dd-HH.mm.ss");
        model?.timestamp =
            dateFormat.parse(time).millisecondsSinceEpoch ~/ 1000;
        if (model != null) {
          list.add(model);
        }
      }
    }
    if (list.isEmpty) {
      return;
    }

    page.value = 0;
    print("convertModel_end:${list.length}");
    updateChartUI(list);
  }

  void updateSeperateString(String? seperate) {
    if (seperate != null && seperate != seperateString) {
      seperateString = seperate;
      convertModel();
    }
  }

  List<String> chs() {
    return [
      "FFF1",
      "2ACE", //椭圆机
      "2AD2", //单车
      "2AD1", //划船机
      "2ACD", //跑步机
      "59554C55-0001-6666-8888-4D4552414348", //mrk
      // "2A37", //电量
      // "2A19", //心率
    ];
  }

  void updateChartUI(List<DeviceDataModel> list) {
    total = (list.length / pageCount).ceil();
    for (var model in list) {
      streamController.sink.add(model.toString());
    }
    models.value = list;
  }

  void streamParseData() async {
    analysisContent = await rootBundle.loadString('assets/test.txt');
    convertModel();
  }

  int _getProtocolFromCharacteristic(String? characteristic) {
    if (characteristic == null) {
      return BlueDataProtocol.ZJProtocol;
    }
    if (['2ACE', '2AD2', '2AD1'].any(characteristic.contains)) {
      return BlueDataProtocol.FTMSProtocol;
    }

    if (['FFF1'].any(characteristic.contains)) {
      return BlueDataProtocol.ZJProtocol;
    }
    if (['2A37', '2A19'].any(characteristic.contains)) {
      return BlueDataProtocol.HeartRateProtocol;
    }

    if (['2A37', '2A19'].any(characteristic.contains)) {
      return BlueDataProtocol.HeartRateProtocol;
    }

    if (['59554C55-8000-6666-8888-4D4552414348'].any(characteristic.contains)) {
      return BlueDataProtocol.MRKProtocol;
    }

    return BlueDataProtocol.MRKProtocol;
  }

  @override
  void onClose() {
    streamController.close();
    super.onClose();
  }
}
