import 'package:flutter/material.dart';

class HelpCenterPage extends StatefulWidget {
  @override
  _HelpCenterPageState createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final Color primaryColor = Color(0xFF8092CC);
  final Color accentColor = Color(0xFFFFFFFF);
  final Color textColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Help Center",
          style: TextStyle(
            fontFamily: "Fredoka One",
            fontSize: screenWidth * 0.06,
          ),
        ),
        backgroundColor: Color(0xFF3A435F),
        foregroundColor: textColor,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Fixed Cloud Background
          Positioned.fill(
            child: Stack(
              children: [
                Positioned(
                  top: screenHeight * 0.05,
                  left: screenWidth * 0.6,
                  child: Opacity(
                    opacity: 0.7,
                    child: Image.asset(
                      "assets/images/cloud.png",
                      width: screenWidth * 0.4,
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.2,
                  right: screenWidth * 0.7,
                  child: Opacity(
                    opacity: 0.7,
                    child: Image.asset(
                      "assets/images/cloud.png",
                      width: screenWidth * 0.4,
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.47,
                  left: screenWidth * 0.6,
                  child: Opacity(
                    opacity: 0.7,
                    child: Image.asset(
                      "assets/images/cloud.png",
                      width: screenWidth * 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Content
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: screenHeight * 0.4,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/help_center_page.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle("What is Spello?"),
                      _buildContentText(
                        "Spello is a gamified speech therapy app designed to make pronunciation practice "
                        "fun and engaging. It helps improve speech using real-time speech recognition "
                        "and interactive mini-games with instant feedback.",
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      _buildSectionTitle("How Do the Games Work?"),
                      _buildGameFeature(
                        icon: Icons.mic,
                        title: "Speak to Play",
                        content:
                            "Say target words aloud to progress through levels. Get instant feedback on your pronunciation.",
                      ),
                      _buildGameFeature(
                        icon: Icons.feedback,
                        title: "Real-Time Feedback",
                        content:
                            "Advanced speech analysis provides gentle corrections and allows retries.",
                      ),
                      _buildGameFeature(
                        icon: Icons.games,
                        title: "Interactive Mini-Games",
                        content:
                            "Play Hangman and Zip and Zap with voice controls.",
                      ),
                      _buildGameFeature(
                        icon: Icons.trending_up,
                        title: "Skill Progression",
                        content:
                            "Start with simple words and progress to complex sentences. Track your fluency growth!",
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Divider(color: textColor.withOpacity(0.3)),
                      SizedBox(height: screenHeight * 0.03),
                      _buildSectionTitle("Game Examples"),
                      _buildGameExample("🎭 Hangman",
                          "Guess words letter by letter using your voice before the stick figure is fully drawn."),
                      _buildGameExample("⚡ Zip and Zap",
                          "Control a fast-moving object by pronouncing words correctly to avoid obstacles."),
                      SizedBox(height: screenHeight * 0.05),
                      Center(
                        child: Text(
                          "Need help? Contact: support@spelloapp.com",
                          style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: screenWidth * 0.035,
                              color: Color(0xFFFFC107),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Fredoka One',
          fontSize: 22,
          color: accentColor,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildContentText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Fredoka',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textColor.withOpacity(0.9),
        height: 1.5,
      ),
    );
  }

  Widget _buildGameFeature(
      {required IconData icon,
      required String title,
      required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Fredoka One',
                    fontSize: 16,
                    color: Color(0xFFFFC107),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  content,
                  style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 14,
                      color: textColor.withOpacity(0.8),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameExample(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Fredoka One',
                      fontSize: 14,
                      color: Color(0xFFFFC107),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
