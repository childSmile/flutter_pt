// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceDataModel _$DeviceDataModelFromJson(Map<String, dynamic> json) =>
    DeviceDataModel(
      spm: json['spm'] as num?,
      avgSpm: json['avgSpm'] as num?,
      avgSpeed: json['avgSpeed'] as num?,
      speed: json['speed'] as num?,
      time: json['time'] as num?,
      distance: json['distance'] as num?,
      enery: json['enery'] as num?,
      avgPower: json['avgPower'] as num?,
      power: json['power'] as num?,
      drag: json['drag'] as num?,
      slope: json['slope'] as num?,
      count: json['count'] as num?,
      rate: json['rate'] as num?,
      state: json['state'] as num?,
      electric: json['electric'] as num?,
      timestamp: json['timestamp'] as int?,
    );

Map<String, dynamic> _$DeviceDataModelToJson(DeviceDataModel instance) =>
    <String, dynamic>{
      'spm': instance.spm,
      'avgSpm': instance.avgSpm,
      'avgSpeed': instance.avgSpeed,
      'speed': instance.speed,
      'time': instance.time,
      'distance': instance.distance,
      'enery': instance.enery,
      'avgPower': instance.avgPower,
      'power': instance.power,
      'drag': instance.drag,
      'slope': instance.slope,
      'count': instance.count,
      'rate': instance.rate,
      'state': instance.state,
      'electric': instance.electric,
      'timestamp': instance.timestamp,
    };
