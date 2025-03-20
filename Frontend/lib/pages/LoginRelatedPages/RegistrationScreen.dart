import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spello_frontend/pages/HomePages/MainPages/onboarding_page.dart';
import 'package:spello_frontend/config/config.dart';

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

class ApiService {
  static const String baseUrl = Config.baseUrl;

  static Future<Map<String, dynamic>> registerUser(User user) async {
    try {
      int? age = int.tryParse(user.age);
      if (age == null || age < 0 || age > 100) {
        return {'success': false, 'message': 'Age must be between 0 and 100'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        final userData = responseData['user'];
        if (userData != null) {
          int? responseAge = int.tryParse(userData['age'].toString());
          if (responseAge == null || responseAge < 0 || responseAge > 100) {
            userData['age'] = responseAge != null
                ? (responseAge > 100
                    ? "100"
                    : (responseAge < 0 ? "0" : userData['age']))
                : "0";
          }
          return {'success': true, 'userData': userData};
        } else {
          return {'success': false, 'message': 'Invalid response data'};
        }
      } else {
        return {'success': false, 'message': 'Server error'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty)
      return 'Please enter your ${fieldName.toLowerCase()}';
    if (fieldName == 'email' &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    if (fieldName == 'age') {
      int? age = int.tryParse(value);
      if (age == null) return 'Age must be a number';
      if (age < 0 || age > 100) return 'Age must be 0-100';
    }
    if (fieldName == 'password' && value.length < 6)
      return 'Password must be 6+ characters';
    return null;
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final user = User(
        name: _nameController.text,
        age: _ageController.text,
        gender: _selectedGender ?? '',
        email: _emailController.text,
        password: _passwordController.text,
      );

      try {
        final result = await ApiService.registerUser(user);
        setState(() => _isLoading = false);
        if (result['success'] == true) {
          _showSuccessDialog(result['userData']);
          _clearForm();
        } else {
          _showErrorDialog();
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorDialog();
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _ageController.clear();
    _emailController.clear();
    _passwordController.clear();
    setState(() => _selectedGender = null);
  }

  void _showSuccessDialog(Map<String, dynamic> userData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registration successful!'),
            const SizedBox(height: 10),
            Text('Name: ${userData['name']}'),
            Text('Email: ${userData['email']}'),
            Text('Age: ${userData['age']}'),
            Text('Gender: ${userData['gender']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => OnboardingPage(userData: {
                    'name': userData['name'],
                    'email': userData['email'],
                    'age': userData['age'],
                    'gender': userData['gender'],
                  }),
                ),
              );
            },
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
        content: const Text('Registration failed. Please try again.'),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF8092CC)),
        child: Stack(children: [
          Positioned(
            top: screenHeight * 0,
            left: screenWidth * 0,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                "assets/images/cloud.png",
                width: screenWidth * 0.4,
              ),
            ),
          ),
          // Cloud 2
          Positioned(
            top: screenHeight * 0.15,
            left: screenWidth * 0.8,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                "assets/images/cloud.png",
                width: screenWidth * 0.4,
              ),
            ),
          ),
          // Cloud 3
          Positioned(
            top: screenHeight * 0.4,
            left: screenWidth * 0.22,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                "assets/images/cloud.png",
                width: screenWidth * 0.6,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon:
                              Icon(Icons.arrow_back, size: screenWidth * 0.07),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Padding(
                        padding: const EdgeInsets.only(left: 14),
                        child: Text(
                          'Register now to get started!',
                          style: TextStyle(
                            fontSize: screenWidth * 0.084,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Fredoka One",
                            shadows: const [
                              Shadow(
                                blurRadius: 5.0,
                                color: Colors.black26,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      _buildTextField(_nameController, 'Name'),
                      SizedBox(height: screenHeight * 0.02),
                      _buildTextField(_ageController, 'Age',
                          keyboardType: TextInputType.number),
                      SizedBox(height: screenHeight * 0.02),
                      _buildDropdownField(),
                      SizedBox(height: screenHeight * 0.02),
                      _buildTextField(_emailController, 'Email',
                          keyboardType: TextInputType.emailAddress),
                      SizedBox(height: screenHeight * 0.02),
                      _buildPasswordField(),
                      SizedBox(height: screenHeight * 0.04),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: screenWidth * 0.375,
                            child: _buildButton(
                              text: 'Back',
                              color: Colors.white,
                              textColor: Color(0xFF4C5679).withOpacity(0.8),
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              isPrimary: false,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.05),
                          Container(
                            width: screenWidth * 0.375,
                            child: _buildButton(
                              text: 'Next',
                              color: const Color(0xFFFFC107),
                              textColor: Colors.white,
                              onPressed: _isLoading ? null : _handleSubmit,
                              isLoading: _isLoading,
                              isPrimary: true,
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
        ]),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback? onPressed,
    bool isLoading = false,
    bool isPrimary = true,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isLoading ? color.withOpacity(0.6) : color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isPrimary ? const Color(0xFFD29338) : Colors.grey,
              offset: const Offset(0, 5),
              blurRadius: 0,
            )
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: screenWidth * 0.04,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => _validateField(value, label),
        style: const TextStyle(
          fontSize: 14,
          fontFamily: "Fredoka",
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          labelText: '$label:',
          labelStyle: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          errorStyle: const TextStyle(
            fontSize: 10,
            height: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => _validateField(value, 'Password'),
        style: const TextStyle(
          fontSize: 14,
          fontFamily: "Fredoka",
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          labelText: 'Password:',
          labelStyle: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          errorStyle: const TextStyle(
            fontSize: 10,
            height: 0.8,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 60,
      width: screenWidth * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        hint: const Text(
          'Gender:',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontFamily: "Fredoka",
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
        ),
        icon: const Icon(
          Icons.arrow_drop_down,
          color: Colors.grey,
          size: 24,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 4,
        menuMaxHeight: 200,
        items: _genderOptions
            .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(
                    gender,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: "Fredoka",
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ))
            .toList(),
        onChanged: (value) => setState(() => _selectedGender = value),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
