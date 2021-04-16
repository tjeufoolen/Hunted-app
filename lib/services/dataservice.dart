import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hunted_app/models/HttpError.dart';

import '../exceptions/HTTPResponseException.dart';

abstract class DataService<T> {
  final String url = env['API_URL'];
  final String genericEndpoint;

  final Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json; charset=UTF-8'
  };

  DataService({this.genericEndpoint});

  Future<T> get(int id) async {
    return executeRequest(http_methods.GET, endpoint: "/$id")
        .then((value) => convert(json.decode(value)));
  }

  Future<T> getAll() {
    return executeRequest(http_methods.GET)
        .then((value) => convertArray(json.decode(value)));
  }

  T convert(Map<String, dynamic> json);
  T convertArray(Map<String, dynamic> json);

  Future<String> executeRequest(http_methods method,
      {String endpoint: '', Map<String, dynamic> content}) async {
    var response;

    switch (method) {
      case http_methods.GET:
        {
          response = await http.get(createRequestUri(endpoint));
        }
        break;

      case http_methods.POST:
        {
          if (content == null)
            throw Exception(
                "Argument Exception: executeRequest with post method requires content body to be set.");

          var body = jsonEncode(content);
          response = await http.post(createRequestUri(endpoint),
              headers: _jsonHeaders, body: body);
        }
        break;

      case http_methods.PUT:
        {
          if (content == null)
            throw Exception(
                "Argument Exception: executeRequest with put method requires content body to be set.");
          response = await http.put(createRequestUri(endpoint),
              headers: _jsonHeaders, body: jsonEncode(content));
        }
        break;

      case http_methods.PATCH:
        {
          if (content == null)
            throw Exception(
                "Argument Exception: executeRequest with patch method requires content body to be set.");
          response = await http.patch(createRequestUri(endpoint),
              headers: _jsonHeaders, body: jsonEncode(content));
        }
        break;

      case http_methods.DELETE:
        {
          response = await http.delete(createRequestUri(endpoint));
        }
        break;
    }

    if ([200, 201, 202, 204].contains(response.statusCode)) {
      return response.body;
    } else {
      final error = HttpError.fromJson(json.decode(response.body));
      return Future.error(
        HTTPResponseException(response.statusCode, error.message),
      );
    }
  }

  Uri createRequestUri(String endpoint) {
    return Uri.parse(env['API_URL'] + genericEndpoint + endpoint);
  }
}

enum http_methods { GET, POST, PUT, PATCH, DELETE }
