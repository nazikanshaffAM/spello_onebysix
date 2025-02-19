import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:5000";

  static Future<int> fetchRandomValue() async {
    final response = await http.get(Uri.parse("$baseUrl/get-random"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["value"];
    } else {
      throw Exception("Failed to fetch value");
    }
  }
}
