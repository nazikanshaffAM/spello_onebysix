import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic>
      userData; // Receives userData from login or registration flow

  const HomePage({super.key, required this.userData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? _tappedIndex;
  final List<GlobalKey> _gridItemKeys =
      List.generate(6, (index) => GlobalKey());
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  // Method to safely access user data with fallback values
  String get userName => widget.userData['name'] ?? 'User';
  String get userEmail => widget.userData['email'] ?? '';
  String get userAge => widget.userData['age']?.toString() ?? '';
  String get userGender => widget.userData['gender'] ?? '';

  final List<Map<String, dynamic>> gridItems = [
    {
      'icon': "assets/images/start.png",
      'label': 'START PRACTICE',
      'navigateTo': "/startPractice",
    },
    {
      'icon': "assets/images/parental_control.png",
      'label': 'PARENTAL CONTROL',
      'navigateTo': "/parentalControl",
    },
    {
      'icon': "assets/images/dashboard.png",
      'label': 'DASHBOARD',
      'navigateTo': "/dashboard",
    },
    {
      'icon': "assets/images/notification.png",
      'label': 'NOTIFICATIONS',
      'navigateTo': "/notifications",
    },
    {
      'icon': "assets/images/settings.png",
      'label': 'SETTINGS',
      'navigateTo': "/settings",
    },
    {
      'icon': "assets/images/help_center.png",
      'label': 'HELP CENTER',
      'navigateTo': "/helpCenter",
    },
  ];

  @override
  void initState() {
    super.initState();

    // Log userData to verify it's being passed correctly
    print("HomePage received userData: ${widget.userData}");

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
        textSkip: "Skip", // Made the skip button text simpler
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
      // Improved descriptive prompts for each grid item
      String prompt;
      switch (gridItems[index]['label']) {
        case 'START PRACTICE':
          prompt =
              "Browse our game library and select fun activities to practice with. Find the perfect game for your learning needs!";
          break;
        case 'PARENTAL CONTROL':
          prompt =
              "Customize games with specific sounds and words for your child's learning journey. Set up the perfect practice environment!";
          break;
        case 'DASHBOARD':
          prompt =
              "Track weekly progress, view accuracy rates, and see how your skills are improving over time!";
          break;
        case 'NOTIFICATIONS':
          prompt =
              "Stay informed with important alerts, practice reminders, and achievement notifications!";
          break;
        case 'SETTINGS':
          prompt =
              "Adjust app preferences, manage your account, update profile information, and log out when needed!";
          break;
        case 'HELP CENTER':
          prompt =
              "Find answers to common questions, access tutorials, and get support whenever you need assistance!";
          break;
        default:
          prompt = "Explore ${gridItems[index]['label']} features";
      }

      // For the last two tiles (Settings and Help Center), set alignment to top
      ContentAlign alignment = ContentAlign.bottom;
      if (index >= 4) {
        // Index 4 and 5 are Settings and Help Center
        alignment = ContentAlign.top;
      }

      return TargetFocus(
        identify: gridItems[index]['label'],
        keyTarget: _gridItemKeys[index],
        shape: ShapeLightFocus.RRect,
        radius: 8,
        contents: [
          TargetContent(
            align: alignment, // Use dynamic alignment based on index
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

  // Pass userData to all routes
  void _onTileTap(int index, BuildContext context) {
    setState(() {
      _tappedIndex = index;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _tappedIndex = null;
      });

      // Get the route name
      String routeName = gridItems[index]['navigateTo'];

      // Pass userData to all routes
      print("Navigating to $routeName with user data: ${widget.userData}");

      Navigator.pushNamed(
        context,
        routeName,
        arguments: widget.userData, // Pass complete userData as arguments
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
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
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.03),
                  // User greeting container
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.18,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA7B6E7),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF4C5679),
                          offset: Offset(0, 5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: screenWidth * 0.02),
                        CircleAvatar(
                          backgroundColor: Colors.white60,
                          radius: 30,
                          child: const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/profile_picture.png'),
                            backgroundColor: Colors.red,
                            radius: 25,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.06),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: screenHeight * 0.04),
                            Text(
                              "Hello, ${userName}!", // Uses userName getter with fallback
                              style: TextStyle(
                                color: const Color(0xFF3C3939),
                                fontSize: screenWidth * 0.06,
                                fontFamily: "Fredoka One",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Keep up the great work!",
                              style: TextStyle(
                                  color: const Color(0xFF3A4552),
                                  fontSize: screenWidth * 0.035,
                                  fontFamily: "Fredoka",
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.007),
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
                                    color: const Color(0xFF3C3939),
                                    fontSize: screenWidth * 0.0335,
                                    fontFamily: "Fredoka One",
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
          ),
        ],
      ),
    );
  }
}
