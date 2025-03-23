import 'package:flutter/material.dart';

import 'game_page.dart';
import 'game_start_page.dart';

class EndingPage extends StatelessWidget {
  final int correctlyPronouncedWords;
  final int livesLeft;

  const EndingPage({
    super.key,
    required this.correctlyPronouncedWords,
    required this.livesLeft,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate XP (100 XP for each correct word)
    final int totalXP = correctlyPronouncedWords * 100;

    // Modified logic: Always show at least one star if they pronounced any words correctly
    final int starsToShow = correctlyPronouncedWords > 0
        ? (livesLeft > 0
            ? livesLeft
            : 1) // At least 1 star if they got any words right
        : 1; // Default to 1 star even if they got no words right

    return Scaffold(
      body: Stack(
        children: [
          // Background Image (remains the same)
          Positioned.fill(
            child: Image.asset(
              'assets/images/b11.png',
              fit: BoxFit.cover,
            ),
          ),

          // New UI Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Game Summary Box with Border matching button color
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withOpacity(0.2), // 20% opacity as requested
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF235A82), // Matching button color
                      width: 4.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Stars in an arc based on lives left
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Create 3 stars in an arc, visible based on starsToShow
                          Transform.translate(
                            offset: const Offset(-20, 10),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3.0,
                                ),
                              ),
                              child: Opacity(
                                opacity: starsToShow >= 1 ? 1.0 : 0.3,
                                child: Image.asset(
                                  'assets/images/star.png', // Your star asset
                                  width: 50,
                                  height: 50,
                                  color: Colors.white.withOpacity(
                                      0.05), // Very low background opacity
                                  colorBlendMode: BlendMode.dstIn,
                                ),
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(0, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3.0,
                                ),
                              ),
                              child: Opacity(
                                opacity: starsToShow >= 2 ? 1.0 : 0.3,
                                child: Image.asset(
                                  'assets/images/star.png', // Your star asset
                                  width: 60,
                                  height: 60,
                                  color: Colors.white.withOpacity(
                                      0.05), // Very low background opacity
                                  colorBlendMode: BlendMode.dstIn,
                                ),
                              ),
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(20, 10),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3.0,
                                ),
                              ),
                              child: Opacity(
                                opacity: starsToShow >= 3 ? 1.0 : 0.3,
                                child: Image.asset(
                                  'assets/images/star.png', // Your star asset
                                  width: 50,
                                  height: 50,
                                  color: Colors.white.withOpacity(
                                      0.05), // Very low background opacity
                                  colorBlendMode: BlendMode.dstIn,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // GAME OVER text with Fredoka One font and stroke
                      Stack(
                        children: [
                          // Stroke layer
                          Text(
                            "GAME OVER",
                            style: TextStyle(
                              fontFamily: 'Fredoka One',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 3
                                ..color = Colors.black,
                            ),
                          ),
                          // Text layer
                          Text(
                            "GAME OVER",
                            style: TextStyle(
                              fontFamily: 'Fredoka One',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // XP Container with Fredoka One font and stroke
                      Container(
                        width: 220,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.green.shade600, width: 2),
                        ),
                        child: Center(
                          child: Stack(
                            children: [
                              // Stroke layer
                              Text(
                                "+ $totalXP XP",
                                style: TextStyle(
                                  fontFamily: 'Fredoka One',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 3
                                    ..color = Colors.black,
                                ),
                              ),
                              // Text layer
                              Text(
                                "+ $totalXP XP",
                                style: TextStyle(
                                  fontFamily: 'Fredoka One',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Words Completed Container with Fredoka One font and stroke
                      Container(
                        width: 220,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.blue.shade600, width: 2),
                        ),
                        child: Center(
                          child: Stack(
                            children: [
                              // Stroke layer
                              Text(
                                "+ $correctlyPronouncedWords Words",
                                style: TextStyle(
                                  fontFamily: 'Fredoka One',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 2
                                    ..color = Colors.black,
                                ),
                              ),
                              // Text layer
                              Text(
                                "+ $correctlyPronouncedWords Words",
                                style: TextStyle(
                                  fontFamily: 'Fredoka One',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Updated buttons with new styling
                _buildButton("PLAY AGAIN", () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Game1()),
                  );
                }),

                const SizedBox(height: 16),

                _buildButton("MAIN MENU", () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const StartPage()),
                  );
                }),

                const SizedBox(height: 16),

                _buildButton("GAME CENTER", () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const StartPage()),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    // Using a lighter icy blue color based on your original 0xFF0E3955
    final Color buttonColor = const Color(0xFF235A82); // Lighter icy blue
    final Color shadowColor =
        const Color(0xFF0E3955); // Original darker blue for shadow

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24), // Matching original radius
      child: Container(
        width: 200, // Original fixed width
        height: 60, // Original fixed height
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(24), // Matching original radius
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 3), // Fixed shadow offset
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 20, // Original fixed font size
              fontFamily: "Fredoka One", // Updated font
              fontWeight: FontWeight.w600, // Matching original weight
            ),
          ),
        ),
      ),
    );
  }
}
