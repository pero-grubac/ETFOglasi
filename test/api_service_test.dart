import 'dart:convert';
import 'dart:io';

import 'package:etf_oglasi/core/model/api_exception.dart';
import 'package:etf_oglasi/core/service/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('reports TLS failures as certificate errors', () async {
    final service = ApiService(
      client: MockClient((_) async => throw const HandshakeException('bad')),
    );

    expect(
      service.fetchData(url: 'https://example.com', fromJson: (json) => json),
      throwsA(
        isA<ApiException>().having(
          (e) => e.kind,
          'kind',
          ApiErrorKind.certificate,
        ),
      ),
    );
  });

  test('classifies errors by status code', () {
    expect(ApiException('', null).kind, ApiErrorKind.network);
    expect(ApiException('', 503).kind, ApiErrorKind.server);
    expect(ApiException('', 404).kind, ApiErrorKind.other);
  });

  test('decodes the body as UTF-8 even without a charset header', () async {
    final client = MockClient(
      (_) async => http.Response.bytes(
        utf8.encode('{"name": "Čačak Ђурђевак"}'),
        200,
        headers: {'content-type': 'application/json'},
      ),
    );
    final service = ApiService(client: client);

    final name = await service.fetchData(
      url: 'https://example.com',
      fromJson: (json) => json['name'] as String,
    );

    expect(name, 'Čačak Ђурђевак');
  });

  test('keeps the status code of failed responses', () async {
    final service = ApiService(
      client: MockClient((_) async => http.Response('', 404)),
    );

    expect(
      service.fetchData(url: 'https://example.com', fromJson: (json) => json),
      throwsA(
        isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404),
      ),
    );
  });

  test('wraps network and parsing errors in ApiException', () async {
    final failing = ApiService(
      client: MockClient((_) async => throw http.ClientException('down')),
    );
    final invalid = ApiService(
      client: MockClient((_) async => http.Response('{', 200)),
    );

    expect(
      failing.fetchData(url: 'https://example.com', fromJson: (json) => json),
      throwsA(isA<ApiException>()),
    );
    expect(
      invalid.fetchData(url: 'https://example.com', fromJson: (json) => json),
      throwsA(isA<ApiException>()),
    );
  });

  test('fetchList maps every item', () async {
    final service = ApiService(
      client: MockClient((_) async => http.Response('[{"a":1},{"a":2}]', 200)),
    );

    final values = await service.fetchList(
      url: 'https://example.com',
      fromJson: (json) => json['a'] as int,
    );

    expect(values, [1, 2]);
  });
}
