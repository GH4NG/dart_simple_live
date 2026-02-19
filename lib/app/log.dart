import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:simple_live_app/app/utils.dart';

class LogFileModel {
  late String name;
  late String path;
  late DateTime time;
  late int size;
  LogFileModel(this.name, this.path, this.time, this.size);
}

class SimpleLiveLogPrinter extends PrettyPrinter {
  SimpleLiveLogPrinter()
    : super(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      );

  @override
  List<String> log(LogEvent event) {
    if (event.level.index <= Level.info.index) {
      final msg = stringifyMessage(event.message);
      final time = getTime(event.time);
      final prefix = _getPrefix(event.level);
      final levelName = _getLevelName(event.level);
      return ['$prefix $time $levelName $msg'];
    }
    return super.log(event);
  }

  String _getPrefix(Level level) {
    if (!colors) return _getLevelTag(level);

    const reset = '\x1B[0m';
    String colorCode;
    switch (level) {
      case Level.trace:
        colorCode = '\x1B[90m'; // Bright Black
        break;
      case Level.debug:
        colorCode = '\x1B[36m'; // Cyan
        break;
      case Level.info:
        colorCode = '\x1B[32m'; // Green
        break;
      case Level.warning:
        colorCode = '\x1B[33m'; // Yellow
        break;
      case Level.error:
        colorCode = '\x1B[31m'; // Red
        break;
      case Level.fatal:
        colorCode = '\x1B[35m'; // Magenta
        break;
      default:
        colorCode = '';
    }
    return '$colorCode${_getLevelTag(level)}$reset';
  }

  String _getLevelTag(Level level) {
    switch (level) {
      case Level.trace:
        return '[·]';
      case Level.debug:
        return '[*]';
      case Level.info:
        return '[i]';
      case Level.warning:
        return '[!]';
      case Level.error:
        return '[×]';
      case Level.fatal:
        return '[‼]';
      default:
        return '[-]';
    }
  }

  String _getLevelName(Level level) => level.name.toUpperCase().padRight(7);
}

class SimpleLiveLogOutput extends LogOutput {
  static final Lock _logLock = Lock();
  static String? _logFilePath;
  static const int _maxLogFiles = 7;
  static bool _logEnable = false;

  static void setLogEnabled(bool enabled) {
    _logEnable = enabled;
  }

  static Future<String> _getLogFilePath() async {
    if (_logFilePath != null) return _logFilePath!;

    final supportDir = await getApplicationSupportDirectory();
    final logDir = Directory("${supportDir.path}/logs");
    if (!logDir.existsSync()) {
      await logDir.create(recursive: true);
    }

    final dt = DateFormat("yyyy-MM-dd HH-mm-ss").format(DateTime.now());
    _logFilePath = p.join(logDir.path, "$dt.log");
    await _pruneOldLogs(logDir);
    await _writeSystemInfoToPath(_logFilePath!);
    return _logFilePath!;
  }

  static Future<void> _pruneOldLogs(Directory logDir) async {
    try {
      final files = logDir
          .listSync()
          .whereType<File>()
          .where((f) => p.extension(f.path).toLowerCase() == '.log')
          .toList();

      if (files.length <= _maxLogFiles) return;

      files.sort((a, b) {
        try {
          final am = a.lastModifiedSync();
          final bm = b.lastModifiedSync();
          return bm.compareTo(am);
        } catch (_) {
          return 0;
        }
      });

      for (var i = _maxLogFiles; i < files.length; i++) {
        try {
          files[i].deleteSync();
        } catch (e) {
          stdout.writeln(
            'Failed to delete old log file: ${files[i].path} -> $e',
          );
        }
      }
    } catch (e) {
      stdout.writeln('Failed to prune old logs: $e');
    }
  }

  static Future<void> _writeSystemInfoToPath(String path) async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      final file = File(path);
      final buffer = StringBuffer()
        ..writeln('System Info:')
        ..writeln('Platform: ${Platform.operatingSystem}')
        ..writeln('Version: ${Platform.operatingSystemVersion}')
        ..writeln(
          'App Version: ${Utils.packageInfo.version}+${Utils.packageInfo.buildNumber}',
        );
      final BaseDeviceInfo info =
          await ({
                'android': () => deviceInfo.androidInfo,
                'ios': () => deviceInfo.iosInfo,
                'windows': () => deviceInfo.windowsInfo,
                'linux': () => deviceInfo.linuxInfo,
                'macos': () => deviceInfo.macOsInfo,
              }[Platform.operatingSystem] ??
              () async => BaseDeviceInfo({}))();

      buffer.writeln('DeviceInfo: ${info.data}');
      await file.writeAsString(
        buffer.toString(),
        mode: FileMode.writeOnlyAppend,
      );
    } catch (e) {
      stdout.writeln('Failed to write system info to log: $e');
    }
  }

  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      stdout.writeln(line);
    }

    if (event.level.index >= Level.warning.index || _logEnable) {
      _writeToFile(event);
    }
  }

  void _writeToFile(OutputEvent event) {
    _logLock.synchronized(() async {
      try {
        final filePath = await _getLogFilePath();
        final file = File(filePath);

        final timestamp = DateTime.now().toString();

        final buffer = StringBuffer()..writeln('[$timestamp]');

        for (var line in event.lines) {
          final cleanLine = _removeAnsiCodes(line);
          buffer.writeln(cleanLine);
        }
        buffer.writeln();

        await file.writeAsString(
          buffer.toString(),
          mode: FileMode.writeOnlyAppend,
        );
      } catch (e) {
        stdout.writeln('Failed to write log to file: $e');
      }
    });
  }

  String _removeAnsiCodes(String text) {
    return text.replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '');
  }
}

class SimpleLiveLogger {
  SimpleLiveLogger._internal() {
    _logger = Logger(
      printer: SimpleLiveLogPrinter(),
      output: SimpleLiveLogOutput(),
    );
  }

  static final SimpleLiveLogger _instance = SimpleLiveLogger._internal();
  factory SimpleLiveLogger() => _instance;

  late final Logger _logger;

  void _log(void Function(Logger logger) fn, {bool forceLog = false}) {
    if (forceLog) {
      final logOutput = SimpleLiveLogOutput();
      final logger = Logger(printer: SimpleLiveLogPrinter(), output: logOutput);
      fn(logger);
    } else {
      fn(_logger);
    }
  }

  void t(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    bool forceLog = false,
  }) {
    _log(
      (logger) => logger.t(message, error: error, stackTrace: stackTrace),
      forceLog: forceLog,
    );
  }

  void d(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    bool forceLog = false,
  }) {
    _log(
      (logger) => logger.d(message, error: error, stackTrace: stackTrace),
      forceLog: forceLog,
    );
  }

  void i(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    bool forceLog = false,
  }) {
    _log(
      (logger) => logger.i(message, error: error, stackTrace: stackTrace),
      forceLog: forceLog,
    );
  }

  void w(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    bool forceLog = false,
  }) {
    _log(
      (logger) => logger.w(message, error: error, stackTrace: stackTrace),
      forceLog: forceLog,
    );
  }

  void e(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    bool forceLog = false,
  }) {
    _log(
      (logger) => logger.e(message, error: error, stackTrace: stackTrace),
      forceLog: forceLog,
    );
  }

  void f(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
    bool forceLog = false,
  }) {
    _log(
      (logger) => logger.f(message, error: error, stackTrace: stackTrace),
      forceLog: forceLog,
    );
  }
}
