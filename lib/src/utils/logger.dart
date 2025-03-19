import "package:logging/logging.dart";

/// Global flag enabling hierarchical logging configuration
///
/// When true, allows parent-child relationships between loggers
/// for granular control of logging behavior
const bool hierarchicalLoggingEnabled = true;

/// Creates and configures a Logger instance with standardized formatting
///
/// - [name]: Identifier for the logger (typically the class name)
/// - Returns: Preconfigured [Logger] instance with:
///   - All log levels enabled
///   - ISO8601 timestamp formatting
///   - Colored level indicators
Logger returnLogger(String name) {
  final logger = Logger(name);

  Logger.root.level = Level.ALL;
  final formatter = _LogFormatter();

  Logger.root.onRecord.listen((record) {
    final message = formatter.format(record);
    print("$name: $message");
  });

  return logger;
}

class _LogFormatter {
  String format(LogRecord record) {
    // 时间格式化为 ISO8601（包含毫秒）
    final time = record.time.toUtc().toIso8601String();
    final level = record.level.name.padRight(7);
    return "$time: $level ${record.message}";
  }
}
