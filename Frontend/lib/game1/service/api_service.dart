import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://spello.pythonanywhere.com";

  // Utility Function to Retrieve Stored Cookies
  // static Future<String?> getStoredCookies() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString("cookies");
  // }

  // Upload WAV file and get pronunciation accuracy
  static Future<int?> uploadAudio(String filePath, [Map<String, dynamic>? userData]) async {
    try {
      // Construct the URL with email as query parameter if available
      String uri = "$baseUrl/speech-to-text";
      
      if (userData != null && userData.containsKey('email')) {
        uri += "?email=${Uri.encodeComponent(userData['email'])}";
        print("Adding email as query parameter for audio upload: ${userData['email']}");
      }
      
      var requestUri = Uri.parse(uri);
      var request = http.MultipartRequest('POST', requestUri);

      // Retrieve stored session cookies
      //String? cookies = await getStoredCookies();

      // Attach the audio file
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        filePath,
        contentType: MediaType('audio', 'wav'), // Ensure correct content type
      ));

      // Add cookies if available
      // if (cookies != null) {
      //   request.headers['Cookie'] = cookies;
      // }

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (kDebugMode) debugPrint("Response from backend: $responseData");

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        return jsonResponse.containsKey('accuracy') ? jsonResponse['accuracy']?.toInt() : null;
      } else {
        debugPrint("Error: ${response.reasonPhrase}");
        debugPrint("Response data: $responseData");
        return null;
      }
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }

  // Fetch the target word with authentication
  static Future<String?> fetchTargetWord([Map<String, dynamic>? userData]) async {
    try {
      // Construct the URL with email as query parameter if available
      String uri = "$baseUrl/get-target-word";
      
      if (userData != null && userData.containsKey('email')) {
        uri += "?email=${Uri.encodeComponent(userData['email'])}";
        print("Adding email as query parameter: ${userData['email']}");
      }
      
      final targetWordUri = Uri.parse(uri);

      // Retrieve stored session cookies
      //String? cookies = await getStoredCookies();

      // Prepare headers
      Map<String, String> headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      // Add cookies if available
      // if (cookies != null) {
      //   headers["Cookie"] = cookies;
      // }

      // Make the request with all available authentication
      final response = await http.get(targetWordUri, headers: headers);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['target_word'];
      } else {
        debugPrint("Error fetching word: ${response.reasonPhrase}");
        debugPrint("Response body: ${response.body}");
        throw Exception("UNAUTHORIZED");
      }
    } catch (e) {
      debugPrint("Exception: $e");
      throw e;
    }
  }

  // Login endpoint to establish a session
  static Future<bool> login(Map<String, dynamic>? userData) async {
    if (userData == null || !userData.containsKey('email')) {
      print("No email found in userData for authentication");
      return false;
    }

    try {
      final uri = Uri.parse("$baseUrl/login");
      
      // Get the email and prepare request body
      final email = userData['email'];
      // Note: Your backend requires password too, but we don't have it
      // This is a demo implementation - you might need to adjust this
      final body = json.encode({
        'email': email,
        'password': 'demo_password' // This won't work in production!
      });

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: body,
      );

      // Store cookies if available
      if (response.statusCode == 200) {
        String? cookies = response.headers['set-cookie'];
        if (cookies != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("cookies", cookies);
          print("Stored authentication cookies");
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print("Login exception: $e");
      return false;
    }
  }
}