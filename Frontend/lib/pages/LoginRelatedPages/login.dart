import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Placeholder Home Screen
class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${userData['name']}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder Signup Screen
class SignupPage extends StatelessWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7B95D3), Color(0xFF6A82C3)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black26,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'This is a placeholder for the signup page',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Back to Login', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
      final response = await http.post(
        Uri.parse('http://192.168.8.163:5000/login'),
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
        // Navigate to home page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(userData: responseData['user']),//direction to screen if sucess
          ),
        );
      } else {
        // Login failed
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF7B95D3), // Matches the blue in your Figma
        ),
        child: Stack(
          children: [
            // Login form
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 60),
                        const Text(
                          'Hello From Spello!',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 5.0,
                                color: Colors.black26,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        
                        // Image placeholder
                        Image.asset(
                          'assets/images/login.png',
                          height: 240,
                          fit: BoxFit.contain,
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Email Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email :',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Password Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(
                              labelText: 'Password:',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(color: Colors.red, backgroundColor: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        
                        // Login Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBackgroundColor: Colors.amber.withOpacity(0.6),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Registration link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sign up to Start Journey',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const SignupPage()),
                                );
                              },
                              child: const Text(
                                'Sign urp',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
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