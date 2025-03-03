
import 'package:flutter/material.dart';
import 'ApiService.dart';
import 'EndingPage.dart';

class GameRules extends ChangeNotifier {
  BuildContext context;
  double position = 500;
  int xp = 0;
  int lives = 3;
  int timeLeft = 30;
  List<String> words = [];
  int currentWordIndex = 0;
  bool gameEnded = false;
  bool shouldAnimate = true;

  String get currentWord => words.isNotEmpty ? words[currentWordIndex] : '';

  GameRules(this.context) {
    initializeGame();
  }

  // Fetch words and start the game
  Future<void> initializeGame() async {
    words = await ApiService.fetchWords();

    if (words.isEmpty) {
      words = ["default", "words", "if", "API", "fails"];
    }

    notifyListeners();
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

  void checkPronunciation(String filePath) async {
    int? accuracy = await ApiService.uploadAudio(filePath);

    if (accuracy != null) {
      if (accuracy >= 75) {
        moveImageToTop();
        Future.delayed(const Duration(seconds: 1), () {
          shouldAnimate = false;
          resetImagePosition();
          shouldAnimate = true;
          xp += 100;
          nextWord();
        });
      } else {
        moveImageHalfway();
      }
    } else {
      print("Error: Could not fetch pronunciation accuracy.");
    }

    notifyListeners();
  }

  void moveImageToTop() {
    if (shouldAnimate) {
      position = -50;
    }
    notifyListeners();
  }

  void moveImageHalfway() {
    if (shouldAnimate) {
      position = 200;
      Future.delayed(const Duration(seconds: 1), () {
        position = 500;
        loseLife();
        notifyListeners();
      });
    }
  }

  void resetImagePosition() {
    position = 500;
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
