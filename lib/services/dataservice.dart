import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hunted_app/models/HttpError.dart';

import '../exceptions/HTTPResponseException.dart';

abstract class DataService<T> {
  final String url = env['API_URL'];
  final String genericEndpoint;

  DataService({this.genericEndpoint});

  Future<T> get(int id) async {
    return executeRequest(endpoint: "/$id")
        .then((value) => convert(json.decode(value)));
  }

  Future<T> getAll() {
    return executeRequest().then((value) => convertArray(json.decode(value)));
  }

  T convert(Map<String, dynamic> json);
  T convertArray(Map<String, dynamic> json);

  Future<String> executeRequest({String endpoint: ''}) async {
    final response = await http.get(createRequestUri(endpoint));

    if ([200, 201, 202, 204].contains(response.statusCode)) {
      return response.body;
    } else {
      final error = HttpError.fromJson(json.decode(response.body));
      return Future.error(
          HTTPResponseException(response.statusCode, error.message));
    }
  }

  Uri createRequestUri(String endpoint) {
    return Uri.parse(env['API_URL'] + genericEndpoint + endpoint);
  }
}
