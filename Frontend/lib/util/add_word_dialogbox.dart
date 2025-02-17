import 'package:flutter/material.dart';
import 'package:spello_frontend/util/custom_elevated_button.dart';

class AddWordDialogbox extends StatelessWidget {
  AddWordDialogbox({
    super.key,
    required this.controller,
    required this.onCancel,
    required this.onSave,
  });

  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery for responsive sizing.
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor:
          const Color(0xFF5A6C81), // Three shades lighter than dark blue.
      content: SizedBox(
        height: screenHeight * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              controller: controller,
              style: const TextStyle(
                color: Color(0xFF3A435F), // Input text color
                fontFamily: "Fredoka One",
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white, // TextField background is white
                border: const OutlineInputBorder(),
                hintText: "Add a new Word",
                hintStyle: const TextStyle(
                    color: Color(0xFF3A435F), // Hint text color
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomElevatedButton(
                    buttonLength: screenWidth * 0.29, // responsive button width
                    buttonHeight:
                        screenHeight * 0.05, // responsive button height
                    buttonName: "Save",
                    primaryColor: 0xFFFFC000,
                    shadowColor: 0xFFD29338,
                    textColor: Colors.white,
                    onPressed: onSave,
                  ),
                  SizedBox(width: screenWidth * 0.05),
                  CustomElevatedButton(
                    buttonLength: screenWidth * 0.29,
                    buttonHeight: screenHeight * 0.05,
                    buttonName: "Cancel",
                    primaryColor: 0xFFFFC000,
                    shadowColor: 0xFFD29338,
                    textColor: Colors.white,
                    onPressed: onCancel,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
