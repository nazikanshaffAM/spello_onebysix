// game_rules.dart (Game Logic)
import 'dart:math';
import 'package:flutter/material.dart';
import 'ApiService.dart';
import 'EndingPage.dart';

class GameRules extends ChangeNotifier {
  BuildContext context;
  double position = 500;
  int xp = 0;
  int lives = 3;
  int timeLeft = 30;
  List<String> words = ["apple", "banana", "cherry","miyuru"];
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

  void checkPronunciation(String filePath) async {
    int? accuracy = await ApiService.uploadAudio(filePath); //  Wait for backend response

    if (accuracy != null) { //  Call logic only if accuracy is received
      if (accuracy >= 75) {
        moveImageToTop();
        Future.delayed(const Duration(seconds: 1), () {
          shouldAnimate = false; // Disable animation
          resetImagePosition();  // Instantly reset position
          shouldAnimate = true;  // Enable animation for next round
          xp += 100;
          nextWord();
        });
      } else {
        moveImageHalfway();
      }
    } else {
      print(" Error: Could not fetch pronunciation accuracy.");
    }

    notifyListeners();
  }



  bool shouldAnimate = true; // Default to animated movement


  void moveImageToTop() {
    if (shouldAnimate) {
      position = -50; // Move to top smoothly
    }
    notifyListeners();
  }

  void moveImageHalfway() {
    if (shouldAnimate) {
      position = 200; // Move halfway
      Future.delayed(const Duration(seconds: 1), () {
        position = 500; // Move back to bottom
        loseLife();
        notifyListeners();
      });
    }
  }

  void resetImagePosition() {
    position = 500; // Instantly reset to default
    notifyListeners();
  }



  Future<int> testValue() async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
    return Random().nextInt(51) + 50; // Generates a number between 50 and 100
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
