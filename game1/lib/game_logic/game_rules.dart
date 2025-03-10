import 'package:flutter/material.dart';
import '../service/api_service.dart';
import '../screens/ending_page.dart';


class GameRules extends ChangeNotifier {
  BuildContext context;
  double position = 600;
  int xp = 0;
  int lives = 3;
  int timeLeft = 30;
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
  String sampleEmail = "xyz@gmail.com";
  List<String> selectedSounds = ['p', 'b', 't'];



  GameRules(this.context) {
    initializeGame(sampleEmail, selectedSounds);
  }

  // Fetch the first word
  //Future<void> initializeGame1() async {
   // word = "Loading..."; // Temporary placeholder until the words are loading from the backend
   // notifyListeners(); //

    //try {
      //String? fetchedWord = await ApiService.fetchTargetWord('',);
      //if (fetchedWord != null && fetchedWord.isNotEmpty) {
        //word = fetchedWord;
      //} else {
        //word = "default"; // Fallback word
      //}
    //} catch (e) {
      //word = "Error fetching word";
    //}

    //notifyListeners();
    //();
  //}
//second methode to work with new backend update
  Future<void> initializeGame(String email, List<String> selectedSounds) async {
    word = "Loading..."; // Temporary placeholder until the words are loading from the backend
    notifyListeners(); // Notify listeners that the word is being loaded

    try {
      // Fetch the target word from the API by passing email and selected sounds
      String? fetchedWord = await ApiService.fetchTargetWord(email, selectedSounds);

      if (fetchedWord != null && fetchedWord.isNotEmpty) {
        word = fetchedWord;
      } else {
        word = "default"; // Fallback word if the fetched word is empty
      }
    } catch (e) {
      word = "Error fetching word"; // Handle the error case
    }

    notifyListeners(); // Notify listeners once the word is set
    startTimer(); // Start the game timer (you might want to adjust how/where this is called)
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
    int? accuracy = await ApiService.uploadAudio(filePath);

    if (accuracy != null) {
      if (accuracy >= 75) {
        moveImageToTop();
        Future.delayed(const Duration(seconds: 1), () async {
          //updateAlienOpacity(0.0);
          resetImagePosition();
          //updateAlienOpacity(1.0);
          xp += 100;

          // Fetch the next word after pronunciation check
          String? fetchedWord = await ApiService.fetchTargetWord(sampleEmail, selectedSounds);
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
      print("Error: Could not fetch pronunciation accuracy.");
    }

    notifyListeners();
  }


  void moveImageToTop() {
      position = 200;
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