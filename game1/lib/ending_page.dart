import 'package:flutter/material.dart';
import 'package:mygame/game_start_page.dart';
import 'game_page.dart';

class EndingPage extends StatelessWidget {
  final int correctlyPronouncedWords;
  //final double accuracy;
  final int livesLeft;

  const EndingPage({
    super.key,
    required this.correctlyPronouncedWords,
    //required this.accuracy,
    required this.livesLeft,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate XP (100 XP for each correct word)
    final int totalXP = correctlyPronouncedWords * 100;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Gameplay Summary & Buttons
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Game Over Title
                Text(
                  "GAME OVER",
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Game Summary
                Card(
                  elevation: 8,
                  color: Colors.white.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Game Summary",
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Correct Words: $correctlyPronouncedWords",
                          style: TextStyle(fontSize: 20, color: Colors.black87),
                        ),
                        //Text(
                          //"Accuracy: ${accuracy.toStringAsFixed(2)}%",
                          //style: TextStyle(fontSize: 20, color: Colors.black87),
                        //),
                        const SizedBox(height: 16),
                        Text(
                          "Total XP: $totalXP",
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Lives Left: $livesLeft",
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),


                _buildFixedSizeButton("PLAY AGAIN", () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => GamePage()),
                  );
                }),
                const SizedBox(height: 16),
                _buildFixedSizeButton("MAIN MENU", () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const StartPage()),
                  );
                }),
                const SizedBox(height: 16),
                _buildFixedSizeButton("GAME CENTER", () {
                  // Placeholder for main app navigation
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFixedSizeButton(String text, VoidCallback onPressed) {
    return Container(
      width: 250,
      child: ElevatedButton(
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
      ),
    );
  }
}
