import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'GameRules.dart';
import 'AudioService.dart';

class GamePage extends StatelessWidget {
  final AudioService _audioService = AudioService();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameRules(context), // ✅ Corrected context usage
      child: Scaffold(
        body: Consumer<GameRules>(
          builder: (context, gameRules, child) {
            return Stack(
              children: [
                // 🖼 Background Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/backgroundEndingPage.png',
                    fit: BoxFit.cover,
                  ),
                ),

                // XP Display
                Positioned(
                  top: 30,
                  left: 20,
                  child: Text("XP: ${gameRules.xp}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),

                // Life Display
                Positioned(
                  top: 30,
                  right: 20,
                  child: Row(
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Image.asset(
                          index < gameRules.lives
                              ? 'assets/images/heart.png'
                              : 'assets/images/emtyheart.png',
                          width: 25,
                        ),
                      );
                    }),
                  ),
                ),

                // Timer Display
                Positioned(
                  top: 30,
                  left: MediaQuery.of(context).size.width / 2 - 30,
                  child: Text(
                    "${(gameRules.timeLeft ~/ 60).toString().padLeft(2, '0')}:${(gameRules.timeLeft % 60).toString().padLeft(2, '0')}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                // Character Animation
                gameRules.shouldAnimate
                    ? AnimatedPositioned(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  top: gameRules.position,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: Image.asset('assets/images/character.png', width: 100),
                )
                    : Positioned(
                  top: gameRules.position,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: Image.asset('assets/images/character.png', width: 100),
                ),

                // Word Display
                Positioned(
                  bottom: 80,
                  left: 20,
                  child: Text(
                    gameRules.currentWord,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),

                // Microphone Button (Fixed Context Usage)
                Positioned(
                  bottom: 50,
                  right: 20,
                  child: _buildMicButton(context), // ✅ Pass context
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 🎤 Hold to record, release to stop & send
  Widget _buildMicButton(BuildContext context) {
    return GestureDetector(
      onLongPress: () async {
        await _audioService.startRecording();
      },
      onLongPressUp: () async {
        await _audioService.stopRecording();

        var gameRules = Provider.of<GameRules>(context, listen: false); // ✅ Get the existing GameRules instance
        await _audioService.sendAudioToBackend(context, gameRules);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.redAccent, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Icon(Icons.mic, size: 35, color: Colors.white),
      ),
    );
  }
}
