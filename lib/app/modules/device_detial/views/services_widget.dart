import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:production_tool_app/app/common/blue_char_extension.dart';
import '../controllers/device_detial_controller.dart';

class ServiceWidget extends StatefulWidget {
  const ServiceWidget({
    super.key,
    required this.controller,
  });

  final DeviceDetialController controller;

  @override
  State<ServiceWidget> createState() => _ServiceWidgetState();
}

class _ServiceWidgetState extends State<ServiceWidget> {
  String writeUUID = "";
  List notifyList = [];
  @override
  Widget build(BuildContext context) {
    writeUUID = widget.controller.writeCharRemoteId;
    notifyList = widget.controller.notifyList;
    // print("write===${widget.controller.writeCharRemoteId}");
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Obx(() => ListView.builder(
              itemCount: widget.controller.serviceList
                  .length, //controller.serviceCharacteristic.keys.length,
              itemBuilder: (context, index) {
                final service = widget.controller.serviceList[index];
                // print("model:${controller.serviceList.length}");
                return ExpansionTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const Text(
                      //   'Service',
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //     color: Colors.lightBlue,
                      //   ),
                      // ),
                      Text(
                        service.serviceShowName,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "UUID:${service.uuidUpperStr}",
                        style: const TextStyle(
                          fontSize: 14,
                          // color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    for (var i = 0; i < service.characteristics.length; i++)
                      // Text("index$index"),
                      _buildCharacteristicWidget(
                          service.characteristics[i], context),
                  ],
                );
              })),
        ),
        Row(
          children: [
            const Spacer(),
            FloatingActionButton(
              onPressed: widget.controller.getService,
              child: const Text("Service"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCharacteristicWidget(
      BluetoothCharacteristic char, BuildContext context) {
    String uuid = char.uuidUpperStr;
    printError(
        info: "write= ${widget.controller.readValueCharacteristicMap[char]}");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  char.charShowName,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  "UUID:$uuid",
                  maxLines: 5,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Obx(() => Text(
                      "Value:${widget.controller.readValueCharacteristicMap[char]}",
                      // maxLines: 1,
                      // overflow: TextOverflow.clip,
                    )),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildCharacteristicRowWidget(char),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristicRowWidget(BluetoothCharacteristic char) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Visibility(
          visible: char.isNotify,
          child: InkWell(
            onTap: () {
              widget.controller.nofity(char);
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.vertical_align_bottom,
                color: notifyList.contains(char)
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0XFF666666),
              ),
            ),
            // child: Text(
            //   "Notify",
            //   style: TextStyle(
            //     color: notifyList.contains(char)
            //         ? Theme.of(context).colorScheme.primary
            //         : const Color(0XFF666666),
            //   ),
            // ),
          ),
        ),
        const SizedBox(
          width: 6,
        ),
        Visibility(
          visible: char.isWrite,
          child: InkWell(
            onTap: () {
              widget.controller.setWriteChar(char);
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.vertical_align_top,
                color: char.uuid.str == writeUUID
                    ? Theme.of(context).colorScheme.primary
                    : const Color(0XFF666666),
              ),
            ),
            // child: Text(
            //   "Write",
            //   style: TextStyle(
            //     color: char.uuid.str == writeUUID
            //         ? Theme.of(context).colorScheme.primary
            //         : const Color(0XFF666666),
            //   ),
            // ),
          ),
        ),
        const SizedBox(
          width: 6,
        ),
        Visibility(
          visible: char.isRead,
          child: InkWell(
            onTap: () {
              widget.controller.read(char);
              Future.delayed(const Duration(milliseconds: 500), () {
                setState(() {});
              });
            },
            child: const Text("Read"),
          ),
        ),
      ],
    );
  }
}
