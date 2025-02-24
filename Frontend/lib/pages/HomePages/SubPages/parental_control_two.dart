import 'package:flutter/material.dart';
import 'package:spello_frontend/util/added_word_tile.dart';
import '../../../util/add_word_dialogbox.dart';

class ParentalControlTwo extends StatefulWidget {
  const ParentalControlTwo({super.key});

  @override
  State<ParentalControlTwo> createState() => _ParentalControlTwoState();
}

class _ParentalControlTwoState extends State<ParentalControlTwo> {
  final TextEditingController _controller = TextEditingController();
  final List<List<dynamic>> wordList = []; // Stores added words

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void saveNewWord() {
    String newWord = _controller.text.trim();
    if (newWord.isNotEmpty && RegExp(r'^\S+$').hasMatch(newWord)) {
      setState(() {
        wordList.add([newWord]);
      });
      _controller.clear();
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop();
    }
  }

  void addNewWord() {
    if (wordList.length >= 5) {
      // Show the snackbar only if the disabled button is clicked
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Maximum of 5 words reached.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AddWordDialogbox(
          controller: _controller,
          onSave: saveNewWord,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  void deleteWord(int index) {
    setState(() {
      wordList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    bool isLimitReached = wordList.length >= 5;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF8092CC),
      appBar: AppBar(
        title: Text(
          "Parental Control",
          style: TextStyle(
              fontFamily: "Fredoka One", fontSize: screenWidth * 0.07),
        ),
        backgroundColor: Color(0xFF3A435F),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          right: screenWidth * 0.02,
          bottom: screenHeight * 0.03,
        ),
        child: FloatingActionButton(
          backgroundColor: isLimitReached
              ? const Color(0xFFB0B0B0)
              : const Color(0xFFFFC000),
          foregroundColor: Colors.white,
          onPressed: addNewWord,
          child: Icon(
            Icons.add,
            size: screenWidth * 0.08,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            SizedBox(
              height: screenHeight * 0.02,
            ), // Heading
            Text(
              wordList.isEmpty
                  ? "No words, please Add a New word."
                  : "Added Words:",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                color: Colors.white,
                fontFamily: "Fredoka",
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            // Show an image if the list is empty
            if (wordList.isEmpty)
              Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.05,
                ),
                child: Center(
                  child: Image.asset(
                    "assets/images/parental_control_two.png",
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.4,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

            // List of added words
            if (wordList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: wordList.length,
                  itemBuilder: (context, index) {
                    return AddedWordTile(
                      taskName: wordList[index][0],
                      deleteFunction: (context) => deleteWord(index),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
