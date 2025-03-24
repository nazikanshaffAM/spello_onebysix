import 'package:flutter/material.dart';
import 'package:hangman/engine/hangman.dart'; // Import the Hangman game engine
import 'package:hangman/ui/hangman_page.dart'; // Import the Hangman game page

// Main function to start the application
void main() {
  runApp(MyApp());
}

// Stateless widget for the main application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Hangman Game', // Set the app title
      theme: ThemeData(
        primarySwatch: Colors.blue, // Set primary theme color
        visualDensity: VisualDensity.adaptivePlatformDensity, // Adjust visual density based on platform
      ),
      home: StartScreen(), // Set the initial screen to StartScreen
    );
  }
}

// Stateless widget for the Start screen
class StartScreen extends StatelessWidget {
  final HangmanGame _engine = HangmanGame(); // Initialize the game engine

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Hangman Game'), // Set the app bar title
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: <Widget>[
            // Display the game title
            Text(
              'Hangman Game',
              style: TextStyle(
                fontSize: 53.0, // Set font size
                fontWeight: FontWeight.bold, // Make the text bold
                color: Colors.indigo
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05), // Add space between elements
            // Button to start the game
            ElevatedButton(
              child: Text('Start Game',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                fontSize: 25,
                color: Colors.blue
              ),), // Button text
              onPressed: () {
                // Navigate to the Hangman game page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HangmanPage(_engine),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
