import 'package:flutter/material.dart';

class OnboardingScreenOne extends StatelessWidget {
  final Map<String, dynamic> userData;
  
  const OnboardingScreenOne({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    // Debug print to verify data is received
    print('OnboardingScreenOne received userData: $userData');
    
    // Get user's name with a fallback value
    final String userName = userData['name'] ?? 'Friend';
    
    // Retrieve screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Cloud images
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                "assets/images/cloud.png",
                width: screenWidth * 0.4,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.2,
            left: screenWidth * 0.8,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                "assets/images/cloud.png",
                width: screenWidth * 0.4,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.4,
            left: screenWidth * 0,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                "assets/images/cloud.png",
                width: screenWidth * 0.4,
              ),
            ),
          ),
          
          // Welcome text with user's name
          Positioned(
            top: screenHeight * 0.12,
            left: screenWidth * 0.09,
            child: Text(
              'Welcome, $userName!', 
              style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.09,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Fredoka One"),
            ),
          ),
          
          // Main image
          Positioned(
            top: screenHeight * 0.14,
            left: screenWidth * 0.15,
            child: Image.asset(
              "assets/images/onboarding_screen_one.png",
              height: screenHeight * 0.5,
              width: screenWidth * 0.7,
            ),
          ),
          
          // Description text
          Positioned(
            top: screenHeight * 0.57,
            left: screenWidth * 0.1,
            right: screenWidth * 0.1,
            child: Text(
              "Practice pronunciation with fun\ngames and real-time feedback.\nLet's start your journey to \nclearer speech!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Fredoka"),
            ),
          ),
        ],
      ),
    );
  }
}