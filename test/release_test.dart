import 'dart:convert';
import 'dart:io';

import 'package:etf_oglasi/core/model/api_exception.dart';
import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:etf_oglasi/core/service/error_log.dart';
import 'package:etf_oglasi/core/service/update_service.dart';
import 'package:etf_oglasi/features/announcements/service/announcement_workmanager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

UpdateService _updateService(String tagName) => UpdateService(
  service: ApiService(
    client: MockClient(
      (request) async => http.Response(
        jsonEncode({
          'tag_name': tagName,
          'html_url':
              'https://github.com/pero-grubac/ETFOglasi/releases/tag/'
              '$tagName',
        }),
        200,
      ),
    ),
  ),
);

void main() {
  group('versions', () {
    test('normalizeVersion drops the v prefix and build number', () {
      expect(normalizeVersion('v1.2.0'), '1.2.0');
      expect(normalizeVersion('1.2.0+3'), '1.2.0');
      expect(normalizeVersion(' 1.0.0 '), '1.0.0');
    });

    test('isNewerVersion compares numerically', () {
      expect(isNewerVersion('1.1.0', '1.0.0'), isTrue);
      expect(isNewerVersion('1.10.0', '1.9.2'), isTrue);
      expect(isNewerVersion('2.0', '1.9.9'), isTrue);
      expect(isNewerVersion('v1.1.0', '1.1.0'), isFalse);
      expect(isNewerVersion('1.0.0', '1.1.0'), isFalse);
      expect(isNewerVersion('1.1', '1.1.0'), isFalse);
      expect(isNewerVersion('1.1.0-beta', '1.1.0'), isFalse);
    });
  });

  group('UpdateService', () {
    test('finds a newer release', () async {
      final release = await _updateService('v1.2.0').findUpdate('1.1.0');

      expect(release?.version, '1.2.0');
      expect(release?.url, endsWith('/releases/tag/v1.2.0'));
    });

    test('returns null when up to date', () async {
      expect(await _updateService('1.1.0').findUpdate('1.1.0'), isNull);
    });

    test('checks automatically at most once a week', () async {
      SharedPreferences.setMockInitialValues({});
      final now = DateTime(2026, 10, 2, 12);

      // Due until a check succeeds.
      expect(await UpdateService.isAutomaticCheckDue(now: now), isTrue);
      expect(await UpdateService.isAutomaticCheckDue(now: now), isTrue);

      await UpdateService.markChecked(now: now);
      expect(
        await UpdateService.isAutomaticCheckDue(
          now: now.add(const Duration(days: 6, hours: 23)),
        ),
        isFalse,
      );
      expect(
        await UpdateService.isAutomaticCheckDue(
          now: now.add(const Duration(days: 7)),
        ),
        isTrue,
      );
    });
  });

  group('ErrorLog', () {
    late Directory dir;
    late ErrorLog log;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('error_log_test');
      log = ErrorLog(directory: () async => dir);
    });

    tearDown(() => dir.delete(recursive: true));

    test('records and reads entries', () async {
      await log.record(StateError('boom'), StackTrace.current, source: 'test');

      final entries = await log.read();
      expect(entries, hasLength(1));
      expect(entries.single.source, 'test');
      expect(entries.single.error, contains('boom'));
      expect(entries.single.stackTrace, isNotNull);
    });

    test('keeps only the newest entries', () async {
      for (var i = 0; i < ErrorLog.maxEntries + 5; i++) {
        await log.record('error $i', null, source: 'test');
      }

      final entries = await log.read();
      expect(entries, hasLength(ErrorLog.maxEntries));
      expect(entries.first.error, 'error 5');
      expect(entries.last.error, 'error ${ErrorLog.maxEntries + 4}');
    });

    test('skips damaged lines and can be cleared', () async {
      await log.record('first', null, source: 'test');
      final file = File('${dir.path}/error_log.jsonl');
      await file.writeAsString('\nnot json', mode: FileMode.append);
      await log.record('second', null, source: 'test');

      expect((await log.read()).map((e) => e.error), ['first', 'second']);

      await log.clear();
      expect(await log.read(), isEmpty);
    });
  });

  test('background check retries only network and server errors', () {
    expect(shouldRetryBackgroundError(ApiException('offline', null)), isTrue);
    expect(shouldRetryBackgroundError(ApiException('server', 503)), isTrue);
    expect(shouldRetryBackgroundError(ApiException('missing', 404)), isFalse);
    expect(shouldRetryBackgroundError(ApiException('bad json', 200)), isFalse);
    expect(shouldRetryBackgroundError(const FormatException()), isFalse);
    expect(
      shouldRetryBackgroundError(
        ApiException('tls', null, kind: ApiErrorKind.certificate),
      ),
      isFalse,
    );
  });
}
