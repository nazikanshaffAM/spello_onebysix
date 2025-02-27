import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:8080';

  // Fetch random number from the backend
  static Future<int> fetchRandomValue() async {
    final response = await http.get(Uri.parse('$_baseUrl/random'));

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('❌ Failed to load random value');
    }
  }
}
