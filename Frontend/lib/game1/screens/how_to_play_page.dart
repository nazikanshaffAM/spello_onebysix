import 'package:flutter/material.dart';

class HowtoPlayPage extends StatelessWidget {
  const HowtoPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive UI
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    // Responsive font sizing
    final double titleFontSize =
        screenWidth * 0.08 > 32 ? 32 : screenWidth * 0.08;
    final double headingFontSize =
        screenWidth * 0.05 > 22 ? 22 : screenWidth * 0.05;
    final double bodyFontSize =
        screenWidth * 0.04 > 16 ? 16 : screenWidth * 0.04;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/b5.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF235A82),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0E3955),
                          offset: const Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                // Title with the same styling as in other pages
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E3955).withOpacity(0.9),
                      border: Border.all(
                        color: const Color(0xFF0E3955),
                        width: screenWidth * 0.01 > 4 ? 4 : screenWidth * 0.01,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF00F96B), // Green
                          Color(0xFF00BCD4), // Cyan
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'How To Play',
                        style: TextStyle(
                          fontFamily: 'Fredoka One',
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              color: Colors.black38,
                              offset: Offset(2, 2),
                              blurRadius: 3,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                // Game rules content updated for the speech therapy game concept
                _buildSection(
                  context,
                  "Game Objective",
                  "Help aliens return to their spaceship by pronouncing words correctly! The better your pronunciation, the higher the alien will be beamed up.",
                  headingFontSize,
                  bodyFontSize,
                ),

                _buildSection(
                  context,
                  "How to Play",
                  "1. A word appears on the screen\n2. Tap the microphone button to start speaking\n3. Pronounce the word clearly\n4. Watch the alien get beamed up based on your accuracy",
                  headingFontSize,
                  bodyFontSize,
                ),

                _buildSection(
                  context,
                  "Scoring System",
                  "• 75% or higher accuracy: The alien is successfully beamed up\n• Below 75% accuracy: The alien rises slightly but falls back down\n• Each failed attempt costs one life\n• You have 3 lives per game",
                  headingFontSize,
                  bodyFontSize,
                ),

                _buildSection(
                  context,
                  "Game Progression",
                  "• Words become more challenging as you advance\n• Successfully beam up multiple aliens to complete a level\n• Higher pronunciation accuracy earns more points\n• Try to beat your high score with each playthrough!",
                  headingFontSize,
                  bodyFontSize,
                ),

                _buildSection(
                  context,
                  "Tips",
                  "• Speak clearly into your device's microphone\n• Find a quiet environment for better recognition\n• Practice difficult words between games\n• Watch the beam strength to gauge your accuracy",
                  headingFontSize,
                  bodyFontSize,
                ),

                SizedBox(height: screenHeight * 0.03),

                // "Start Speaking!" button
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 200,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF235A82),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0E3955),
                            offset: const Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "START SPEAKING!",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                            fontFamily: "Fredoka One",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content,
      double headingSize, double bodySize) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E3955).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00BCD4).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 24,
                width: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00F96B), Color(0xFF00BCD4)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Fredoka One',
                  fontSize: headingSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'Fredoka', // Changed from default to Fredoka
              fontSize: bodySize,
              fontWeight: FontWeight.bold, // Added bold weight
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
