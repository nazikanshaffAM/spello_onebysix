import 'package:flutter/material.dart';
import 'ui/start_screen.dart'; // Import the StartScreen

// Main function to start the Hangman application
void main() => runApp(HangmanApp());

// Stateless widget representing the Hangman application
class HangmanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hangman', // Set the application title
      debugShowCheckedModeBanner: false, // Hide the debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue, // Set the primary color theme
      ),
      home: StartScreen(), // Set the StartScreen as the initial screen
    );
  }
}
