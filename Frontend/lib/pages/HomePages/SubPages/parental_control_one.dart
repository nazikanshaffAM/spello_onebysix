import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:spello_frontend/util/custom_elevated_button.dart';
import 'package:spello_frontend/util/parental_control_tile.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ParentalControlOne extends StatefulWidget {
  const ParentalControlOne({super.key});

  @override
  State<ParentalControlOne> createState() => _ParentalControlOneState();
}

class _ParentalControlOneState extends State<ParentalControlOne> {
  bool parentalToggle = false; // Holds the state of the toggle switch

  // Create GlobalKeys for the two elements to be highlighted.
  final GlobalKey _patTileKey = GlobalKey();
  final GlobalKey _applyButtonKey = GlobalKey();

  // Tutorial Coach Mark instance and targets list.
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  @override
  void initState() {
    super.initState();
    // Schedule the tutorial to run after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTargets();
      _showTutorial();
    });
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "PARENTAL CONTROL",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Fredoka One",
              fontSize: screenWidth * 0.06,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF3A435F),
      ),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.015),
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
          SizedBox(height: screenHeight * 0.015),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // Attach the GlobalKey to the first tile.
                ControlPanelTiles(
                  key: _patTileKey,
                  tileName: "P (pat)",
                  isLocked: false,
                ),
                ControlPanelTiles(
                  tileName: "B (bat)",
                  isLocked: false,
                ),
                ControlPanelTiles(
                  tileName: "T (top)",
                  isLocked: false,
                ),
                ControlPanelTiles(
                  tileName: "D (dog)",
                  isLocked: false,
                ),
                ControlPanelTiles(
                  tileName: "K (cat)",
                  isLocked: false,
                ),
                ControlPanelTiles(
                  tileName: "G (go)",
                  isLocked: true,
                ),
                ControlPanelTiles(tileName: "M (man)", isLocked: true),
                ControlPanelTiles(tileName: "N (net)", isLocked: true),
                ControlPanelTiles(tileName: "NG (sing)", isLocked: true),
                ControlPanelTiles(tileName: "F (fan)", isLocked: true),
                ControlPanelTiles(tileName: "V (van)", isLocked: true),
                ControlPanelTiles(tileName: "S (sun)", isLocked: true),
                ControlPanelTiles(tileName: "Z (zoo)", isLocked: true),
                ControlPanelTiles(tileName: "SH (shoe)", isLocked: true),
                ControlPanelTiles(tileName: "ZH (measure)", isLocked: true),
                ControlPanelTiles(tileName: "L (lamp)", isLocked: true),
                ControlPanelTiles(tileName: "R (red)", isLocked: true),
                ControlPanelTiles(tileName: "TH (thin)", isLocked: true),
                ControlPanelTiles(tileName: "TH (this)", isLocked: true),
                ControlPanelTiles(tileName: "H (hat)", isLocked: true),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          // Attach the GlobalKey to the Apply button.
          CustomElevatedButton(
            key: _applyButtonKey,
            buttonLength: screenWidth * 0.7,
            buttonHeight: screenHeight * 0.055,
            buttonName: "Apply",
            primaryColor: 0xFFFFC000,
            shadowColor: 0xFFD29338,
            textColor: Colors.white,
            onPressed: () {},
          ),
          SizedBox(height: screenHeight * 0.03),
        ],
      ),
    );
  }
}
