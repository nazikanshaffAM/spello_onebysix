import 'package:flutter/material.dart';
import 'start_screen.dart'; // Import the StartScreen

// Stateless widget for displaying the result screen
class ResultPage extends StatelessWidget {
  final double averageAccuracy; // Holds the average accuracy percentage
  final int livesLeft; // Holds the number of lives left at the end of the game

  // Constructor requiring averageAccuracy and livesLeft as parameters
  ResultPage({required this.averageAccuracy, required this.livesLeft});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'), // Set the app bar title
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
          children: <Widget>[
            // Display the average accuracy percentage
            Text(
              'Average Accuracy: ${averageAccuracy.toStringAsFixed(2)}%',
              style: TextStyle(fontSize: 28, color: Colors.lightGreen), // Set font size
            ),
            SizedBox(height: 20), // Add space between elements
            // Display the number of lives left
            Text(
              'Lives Left: $livesLeft',
              style: TextStyle(fontSize: 30, color: Colors.redAccent), // Set font size
            ),
            SizedBox(height: 50), // Add space before the button
            ElevatedButton(
              onPressed: () {
                // Navigate to the StartScreen, replacing the current screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StartScreen(),
                  ),
                );
              },
              child: Text('Back to Game'), // Button text
            ),
          ],
        ),
      ),
    );
  }
}
