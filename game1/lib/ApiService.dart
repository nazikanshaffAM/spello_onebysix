import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ApiService {
  static const String baseUrl = "http://192.168.194.48:5000";

  // Upload WAV file and get pronunciation accuracy
  static Future<int?> uploadAudio(String filePath) async {
    try {
      var uri = Uri.parse("$baseUrl/speech-to-text");
      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('audio', filePath));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        if (kDebugMode) {
          print("Response from backend: $responseData");
        }
        var jsonResponse = json.decode(responseData);
        return jsonResponse['accuracy']?.toInt();
      } else {
        print("Error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  // Fetch words from backend (modify this if needed)
  static Future<List<String>> fetchWords() async {
    return [
      "Think",
      "This",
      "Rabbit",
      "Lemon",
      "Snake",
      "Ship",
      "Cheese",
      "Juice",
      "Zebra",
      "Violin"
    ]; // Hardcoded words (modify if API is implemented)
  }
}
