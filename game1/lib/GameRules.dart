import 'package:flutter/material.dart';
import 'ApiService.dart';
import 'EndingPage.dart';
import 'dart:math';

class GameRules extends ChangeNotifier {
  BuildContext context;
  double position = 600;
  int xp = 0;
  int lives = 3;
  int timeLeft = 30;
  String word = "";  // Store the current word
  bool gameEnded = false;
  bool shouldAnimate = true;

  // Add a list of alien images
  List<String> aliens = [
    'assets/images/alien1.png',
    'assets/images/alien2.png',
    'assets/images/alien3.png',
    'assets/images/alien4.png',
    'assets/images/alien5.png',
    'assets/images/alien6.png',
    'assets/images/alien7.png',
  ];

  // Track selected alien
  String selectedAlienImage = 'assets/images/alien1.png';

  GameRules(this.context) {
    initializeGame();
  }

  // Fetch the first word
  Future<void> initializeGame() async {
    word = "Loading..."; // Temporary placeholder untile the words are loading from the backend
    notifyListeners(); //

    try {
      String? fetchedWord = await ApiService.fetchTargetWord();
      if (fetchedWord != null && fetchedWord.isNotEmpty) {
        word = fetchedWord;
      } else {
        word = "default"; // Fallback word
      }
    } catch (e) {
      word = "Error fetching word"; // Error handling
    }

    notifyListeners();
    startTimer();
  }

  // Set selected alien (randomly or based on user input)
  void setSelectedAlien(int index) {
    selectedAlienImage = aliens[index];
    notifyListeners();
  }

  // Countdown Timer
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

  // Check pronunciation accuracy
  void checkPronunciation(String filePath) async {
    int? accuracy = await ApiService.uploadAudio(filePath);

    if (accuracy != null) {
      if (accuracy >= 75) {
        moveImageToTop();
        Future.delayed(const Duration(seconds: 1), () async {
          shouldAnimate = false;
          resetImagePosition();
          shouldAnimate = true;
          xp += 100;
          await ApiService.fetchTargetWord(); // Fetch the next word
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
        position = 600;
        loseLife();
      });
    }
  }

  void resetImagePosition() {
    position = 600;
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
          totalWords: xp ~/ 100, // Since each correct word gives 100 XP
          accuracy: xp / ((xp ~/ 100) * 100) * 100,
          userLevel: xp ~/ 500,
        ),
      ),
    ));
  }
}
