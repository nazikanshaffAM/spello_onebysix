import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spello_frontend/util/custom_elevated_button.dart';
import 'package:spello_frontend/util/parental_control_tile.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ParentalControlOne extends StatefulWidget {
  const ParentalControlOne({super.key});

  @override
  State<ParentalControlOne> createState() => _ParentalControlOneState();
}

class _ParentalControlOneState extends State<ParentalControlOne> {
  bool parentalToggle = false;
  final GlobalKey _patTileKey = GlobalKey();
  final GlobalKey _applyButtonKey = GlobalKey();
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initTargets();
      bool tutorialShown = await _getTutorialShown();
      if (!tutorialShown) {
        _showTutorial();
        _setTutorialShown();
      }
    });
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      parentalToggle = prefs.getBool('parentalToggle') ?? false;
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('parentalToggle', parentalToggle);
  }

  Future<bool> _getTutorialShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorialShown') ?? false;
  }

  Future<void> _setTutorialShown() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('tutorialShown', true);
  }

  void _initTargets() {
    targets = [
      TargetFocus(
        identify: "PatTile",
        keyTarget: _patTileKey,
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Text(
              "Click the tile to allocate the sound for practice.",
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
      TargetFocus(
        identify: "ApplyButton",
        keyTarget: _applyButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Text(
              "Click 'Apply' to apply the selected sounds.",
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

  void _showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color.fromRGBO(0, 0, 0, 0.8),
      textSkip: "SKIP",
      paddingFocus: 8,
      onFinish: () => debugPrint("Tutorial finished"),
      onClickTarget: (target) =>
          debugPrint("Target clicked: \${target.identify}"),
      onClickOverlay: (target) =>
          debugPrint("Overlay clicked: \${target.identify}"),
    );
    tutorialCoachMark.show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
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
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.bold,
                fontFamily: "Fredoka",
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: List.generate(
                21,
                (index) => ControlPanelTiles(
                  tileName: _getTileName(index),
                  isLocked: index >= 6,
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          CustomElevatedButton(
            key: _applyButtonKey,
            buttonLength: screenWidth * 0.7,
            buttonHeight: screenHeight * 0.055,
            buttonName: "Apply",
            primaryColor: 0xFFFFC000,
            shadowColor: 0xFFD29338,
            textColor: Colors.white,
            onPressed: () {
              _savePreferences();
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
