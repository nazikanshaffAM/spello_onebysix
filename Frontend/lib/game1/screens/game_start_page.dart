import 'package:flutter/material.dart';
import 'package:spello_frontend/game1/screens/settings_page.dart';
import 'game_page.dart';
import 'how_to_play_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    // Responsive font sizes and spacing
    final double titleFontSize =
        screenWidth * 0.12 > 48 ? 48 : screenWidth * 0.12;
    final double titleBottomMargin =
        screenHeight * 0.05 > 40 ? 40 : screenHeight * 0.05;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add the Zip & Zap title container with green/teal colors
                Container(
                  margin: EdgeInsets.only(bottom: titleBottomMargin),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.07,
                    vertical: screenHeight * 0.02,
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
                        Color(0xFF00F96B), // Teal// Green
                        Color(0xFF00BCD4), // Cyan
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      'Zip & Zap',
                      style: TextStyle(
                        fontFamily: 'Fredoka One',
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // This gets replaced by the shader
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
                SizedBox(
                  height: screenHeight * 0.1,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildButton('NEW GAME', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Game1(),
                          ),
                        );
                      }),
                      const SizedBox(height: 20),
                      _buildButton('MAP', () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SettingsPage(
                                onBackgroundSelected: (String newBackground) {
                                  setState(() {}); //
                                },
                              ),
                            ));
                      }),
                      const SizedBox(height: 20),
                      _buildButton('HOW TO PLAY', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HowtoPlayPage(),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    // Using a lighter icy blue color based on your original 0xFF0E3955
    final Color buttonColor = const Color(0xFF235A82); // Lighter icy blue
    final Color shadowColor =
        const Color(0xFF0E3955); // Original darker blue for shadow

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24), // Matching original radius
      child: Container(
        width: 200, // Original fixed width
        height: 60, // Original fixed height
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(24), // Matching original radius
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 3), // Fixed shadow offset
              blurRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 20, // Original fixed font size
              fontFamily: "Fredoka One", // Updated font
              fontWeight: FontWeight.w600, // Matching original weight
            ),
          ),
        ),
      ),
    );
  }
}
