import 'package:flutter/material.dart';
import 'package:production_tool_app/app/models/device_data_model/device_data_model.dart';
import 'package:production_tool_app/app/modules/device_detial/controllers/device_detial_controller.dart';

class ModelWidget extends StatefulWidget {
  const ModelWidget({
    super.key,
    required this.model,
    required this.controller,
  });

  final DeviceDataModel model;
  final DeviceDetialController controller;

  @override
  State<ModelWidget> createState() => _ModelWidgetState();
}

class _ModelWidgetState extends State<ModelWidget> {
  @override
  Widget build(BuildContext context) {
    final list = ["MRK", "FTMS", "ZJ", "BQ"];
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Container(
              color: const Color(0x00ff0000),
            ),
            SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("distance: ${widget.model.distance}"),
                  Text("time: ${widget.model.time}"),
                  Text("count: ${widget.model.count}"),
                  Text("enery: ${widget.model.enery}"),
                  Text("spm: ${widget.model.spm}"),
                  Text("speed: ${widget.model.speed}"),
                  Text("power: ${widget.model.power}"),
                  Text("rate: ${widget.model.rate}"),
                  _buildControlWidget(widget.model, 0, des: "阻力"),
                  _buildControlWidget(widget.model, 1, des: "速度"),
                  _buildControlWidget(widget.model, 2, des: "坡度"),
                  Row(
                    children: [
                      for (int i = 0; i < list.length; i++)
                        Expanded(
                          child: RadioMenuButton(
                            value: i + 1,
                            groupValue: widget.controller.protocol.value,
                            onChanged: (selectValue) {
                              // print("index=$selectValue");
                              widget.controller.protocol.value =
                                  selectValue ?? 0;
                              setState(() {});
                            },
                            child: Text(
                              list[i],
                              style: const TextStyle(fontSize: 11.0),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildControlWidget(DeviceDataModel model, int index,
      {String des = "描述"}) {
    final num = (index == 0
            ? model.drag
            : index == 1
                ? model.speed
                : model.slope) ??
        0;
    final unit = index == 0
        ? 1
        : index == 1
            ? 0.1
            : 1;
    final unitDes = "单位：$unit";
    return Row(
      children: [
        const SizedBox(
          width: 0.0,
        ),
        Text(des),
        IconButton(
          onPressed: () {
            var temp = num - unit;
            Map<dynamic, dynamic> para = _buildCtlPara(index, temp, model);
            widget.controller.sendCtlCommand(para);
          },
          icon: const Icon(
            Icons.remove_circle,
            size: 30,
            color: Colors.blue,
          ),
        ),
        TextButton(
          child: Text(" $num"),
          onPressed: () {
            _alertCtlDialog(
              context,
              num,
              confirm: (value) {
                Map<dynamic, dynamic> para =
                    _buildCtlPara(index, int.parse(value), model);
                widget.controller.sendCtlCommand(para);
              },
            );
          },
        ),
        IconButton(
          onPressed: () {
            var temp = num + unit;
            Map<dynamic, dynamic> para = _buildCtlPara(index, temp, model);
            widget.controller.sendCtlCommand(para);
          },
          icon: const Icon(
            Icons.add_circle,
            size: 30,
            color: Colors.blue,
          ),
        ),
        Text(unitDes),
      ],
    );
  }

  Map<dynamic, dynamic> _buildCtlPara(
      int index, num temp, DeviceDataModel model) {
    var para = {};
    switch (index) {
      case 0:
        {
          //阻力
          temp = temp < 1 ? 1 : temp;
          para["drag"] = "$temp";
          if (model.slope != null) {
            para["slope"] = "${model.slope}";
          }
        }

        break;
      case 1:
        {
          //速度
          temp = temp < 0 ? 1 : temp;
          para["speed"] = "$temp";
          if (model.slope != null) {
            para["slope"] = "${model.slope}";
          }
        }
        break;
      case 2:
        {
          //坡度
          temp = temp;
          para["slope"] = "$temp";
          if (model.drag != null) {
            para["drag"] = "${model.drag}";
          }
          if (model.speed != null) {
            para["speed"] = "${model.speed}";
          }
        }
        break;
      default:
    }
    return para;
  }

  Future<dynamic> _alertCtlDialog(BuildContext context, num text,
      {Function(String value)? confirm}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController dataController =
              TextEditingController(text: "$text");
          // TextEditingController nameController = TextEditingController();
          return AlertDialog(
            title: const Text("输入控制参数"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: dataController,
                  decoration: const InputDecoration(
                    labelText: "参数",
                  ),
                ),
                // TextField(
                //   controller: nameController,
                //   decoration: const InputDecoration(
                //     labelText: "速度",
                //   ),
                // ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (confirm != null) {
                      confirm(dataController.text);
                    }
                  },
                  child: const Text("control")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("cancel")),
            ],
          );
        });
  }
}
