import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:production_tool_app/app/models/device_data_model/device_data_model.dart';
import 'package:production_tool_app/app/modules/device_detial/views/choose_command_widget.dart';

import '../controllers/device_detial_controller.dart';
import '../views/log_widget.dart';
import '../views/model_widget.dart';
import '../views/services_widget.dart';
import '../../data_analysis/views/dropdown_menu_widget.dart';

class DeviceDetialView extends GetView<DeviceDetialController> {
  const DeviceDetialView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.deviceName),
        actions: [
          Obx(
            () => ElevatedButton(
              onPressed: controller.connectAction,
              child:
                  Text(controller.isConnect.value ? "disconnect" : "connect"),
            ),
          )
        ],
        centerTitle: true,
      ),
      body: Stack(
        children: [
          _buildBodyWidget(context),
          Obx(
            () => Visibility(
              visible: !controller.isConnect.value,
              child: Container(
                color: Color(0x55000000),
                width: context.width,
                height: context.height,
                child: const Center(
                  child: Text(
                    "disconnect",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyWidget(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 30.0, top: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      color: const Color(0xfff1f1f1),
                    ),
                    index == 0
                        ? _buildServiceWidget()
                        : index == 1
                            ? Obx(() =>
                                _buildDataWidget(controller.dataModel.value))
                            : _buildLogWidget(),
                  ],
                );
              },
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.textEditingController,
                  decoration: const InputDecoration(
                    labelText: "write data",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                onPressed: controller.write,
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () {
                  _alertSaveCtlDialog(context);
                },
                icon: Icon(
                  Icons.save,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: controller.importCommand,
                icon: Icon(
                  Icons.arrow_downward,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () {
                  controller.clearLoopSendData();
                  showDialog(
                      context: context,
                      builder: (context) {
                        return CustomSelectionDialog(
                          items: controller.commandList,
                          onConfirm: (p0, loop) {
                            controller.sendCommand(p0, loop);
                          },
                        );
                      });
                },
                icon: Icon(
                  Icons.loop,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              IconButton(
                onPressed: () {
                  _alertOTADialog(context);
                },
                icon: Icon(
                  Icons.upgrade_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            // color: Colors.red,
            height: 150,
            child: Obx(
              () => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 140,
                    // crossAxisCount: 5,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 8,
                    mainAxisExtent: 40,
                  ),
                  itemCount: controller.commandList.length,
                  itemBuilder: (item, index) {
                    String command = controller.commandList[index];
                    String cmdString = command.split(":").last;
                    String cmdNameString = command.split(":").first;

                    return LongPressDraggable(
                      feedback: Material(
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                      childWhenDragging: Container(
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      data: command.split(":").first,
                      onDragStarted: () => _showDeleteDialog(index, context),
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: TextButton(
                            onPressed: () {
                              controller.write(command: cmdString);
                            },
                            child: Text(
                              cmdNameString,
                              style: const TextStyle(color: Color(0xffffffff)),
                            )),
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  // 显示删除确认对话框
  void _showDeleteDialog(int index, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 ${controller.commandList[index]} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteCommand(controller.commandList[index]);
              // _deleteItem(index);
              Navigator.pop(context);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _alertOTADialog(BuildContext context) {
    controller.otaResult.value = 0;
    return showDialog(
        context: context,
        builder: (context) {
          return Obx(
            () => controller.otaResult.value == 1
                ? AlertDialog(
                    content: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("OTA成功了")))
                : controller.otaResult.value == 2
                    ? AlertDialog(
                        content: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("OTA失败了")))
                    : AlertDialog(
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("取消"),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigator.of(context).pop();
                              controller.startOTA();
                            },
                            child: const Text("确定"),
                          ),
                        ],
                        title: const Text("固件升级"),
                        content: _buildOTAWidget(context),
                      ),
          );
        });
  }

  Future<dynamic> _alertSaveCtlDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController dataController = TextEditingController(
              text: controller.textEditingController.text);
          TextEditingController nameController = TextEditingController();
          return AlertDialog(
            title: const Text("保存指令"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: dataController,
                  decoration: const InputDecoration(
                    labelText: "指令",
                  ),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "指令名称",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    controller.saveControlData(
                        data: dataController.text, name: nameController.text);
                  },
                  child: const Text("save")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("cancel")),
            ],
          );
        });
  }

  Widget _buildDataWidget(DeviceDataModel model) {
    return ModelWidget(model: model, controller: controller);
  }

  Widget _buildLogWidget() {
    return LogWidget(controller: controller);
  }

  Widget _buildServiceWidget() {
    return ServiceWidget(controller: controller);
  }

  Widget _buildOTAWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownMenuWidget(
          titleList: controller.titleList,
          onValueChanged: (value) {
            // print("value_changed==$value");
            controller.selectOTAMethod(value);
          },
        ),
        const SizedBox(
          height: 10,
        ),
        TextButton(
          onPressed: controller.uploadFile,
          child: const Text("上传固件"),
        ),
        const SizedBox(
          height: 10,
        ),
        TextButton(
          onPressed: controller.scanQRCode,
          child: const Text("扫描二维码"),
        ),
        const SizedBox(
          height: 10,
        ),
        Obx(() => Text("${controller.fileName}")),
        const SizedBox(
          height: 10,
        ),
        Obx(() => Text("${controller.otaProgress.value * 100}%")),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
          child: Obx(
            () => LinearProgressIndicator(
              value: controller.otaProgress.value,
              backgroundColor: const Color(0xfff6f6f6),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
