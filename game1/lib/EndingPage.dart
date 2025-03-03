import 'package:flutter/material.dart';
import 'package:mygame/StartPage.dart';

import 'GamePage.dart';

class EndingPage extends StatelessWidget {
  final int correctlyPronouncedWords;
  final int totalWords;
  final double accuracy;
  final int userLevel;

  const EndingPage({
    super.key,
    required this.correctlyPronouncedWords,
    required this.totalWords,
    required this.accuracy,
    required this.userLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/backgroundEndingPage.png',
              fit: BoxFit.cover,
            ),
          ),

          // Gameplay Summary & Buttons
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Game Summary Card
                Card(
                  elevation: 8,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Game Summary",
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text("Correct Words: $correctlyPronouncedWords / $totalWords",
                            style: const TextStyle(fontSize: 18)),
                        Text("Accuracy: ${accuracy.toStringAsFixed(2)}%",
                            style: const TextStyle(fontSize: 18)),
                        Text("Current Level: $userLevel",
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                _buildButton("PLAY AGAIN", () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => GamePage()),
                  );
                }),
                const SizedBox(height: 16),
                _buildButton("GO TO START PAGE", () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const StartPage()),
                  );
                }),
                const SizedBox(height: 16),
                _buildButton("GO TO MAIN APP", () {
                  // Placeholder for main app navigation
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6B96AB),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 3,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black26,
              offset: Offset(2, 2),
              blurRadius: 2,
            )
          ],
        ),
      ),
    );
  }
}
