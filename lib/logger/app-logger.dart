import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppLogger {
  static String? _logFilePath;

  static Future<void> init() async {
    try {
      // Prefer getApplicationDocumentsDirectory for visibility
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory(p.join(directory.path, 'DrCamApp/logs'));

      if (kDebugMode) {
        print('Using logs directory: ${logsDir.path}');
      }

      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
        if (kDebugMode) print("Logs directory created.");
      }

      _logFilePath = p.join(logsDir.path, 'applicationlogs.txt');
      final logFile = File(_logFilePath!);

      if (!await logFile.exists()) {
        await logFile.create();
        if (kDebugMode) print("Log file created.");
      } else {
        if (kDebugMode) print("Log file already exists.");
      }

    } catch (e, st) {
      debugPrint("AppLogger init error: $e\n$st");
    }
  }

  static Future<void> log(String message) async {
    try {
      if (_logFilePath == null) {
        throw Exception("AppLogger is not initialized. Call init() first.");
      }

      final timestamp = DateTime.now().toIso8601String();
      final logLine = "[$timestamp] $message\n";
      final logFile = File(_logFilePath!);

      await logFile.writeAsString(logLine, mode: FileMode.append, flush: true);

      if (kDebugMode) print("Logged: $logLine");
    } catch (e, st) {
      debugPrint("AppLogger write error: $e\n$st");
    }
  }
}
