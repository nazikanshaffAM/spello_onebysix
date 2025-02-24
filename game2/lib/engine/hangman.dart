import 'dart:async';
import 'dart:math';

class HangmanGame {
  static const int maxLives = 7; // Original Hangman life system (7 incorrect attempts)

  final String wordToPronounce = "Apple"; // Placeholder word
  int _livesLeft;
  int _letterIndex = 0; // Tracks which letters are revealed
  int _accuracy = 0; // Tracks pronunciation accuracy

  late StreamController<Null> _onWin;
  Stream<Null> get onWin => _onWin.stream;

  late StreamController<Null> _onLose;
  Stream<Null> get onLose => _onLose.stream;

  late StreamController<int> _onLivesChange;
  Stream<int> get onLivesChange => _onLivesChange.stream;

  late StreamController<String> _onWordChange;
  Stream<String> get onWordChange => _onWordChange.stream;

  late StreamController<int> _onProgressChange;
  Stream<int> get onProgressChange => _onProgressChange.stream;

  late StreamController<int> _onAccuracyChange;
  Stream<int> get onAccuracyChange => _onAccuracyChange.stream;

  HangmanGame() : _livesLeft = maxLives {
    _onWin = StreamController<Null>.broadcast();
    _onLose = StreamController<Null>.broadcast();
    _onLivesChange = StreamController<int>.broadcast();
    _onWordChange = StreamController<String>.broadcast();
    _onProgressChange = StreamController<int>.broadcast();
    _onAccuracyChange = StreamController<int>.broadcast();
  }

  void newGame() {
    _livesLeft = maxLives;
    _letterIndex = 0;
    _accuracy = 0;
    _onLivesChange.add(_livesLeft);
    _onProgressChange.add(0); // No body parts drawn at the start
    _onWordChange.add(wordForDisplay);
    _onAccuracyChange.add(_accuracy);
  }

  void pronounceWord() {
    _accuracy = _simulatePronunciationAccuracy();
    _onAccuracyChange.add(_accuracy);

    if (_accuracy >= 0) {  // Changed condition to 70%
      // Simulate revealing a letter and no life lost
      if (_letterIndex < wordToPronounce.length) {
        _letterIndex++;
        _onWordChange.add(wordForDisplay);
      }
    } else {
      // Lose a life if accuracy is below 70%
      _livesLeft--;
      _onLivesChange.add(_livesLeft);
      _onProgressChange.add(maxLives - _livesLeft); // Progress = body parts drawn

      if (_livesLeft == 0) {
        _onLose.add(null); // Game over
      }
    }

    // Check if the word is completely revealed (win condition)
    if (_letterIndex == wordToPronounce.length) {
      _onWin.add(null); // Trigger win condition
    }
  }

  String get wordForDisplay {
    return wordToPronounce.substring(0, _letterIndex) +
        '_' * (wordToPronounce.length - _letterIndex);
  }

  int _simulatePronunciationAccuracy() {
    Random random = Random();
    return random.nextInt(101); // Simulate accuracy between 0 and 100
  }
}
