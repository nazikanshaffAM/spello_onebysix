import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_rules.dart';
import 'audio_recorder.dart';

class GamePage extends StatefulWidget {
  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  final AudioService _audioService = AudioService();
  String backgroundImage = 'assets/images/b1.jpg'; // Default background
  bool _isRecording = false;


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
                  top: screenHeight * 0.06,
                  right: screenWidth * 0.04,
                  child: Row(
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                        child: Image.asset(
                          index < gameRules.lives
                              ? 'assets/images/heart.png'
                              : 'assets/images/emtyheart.png',
                          width: screenWidth * 0.07,
                        ),
                      );
                    }),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.05),
                    child: Text(
                      "${(gameRules.timeLeft ~/ 60).toString().padLeft(2, '0')}:${(gameRules.timeLeft % 60).toString().padLeft(2, '0')}",
                      style: TextStyle(
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.bold,
                        color: gameRules.timeLeft <= 10 ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ),



                AnimatedPositioned(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  top: gameRules.position,
                  left: screenWidth * 0.5 - 50,
                  child: Opacity(
                    opacity: gameRules.alienOpacity,
                    child: Image.asset(gameRules.selectedAlienImage, width: screenWidth * 0.15),
                  ),
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

                // Alien images at the bottom
                Positioned(
                  bottom: 20,
                  left: screenWidth * 0.04,
                  child: Row(
                    children: gameRules.aliens.map((alienImage) {
                      int index = gameRules.aliens.indexOf(alienImage);
                      return GestureDetector(
                        onTap: () {
                          gameRules.setSelectedAlien(index);
                        },
                        child: Image.asset(
                          alienImage,
                          width: screenWidth * 0.1,
                          height: screenHeight * 0.1,
                        ),
                      );
                    }).toList(),
                  ),
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
        // Start recording when the button is held
        setState(() {
          _isRecording = true;
        });
        await _audioService.startRecording();
      },
      onLongPressUp: () async {
        // Stop recording and reset the button state
        setState(() {
          _isRecording = false;
        });
        await _audioService.stopRecording();
        var gameRules = Provider.of<GameRules>(context, listen: false);
        await _audioService.sendAudioToBackend(context, gameRules);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        height: _isRecording ? screenWidth * 0.22 : screenWidth * 0.18, // Increase size on press
        width: _isRecording ? screenWidth * 0.22 : screenWidth * 0.18, // Increase size on press
        decoration: BoxDecoration(
          color: _isRecording ? Colors.green : Colors.red, // Change color on press
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _isRecording ? Colors.greenAccent : Colors.redAccent,
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          Icons.mic,
          size: _isRecording ? screenWidth * 0.12 : screenWidth * 0.09, // Bigger icon when recording
          color: Colors.white,
        ),
      ),
    );
  }
}