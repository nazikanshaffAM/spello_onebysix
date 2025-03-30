import 'package:flutter/material.dart';
import '../service/api_service.dart';
import '../screens/ending_page.dart';


class GameRules extends ChangeNotifier {
  BuildContext context;
  double position = 600;
  int xp = 0;
  int lives = 3;
  int timeLeft = 60;
  String word = "";  // Store the current word
  bool gameEnded = false;
  bool shouldAnimate = true;
  double alienOpacity = 1.0;


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

  Map<String, dynamic>? userData;
  GameRules(this.context, {this.userData}) {
    print("GameRules received userData: $userData");
    initializeGame();
  }


  Future<void> initializeGame() async {
    word = "Loading..."; // Temporary placeholder
    notifyListeners(); // Notify UI that loading has started

    try {
      // Debug print to check if we have the email
      if (userData != null && userData!.containsKey('email')) {
        print("GameRules using email for authentication: ${userData!['email']}");
      } else {
        print("Warning: No email found in userData for authentication");
      }

      // Fetch target word using the user's email for authentication
      String? fetchedWord = await ApiService.fetchTargetWord(userData);

      if (fetchedWord != null && fetchedWord.isNotEmpty) {
        word = fetchedWord;
      } else {
        word = "default"; // Fallback if API response is empty
      }
    } catch (e) {
      word = "Error fetching word"; // Handle the error case
      print("Error: $e");
    }

    notifyListeners(); // Notify UI about the word update
    startTimer(); // Start the game timer
  }





  // Function to update the opacity
  void updateAlienOpacity(double opacity) {

    alienOpacity = opacity.clamp(0.0, 1.0);
    notifyListeners();
  }

  // Set selected alien
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
    int? accuracy = await ApiService.uploadAudio(filePath, userData);

    if (accuracy != null) {
      if (accuracy >= 75) {
        moveImageToTop();
        Future.delayed(const Duration(seconds: 1), () async {
          //updateAlienOpacity(0.0);
          resetImagePosition();
          //updateAlienOpacity(1.0);
          xp += 100;

          // Fetch the next word after pronunciation check
          String? fetchedWord = await ApiService.fetchTargetWord(userData);
          if (fetchedWord != null && fetchedWord.isNotEmpty) {
            word = fetchedWord;
          } else {
            word = "default"; // Fallback word if the new word fetch fails
          }

          notifyListeners();
        });
      } else {
        moveImageHalfway();
      }
    } else {
      print("Error: words");
    }

    notifyListeners();
  }


  void moveImageToTop() {
      position = 400;
      notifyListeners();

      // Wait for animation to complete before setting opacity to 0
      Future.delayed(Duration(seconds: 1), () {
        alienOpacity = 0.0;  // Hide the image
        notifyListeners();
      });

  }


  void moveImageHalfway() {
    if (shouldAnimate) {
      position = 500;
      Future.delayed(const Duration(seconds: 1), () {
        position = 600;
        loseLife();
        notifyListeners();
      });
    }
  }

  void resetImagePosition() {
    position = 600; // Move back to the bottom
    Future.delayed(Duration(seconds: 1), () {
      alienOpacity = 1.0;  // show the image
      notifyListeners();
    });
  }

  void loseLife() {
    lives--;
    if (lives == 0) {
      endGame();
    }
    notifyListeners();
  }
//game logic for end the game
  void endGame() {
    gameEnded = true;
    notifyListeners();


    int correctlyPronouncedWords = xp ~/ 100; // Each correct word gives 100 XP

    // Calculate accuracy based on the number of correctly pronounced words vs total attempts
    //int totalAttempts = 30; //
    //double accuracy = (correctlyPronouncedWords / totalAttempts) * 100;

    // Navigate to EndingPage with only the correct data
    Future.microtask(() => Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EndingPage(
          correctlyPronouncedWords: correctlyPronouncedWords,
          //accuracy: accuracy,
          livesLeft: lives,
        ),
      ),
    ));
  }


}