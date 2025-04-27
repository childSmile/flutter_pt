import 'package:logger/logger.dart';

class LogUtil {
  // 单例模式：确保只有一个 Logger 实例
  static final LogUtil _instance = LogUtil._internal();
  factory LogUtil() => _instance;

  late Logger _logger;

  LogUtil._internal() {
    // 初始化 Logger，使用 PrettyPrinter 格式化输出
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2, // 显示堆栈跟踪的方法数
        errorMethodCount: 5, // 错误堆栈跟踪的方法数
        lineLength: 120, // 每行日志的最大长度
        colors: true, // 启用颜色输出
        printEmojis: true, // 启用表情符号
        printTime: true, // 显示时间戳
      ),
    );
  }

  // 调试日志 (Debug)
  void d(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  // 信息日志 (Info)
  void i(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  // 警告日志 (Warning)
  void w(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  // 错误日志 (Error)
  void e(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // 严重错误日志
  void wtf(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
