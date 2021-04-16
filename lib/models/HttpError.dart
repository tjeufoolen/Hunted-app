class HttpError {
  final String message;

  HttpError({this.message});

  factory HttpError.fromJson(Map<String, dynamic> json) {
    return HttpError(
      message: json['error'],
    );
  }
}
