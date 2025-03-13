import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spello_frontend/config/config.dart';

class Settings extends StatefulWidget {
  final Map<String, dynamic> userData; // Receives userData from HomePage

  const Settings({super.key, required this.userData});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool isLoading = false;
  String? errorMessage;

  Future<void> _handleLogout() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      // Get the email from userData
      final String email = widget.userData['email'];
      print("Logging out user: $email");
      
      // Make the API call directly without a service
      final response = await http.post(
         Uri.parse('${Config.baseUrl}/logout'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      print("Logout response status: ${response.statusCode}");
      
      // Consider any 2xx status code as success
      if (response.statusCode >= 200 && response.statusCode < 300 && mounted) {
        print("Logout successful");
        
        // Clear any stored preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        
        // Navigate to login screen and clear navigation stack
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        print("Logout failed");
        
        // Try to parse the error message from response
        String message = 'Failed to logout';
        if (response.body.isNotEmpty) {
          try {
            final data = jsonDecode(response.body);
            message = data['message'] ?? message;
          } catch (e) {
            // Ignore JSON parsing errors
          }
        }
        
        setState(() {
          errorMessage = message;
        });
        
        // Show error dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout Error'),
              content: Text(errorMessage ?? 'An unknown error occurred'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print("Logout exception: $e");
      setState(() {
        errorMessage = 'Could not connect to server. Please try again later.';
      });
      
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout Error'),
            content: Text(errorMessage ?? 'An unknown error occurred'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(
            fontFamily: "Fredoka One",
            fontSize: screenWidth * 0.07,
          ),
        ),
        backgroundColor: const Color(0xFF3A435F),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFF8092CC),
        child: Column(
          children: [
            // User Info Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "User Profile",
                        style: TextStyle(
                          fontFamily: "Fredoka One",
                          fontSize: 20,
                          color: Color(0xFF3A435F),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Name: ${widget.userData['name'] ?? 'Not available'}",
                        style: TextStyle(
                          fontFamily: "Fredoka",
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Email: ${widget.userData['email'] ?? 'Not available'}",
                        style: TextStyle(
                          fontFamily: "Fredoka",
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // App Info Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Spello",
                        style: TextStyle(
                          fontFamily: "Fredoka One",
                          fontSize: 24,
                          color: Color(0xFF3A435F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Version 1.0.0",
                        style: TextStyle(
                          fontFamily: "Fredoka",
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "A pronunciation learning app for children.",
                        style: TextStyle(
                          fontFamily: "Fredoka",
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red, 
                    fontFamily: "Fredoka",
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            
            const Spacer(),
            
            // Logout Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC000),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 10),
                            Text(
                              "Logout",
                              style: TextStyle(
                                fontFamily: "Fredoka",
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }
}