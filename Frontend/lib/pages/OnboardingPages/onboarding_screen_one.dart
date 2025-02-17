import 'package:flutter/material.dart';

class OnboardingScreenOne extends StatelessWidget {
  const OnboardingScreenOne({super.key});

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
            left: screenWidth * 0.09, // 25% from the left
            child: Text(
              "Welcome to Spello",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.09, // Scales with screen width
                  fontWeight: FontWeight.w700,
                  fontFamily: "Fredoka One"),
            ),
          ),
          // Star image positioned responsively
          Positioned(
            top: screenHeight * 0.14,
            left: screenWidth * 0.15,
            child: Image.asset(
              "assets/images/onboarding_screen_one.png",
              height: screenHeight * 0.5, // 40% of screen height
              width: screenWidth * 0.7, // 60% of screen width
            ),
          ),
          // Descriptive text positioned responsively
          Positioned(
            top: screenHeight * 0.57,
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            child: Text(
              "Practice pronunciation with fun\ngames and real-time feedback.\nLet's start your journey to \nclearer speech!",
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
