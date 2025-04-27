import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileHelper {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.txt');
  }

  static Future<void> writeData(String data) async {
    debugPrint("write==$data");
    final path = await _localPath;
    final file = File('$path/data.txt');
    debugPrint("path==$path");
    // _localFile;
    final IOSink sink = file.openWrite(mode: FileMode.writeOnlyAppend);
    try {
      final res = await readData();
      if (res != null && !res.contains(data)) {
        sink.write(data);
        debugPrint("写入完成");
      }
    } finally {
      await sink.flush();
      await sink.close();
    }
  }

  static Future<String?> readData() async {
    try {
      final file = await _localFile;
      String content = await file.readAsString();
      return content;
    } catch (e) {
      return null;
    }
  }

  // 核心处理函数
  static Future<void> deleteFileContent(String targetContent) async {
    try {
      final file = await _localFile;
      // 读取文件内容
      String content = await file.readAsString();

      // 删除目标内容（支持正则表达式）
      String modifiedContent = content.replaceAll(RegExp(targetContent), '');

      // 写回文件（覆盖模式）
      await file.writeAsString(modifiedContent, mode: FileMode.write);

      print(
          '✅ 内容删除成功 | 原始大小：${content.length} → 新大小：${modifiedContent.length}');
    } on FileSystemException catch (e) {
      print('❌ 文件操作异常：${e.message}');
    }
  }

  static Future<void> deleteCacheFiles() async {
    // 获取缓存目录
    final cacheDir = await getApplicationDocumentsDirectory();

    if (cacheDir.existsSync()) {
      // 列出缓存目录中的所有文件和子目录
      final entities = cacheDir.listSync();

      for (final entity in entities) {
        try {
          if (entity is File) {
            // 如果是文件，则删除文件
            await entity.delete();
            print('已删除文件: ${entity.path}');
          } else if (entity is Directory) {
            // 如果是目录，则递归删除目录及其内容
            await entity.delete(recursive: true);
            print('已删除目录: ${entity.path}');
          }
        } catch (e) {
          print('删除失败: ${entity.path}, 错误: $e');
        }
      }

      print('所有缓存文件和目录已成功删除');
    } else {
      print('缓存目录不存在');
    }
  }

  static Future<void> writeDataToFile(dynamic data, String filePath) async {
    debugPrint("write==$data");
    final path = await _localPath;
    final file = File('$path/$filePath');
    await file.writeAsBytes(data);
    // final IOSink sink = file.openWrite(mode: FileMode.writeOnlyAppend);
    // try {
    //   final res = await readData();
    //   if (res != null && !res.contains(data)) {
    //     sink.write("$data");
    //     debugPrint("写入完成");
    //   }
    // } finally {
    //   await sink.flush();
    //   await sink.close();
    // }
  }
}
