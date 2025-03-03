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
        primaryColor: const Color.fromARGB(255, 10, 87, 151), // Option 2: Use primaryColor instead
      ),
      home: const RegistrationScreen(),
    );
  }
}

// User model to structure the data
class User {
  final String name;
  final String age;
  final String gender;
  final String email;

  User({
    required this.name,
    required this.age,
    required this.gender,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'email': email,
    };
  }
}

// API service
class ApiService {
  static const String baseUrl = 'https://dummy-api-endpoint.com/api';

  static Future<bool> registerUser(User user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(user.toJson()),
      );

      // For demonstration purposes, we're considering any status code in the 200 range as success
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error registering user: $e');
      // In a real app, you might want to handle specific exceptions differently
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
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Loading state
  bool _isLoading = false;

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
    _genderController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Function to handle form submission
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
      gender: _genderController.text,
      email: _emailController.text,
    );

    try {
      // Send data to API
      final success = await ApiService.registerUser(user);
      
      // Update loading state
      setState(() {
        _isLoading = false;
      });
      
      // Handle response (will add dialog in next commit)
      print(success ? 'Registration successful' : 'Registration failed');
      
    } catch (e) {
      // Handle errors
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }
}
void _showSuccessDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Success'),
      content: const Text('Registration completed successfully!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

void _showErrorDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Error'),
      content: const Text('Failed to register. Please try again later.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF8092CC), // Changed from gradient to solid color
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back arrow
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        // TODO: Add navigation logic to go back
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'Register now to get started!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Form fields
                  _buildTextField(_nameController, 'Name:'),
                  const SizedBox(height: 20),
                  _buildTextField(_ageController, 'Age:', keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  _buildTextField(_genderController, 'Gender:'),
                  const SizedBox(height: 20),
                  _buildTextField(_emailController, 'Email:', keyboardType: TextInputType.emailAddress),

                  const Spacer(),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'NEXT',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'BACK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) => _validateField(value, label.replaceAll(':', '')),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}