import 'dart:convert';
import 'package:etf_oglasi/core/model/http_exception.dart';
import 'package:http/http.dart' as http;

class ApiService {
  Future<T> fetchData<T>({
    required String url,
    required T Function(dynamic json) fromJson,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return fromJson(data);
      } else {
        throw HttpException(
          'Failed to load data: ${response.statusCode} ${response.reasonPhrase}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw HttpException(
        'Error occurred while fetching data: $e',
        null,
      );
    }
  }
}
