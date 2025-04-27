import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/device_detial_controller.dart';

class LogWidget extends StatelessWidget {
  const LogWidget({
    super.key,
    required this.controller,
  });

  final DeviceDetialController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Obx(
            () => ListView.builder(
              controller: controller.scrollController,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: controller.logList.length,
              itemBuilder: (context, index) {
                final model = controller.logList[index];
                // printError(info: "show:${model.showValue}");
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Text(
                            model.time ?? "",
                            style: const TextStyle(
                                color: Color(0xffff0000),
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              model.char.uuid.str,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Color(0xff000000),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      model.value!
                          .map((element) => element
                              .toRadixString(16)
                              .toUpperCase()
                              .padLeft(2, '0'))
                          .toList()
                          .join('-'),
                      style: const TextStyle(color: Color(0xff0000ff)),
                    ),
                    Text(
                      model.showValue ?? "",
                      style: const TextStyle(color: Color(0xffee33ee)),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Column(
          children: [
            Row(
              children: [
                const Spacer(),
                FloatingActionButton(
                  heroTag: "tag1",
                  onPressed: () {
                    controller.autoScroll.value = !controller.autoScroll.value;
                  },
                  child: Obx(() =>
                      Text(controller.autoScroll.value ? "manual" : "auto")),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Spacer(),
                FloatingActionButton(
                  heroTag: "tag2",
                  onPressed: controller.toDataAnalysis,
                  child: const Text("chart"),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
