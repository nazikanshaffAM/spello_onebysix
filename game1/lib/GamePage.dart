// game_page.dart (Game UI)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'GameRules.dart';


class GamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameRules(context),
      child: Scaffold(
        body: Consumer<GameRules>(
          builder: (context, gameRules, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/backgroundEndingPage.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 20,
                  child: Text("XP: ${gameRules.xp}",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
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
                Positioned(
                  top: 30,
                  left: MediaQuery.of(context).size.width / 2 - 30,
                  child: Text(
                    "${(gameRules.timeLeft ~/ 60).toString().padLeft(2, '0')}:${(gameRules.timeLeft % 60).toString().padLeft(2, '0')}",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                AnimatedPositioned(
                  duration: Duration(seconds: 2),
                  top: gameRules.position,
                  left: MediaQuery.of(context).size.width / 2 - 50,
                  child: Image.asset('assets/images/character.png', width: 100),
                ),
                Positioned(
                  bottom: 80,
                  left: 20,
                  child: Text(
                    gameRules.currentWord,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                Positioned(
                  bottom: 50,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () => gameRules.checkPronunciation(),
                    backgroundColor: Colors.red,
                    child: Icon(Icons.mic, size: 30),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

