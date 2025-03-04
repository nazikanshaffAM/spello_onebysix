import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _tappedIndex;
  final List<GlobalKey> _gridItemKeys =
      List.generate(6, (index) => GlobalKey());
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  final List<Map<String, dynamic>> gridItems = [
    {
      'icon': "assets/images/start.png",
      'label': 'Start Practice',
      'navigateTo': "/startPractice",
    },
    {
      'icon': "assets/images/parental_control.png",
      'label': 'Parental\nControl',
      'navigateTo': "/parentalControl",
    },
    {
      'icon': "assets/images/dashboard.png",
      'label': 'Dashboard',
      'navigateTo': "/dashboard",
    },
    {
      'icon': "assets/images/notification.png",
      'label': 'Notifications',
      'navigateTo': "/notifications",
    },
    {
      'icon': "assets/images/settings.png",
      'label': 'Settings',
      'navigateTo': "/settings",
    },
    {
      'icon': "assets/images/help_center.png",
      'label': 'Help Center',
      'navigateTo': "/helpCenter",
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initTargets();
      await _showTutorial();
    });
  }

  Future<void> _showTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasSeenTutorial = prefs.getBool('hasSeenTutorial') ?? false;

    if (!hasSeenTutorial) {
      tutorialCoachMark = TutorialCoachMark(
        targets: targets,
        colorShadow: const Color.fromRGBO(0, 0, 0, 0.8),
        textSkip: "skip",
        paddingFocus: 8,
        onFinish: () async {
          await prefs.setBool(
              'hasSeenTutorial', true); // Mark as seen when finished
        },
        onSkip: () {
          // Mark as seen when skipped
          prefs.setBool('hasSeenTutorial', true).then((_) {
            print("Tutorial skipped and marked as seen.");
          });
          return true; // Explicitly return a boolean value
        },
      );
      tutorialCoachMark.show(context: context);
    }
  }

  void _initTargets() {
    targets = List.generate(gridItems.length, (index) {
      // Curated prompts for each grid item
      String prompt;
      switch (gridItems[index]['label']) {
        case 'Start Practice':
          prompt = "Begin your practice sessions here. Tap to start!";
          break;
        case 'Parental\nControl':
          prompt =
              "Customize your childs gameplay with specific sounds and words. Tap to Customize!";
          break;
        case 'Dashboard':
          prompt = "View your progress and insights. Tap to check it out!";
          break;
        case 'Notifications':
          prompt =
              "Stay updated with important alerts. Tap to see notifications!";
          break;
        case 'Settings':
          prompt = "Customize your app experience. Tap to adjust settings!";
          break;
        case 'Help Center':
          prompt = "Get assistance and support. Tap to access help!";
          break;
        default:
          prompt = "Tap here for ${gridItems[index]['label']}";
      }

      return TargetFocus(
        identify: gridItems[index]['label'],
        keyTarget: _gridItemKeys[index],
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3A435F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                prompt,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Fredoka",
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  void _onTileTap(int index, BuildContext context) {
    setState(() {
      _tappedIndex = index;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _tappedIndex = null;
      });
      Navigator.pushNamed(context, gridItems[index]['navigateTo']);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(
            fontFamily: "Fredoka One",
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.07,
          ),
        ),
        backgroundColor: const Color(0xFF3A435F),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0,
            left: screenWidth * 0.5,
            child: Image.asset(
              "assets/images/cloud.png",
              width: screenWidth * 0.4,
            ),
          ),
          Positioned(
            top: screenHeight * 0.2,
            left: screenWidth * 0,
            child: Image.asset(
              "assets/images/cloud.png",
              width: screenWidth * 0.4,
            ),
          ),
          Positioned(
            top: screenHeight * 0.5,
            left: screenWidth * 0.5,
            child: Image.asset(
              "assets/images/cloud.png",
              width: screenWidth * 0.5,
            ),
          ),
          Positioned(
            top: screenHeight * 0.6,
            left: screenWidth * 0,
            child: Image.asset(
              "assets/images/cloud.png",
              width: screenWidth * 0.5,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.03),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.only(top: screenHeight * 0.02),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: screenWidth * 0.04,
                      mainAxisSpacing: screenWidth * 0.04,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: gridItems.length,
                    itemBuilder: (context, index) {
                      final bool isTapped = (_tappedIndex == index);
                      return GestureDetector(
                        onTap: () => _onTileTap(index, context),
                        child: AnimatedContainer(
                          key: _gridItemKeys[index],
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeOut,
                          decoration: BoxDecoration(
                            color: isTapped
                                ? const Color(0xFFFFC000)
                                : const Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: isTapped
                                    ? const Color(0xFF3A4562)
                                    : const Color(0xFF4C5679),
                                offset: const Offset(0, 5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                gridItems[index]["icon"],
                                width: screenWidth * 0.18,
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                gridItems[index]['label'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF3A4562),
                                  fontSize: screenWidth * 0.05,
                                  fontFamily: "Fredoka One",
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
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
