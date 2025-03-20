import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spello_frontend/util/added_word_tile.dart';
import 'package:spello_frontend/util/add_word_dialogbox.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:spello_frontend/config/config.dart';

class ParentalControlTwo extends StatefulWidget {
  // Add userData parameter
  final Map<String, dynamic> userData;

  // Update constructor to require userData
  const ParentalControlTwo({super.key, required this.userData});

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
  final ScrollController _scrollController = ScrollController();

  bool isLoading = false;
  String errorMessage = '';

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchCustomWords();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowAddButtonTutorial();
    });
  }

  // Fetch custom words from the backend
  Future<void> _fetchCustomWords() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      wordList.clear();
    });

    try {
      // Use email as a query parameter like in the working solutions
      // Change this line in all API calls
      final url = Uri.parse(
          '${Config.baseUrl}/get_user?email=${widget.userData['email']}');
      print("Fetching custom words from: $url");

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print("Fetch response status: ${response.statusCode}");
      print("Fetch response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check if user has custom words
        if (data.containsKey('custom_words')) {
          List<dynamic> customWords = data['custom_words'];
          print("Loaded custom words: $customWords");
          setState(() {
            for (var word in customWords) {
              // Ensure word is treated as a string
              String wordStr = word.toString();
              wordList.add([wordStr]);
            }
          });
          print("Updated wordList: $wordList");
        } else {
          print("No custom words found in response");
        }
      } else {
        setState(() {
          errorMessage =
              'Failed to load words: Server error (${response.statusCode})';
        });
      }
    } catch (e) {
      print("Error fetching custom words: $e");
      setState(() {
        errorMessage = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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

  // Modified to save to backend
  Future<void> saveNewWord() async {
    String newWord = _controller.text.trim();
    if (newWord.isEmpty || !RegExp(r'^\S+$').hasMatch(newWord)) {
      Navigator.of(context).pop();
      return;
    }

    // Close the dialog first
    Navigator.of(context).pop();

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Send request to backend to add custom word
      // Using query parameter for email instead of relying on session
      final url = Uri.parse(
          '${Config.baseUrl}/add-custom-word?email=${widget.userData['email']}');
      print("Making request to: $url");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'custom_word': newWord,
        }),
      );

      print("Add word response status: ${response.statusCode}");
      print("Add word response body: ${response.body}");

      if (response.statusCode == 200) {
        // Add word to local list if successful
        setState(() {
          wordList.add([newWord]);
        });
        _controller.clear();
        if (wordList.length == 1) {
          _checkAndShowTileTutorial();
        }
      } else {
        String errorMsg = 'Failed to add word: Server error';
        try {
          final responseData = jsonDecode(response.body);
          errorMsg = responseData['error'] ?? errorMsg;
        } catch (e) {
          print("Error parsing response JSON: $e");
        }

        setState(() {
          errorMessage = errorMsg;
        });
      }
    } catch (e) {
      print("Error adding custom word: $e");
      setState(() {
        errorMessage = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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

  // Modified to delete from backend
  Future<void> deleteWord(int index) async {
    final wordToDelete = wordList[index][0];

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Send request to backend to remove custom word
      // Using query parameter for email instead of relying on session
      final url = Uri.parse(
          '${Config.baseUrl}/remove-custom-word?email=${widget.userData['email']}');
      print("Making delete request to: $url");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'custom_word': wordToDelete,
        }),
      );

      print("Delete word response status: ${response.statusCode}");
      print("Delete word response body: ${response.body}");

      if (response.statusCode == 200) {
        // Remove from local list if successful
        setState(() {
          wordList.removeAt(index);
        });
      } else {
        String errorMsg = 'Failed to remove word: Server error';
        try {
          final responseData = jsonDecode(response.body);
          errorMsg = responseData['error'] ?? errorMsg;
        } catch (e) {
          print("Error parsing response JSON: $e");
        }

        setState(() {
          errorMessage = errorMsg;
        });
      }
    } catch (e) {
      print("Error removing custom word: $e");
      setState(() {
        errorMessage = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
              child: const Text(
                "Press the button to add a word for practice.",
                style: TextStyle(
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
              child: const Text(
                "Swipe left to delete.",
                style: TextStyle(
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
          backgroundColor: isLimitReached || isLoading
              ? const Color(0xFFB0B0B0)
              : const Color(0xFFFFC000),
          foregroundColor: Colors.white,
          onPressed: isLoading || isLimitReached ? null : addNewWord,
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
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
                    fontSize: screenWidth * 0.045,
                    color: Colors.white,
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Error message display
                if (errorMessage.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: 8,
                    ),
                    margin: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: TextStyle(color: Colors.red.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (isLoading && wordList.isEmpty)
                  Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (wordList.isEmpty)
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
                      controller: _scrollController,
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
