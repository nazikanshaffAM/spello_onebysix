import 'package:flutter/material.dart';
import '../engine/hangman.dart'; // Import the Hangman game engine
import 'how_to_play_page.dart'; // Import the HowToPlayPage
import 'hangman_page.dart';      // Import the HangmanPage

// Stateless widget for the Settings page
class SettingsPage extends StatelessWidget {
  final HangmanGame _engine = HangmanGame(); // Initialize the game engine

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'), // Set the app bar title
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding around content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the content
            children: <Widget>[
              // Button to navigate to the How to Play page
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HowToPlayPage()),
                  );
                },
                child: Text('How to Play'), // Button text
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),  // Optional: Adjust button size
                ),
              ),
              SizedBox(height: 20), // Add space between buttons
              // Button to restart the game by navigating to the Hangman page
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HangmanPage(_engine)),
                  );
                },
                child: Text('Restart'), // Button text
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),  // Optional: Adjust button size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
