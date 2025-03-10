import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.209.48:5000";

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
        if (jsonResponse.containsKey('accuracy')) {
          return jsonResponse['accuracy']?.toInt();
        } else {
          print("Error: 'accuracy' key missing in response.");
          return null;
        }
      } else {
        print("Error: ${response.reasonPhrase}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }


  // Fetch the target word from the backend
  static Future<String?> fetchTargetWord1() async {
    try {
      final uri = Uri.parse("$baseUrl/get-target-word");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['target_word']; // Get word from API response
      } else {
        debugPrint("Error fetching word: ${response.reasonPhrase}");
        return null; // No fallback needed since backend guarantees a word
      }
    } catch (e) {
      debugPrint("Exception: $e");
      return null;
    }
  }


  // Fetch the target word from the backend
  static Future<String?> fetchTargetWord(String email, List<String> selectedSounds) async {
    try {
      // Convert the list of selected sounds to a comma-separated string
      String soundsParam = selectedSounds.join(',');

      // Construct the full URI with query parameters (sounds and email)
      final uri = Uri.parse("$baseUrl/get-target-word?sounds=$soundsParam&email=$email");

      // Send a GET request to the backend API
      final response = await http.get(uri);

      // Handle the response
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse['target_word']; // Return the target word from API response
      } else {
        debugPrint("Error fetching word: ${response.reasonPhrase}");
        return null; // Return null if the API response is not successful
      }
    } catch (e) {
      debugPrint("Exception: $e");
      return null; // Return null in case of any exception
    }
  }
}


  // Fetch words from backend (for testing)
  Future<List<String>> fetchWords() async {
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
    ]; // Hardcoded words
  }


