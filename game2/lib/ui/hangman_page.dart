import 'dart:math'; // Importing dart:math for generating random feedback messages

import 'package:flutter/material.dart'; // Importing Flutter material package for UI components
import 'package:hangman/ui/results_page.dart'; // Importing results page
import 'package:hangman/ui/settings_page.dart'; // Importing settings page
import '../engine/hangman.dart'; // Importing the Hangman game engine

// List of images representing the game's progress
const List<String> progressImages = [
  'data_repo/img/prog0.png', // Initial stage
  'data_repo/img/prog1.png',
  'data_repo/img/prog2.png',
  'data_repo/img/prog3.png',
  'data_repo/img/prog4.png',
  'data_repo/img/prog5.png',
  'data_repo/img/prog6.png',
  'data_repo/img/prog7.png', // Losing stage
];

// Image displayed upon victory
const String victoryImage = 'data_repo/img/progvic.png';

// Text style for displaying the active word
const TextStyle activeWordStyle = TextStyle(
  fontSize: 30.0, // Font size of 30
  letterSpacing: 5.0, // Space between letters
);

// Stateful widget for the Hangman game page
class HangmanPage extends StatefulWidget {
  final HangmanGame _engine; // Instance of the Hangman game engine

  HangmanPage(this._engine); // Constructor

  @override
  State<StatefulWidget> createState() => _HangmanPageState();
}

// State class for HangmanPage
class _HangmanPageState extends State<HangmanPage> {
  bool _showNewGame = false; // Flag to show new game button
  String _activeWord = ''; // Current word being guessed
  String _activeImage = ''; // Current progress image
  int _livesLeft = 7; // Remaining lives
  int _accuracy = 0; // Last pronunciation accuracy percentage
  String _feedbackMessage = ''; // Feedback message for the player
  bool _isGameOver = false; // Flag indicating game over state

  @override
  void initState() {
    super.initState();
    // Listening to game engine events and updating UI accordingly
    widget._engine.onWordChange.listen(this._updateWordDisplay);
    widget._engine.onLivesChange.listen(this._updateLives);
    widget._engine.onProgressChange.listen(this._updateProgress);
    widget._engine.onAccuracyChange.listen(this._updateAccuracy);
    widget._engine.onWin.listen(this._win);
    widget._engine.onLose.listen(this._lose);

    this._newGame(); // Start a new game on initialization
  }

  // Updates the displayed word
  void _updateWordDisplay(String word) {
    setState(() {
      _activeWord = word;
    });
  }

  // Updates the number of lives left
  void _updateLives(int lives) {
    setState(() {
      _livesLeft = lives;
      if (_livesLeft == 0) {
        _activeImage = progressImages[7]; // Set losing image
      }
    });
  }

  // Updates the progress image based on game progress
  void _updateProgress(int progress) {
    setState(() {
      _activeImage = progressImages[progress];
    });
  }

  // Updates accuracy and provides feedback
  void _updateAccuracy(int accuracy) {
    setState(() {
      _accuracy = accuracy;

      // Positive feedback messages
      List<String> positiveFeedback = [
        "Great work! Keep it up!",
        "You're doing awesome!",
        "Nice pronunciation!",
        "Fantastic effort!",
        "Keep going, you're nailing it!"
      ];

      // Negative feedback messages
      List<String> negativeFeedback = [
        "Almost there! Try again!",
        "Don't give up! You got this!",
        "A little more effort, and you'll ace it!",
        "Keep practicing! You'll get it!",
        "Stay focused! Try again!"
      ];

      // Choose feedback based on accuracy threshold
      if (_accuracy >= 70) {
        _feedbackMessage = positiveFeedback[Random().nextInt(positiveFeedback.length)];
      } else {
        _feedbackMessage = negativeFeedback[Random().nextInt(negativeFeedback.length)];
      }
    });
  }

  // Handles win condition
  void _win([_]) {
    setState(() {
      _activeImage = victoryImage; // Show victory image
      _gameOver(); // End game
    });
  }

  // Handles lose condition
  void _lose([_]) {
    setState(() {
      _activeImage = progressImages[7]; // Set losing image
      _isGameOver = true; // Disable further input
    });

    Future.delayed(Duration(seconds: 1), () {
      _gameOver(); // Transition to game over screen after delay
    });
  }

  // Handles game over state
  void _gameOver([_]) {
    setState(() {
      _showNewGame = true; // Show new game button
    });

    // Navigate to results page with final stats
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          averageAccuracy: widget._engine.averageAccuracy,
          livesLeft: _livesLeft,
        ),
      ),
    );
  }

  // Starts a new game
  void _newGame() {
    widget._engine.newGame();
    setState(() {
      _activeWord = ''; // Reset word
      _activeImage = ''; // Reset image
      _livesLeft = 7; // Reset lives
      _accuracy = 0; // Reset accuracy
      _feedbackMessage = ''; // Clear feedback
      _showNewGame = false; // Hide new game button
      _isGameOver = false; // Reset game over flag
    });
  }

  // Simulates pronunciation attempt
  void _simulatePronunciation() {
    if (!_isGameOver) {
      widget._engine.pronounceWord(); // Call engine's pronunciation method
    }
  }

  // Renders the hangman progress image
  Widget _renderProgressImage() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300), // Smooth transition effect
      child: Image.asset(
        _activeImage,
        key: ValueKey<String>(_activeImage), // Ensures image updates properly
        fit: BoxFit.contain, // Adjusts image fit
      ),
    );
  }

  // Renders the bottom button (either "New Game" or "Pronounce Word")
  Widget _renderBottomContent() {
    if (_showNewGame) {
      return ElevatedButton(
        child: Text('New Game'),
        onPressed: this._newGame, // Start a new game when pressed
      );
    } else {
      return ElevatedButton(
        child: Text('Pronounce Word'),
        onPressed: _isGameOver ? null : _simulatePronunciation, // Disable if game is over
      );
    }
  }

  // Builds the UI for the Hangman game
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color
      appBar: AppBar(
        title: Text('Hangman'), // App title
        backgroundColor: Colors.white, // AppBar background color
        elevation: 0, // No shadow
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // Back button
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black,), // Settings button
            onPressed: () {
              // Navigate to the settings page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center all elements
          children: <Widget>[
            if (_activeImage.isNotEmpty) Expanded(child: _renderProgressImage()), // Show hangman image
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(_activeWord, style: activeWordStyle), // Display active word
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Lives: $_livesLeft',
              style: TextStyle(fontSize: 17, color: Colors.deepOrange),), // Show remaining lives
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('Accuracy: $_accuracy%', style: TextStyle(fontSize: 20.0, color: Colors.green)), // Show accuracy
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                _feedbackMessage, // Show feedback message
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Center(child: this._renderBottomContent()), // Render action button
            ),
          ],
        ),
      ),
    );
  }
}
