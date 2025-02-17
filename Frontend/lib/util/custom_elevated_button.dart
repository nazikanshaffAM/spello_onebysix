import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final double buttonLength;
  final double buttonHeight;
  final String buttonName;
  final int primaryColor;
  final int shadowColor;
  final Color textColor; // Text color parameter
  final VoidCallback onPressed; // Function callback for button press

  const CustomElevatedButton({
    super.key,
    required this.buttonLength,
    required this.buttonHeight,
    required this.buttonName,
    required this.primaryColor,
    required this.shadowColor,
    required this.textColor,
    required this.onPressed, // Required onPressed function
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width for calculating a responsive font size
    final screenWidth = MediaQuery.of(context).size.width;
    // For example, set the font size to 4% of the screen width
    final double responsiveFontSize = screenWidth * 0.04;

    return Container(
      width: buttonLength,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: Color(primaryColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(shadowColor),
            offset: const Offset(0, 5),
            blurRadius: 0,
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed, // Calls the passed function
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          buttonName,
          style: TextStyle(
            color: textColor, // Use the parameter here
            fontSize: responsiveFontSize,
            fontFamily: "Fredoka", // Custom font family
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
