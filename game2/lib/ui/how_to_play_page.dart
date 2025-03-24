import 'package:flutter/material.dart';
import 'settings_page.dart'; // Import the SettingsPage

// Stateless widget for the How to Play page
class HowToPlayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('How to Play'), // Set the app bar title
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Add padding around content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
            children: <Widget>[
              // Text explaining how to play the game
              Text(
                'Here is how you play the game:\n\n'
                    '1. Listen carefully to the word.\n'
                    '2. Pronounce the word correctly.\n'
                    '3. Your pronunciation accuracy will be evaluated.\n'
                    '4. You have 7 lives. If your accuracy is low, you lose a life.\n'
                    '5. Correctly pronounce enough words to win the game!',
                textAlign: TextAlign.center, // Center-align the text
                style: TextStyle(fontSize: 22.0), // Set font size
              ),
              SizedBox(height: 20), // Add some space between the text and the button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to the Settings page
                },
                child: Text('Back to Settings'), // Button text
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50), // Optional: Adjust button size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
