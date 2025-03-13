import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.73.48:5000";

  // Upload WAV file and get pronunciation accuracy
  static Future<int?> uploadAudio(String filePath) async {
    try {
      var uri = Uri.parse("$baseUrl/speech-to-text");
      var request = http.MultipartRequest('POST', uri);

      // Retrieve stored session cookies
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cookies = prefs.getString("cookies");

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

  // Login function
  static Future<bool> loginUser(String email, String password) async {
    try {
      final uri = Uri.parse("$baseUrl/login");

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        await saveCookies(response);
        return true;
      } else {
        debugPrint("Login failed: ${response.reasonPhrase}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception: $e");
      return false;
    }
  }

  // Save session cookies after login
  static Future<void> saveCookies(http.Response response) async {
    String? rawCookies = response.headers['set-cookie'];
    if (rawCookies != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("cookies", rawCookies);
      debugPrint("Session cookies saved: $rawCookies");
    }
  }

  // Fetch the target word with session authentication
  static Future<String?> fetchTargetWord() async {
    try {
      final uri = Uri.parse("$baseUrl/get-target-word");

      // Retrieve stored session cookies
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cookies = prefs.getString("cookies");

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
