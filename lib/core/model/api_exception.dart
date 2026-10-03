enum ApiErrorKind {
  /// No connection, DNS failure or timeout.
  network,

  /// The secure connection failed (expired/invalid certificate, or a wrong
  /// clock on the phone).
  certificate,

  /// The server answered with a 5xx status.
  server,

  /// Anything else: other status codes, invalid data.
  other,
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorKind kind;

  ApiException(this.message, this.statusCode, {ApiErrorKind? kind})
    : kind = kind ?? _kindFromStatus(statusCode);

  static ApiErrorKind _kindFromStatus(int? statusCode) => switch (statusCode) {
    null => ApiErrorKind.network,
    >= 500 => ApiErrorKind.server,
    _ => ApiErrorKind.other,
  };

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
}
