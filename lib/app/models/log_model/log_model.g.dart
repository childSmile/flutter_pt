// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogModel _$LogModelFromJson(Map<String, dynamic> json) => LogModel(
      char: json['char'] as BluetoothCharacteristic,
      value: json['value'] as List<int>?,
      time: json['time'] as String?,
      showValue: json['showValue'] as String?,
    );

Map<String, dynamic> _$LogModelToJson(LogModel instance) => <String, dynamic>{
      'char': instance.char,
      'value': instance.value,
      'time': instance.time,
      'showValue': instance.showValue,
    };
