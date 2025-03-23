import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:spello_frontend/pages/HomePages/MainPages/homepage.dart';
import 'package:spello_frontend/pages/LoginRelatedPages/RegistrationScreen.dart';
import 'package:spello_frontend/config/config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      var client = http.Client();
      var response = await client.post(
        Uri.parse('${Config.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Extract cookies from response headers
        String? rawCookies = response.headers['set-cookie'];
        if (rawCookies != null) {
          List<String> cookies = rawCookies.split(';');

          // Save cookies to shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('session_cookie', cookies[0]);
        }

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(userData: responseData['user']),
          ),
        );
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'Authentication failed';
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not connect to server. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFF8092CC)),
        child: Stack(
          children: [
            Positioned(
              top: screenHeight * 0.05,
              left: screenWidth * 0,
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  "assets/images/cloud.png",
                  width: screenWidth * 0.4,
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.2,
              left: screenWidth * 0.8,
              child: Opacity(
                opacity: 0.5,
                child: Image.asset(
                  "assets/images/cloud.png",
                  width: screenWidth * 0.4,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.05,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          'Hello From Spello!',
                          style: TextStyle(
                            fontSize: screenWidth * 0.084,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Fredoka One",
                            shadows: [
                              Shadow(
                                blurRadius: screenWidth * 0.01,
                                color: Colors.black26,
                                offset: Offset(
                                    screenWidth * 0.005, screenWidth * 0.005),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.08),

                        Image.asset(
                          'assets/images/login.png',
                          height: screenHeight * 0.25,
                          fit: BoxFit.contain,
                        ),

                        SizedBox(height: screenHeight * 0.05),

                        // Email Field
                        Container(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.08,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.03),
                            border: Border.all(color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: screenWidth * 0.01,
                                offset: Offset(0, screenHeight * 0.005),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelText: 'Email :',
                              labelStyle: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05,
                                vertical: screenHeight * 0.013,
                              ),
                              errorStyle: TextStyle(
                                fontSize: screenWidth * 0.03,
                                height: 0.8,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontFamily: "Fredoka",
                              fontWeight: FontWeight.bold,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            onChanged: (_) {
                              if (_errorMessage.isNotEmpty) {
                                setState(() => _errorMessage = '');
                              }
                            },
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Password Field
                        Container(
                          width: screenWidth * 0.8,
                          height: screenHeight * 0.08,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.03),
                            border: Border.all(color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: screenWidth * 0.01,
                                offset: Offset(0, screenHeight * 0.005),
                              )
                            ],
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              labelText: 'Password:',
                              labelStyle: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.05,
                                vertical: screenHeight * 0.013,
                              ),
                              errorStyle: TextStyle(
                                fontSize: screenWidth * 0.03,
                                height: 0.8,
                              ),
                            ),
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontFamily: "Fredoka",
                              fontWeight: FontWeight.bold,
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            onChanged: (_) {
                              if (_errorMessage.isNotEmpty) {
                                setState(() => _errorMessage = '');
                              }
                            },
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),

                        // Error message container
                        SizedBox(
                          height: screenHeight * 0.04,
                          child: _errorMessage.isNotEmpty
                              ? Text(
                                  _errorMessage,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: screenWidth * 0.035,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : null,
                        ),

                        // Login Button
                        InkWell(
                          onTap: _isLoading ? null : _login,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.03),
                          child: Container(
                            width: screenWidth * 0.8,
                            height: screenHeight * 0.07,
                            decoration: BoxDecoration(
                              color: _isLoading
                                  ? Colors.amber.withOpacity(0.6)
                                  : const Color(0xFFFFC107),
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.03),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD29338),
                                  offset: Offset(0, screenHeight * 0.005),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: _isLoading
                                  ? SizedBox(
                                      height: screenHeight * 0.03,
                                      width: screenHeight * 0.03,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: screenWidth * 0.008,
                                      ),
                                    )
                                  : Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.04,
                                        fontFamily: "Fredoka",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Registration link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sign up to Start your Journey!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Fredoka",
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegistrationScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign up',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 238, 207, 8),
                                  fontSize: screenWidth * 0.035,
                                  fontFamily: "Fredoka One",
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
