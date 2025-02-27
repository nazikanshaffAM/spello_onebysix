import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:8080';

  // Uploads the recorded audio file and retrieves the random integer
  static Future<int?> uploadAudio(String filePath) async {
    try {
      File file = File(filePath);
      List<int> bytes = await file.readAsBytes();

      final response = await http.post(
        Uri.parse('$_baseUrl/upload-audio'),
        headers: {"Content-Type": "application/octet-stream"},
        body: bytes,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(" Received random value: ${data["randomValue"]}");
        return data["randomValue"];
      } else {
        print(" Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print(" Exception: $e");
      return null;
    }
  }
}
