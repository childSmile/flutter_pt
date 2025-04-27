import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:production_tool_app/app/models/device_data_model/device_data_model.dart';

class ChartWidget extends StatefulWidget {
  List<FlSpot> spots = [];
  Map<String, Map<String, dynamic>> spotModels = {};
  List<DeviceDataModel> models = [];
  int index = 0;

  ChartWidget({
    required this.spotModels,
    required this.spots,
    super.key,
  });

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
      width: widget.spots.length * 5,
      child: _buildLineWidget(),
    );
    // _buildBarWidget(),
  }

  Widget _buildLineWidget() {
    double maxY = widget.spots.map((s) => s.y).toList().reduce(max) * 3;
    double maxX = widget.spots.map((s) => s.x).toList().reduce(max);
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: maxY,
        clipData: const FlClipData(
            top: false, bottom: true, left: false, right: false),
        titlesData: const FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
            ),
            // axisNameSize: 20,
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
            // axisNameSize: 40,
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          // border: Border.all(color: Colors.redAccent),
        ),
        lineBarsData: _linesBarData(),
        lineTouchData: _lineTouchData(),
        //网格
        // gridData: FlGridData(
        //   show: true,
        //   drawHorizontalLine: true,
        //   drawVerticalLine: true,
        //   getDrawingHorizontalLine: (value) {
        //     return const FlLine(
        //       color: Colors.black26,
        //       strokeWidth: 1,
        //     );
        //   },
        //   getDrawingVerticalLine: (value) {
        //     return const FlLine(
        //       color: Colors.black12,
        //       strokeWidth: 1,
        //     );
        //   },
        // ),
      ),
    );
  }

  LineTouchData _lineTouchData() {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((touchedSpot) {
            final flSpot = touchedSpot;
            final spot = FlSpot(flSpot.x, flSpot.y);
            final model = _modelFromSpotString(spot.toString());
            return LineTooltipItem(
              "x:${flSpot.x},y:${model.toString()}",
              const TextStyle(color: Colors.white, fontSize: 10.0),
            );
          }).toList();
        },
      ),
    );
  }

  List<LineChartBarData> _linesBarData() {
    final LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: widget.spots,
      isCurved: true,
      barWidth: 5,
      isStrokeCapRound: true,
      dotData: const FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: true,
        // color: Colors.yellow,
        gradient: const LinearGradient(
          colors: [Colors.red, Colors.green],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        //colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
      ),
    );
    return [lineChartBarData1];
  }

  Widget _buildBarWidget() {
    return BarChart(
      BarChartData(
        alignment:
            //柱状图的对齐方式
            BarChartAlignment.spaceAround,
        maxY: 12, //Y轴的最大值
        //点击可出现提示框
        barTouchData: BarTouchData(
          enabled: true,
          //修改提示框的样式和展示文字
          touchTooltipData: BarTouchTooltipData(
            tooltipBorder: const BorderSide(color: Colors.red, width: 1.0),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(15),
            tooltipMargin: 2,
            // maxContentWidth: 100,
            direction: TooltipDirection.top,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String myData = "第${group.x.toInt()}条数据";
              //当前y轴的数值
              return BarTooltipItem("$myData  ${rod.toY.toInt()}",
                  const TextStyle(color: Colors.amber));
            },
          ),
        ),
        titlesData: FlTitlesData(
          //纵轴
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 3,
              getTitlesWidget: (value, meta) {
                return Text(
                  "$value ",
                  style: const TextStyle(color: Colors.blue),
                );
              },
            ),
          ),
          //横轴
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  "$value ",
                  style: const TextStyle(color: Colors.green),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
        ),
        //是否展示边框
        borderData: FlBorderData(
          show: true,
          border: Border.all(
              color: Colors.black54, width: 1, style: BorderStyle.solid),
        ),
        //调整组与组之间的间隔
        groupsSpace: 12,
        //条形图的数据
        barGroups: [
          for (var i = 0; i < 10; i++)
            BarChartGroupData(
              x: (i + 1),
              barRods: [
                // 一个数据
                BarChartRodData(
                    toY: Random().nextDouble() + Random().nextInt(10),
                    color: Colors.yellow,
                    width: 10),
              ],
            ),
        ],
      ),
    );
  }

  DeviceDataModel _modelFromSpotString(String spotString) {
    Map<String, dynamic>? map = widget.spotModels[spotString];
    return map?["model"];
  }
}
