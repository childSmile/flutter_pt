import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/pressure_controller.dart';

class PressureView extends GetView<PressureController> {
  const PressureView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('压力测试页面'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            _buildRowItem("连接保持时长(ms)", "请输入连接保持时长", (value) {
              controller.connectTime.value = int.tryParse(value) ?? 0;
            }),
            const SizedBox(
              height: 10,
            ),
            _buildRowItem("断开保持时长(ms)", "请输入断开保持时长", (value) {
              controller.disconnectTime.value = int.tryParse(value) ?? 0;
            }),
            const SizedBox(
              height: 10,
            ),
            _buildRowItem("循环次数", "请输入循环次数", (value) {
              controller.count.value = int.tryParse(value) ?? 0;
            }),
            TextButton(
              onPressed: controller.startPressure,
              child: const Text("开始测试"),
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.textList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(controller.textList[index]),
                      // subtitle: Text("距离: 100m, 时间: 10s"),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRowItem(String title, String input, Function(String) onTap) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(
          width: 5,
        ),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              labelText: input,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => {
              // controller.connectTime.value = int.tryParse(value) ?? 0,
              onTap(value),
            },
          ),
        ),
      ],
    );
  }
}
