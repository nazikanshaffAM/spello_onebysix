import 'package:flutter/material.dart';
import 'package:spello_frontend/util/custom_elevated_button.dart';

class AddWordDialogbox extends StatefulWidget {
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
  State<AddWordDialogbox> createState() => _AddWordDialogboxState();
}

class _AddWordDialogboxState extends State<AddWordDialogbox> {
  String _errorMessage = ''; // To store the error message

  void _validateAndSave() {
    final input = widget.controller.text.trim();

    // Check if the input contains more than one word
    if (input.split(' ').length > 1) {
      setState(() {
        _errorMessage =
            'Please enter only one word at a time.'; // Error message
      });
    } else if (input.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a word.'; // Error message for empty input
      });
    } else {
      setState(() {
        _errorMessage = ''; // Clear error message if input is valid
      });
      widget.onSave(); // Call the onSave callback
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery for responsive sizing.
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor:
          const Color(0xFF5A6C81), // Three shades lighter than dark blue.
      content: SizedBox(
        height: screenHeight *
            0.25, // Increased height to accommodate error message
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              controller: widget.controller,
              style: const TextStyle(
                color: Color(0xFF3A435F), // Input text color
                fontFamily: "Fredoka One",
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white, // TextField background is white
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12), // Small border radius
                ),
                hintText: "Add a new Word",
                hintStyle: const TextStyle(
                  color: Color(0xFF3A435F), // Hint text color
                  fontFamily: "Fredoka",
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_errorMessage.isNotEmpty) // Display error message if not empty
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.01),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: Colors.red, // Error message color
                    fontFamily: "Fredoka One",
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.008),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomElevatedButton(
                    buttonLength: screenWidth * 0.3,
                    buttonHeight: screenHeight * 0.05,
                    buttonName: "Cancel",
                    primaryColor: 0xFFFFC000,
                    shadowColor: 0xFFD29338,
                    textColor: Colors.white,
                    onPressed: widget.onCancel,
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  CustomElevatedButton(
                    buttonLength: screenWidth * 0.3, // responsive button width
                    buttonHeight:
                        screenHeight * 0.05, // responsive button height
                    buttonName: "Save",
                    primaryColor: 0xFFFFC000,
                    shadowColor: 0xFFD29338,
                    textColor: Colors.white,
                    onPressed: _validateAndSave, // Use the validation function
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
