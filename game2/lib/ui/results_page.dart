import 'package:flutter/material.dart';
import 'start_screen.dart'; // Import the StartScreen

class ResultPage extends StatelessWidget {
  final double averageAccuracy;
  final int livesLeft;

  ResultPage({required this.averageAccuracy, required this.livesLeft});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Average Accuracy: ${averageAccuracy.toStringAsFixed(2)}%',
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 20),
            Text(
              'Lives Left: $livesLeft',
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                // Navigate to the StartScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StartScreen(),
                  ),
                );
              },
              child: Text('Back to Game'),
            ),
          ],
        ),
      ),
    );
  }
}
