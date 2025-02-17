import 'package:flutter/material.dart';

class OnboardingScreenThree extends StatelessWidget {
  const OnboardingScreenThree({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // "Speak & Play" text positioned using percentages
          Positioned(
            top: screenHeight * 0.12, // 10% from the top
            left: screenWidth * 0.052, // 25% from the left
            child: Text(
              "Track your progress",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.09, // Scales with screen width
                  fontWeight: FontWeight.w700,
                  fontFamily: "Fredoka One"),
            ),
          ),
          // Star image positioned responsively
          Positioned(
            top: screenHeight * 0.18,
            left: screenWidth * 0.13,
            child: Image.asset(
              "assets/images/clipboard.png",
              height: screenHeight * 0.4, // 40% of screen height
              width: screenWidth * 0.5, // 60% of screen width
            ),
          ),
          Positioned(
            top: screenHeight * 0.002,
            left: screenWidth * 0.23,
            child: Image.asset(
              "assets/images/onboarding_screen_three.png",
              height: screenHeight * 0.8, // 40% of screen height
              width: screenWidth * 0.9, // 60% of screen width
            ),
          ),

          // Descriptive text positioned responsively
          Positioned(
            top: screenHeight * 0.57,
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            child: Text(
              "Monitor your improvement with\naccuracy scores and feedback.\n Keep practicing and level up your\nSpeech skills!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.05, // Responsive font size
                  fontWeight: FontWeight.bold,
                  fontFamily: "Fredoka"),
            ),
          ),
        ],
      ),
    );
  }
}
