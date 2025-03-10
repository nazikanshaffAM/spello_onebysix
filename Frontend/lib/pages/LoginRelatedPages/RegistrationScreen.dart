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
