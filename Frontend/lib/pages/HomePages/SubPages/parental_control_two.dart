import 'package:flutter/material.dart';
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
  final List<List<dynamic>> wordList = []; // Stores added words

  // GlobalKey for the add button (floating action button)
  final GlobalKey _addButtonKey = GlobalKey();
  // GlobalKey for the first added word tile
  final GlobalKey _firstTileKey = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

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
      // Show tile tutorial for the first added word if it's the first word.
      if (wordList.length == 1) {
        _initTileTarget();
        _showTileTutorial();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  void addNewWord() {
    if (wordList.length >= 5) {
      // Show a snackbar if maximum limit reached.
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

  // Initialize the tutorial targets for the add button.
  void _initAddButtonTarget() {
    targets = [
      TargetFocus(
        identify: "AddButton",
        keyTarget: _addButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: ContentAlign.top,
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
        ],
      ),
    ];
  }

  // Initialize the target for the first added tile.
  void _initTileTarget() {
    targets = [
      TargetFocus(
        identify: "FirstTile",
        keyTarget: _firstTileKey,
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
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
        ],
      ),
    ];
  }

  void _showTutorial({bool forAddButton = true}) {
    if (forAddButton) {
      _initAddButtonTarget();
    }
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color.fromRGBO(0, 0, 0, 0.8),
      textSkip: "SKIP",
      paddingFocus: 8,
      onFinish: () {
        debugPrint("Tutorial finished");
      },
      onClickTarget: (target) {
        debugPrint("Target clicked: ${target.identify}");
      },
      onClickOverlay: (target) {
        debugPrint("Overlay clicked: ${target.identify}");
      },
    );
    tutorialCoachMark.show(context: context);
  }

  // Convenience: Show add button tutorial.
  void _showAddButtonTutorial() {
    _showTutorial(forAddButton: true);
  }

  // Convenience: Show tile tutorial.
  void _showTileTutorial() {
    _showTutorial(forAddButton: false);
  }

  @override
  void initState() {
    super.initState();
    // Show add button tutorial after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAddButtonTutorial();
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
      body: Padding(
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
            if (wordList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: wordList.length,
                  itemBuilder: (context, index) {
                    // For the first tile, attach the _firstTileKey
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
    );
  }
}
