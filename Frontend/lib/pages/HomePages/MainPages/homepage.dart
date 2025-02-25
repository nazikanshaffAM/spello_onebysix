import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Track which tile is tapped
  int? _tappedIndex;

  // Create a GlobalKey for each grid tile (6 items)
  final List<GlobalKey> _gridItemKeys =
      List.generate(6, (index) => GlobalKey());

  // Tutorial Coach Mark objects
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  // Grid data
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
    // Ensure layout is built before showing the tutorial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTargets();
      _showTutorial();
    });
  }

  /// Define the tutorial targets for all six grid tiles.
  void _initTargets() {
    targets = List.generate(gridItems.length, (index) {
      return TargetFocus(
        identify: gridItems[index]['label'],
        keyTarget: _gridItemKeys[index],
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: index % 2 == 0 ? ContentAlign.bottom : ContentAlign.top,
            child: Text(
              "Tap here for ${gridItems[index]['label']}",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: "Fredoka"),
            ),
          ),
        ],
      );
    });
  }

  /// Show the tutorial overlay.
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

  void _onTileTap(int index, BuildContext context) {
    setState(() {
      _tappedIndex = index;
    });

    // Wait for 100 milliseconds to show the color change
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _tappedIndex = null; // Reset color
      });

      // Navigate to respective screen
      Navigator.pushNamed(context, gridItems[index]['navigateTo']);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double responsiveFontSize = screenWidth * 0.05;
    final double responsivePadding = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(
            fontFamily: "Fredoka One", // Updated font family
            fontWeight: FontWeight.bold, // Updated font weight
            fontSize: screenWidth * 0.07,
          ),
        ),
        backgroundColor: const Color(0xFF3A435F),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsivePadding),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.03), // Moves grid down
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
                            ? const Color(0xFFFFC000) // Tapped color
                            : const Color(0xFFFFFFFF), // Default color
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isTapped
                                ? const Color(0xFF3A4562) // Darker shade on tap
                                : const Color(0xFF4C5679), // Normal state
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
                              fontSize: responsiveFontSize,
                              fontFamily:
                                  "Fredoka One", // Updated font family// Bold text
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
    );
  }
}
