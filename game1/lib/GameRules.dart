import 'package:flutter/material.dart';
import 'ApiService.dart';
import 'EndingPage.dart';

class GameRules extends ChangeNotifier {
  BuildContext context;
  double position = 600;
  int xp = 0;
  int lives = 3;
  int timeLeft = 30;
  String word = "";  // Store the current word
  bool gameEnded = false;
  bool shouldAnimate = true;

  GameRules(this.context) {
    initializeGame();
  }

  // Fetch the first word
  Future<void> initializeGame() async {
    word = "Loading..."; // Temporary placeholder
    notifyListeners(); // Notify UI to update

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

    notifyListeners(); // Notify UI of the change
    startTimer();
  }


  // Fetch a new word from the backend
  Future<void> fetchNewWord() async {
    String? fetchedWord = await ApiService.fetchTargetWord();

    if (fetchedWord != null && fetchedWord.isNotEmpty) {
      word = fetchedWord;
    } else {
      word = "default";  // Fallback word
    }

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
          await fetchNewWord(); // Fetch the next word
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
