import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prototype.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DataService {
  Future<Prototype> fetchPrototypes() async {
    final response =
        // await http.get(Uri.https(FlutterConfig.get('API_URL'), '/21'));
        // await http.get(Uri.https('hunted-api.herokuapp.com', '/21'));
        await http.get(Uri.https(env["API_URL"], '/11'));
    Prototype prototype;

    if (response.statusCode == 200) {
      prototype = (Prototype.fromJson(json.decode(response.body)));
    } else {
      throw Exception('Failed to load prototypes');
    }
    return prototype;
  }
}
