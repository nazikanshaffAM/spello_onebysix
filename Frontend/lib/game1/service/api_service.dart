import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://spello.pythonanywhere.com";

  // **Utility Function to Retrieve Stored Cookies**
  static Future<String?> getStoredCookies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString("cookies");



  }


  // **Upload WAV file and get pronunciation accuracy**
  static Future<int?> uploadAudio(String filePath) async {
    try {
      var uri = Uri.parse("$baseUrl/speech-to-text");
      var request = http.MultipartRequest('POST', uri);

      // Retrieve stored session cookies
      String? cookies = await getStoredCookies();

      // Attach the audio file
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        filePath,
        contentType: MediaType('audio', 'wav'), // Ensure correct content type
      ));

      // Attach session cookies for authentication
      if (cookies != null) {
        request.headers['Cookie'] = cookies;
      }

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (kDebugMode) debugPrint("Response from backend: $responseData");

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        return jsonResponse.containsKey('accuracy') ? jsonResponse['accuracy']?.toInt() : null;
      } else {
        debugPrint("Error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }

  // **Fetch the target word with session authentication**
  static Future<String?> fetchTargetWord() async {
    try {
      final uri = Uri.parse("$baseUrl/get-target-word");

      // Retrieve stored session cookies
      String? cookies = await getStoredCookies();

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (cookies != null) "Cookie": cookies, // Attach session cookie
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['target_word'];
      } else {
        debugPrint("Error fetching word: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }
}
