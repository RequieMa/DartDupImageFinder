import 'package:logging/logging.dart';
const hierarchicalLoggingEnabled = true;

/// 创建并配置符合 Effective Dart 规范的 Logger 实例
///
/// [name] 用于标识日志来源（如模块名称），遵循大驼峰命名法（UpperCamelCase）
/// 返回已配置的 [Logger] 对象，包含统一的格式和处理器
Logger returnLogger(String name) {
  final logger = Logger(name);

  // 设置日志级别为 DEBUG（覆盖默认的 INFO）
  Logger.root.level = Level.ALL;

  final formatter = _LogFormatter();

  // 添加控制台处理器（输出到 stderr）
  Logger.root.onRecord.listen((record) {
    final message = formatter.format(record);
    print(message);
  });

  // 确保处理器仅添加一次（避免重复日志）
  // if (!Logger.root.onRecord.hasListener) {
  // }
  return logger;
}

class _LogFormatter {
  String format(LogRecord record) {
    // 时间格式化为 ISO8601（包含毫秒）
    final time = record.time.toUtc().toIso8601String();
    final level = record.level.name.padRight(7);
    return '$time: $level ${record.message}';
  }
}