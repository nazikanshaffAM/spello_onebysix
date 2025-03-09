import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spello_frontend/util/added_word_tile.dart';
import 'package:spello_frontend/util/add_word_dialogbox.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ParentalControlTwo extends StatefulWidget {
  const ParentalControlTwo({super.key});

  @override
  State<ParentalControlTwo> createState() => _ParentalControlTwoState();
}

class _ParentalControlTwoState extends State<ParentalControlTwo> {
  final TextEditingController _controller = TextEditingController();
  final List<List<dynamic>> wordList = [];
  final GlobalKey _addButtonKey = GlobalKey();
  final GlobalKey _firstTileKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];
  final ScrollController _scrollController =
      ScrollController(); // Add ScrollController

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose(); // Dispose the ScrollController
    super.dispose();
  }

  Future<void> _checkAndShowAddButtonTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool addButtonTutorialShown =
        prefs.getBool('addButtonTutorialShown') ?? false;
    if (!addButtonTutorialShown) {
      await prefs.setBool('addButtonTutorialShown', true);
      _showAddButtonTutorial();
    }
  }

  Future<void> _checkAndShowTileTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool tileTutorialShown = prefs.getBool('tileTutorialShown') ?? false;
    if (!tileTutorialShown) {
      await prefs.setBool('tileTutorialShown', true);
      _initTileTarget();
      _showTileTutorial();
    }
  }

  void saveNewWord() {
    String newWord = _controller.text.trim();
    if (newWord.isNotEmpty && RegExp(r'^\S+$').hasMatch(newWord)) {
      setState(() {
        wordList.add([newWord]);
      });
      _controller.clear();
      Navigator.of(context).pop();
      if (wordList.length == 1) {
        _checkAndShowTileTutorial();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  void addNewWord() {
    if (wordList.length >= 5) {
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

  void _initAddButtonTarget() {
    targets = [
      TargetFocus(
        identify: "AddButton",
        keyTarget: _addButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: ContentAlign.top, // Always display below the target
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3A435F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Press the button to add a word for practice.",
                style: const TextStyle(
                  fontFamily: "Fredoka",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  void _initTileTarget() {
    targets = [
      TargetFocus(
        identify: "FirstTile",
        keyTarget: _firstTileKey,
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: ContentAlign.bottom, // Always display below the target
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3A435F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Swipe left to delete.",
                style: const TextStyle(
                  fontFamily: "Fredoka",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  void _showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color.fromRGBO(0, 0, 0, 0.8),
      paddingFocus: 8,
      onFinish: () => debugPrint("Tutorial finished"),
      onClickTarget: (target) =>
          debugPrint("Target clicked: ${target.identify}"),
      onClickOverlay: (target) =>
          debugPrint("Overlay clicked: ${target.identify}"),
    );
    tutorialCoachMark.show(context: context);

    // Scroll to reveal the delete part of the first tile
    if (wordList.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          100, // Adjust this value to reveal the delete part
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _showAddButtonTutorial() {
    _initAddButtonTarget();
    _showTutorial();
  }

  void _showTileTutorial() {
    _showTutorial();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowAddButtonTutorial();
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
            fontFamily: "Fredoka One",
            fontSize: screenWidth * 0.07,
          ),
        ),
        backgroundColor: const Color(0xFF3A435F),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          right: screenWidth * 0.02,
          bottom: screenHeight * 0.03,
        ),
        child: FloatingActionButton(
          key: _addButtonKey,
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
      body: Stack(
        children: [
          // Cloud Images
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.6,
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
            right: screenWidth * 0.7,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                "assets/images/cloud.png",
                width: screenWidth * 0.4,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.38,
            left: screenWidth * 0.33,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                "assets/images/cloud.png",
                width: screenWidth * 0.4,
              ),
            ),
          ),
          // Main Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
                Text(
                  wordList.isEmpty
                      ? "No words, please add a new word."
                      : "Added Words:",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    color: Colors.white,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (wordList.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.05),
                    child: Center(
                      child: Image.asset(
                        "assets/images/parental_control_two.png",
                        width: screenWidth * 0.6,
                        height: screenHeight * 0.4,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                if (wordList.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController, // Add ScrollController
                      itemCount: wordList.length,
                      itemBuilder: (context, index) {
                        final tileKey = index == 0 ? _firstTileKey : null;
                        return AddedWordTile(
                          key: tileKey,
                          taskName: wordList[index][0],
                          deleteFunction: (context) => deleteWord(index),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
