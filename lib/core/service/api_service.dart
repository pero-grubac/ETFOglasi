import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:etf_oglasi/core/model/api_exception.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<T> fetchData<T>({
    required String url,
    required T Function(dynamic json) fromJson,
    Map<String, String>? headers,
  }) async {
    final response = await _get(url, headers: headers);
    try {
      // Decode explicitly as UTF-8 so Serbian characters survive even when
      // the server omits the charset header.
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return fromJson(data);
    } catch (e) {
      throw ApiException(
        'Invalid response data: $e',
        response.statusCode,
        kind: ApiErrorKind.other,
      );
    }
  }

  Future<List<T>> fetchList<T>({
    required String url,
    required T Function(Map<String, dynamic> json) fromJson,
  }) {
    return fetchData<List<T>>(
      url: url,
      fromJson: (json) => (json as List<dynamic>)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<Uint8List> fetchBytes(String url) async {
    final response = await _get(url);
    return response.bodyBytes;
  }

  Future<http.Response> _get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await _client
          .get(Uri.parse(url), headers: headers)
          .timeout(_timeout);
      if (response.statusCode != 200) {
        throw ApiException(
          'Failed to load data: ${response.statusCode} ${response.reasonPhrase}',
          response.statusCode,
        );
      }
      return response;
    } on ApiException {
      rethrow;
    } on TlsException catch (e) {
      throw ApiException(
        'Secure connection failed: $e',
        null,
        kind: ApiErrorKind.certificate,
      );
    } catch (e) {
      throw ApiException('Error occurred while fetching data: $e', null);
    }
  }
}
