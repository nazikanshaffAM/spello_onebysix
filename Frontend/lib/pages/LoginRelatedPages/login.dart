//its without main have to change and make apath to show this first

import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Get the screen size

    return Scaffold(
      backgroundColor: Color(0xFF91A3E2), // Light purple background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 20), // Moves the text up
              child: Text(
                "Hello From Spello!",
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontFamily: 'Fredoka One', // Use Fredericka font
                ),
              ),
            ),
            // Spaceman on Rocket Image
            Image.asset(
              'assets/images/astronaut.png', // Add your own asset in the "assets" folder
              width: size.width * 0.9, // Responsive width
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 40),
            // Google Login Button
            LoginButton(
              text: "Login with Google",
              icon:
                  "assets/images/google.png", // Replace with Google icon asset
              color: Colors.white,
              textColor: Colors.black,
              textStyle: TextStyle(
                fontFamily: 'Fredoka', // Use Fredoka font
                fontWeight: FontWeight.bold, // Make text bold
              ),
            ),

            const SizedBox(height: 20),
            // Apple Login Button
            LoginButton(
              text: "Login with Facebook",
              icon:
                  "assets/images/google.png", // Replace with Google icon asset
              color: Color(0xFF313FFF),
              textColor: Colors.black,
              textStyle: TextStyle(
                fontFamily: 'Fredoka', // Use Fredoka font
                fontWeight: FontWeight.bold, // Make text bold
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final String text;
  final String icon;
  final Color color;
  final Color textColor;

  const LoginButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.textColor,
    required TextStyle textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // Get the screen size

    return Container(
      width: size.width * 0.8, // Responsive width
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(icon, width: 24), // Icon Image
              const SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
