import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'GameRules.dart';
import 'AudioService.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final AudioService _audioService = AudioService();
  String backgroundImage = 'assets/images/b1.jpg'; // Default background

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
  }

  Future<void> _loadBackgroundImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      backgroundImage = prefs.getString("selectedBackground") ?? 'assets/images/b1.jpg';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider(
      create: (_) => GameRules(context),
      child: Scaffold(
        body: Consumer<GameRules>(
          builder: (context, gameRules, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    backgroundImage,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: -(screenHeight * 0.24),
                  left: screenWidth * 0.03,
                  child: Lottie.asset(
                    'assets/images/UFO.json',
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.9,
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.05,
                  left: screenWidth * 0.05,
                  child: Text(
                    "XP: ${gameRules.xp}",
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.05,
                  right: screenWidth * 0.05,
                  child: Row(
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                        child: Image.asset(
                          index < gameRules.lives
                              ? 'assets/images/heart.png'
                              : 'assets/images/emtyheart.png',
                          width: screenWidth * 0.06,
                        ),
                      );
                    }),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.05,
                  left: screenWidth * 0.5 - (screenWidth * 0.08),
                  child: Text(
                    "${(gameRules.timeLeft ~/ 60).toString().padLeft(2, '0')}:${(gameRules.timeLeft % 60).toString().padLeft(2, '0')}",
                    style: TextStyle(
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                gameRules.shouldAnimate
                    ? AnimatedPositioned(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  top: gameRules.position,
                  left: screenWidth * 0.5 - 50,
                  child: Image.asset('assets/images/character.png', width: screenWidth * 0.15),
                )
                    : Positioned(
                  top: gameRules.position,
                  left: screenWidth * 0.5 - 50,
                  child: Image.asset('assets/images/character.png', width: screenWidth * 0.15),
                ),
                Positioned(
                  bottom: screenHeight * 0.1,
                  left: screenWidth * 0.08,
                  child: Text(
                    gameRules.word,
                    style: TextStyle(
                      fontSize: screenWidth * 0.12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: screenHeight * 0.08,
                  right: screenWidth * 0.05,
                  child: _buildMicButton(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMicButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onLongPress: () async {
        await _audioService.startRecording();
      },
      onLongPressUp: () async {
        await _audioService.stopRecording();
        var gameRules = Provider.of<GameRules>(context, listen: false);
        await _audioService.sendAudioToBackend(context, gameRules);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        height: screenWidth * 0.18,
        width: screenWidth * 0.18,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.redAccent, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Icon(Icons.mic, size: screenWidth * 0.09, color: Colors.white),
      ),
    );
  }
}
