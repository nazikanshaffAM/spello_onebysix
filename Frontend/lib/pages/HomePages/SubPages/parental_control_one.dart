import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/parental_control.dart';
import 'package:spello_frontend/util/custom_elevated_button.dart';
import 'package:spello_frontend/util/parental_control_tile.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:spello_frontend/config/config.dart';

class ParentalControlOne extends StatefulWidget {
  // Add userData parameter
  final Map<String, dynamic> userData;

  // Update constructor to require userData
  const ParentalControlOne({super.key, required this.userData});

  @override
  State<ParentalControlOne> createState() => _ParentalControlOneState();
}

class _ParentalControlOneState extends State<ParentalControlOne> {
  bool parentalToggle = false;
  final GlobalKey _patTileKey = GlobalKey();
  final GlobalKey _applyButtonKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  // Track selected sounds
  List<bool> selectedSounds = List.generate(21, (index) => false);
  bool isLoading = false;
  String errorMessage = '';
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadSelectedSounds();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final screenWidth = MediaQuery.of(context).size.width;
      _initTargets(screenWidth);
      bool tutorialShown = await _getTutorialShown();
      if (!tutorialShown) {
        _showTutorial();
        await _setTutorialShown();
      }
    });
  }

  // Load previously selected sounds from the backend
  Future<void> _loadSelectedSounds() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/get_user?email=${widget.userData['email']}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Loaded user data: $data");
        
        // If the user has selected sounds stored, update the UI
        if (data.containsKey('selected_sounds')) {
          List<dynamic> selectedSoundLetters = data['selected_sounds'];
          print("Loaded selected sounds: $selectedSoundLetters");
          
          // Clear current selections
          List<bool> newSelections = List.generate(21, (index) => false);
          
          // Convert the letters to indices
          for (String letter in selectedSoundLetters) {
            int index = _getSoundIndexFromLetter(letter);
            if (index >= 0 && index < 21) {
              newSelections[index] = true;
              print("Setting selection for letter $letter at index $index");
            }
          }
          
          setState(() {
            selectedSounds = newSelections;
            print("Updated selectedSounds array: $selectedSounds");
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load sounds: Server error';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Get index of a sound based on its letter
  int _getSoundIndexFromLetter(String letter) {
    letter = letter.toLowerCase();
    Map<String, int> letterToIndex = {
      'p': 0,
      'b': 1,
      't': 2,
      'd': 3,
      'k': 4,
      'g': 5,
      'm': 6,
      'n': 7,
      'ng': 8,
      'f': 9,
      'v': 10,
      's': 11,
      'z': 12,
      'sh': 13,
      'zh': 14,
      'l': 15,
      'r': 16,
      'th': 17, // Note: There are two TH sounds at 17 and 18
      'h': 19,
      'ch': 20
    };
    
    return letterToIndex[letter] ?? -1;
  }

  // Get letter for a sound index
  String _getLetterFromSoundIndex(int index) {
    List<String> indexToLetter = [
      'p',   // 0: P (pat)
      'b',   // 1: B (bat)
      't',   // 2: T (top)
      'd',   // 3: D (dog)
      'k',   // 4: K (cat)
      'g',   // 5: G (go)
      'm',   // 6: M (man)
      'n',   // 7: N (net)
      'ng',  // 8: NG (sing)
      'f',   // 9: F (fan)
      'v',   // 10: V (van)
      's',   // 11: S (sun)
      'z',   // 12: Z (zoo)
      'sh',  // 13: SH (shoe)
      'zh',  // 14: ZH (measure)
      'l',   // 15: L (lamp)
      'r',   // 16: R (red)
      'th',  // 17: TH (thin)
      'th',  // 18: TH (this)
      'h',   // 19: H (hat)
      'ch'   // 20: CH (chip)
    ];
    
    if (index >= 0 && index < indexToLetter.length) {
      return indexToLetter[index];
    }
    return '';
  }

  // Save selected sounds to the backend
  Future<void> _saveSelectedSounds() async {
    // Check if any sounds are selected
    bool anySelected = selectedSounds.contains(true);
    if (!anySelected) {
      setState(() {
        errorMessage = 'Please select at least one sound';
      });
      return;
    }
    
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      // Get list of selected sounds as letters
      List<String> selectedSoundLetters = [];
      
      for (int i = 0; i < selectedSounds.length; i++) {
        if (selectedSounds[i]) {
          String letter = _getLetterFromSoundIndex(i);
          if (letter.isNotEmpty) {
            selectedSoundLetters.add(letter);
          }
        }
      }
      
      print("Selected sound letters: $selectedSoundLetters");
      print("Request body: ${jsonEncode({
        'email': widget.userData['email'],
        'selected_sounds': selectedSoundLetters,
      })}");

      // Send selected sounds to backend
      final response = await http.post(
       Uri.parse('${Config.baseUrl}/update_selected_sounds'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': widget.userData['email'],
          'selected_sounds': selectedSoundLetters,
        }),
      );

      if (response.statusCode == 200) {
        // Success - navigate back to parental control
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ParentalControl(
              userData: widget.userData,
            ),
          ),
        );
      } else {
        setState(() {
          errorMessage = 'Failed to save sounds: Server error';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      parentalToggle = prefs.getBool('parentalToggle') ?? false;
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('parentalToggle', parentalToggle);
  }

  Future<bool> _getTutorialShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorialShown') ?? false;
  }

  Future<void> _setTutorialShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorialShown', true);
  }

  void _initTargets(double screenWidth) {
    targets = [
      TargetFocus(
        identify: "PatTile",
        keyTarget: _patTileKey,
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
                "Click the tile to allocate the sound for practice.",
                style: TextStyle(
                  fontFamily: "Fredoka",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: screenWidth * 0.045,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "ApplyButton",
        keyTarget: _applyButtonKey,
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
                "Click 'Apply' to apply the selected sounds.",
                style: TextStyle(
                  fontFamily: "Fredoka",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: screenWidth * 0.045,
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
  }

  // Handle tile selection change
  void _handleSelectionChange(int index, bool isSelected) {
    setState(() {
      selectedSounds[index] = isSelected;
      hasChanges = true;
      print("Selection changed at index $index to $isSelected");
      print("Updated selections: $selectedSounds");
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    
    print("Building ParentalControlOne - selectedSounds: $selectedSounds");
    
    // Count selected sounds
    final int selectedCount = selectedSounds.where((isSelected) => isSelected).length;

    return Scaffold(
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
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.03),
          Center(
            child: Text(
              "Select the appropriate sounds",
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.055 * textScaleFactor,
                fontWeight: FontWeight.bold,
                fontFamily: "Fredoka",
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          
          // Selected sounds counter
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: 8,
            ),
            child: Text(
              "Selected sounds: $selectedCount",
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.045 * textScaleFactor,
                fontFamily: "Fredoka",
              ),
            ),
          ),
          
          // Error message display
          if (errorMessage.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: 8,
              ),
              margin: EdgeInsets.only(bottom: 16),
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
            
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    children: List.generate(
                      21,
                      (index) => ControlPanelTiles(
                        key: index == 0 ? _patTileKey : null,
                        tileName: _getTileName(index),
                        isLocked: index >= 6 && !selectedSounds[index], // Locked if index >= 6 and not selected
                        isSelected: selectedSounds[index],
                        onSelectionChanged: (isSelected) => _handleSelectionChange(index, isSelected),
                      ),
                    ),
                  ),
          ),
          SizedBox(height: screenHeight * 0.02),
          CustomElevatedButton(
              key: _applyButtonKey,
              buttonLength: screenWidth * 0.7,
              buttonHeight: screenHeight * 0.055,
              buttonName: isLoading ? "Saving..." : "Apply",
              primaryColor: (isLoading || !hasChanges) ? 0xFFAAAAAA : 0xFFFFC000,
              shadowColor: 0xFFD29338,
              textColor: Colors.white,
              onPressed: () {
                if (!isLoading && hasChanges) {
                  _saveSelectedSounds();
                } else if (!hasChanges) {
                  // Show message if no changes made
                  setState(() {
                    errorMessage = 'No changes to apply';
                  });
                }
              },
          ),
          SizedBox(height: screenHeight * 0.03),
        ],
      ),
    );
  }

  String _getTileName(int index) {
    List<String> sounds = [
      "P (pat)",
      "B (bat)",
      "T (top)",
      "D (dog)",
      "K (cat)",
      "G (go)",
      "M (man)",
      "N (net)",
      "NG (sing)",
      "F (fan)",
      "V (van)",
      "S (sun)",
      "Z (zoo)",
      "SH (shoe)",
      "ZH (measure)",
      "L (lamp)",
      "R (red)",
      "TH (thin)",
      "TH (this)",
      "H (hat)",
      "CH (chip)"
    ];
    return sounds[index];
  }
}