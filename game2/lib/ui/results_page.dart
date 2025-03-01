import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final double averageAccuracy;
  final int livesLeft;

  ResultPage({required this.averageAccuracy, required this.livesLeft});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Over'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Game Over!',
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Average Accuracy: ${averageAccuracy.toStringAsFixed(2)}%',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 10),
            Text(
              'Lives Left: $livesLeft',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back to Start'),
            ),
          ],
        ),
      ),
    );
  }
}
