import 'package:flutter/material.dart';
import 'ui/start_screen.dart'; // Import the StartScreen

void main() => runApp(HangmanApp());

class HangmanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hangman',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartScreen(), // Set the StartScreen as the initial screen
    );
  }
}
