import 'package:flutter/material.dart';
import 'package:spello_frontend/pages/HomePages/SubPages/parental_control_one.dart';
import 'package:spello_frontend/pages/HomePages/SubPages/parental_control_two.dart';
import 'package:spello_frontend/util/custom_elevated_button.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ParentalControl extends StatefulWidget {
  const ParentalControl({Key? key}) : super(key: key);

  @override
  State<ParentalControl> createState() => _ParentalControlState();
}

class _ParentalControlState extends State<ParentalControl> {
  // GlobalKeys to identify the two buttons
  final GlobalKey _soundsButtonKey = GlobalKey();
  final GlobalKey _wordsButtonKey = GlobalKey();

  // The coach mark instance
  late TutorialCoachMark tutorialCoachMark;

  // List of target focuses
  List<TargetFocus> targets = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTargets();
      _showTutorial();
    });
  }

  void _initTargets() {
    targets = [
      TargetFocus(
        identify: "SoundsButton",
        keyTarget: _soundsButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Tap here to select sounds that match your child's learning goals.",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "WordsButton",
        keyTarget: _wordsButtonKey,
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Tap here to choose words that support your child's speech development.",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: "Fredoka"),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  void _showTutorial() {
    // Create the tutorial coach mark instance
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      // If your linter complains about withOpacity, use Color.fromRGBO(0,0,0,0.8)
      colorShadow: const Color.fromRGBO(0, 0, 0, 0.8),
      textSkip: "SKIP",
      textStyleSkip:
          TextStyle(fontFamily: "Fredoka", fontWeight: FontWeight.bold),
      paddingFocus: 8,
      // The following callbacks are the current valid ones in ^1.2.13
      onFinish: () {
        debugPrint("Tutorial finished");
      },
      onClickTarget: (target) {
        debugPrint("Target clicked: ${target.identify}");
      },
      onClickOverlay: (target) {
        debugPrint("Overlay clicked: ${target.identify}");
      },
      // If you want a custom skip widget, you can use skipWidget:
      // skipWidget: ElevatedButton(
      //   onPressed: () => tutorialCoachMark.finish(),
      //   child: Text("SKIP"),
      // ),
    );

    // Show the tutorial by providing the context here
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
      body: Center(
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.03),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.04,
              ),
              child: Text(
                "Customize the learning experience\nby selecting sounds or words that\nmatch your child's speech goals.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Fredoka",
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Image.asset(
              "assets/images/parental_control_one.png",
              height: screenHeight * 0.4,
              width: screenWidth * 0.7,
              fit: BoxFit.contain,
            ),
            SizedBox(height: screenHeight * 0.03),
            CustomElevatedButton(
              key: _soundsButtonKey,
              buttonLength: screenWidth * 0.8,
              buttonHeight: 50,
              buttonName: "Sounds",
              primaryColor: 0xFFFFC000,
              shadowColor: 0xFFD29338,
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParentalControlOne(),
                  ),
                );
              },
            ),
            SizedBox(height: screenHeight * 0.02),
            CustomElevatedButton(
              key: _wordsButtonKey,
              buttonLength: screenWidth * 0.8,
              buttonHeight: 50,
              buttonName: "Words",
              primaryColor: 0xFFFFC000,
              shadowColor: 0xFFD29338,
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ParentalControlTwo(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
