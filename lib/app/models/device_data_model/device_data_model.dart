import 'package:json_annotation/json_annotation.dart';
import '../../common/extesion.dart';

part 'device_data_model.g.dart';

@JsonSerializable()
class DeviceDataModel {
  num? spm;
  num? avgSpm;
  num? avgSpeed;
  num? speed;
  num? time;
  num? distance;
  num? enery;
  num? avgPower;
  num? power;
  num? drag;
  num? slope;
  num? count;
  num? rate;
  num? state;
  num? electric;
  int? timestamp;

  DeviceDataModel({
    this.spm,
    this.avgSpm,
    this.avgSpeed,
    this.speed,
    this.time,
    this.distance,
    this.enery,
    this.avgPower,
    this.power,
    this.drag,
    this.slope,
    this.count,
    this.rate,
    this.state,
    this.electric,
    this.timestamp,
  });

  // 动态格式化时间戳
  String formatTimestamp(String pattern) {
    int times = (timestamp ?? 0) * 1000;
    return times.toDateString(pattern);
  }

  @override
  String toString() {
    return '(timestamp:${formatTimestamp('yyyy.MM.dd HH:mm:ss')} ,spm: $spm, avgSpm: $avgSpm, avgSpeed: $avgSpeed, speed: $speed, time: $time, distance: $distance, enery: $enery, avgPower: $avgPower, power: $power, drag: $drag, slope: $slope, count: $count, rate: $rate , state:$state , electric:$electric)';
  }

  factory DeviceDataModel.fromJson(Map<String, dynamic> json) {
    return _$DeviceDataModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DeviceDataModelToJson(this);
}
