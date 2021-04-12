class HTTPResponseException implements Exception {
  final int statusCode;
  final String error;

  HTTPResponseException(this.statusCode, this.error);
}
