import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/parental_control.dart';
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
      final screenWidth = MediaQuery.of(context).size.width;
      _initTargets(screenWidth);
      bool tutorialShown = await _getTutorialShown();
      if (!tutorialShown) {
        _showTutorial();
        await _setTutorialShown();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

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
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              children: List.generate(
                21,
                (index) => ControlPanelTiles(
                  key: index == 0
                      ? _patTileKey
                      : null, // Assign key to the first tile
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ParentalControl()));
              }),
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
