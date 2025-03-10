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

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Create controllers to handle text input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Gender dropdown value
  String _selectedGender = 'Male';
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Loading state
  bool _isLoading = false;
  
  // Password visibility
  bool _obscurePassword = true;

  // Function to validate form fields
  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (fieldName == 'Email' && !_isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    
    if (fieldName == 'Age' && !_isNumeric(value)) {
      return 'Age must be a number';
    }
    
    if (fieldName == 'Password' && value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  bool _isValidEmail(String email) {
    // Simple email validation
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isNumeric(String str) {
    // Check if the string is a valid number
    return int.tryParse(str) != null;
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to handle form submission
  void _handleSubmit() async {
    // Validate form
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Create user object
      final user = User(
        name: _nameController.text,
        age: _ageController.text,
        gender: _selectedGender,
        email: _emailController.text,
        password: _passwordController.text,
      );

      try {
        // Send data to API
        final success = await ApiService.registerUser(user);
        
        // Update loading state
        setState(() {
          _isLoading = false;
        });
        
        // Show appropriate dialog based on result
        if (success) {
          _showSuccessDialog();
          // Clear form fields after successful registration
          _nameController.clear();
          _ageController.clear();
          _emailController.clear();
          _passwordController.clear();
          setState(() {
            _selectedGender = 'Male';
          });
        } else {
          _showErrorDialog();
        }
        
      } catch (e) {
        // Handle errors
        setState(() {
          _isLoading = false;
        });
        print('Error: $e');
        _showErrorDialog();
      }
    }
  }

  