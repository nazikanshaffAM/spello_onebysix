// game_rules.dart (Game Logic)
import 'package:flutter/material.dart';
import 'ApiService.dart';
import 'EndingPage.dart';

class GameRules extends ChangeNotifier {
  BuildContext context;
  double position = 500;
  int xp = 0;
  int lives = 3;
  int timeLeft = 300;
  List<String> words = ["apple", "banana", "cherry"];
  int currentWordIndex = 0;
  bool gameEnded = false;

  String get currentWord => words[currentWordIndex];

  GameRules(this.context) {
    startTimer();
  }

  void startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (timeLeft > 0 && lives > 0) {
        timeLeft--;
        notifyListeners();
        startTimer();
      } else {
        endGame();
      }
    });
  }

  void checkPronunciation() async {
    int value = await ApiService.fetchRandomValue();
    if (value >= 75) {
      position = -50;
      xp += 100;
      nextWord();
    } else {
      position = 200;
      Future.delayed(const Duration(seconds: 1), () {
        position = 500;
        loseLife();
      });
    }
    notifyListeners();
  }

  void nextWord() {
    if (currentWordIndex < words.length - 1) {
      currentWordIndex++;
    } else {
      endGame();
    }
    notifyListeners();
  }

  void loseLife() {
    lives--;
    if (lives == 0) {
      endGame();
    }
    notifyListeners();
  }

  void endGame() {
    gameEnded = true;
    notifyListeners();
    Future.microtask(() => Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EndingPage(
          correctlyPronouncedWords: xp ~/ 100,
          totalWords: words.length,
          accuracy: (xp / (words.length * 100)) * 100,
          userLevel: xp ~/ 500,
        ),
      ),
    ));
  }
}
