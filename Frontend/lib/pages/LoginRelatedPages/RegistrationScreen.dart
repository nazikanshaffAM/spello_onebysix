import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(10, 87, 151, 1),
      ),
      home: const RegistrationScreen(),
    );
  }
}
///////////////////////////////////////////////////////////////////
// User model to structure the data
class User {
  final String name;
  final String age;
  final String gender;
  final String email;
  final String password;

  User({
    required this.name,
    required this.age,
    required this.gender,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'email': email,
      'password': password,
    };
  }
}

// API service
class ApiService {
  
  static const String baseUrl = 'http://192.168.8.163:5000';

  static Future<bool> registerUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Registration Response: ${response.body}');
        return true;
      } else {
        print('Registration failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }
}

