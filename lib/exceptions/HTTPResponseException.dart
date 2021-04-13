class HTTPResponseException implements Exception {
  final int statusCode;
  final String message;

  HTTPResponseException(this.statusCode, this.message);
}
