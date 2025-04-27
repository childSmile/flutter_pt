import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:production_tool_app/app/models/device_data_model/device_data_model.dart';

import 'package:production_tool_app/app/modules/data_analysis/views/dropdown_menu_widget.dart';
import 'package:production_tool_app/app/modules/device_detial/views/chart_widget.dart';

import '../controllers/data_analysis_controller.dart';

class DataAnalysisView extends GetView<DataAnalysisController> {
  const DataAnalysisView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = controller.items.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('DataAnalysisView'),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xfff6f6f6),
        child: Column(
          children: [
            DropdownMenuWidget(
              titleList: controller.items.keys.toList(),
              defaultMenuItem: items.first,
              onValueChanged: (value) {
                controller.updateProperty(value);
              },
            ),
            DropdownMenuWidget(
              titleList: controller.seperateList,
              defaultMenuItem: controller.seperateList.first,
              onValueChanged: (value) {
                controller.updateSeperateString(value);
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.first_page),
                    onPressed: controller.previousPage,
                    // child: const Text("上一页"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Obx(() => Text(
                        "当前数据是第${controller.page.value + 1}页，共${(controller.models.length / controller.pageCount).ceil()}页",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xff000000),
                        ),
                      )),
                  IconButton(
                    onPressed: controller.nextPage,
                    icon: const Icon(Icons.last_page),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 400,
              child: StreamBuilder(
                stream: controller.streamController.stream,
                builder: (context, snapshot) {
                  print("StreamBuilder ==${snapshot.connectionState}");
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Error : ${snapshot.error}"),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("no data"),
                    );
                  } else {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: double.infinity,
                          // minWidth: MediaQuery.of(context).size.width * 3,
                          // MediaQuery.of(context).size.width * 1,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Obx(() => ChartWidget(
                              spotModels: _buildSpotMap(
                                    page: controller.page.value,
                                    index: controller.selectedIndex.value,
                                  ) ??
                                  {},
                              spots: _buildSpot(
                                page: controller.page.value,
                                index: controller.selectedIndex.value,
                              ))),
                        ),
                      ), // _showDataWidget(), //(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.uploadFile,
        child: const Text("upload"),
      ),
    );
  }

  Widget _showDataWidget() {
    return ListView.builder(
      itemCount: controller.models.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(
                "data${index + 1}:${controller.models[index].toString()}"));
      },
    );
  }

  Map<String, Map<String, dynamic>>? _buildSpotMap(
      {int page = 0, index = DataProprety.time}) {
    List<FlSpot> list = [];
    Map<String, Map<String, dynamic>> dataSource = {};
    // print("models==${controller.models.length} == $page");
    var count = controller.pageCount;
    if (page == controller.total - 1) {
      count = min((controller.models.length % controller.pageCount),
          controller.pageCount);
    }

    final origin = (page * count);
    List<DeviceDataModel> originList =
        controller.models.sublist(origin, count + origin);
    // print(
    //     "models==${controller.models.length} == $page ===${controller.pageCount}==${originList.length} ");
    for (var i = 0; i < originList.length; i++) {
      DeviceDataModel model = originList[i];
      // DataProprety index = controller.selectedIndex;
      // DataProprety.enery;
      // controller.selectedIndex.value;
      double x =
          i.toDouble(); //(i + (page - 1) * controller.pageCount).toDouble();
      switch (index) {
        case DataProprety.distance:
          //距离
          if (model.distance != null) {
            list.add(FlSpot(x, model.distance!.toDouble()));
            dataSource[list.last.toString()] = {
              "spot": list.last,
              "model": model,
            };
          }
          break;
        case DataProprety.time:
          if (model.time != null) {
            list.add(FlSpot(x, model.time!.toDouble()));
            dataSource[list.last.toString()] = {
              "spot": list.last,
              "model": model,
            };
          }
          break;
        case DataProprety.enery:
          if (model.enery != null) {
            list.add(FlSpot(x, model.enery!.toDouble()));
            dataSource[list.last.toString()] = {
              "spot": list.last,
              "model": model,
            };
          }
          break;
        case DataProprety.spm:
          if (model.spm != null) {
            list.add(FlSpot(x, model.spm!.toDouble()));
            dataSource[list.last.toString()] = {
              "spot": list.last,
              "model": model,
            };
          } else if (model.speed != null) {
            list.add(FlSpot(x, model.speed!.toDouble()));
            dataSource[list.last.toString()] = {
              "spot": list.last,
              "model": model,
            };
          }
          break;
        case DataProprety.count:
          if (model.count != null) {
            list.add(FlSpot(x, model.count!.toDouble()));
            dataSource[list.last.toString()] = {
              "spot": list.last,
              "model": model,
            };
          }
          break;
        default:
      }
    }

    if (dataSource.isEmpty) {
      debugPrint("dataSource is empty");
      return null;
    }

    return dataSource;
  }

  List<FlSpot> _buildSpot({int page = 0, index = DataProprety.time}) {
    List<FlSpot> list = [];
    Map<String, DeviceDataModel> dataSource = {};
    // print("models==${controller.models.length} == $page");
    var count = controller.pageCount;
    if (page == controller.total - 1) {
      count = min((controller.models.length % controller.pageCount),
          controller.pageCount);
    }

    final origin = (page * count);
    List<DeviceDataModel> originList =
        controller.models.sublist(origin, count + origin);
    // print(
    //     "models==${controller.models.length} == $page ===${controller.pageCount}==${originList.length} ");
    for (var i = 0; i < originList.length; i++) {
      DeviceDataModel model = originList[i];
      // DataProprety index = controller.selectedIndex;
      // DataProprety.enery;
      // controller.selectedIndex.value;
      double x =
          i.toDouble(); //(i + (page - 1) * controller.pageCount).toDouble();
      switch (index) {
        case DataProprety.distance:
          //距离
          if (model.distance != null) {
            list.add(FlSpot(x, model.distance!.toDouble()));
            dataSource[list.last.toString()] = model;
          }
          break;
        case DataProprety.time:
          if (model.time != null) {
            list.add(FlSpot(x, model.time!.toDouble()));
            dataSource[list.last.toString()] = model;
          }
          break;
        case DataProprety.enery:
          if (model.enery != null) {
            list.add(FlSpot(x, model.enery!.toDouble()));
            dataSource[list.last.toString()] = model;
          }
          break;
        case DataProprety.spm:
          if (model.spm != null) {
            list.add(FlSpot(x, model.spm!.toDouble()));
            dataSource[list.last.toString()] = model;
          } else if (model.speed != null) {
            list.add(FlSpot(x, model.speed!.toDouble()));
            dataSource[list.last.toString()] = model;
          }
          break;
        case DataProprety.count:
          if (model.count != null) {
            list.add(FlSpot(x, model.count!.toDouble()));
            dataSource[list.last.toString()] = model;
          }
          break;
        default:
      }
    }

    print("list==${list.length}");
    return list;
  }
}
