import 'dart:async';
import 'dart:math';

class HangmanGame {
  static const int maxLives = 7;

  final String wordToPronounce = "Octopus"; // Placeholder word
  int _livesLeft;
  int _letterIndex = 0;
  int _accuracy = 0;

  double _totalAccuracy = 0;
  int _wordsPlayed = 0;
  Map<String, double> wordPerformance = {};

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
    _totalAccuracy = 0;
    _wordsPlayed = 0;
    wordPerformance.clear();
    _onLivesChange.add(_livesLeft);
    _onProgressChange.add(0);
    _onWordChange.add(wordForDisplay);
    _onAccuracyChange.add(_accuracy);
  }

  void pronounceWord() {
    _accuracy = _simulatePronunciationAccuracy();
    _onAccuracyChange.add(_accuracy);

    _updateWordAccuracy(wordToPronounce, _accuracy);

    if (_accuracy >= 70) {
      if (_letterIndex < wordToPronounce.length) {
        _letterIndex++;
        _onWordChange.add(wordForDisplay);
      }
    } else {
      _livesLeft--;
      _onLivesChange.add(_livesLeft);
      _onProgressChange.add(maxLives - _livesLeft);

      if (_livesLeft == 0) {
        _onLose.add(null);
      }
    }

    if (_letterIndex == wordToPronounce.length) {
      _onWin.add(null);
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

  void _updateWordAccuracy(String word, int accuracy) {
    wordPerformance[word] = accuracy.toDouble();
    _totalAccuracy += accuracy;
    _wordsPlayed++;
  }

  double get averageAccuracy => _wordsPlayed == 0 ? 0 : _totalAccuracy / _wordsPlayed;
}
