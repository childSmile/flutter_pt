import 'dart:typed_data';
import 'package:intl/intl.dart';

extension IntExt on int {
  // int -> uint8List
  Uint8List toBytes(int byteCount, Endian endian) {
    final list = Uint8List(byteCount);
    final buffer = list.buffer.asByteData();
    switch (byteCount) {
      case 1:
        buffer.setUint8(0, this);
      case 2:
        buffer.setUint16(0, this, endian);
        break;
      case 4:
        buffer.setUint32(0, this, endian);
        break;
      // 其他字节长度处理
    }
    return list;
  }

  String toDateString(String format) {
    // int -> dateString
    final dateTime = DateTime.fromMillisecondsSinceEpoch((this));
    return DateFormat(format).format(dateTime);
  }
}

extension Uint8ListExt on Uint8List {
  Uint8List safeSublist(int start, [int? end]) {
    // 检查输入参数是否合法
    if (start < 0 || start > length) {
      throw RangeError.value(start, "start", "Start index out of bounds");
    }

    // 如果 end 为空，则默认取到列表末尾
    end ??= length;

    // 确保 end 不会超出列表长度，并且不小于 start
    if (end > length) {
      end = length;
    }
    if (end < start) {
      throw RangeError.value(end, "end", "End index is less than start index");
    }
    if (end < 0 || end > length) {
      throw RangeError.value(end, "end", "End index out of bounds");
    }
    return sublist(start, end);
  }

  int crc16() {
    const int polynomial = 0xA001;
    int crc = 0xFFFF; // Initial CRC value

    for (var byte in this) {
      for (int i = 0; i < 8; i++) {
        bool bit = (crc ^ byte) & 0x01 != 0;
        crc = (crc >> 1) ^ (bit ? polynomial : 0);
        byte = byte >> 1;
      }
    }

    // Mask to ensure it's a 16-bit value
    return crc & 0xFFFF;
  }

  int xor() {
    var res = 0;
    for (var element in this) {
      res = res ^ element;
    }
    return res;
  }

  int sum() {
    // 计算 Uint8List 的累加和
    int checksum = 0;
    for (int byte in this) {
      checksum += byte; // 对每个字节进行累加
    }
    return checksum & 0xff;
  }

  String desString() {
    //  uint8List -> string
    return toList()
        .map((e) => e.toRadixString(16).padLeft(2, '0').toString())
        .join("")
        .toUpperCase();
  }
}

extension ListExt on List {
  String desString() {
    //  List<int> -> string
    return toList()
        .map((e) => e.toRadixString(16).padLeft(2, '0').toString())
        .join("-")
        .toUpperCase();
  }

  Uint8List toUint8List() {
    // List<int> -> Uint8List
    return Uint8List.fromList(cast<int>());
  }
}
