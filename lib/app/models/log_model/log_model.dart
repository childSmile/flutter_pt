import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:json_annotation/json_annotation.dart';

part 'log_model.g.dart';

@JsonSerializable()
class LogModel {
  BluetoothCharacteristic char;
  List<int>? value;
  String? time;
  String? showValue;

  LogModel({required this.char, this.value, this.time, this.showValue});

  @override
  String toString() =>
      'LogModel(char: $char, value: $value, time: $time , showValue:$showValue)';

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return _$LogModelFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LogModelToJson(this);
}
