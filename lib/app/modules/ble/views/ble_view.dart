import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:get/get.dart';

import '../controllers/ble_controller.dart';

class BleView extends GetView<BleController> {
  const BleView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BleManagerView'),
        centerTitle: true,
        leading: IconButton(
            onPressed: controller.back, icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                  labelText: "请输入搜索名称",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder()),
              onChanged: (value) {
                print("筛选名称: $value");
                controller.filterDevice(value);
              },
            ),
            Expanded(
              child: Obx(() => ListView(
                    shrinkWrap: true,
                    children: controller.devices.map((element) {
                      ScanResult r = controller.deviceResults[element]!;
                      int signalCount = 4;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    // const Icon(
                                    //   Icons.signal_cellular_alt_rounded,
                                    //   color: Colors.black38,
                                    // ),
                                    // 使用示例：
                                    BluetoothSignalIndicator(
                                      strength: (r.rssi.abs() ~/
                                          (100 ~/ signalCount)),
                                      signalCount: signalCount,
                                      // activeColor: Colors.green, // 自定义激活颜色
                                      barWidth: 3, // 加宽信号条
                                      barHeights: const [
                                        8,
                                        12,
                                        16,
                                        20
                                      ], // 修改高度配置
                                    ),

                                    Text(
                                      "${r.rssi}",
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                      element,
                                      overflow: TextOverflow.ellipsis,
                                    )),
                                ElevatedButton(
                                  child: const Text("connect"),
                                  onPressed: () =>
                                      controller.connectDevice(element),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            height: 1,
                            color: Color(0XFFf9f9f9),
                          )
                        ],
                      );
                    }).toList(),
                  )),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: controller.startSearch,
            child: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}

// 核心组件优化
class BluetoothSignalIndicator extends StatelessWidget {
  final int signalCount; // 4
  final int strength; // 0-4
  final Color activeColor;
  final Color inactiveColor;
  final double barWidth;
  final List<double> barHeights;
  final Duration animationDuration;

  const BluetoothSignalIndicator({
    super.key,
    required this.strength,
    this.signalCount = 4,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.barWidth = 10,
    this.barHeights = const [8, 14, 20, 26],
    this.animationDuration = const Duration(milliseconds: 300),
  });

  Widget _buildAnimatedBar(int index, bool isActive) {
    if (barHeights.length != signalCount) {
      assert(false, 'barHeights must have the same length as signalCount');
    }
    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeInOut,
      width: barWidth,
      height: barHeights[index],
      margin: EdgeInsets.only(right: barWidth * 0.8),
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(barWidth * 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final level = strength.clamp(0, barHeights.length);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(barHeights.length, (index) {
        return _buildAnimatedBar(index, level > index);
      }),
    );
  }
}
