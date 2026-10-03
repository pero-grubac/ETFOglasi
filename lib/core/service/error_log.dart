import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ErrorLogEntry {
  final DateTime time;

  /// Where the error happened, e.g. `flutter`, `platform`, `background`.
  final String source;
  final String error;
  final String? stackTrace;

  const ErrorLogEntry({
    required this.time,
    required this.source,
    required this.error,
    this.stackTrace,
  });

  factory ErrorLogEntry.fromJson(Map<String, dynamic> json) => ErrorLogEntry(
    time: DateTime.parse(json['time'] as String),
    source: json['source'] as String,
    error: json['error'] as String,
    stackTrace: json['stackTrace'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'source': source,
    'error': error,
    if (stackTrace != null) 'stackTrace': stackTrace,
  };

  @override
  String toString() {
    final buffer = StringBuffer('[${time.toIso8601String()}] $source: $error');
    if (stackTrace != null) buffer.write('\n$stackTrace');
    return buffer.toString();
  }
}

/// Keeps the last [maxEntries] errors in a file on the device, so users can
/// attach them to a bug report. Nothing is sent anywhere.
///
/// Used from both the UI isolate and the background worker. Writing never
/// throws, so logging can't cause a new error.
class ErrorLog {
  static const int maxEntries = 50;
  static const int _maxStackLines = 20;
  static const String _fileName = 'error_log.jsonl';

  final Future<Directory> Function() _directory;

  ErrorLog({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationSupportDirectory;

  Future<File> _file() async =>
      File(path.join((await _directory()).path, _fileName));

  Future<void> record(
    Object error,
    StackTrace? stackTrace, {
    required String source,
  }) async {
    debugPrint('[$source] $error');
    try {
      final entries = await read();
      entries.add(
        ErrorLogEntry(
          time: DateTime.now(),
          source: source,
          error: error.toString(),
          stackTrace: _shortStack(stackTrace),
        ),
      );
      final kept = entries.length > maxEntries
          ? entries.sublist(entries.length - maxEntries)
          : entries;
      await (await _file()).writeAsString(
        kept.map((e) => jsonEncode(e.toJson())).join('\n'),
        flush: true,
      );
    } catch (e) {
      debugPrint('Could not write the error log: $e');
    }
  }

  /// Entries from oldest to newest. Lines that can't be parsed are skipped.
  Future<List<ErrorLogEntry>> read() async {
    try {
      final file = await _file();
      if (!await file.exists()) return [];
      final entries = <ErrorLogEntry>[];
      for (final line in await file.readAsLines()) {
        if (line.trim().isEmpty) continue;
        try {
          entries.add(
            ErrorLogEntry.fromJson(jsonDecode(line) as Map<String, dynamic>),
          );
        } catch (_) {}
      }
      return entries;
    } catch (_) {
      return [];
    }
  }

  Future<void> clear() async {
    try {
      final file = await _file();
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  static String? _shortStack(StackTrace? stackTrace) {
    if (stackTrace == null) return null;
    final lines = stackTrace.toString().trimRight().split('\n');
    if (lines.length <= _maxStackLines) return lines.join('\n');
    return [...lines.take(_maxStackLines), '...'].join('\n');
  }
}

final errorLog = ErrorLog();
