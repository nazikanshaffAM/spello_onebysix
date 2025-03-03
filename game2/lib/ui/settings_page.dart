import 'package:flutter/material.dart';
import '../engine/hangman.dart';
import 'how_to_play_page.dart';
import 'hangman_page.dart';      // Import the HangmanPage

class SettingsPage extends StatelessWidget {
  final HangmanGame _engine = HangmanGame(); // Initialize the game engine

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the content
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HowToPlayPage()),
                  );
                },
                child: Text('How to Play'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),  // Optional: Adjust button size
                ),
              ),
              SizedBox(height: 20), // Add space between buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HangmanPage(_engine)),
                  );
                },
                child: Text('Restart'),
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
