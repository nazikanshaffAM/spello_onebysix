import 'package:flutter/material.dart';

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

          // Gameplay details & buttons
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gameplay Details Card
                Card(
                  elevation: 8,
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Game Summary",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                const SizedBox(height: 20),

                // Buttons
                Column(
                  children: [
                    // Play Again Button
                    ElevatedButton(
                      onPressed: () {
                        // Restart Game Logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      child: const Text("Play Again", style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 10),

                    // Go to Start Page Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Navigates back to start page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      child: const Text("Go to Start Page", style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 10),

                    // Go to Main Flutter App (Placeholder)
                    ElevatedButton(
                      onPressed: () {
                        // Placeholder for future navigation
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      child: const Text("Go to Main App", style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
