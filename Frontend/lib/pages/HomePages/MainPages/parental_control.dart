import 'package:flutter/material.dart';
import 'package:spello_frontend/pages/HomePages/SubPages/parental_control_one.dart';
import 'package:spello_frontend/pages/HomePages/SubPages/parental_control_two.dart';
import 'package:spello_frontend/util/custom_elevated_button.dart';

class ParentalControl extends StatefulWidget {
  const ParentalControl({super.key});

  @override
  State<ParentalControl> createState() => _ParentalControlState();
}

class _ParentalControlState extends State<ParentalControl> {
  @override
  Widget build(BuildContext context) {
    // Retrieve screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Parental Control',
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Fredoka One",
              fontSize: screenWidth * 0.09,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF373E58),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.05),

            // Top text
            Padding(
              padding: EdgeInsets.only(
                top: screenWidth * 0.04,
                left: screenWidth * 0.04,
                right: screenWidth * 0.04,
              ),
              child: Text(
                "Customize the learning experience\nby selecting sounds or words that\nmatch your child's speech goals.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.05, // Increased text size
                  fontWeight: FontWeight.bold,
                  fontFamily: "Fredoka",
                ),
              ),
            ),

            // Image
            Image.asset(
              "assets/images/parental_control_one.png",
              height: screenHeight * 0.4, // 40% of screen height
              width: screenWidth * 0.7,
              fit: BoxFit.contain,
            ),

            // Buttons
            Column(
              children: [
                CustomElevatedButton(
                  buttonLength: screenWidth * 0.8,
                  buttonHeight: 50,
                  buttonName: "Sounds",
                  primaryColor: 0xFFFFC000,
                  shadowColor: 0xFFD29338,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ParentalControlOne()),
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                CustomElevatedButton(
                  buttonLength: screenWidth * 0.8,
                  buttonHeight: 50,
                  buttonName: "Words",
                  primaryColor: 0xFFFFC000,
                  shadowColor: 0xFFD29338,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ParentalControlTwo()),
                    );
                    // Button action for Words
                  },
                ),
              ],
            ),

            // Optional bottom spacing
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}
