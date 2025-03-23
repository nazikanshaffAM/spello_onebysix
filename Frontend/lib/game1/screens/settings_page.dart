import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function(String) onBackgroundSelected; // Callback function

  const SettingsPage({super.key, required this.onBackgroundSelected});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  List<String> backgroundImages = [
    "assets/images/b1.jpg",
    "assets/images/b2.jpg",
    "assets/images/b3.jpg",
    "assets/images/b4.jpg",
    "assets/images/b5.jpg",
    "assets/images/b6.jpg",
  ];

  List<String> backgroundNames = [
    "Space Adventure",
    "Mystic Forest",
    "Cyber Grid",
    "Neon City",
    "Dark Galaxy",
    "Retro Arcade"
  ];

  String selectedBackground = "";

  @override
  void initState() {
    super.initState();
    _loadSelectedBackground();
  }

  // Load the saved background selection
  Future<void> _loadSelectedBackground() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedBackground =
          prefs.getString("selectedBackground") ?? backgroundImages[0];
    });
  }

  // Save the selected background
  Future<void> _saveSelectedBackground(String background) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedBackground", background);
    widget.onBackgroundSelected(background); // Notify the main screen
    setState(() {
      selectedBackground = background;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive UI
    final screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    // Responsive font sizing
    final double titleFontSize =
        screenWidth * 0.07 > 30 ? 30 : screenWidth * 0.07;
    final double subtitleFontSize =
        screenWidth * 0.04 > 18 ? 18 : screenWidth * 0.04;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/b5.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button (optional - add if needed)
                // GestureDetector(
                //   onTap: () => Navigator.pop(context),
                //   child: Container(
                //     padding: const EdgeInsets.all(8.0),
                //     decoration: BoxDecoration(
                //       color: const Color(0xFF235A82),
                //       borderRadius: BorderRadius.circular(12),
                //       boxShadow: [
                //         BoxShadow(
                //           color: const Color(0xFF0E3955),
                //           offset: const Offset(0, 3),
                //           blurRadius: 0,
                //         ),
                //       ],
                //     ),
                //     child: const Icon(
                //       Icons.arrow_back,
                //       color: Colors.white70,
                //       size: 24,
                //     ),
                //   ),
                // ),

                SizedBox(height: screenHeight * 0.03),

                // Title with consistent styling from How to Play page
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E3955).withOpacity(0.9),
                      border: Border.all(
                        color: const Color(0xFF0E3955),
                        width: screenWidth * 0.01 > 4 ? 4 : screenWidth * 0.01,
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    ),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF00F96B), // Green
                          Color(0xFF00BCD4), // Cyan
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'Select Game Map',
                        style: TextStyle(
                          fontFamily: 'Fredoka One',
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              color: Colors.black38,
                              offset: Offset(2, 2),
                              blurRadius: 3,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.01),

                // Main content container
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E3955).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00BCD4).withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtitle

                        SizedBox(height: screenHeight * 0.02),

                        // Background grid
                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: screenWidth * 0.03,
                              mainAxisSpacing: screenHeight * 0.02,
                              childAspectRatio: 0.96,
                            ),
                            itemCount: backgroundImages.length,
                            itemBuilder: (context, index) {
                              String background = backgroundImages[index];
                              bool isSelected =
                                  selectedBackground == background;

                              return GestureDetector(
                                onTap: () {
                                  _saveSelectedBackground(background);
                                },
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // Background image with selection border
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(
                                                  0xFF00F96B) // Gradient green matching the title
                                              : Colors.transparent,
                                          width: 4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                        image: DecorationImage(
                                          image: AssetImage(background),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    // Label at the bottom
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.01,
                                        horizontal: screenWidth * 0.02,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0E3955)
                                            .withOpacity(0.9),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        backgroundNames[index],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Fredoka',
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth * 0.035 > 14
                                              ? 14
                                              : screenWidth * 0.035,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
