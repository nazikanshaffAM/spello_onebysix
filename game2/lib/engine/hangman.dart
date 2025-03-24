import 'dart:async';
import 'dart:math';

class HangmanGame {
  static const int maxLives = 7; // Maximum number of lives

  // List of words for the game
  final List<String> wordPool = [
    "Cat", "Pin", "Bun", "Red", "Sin",
    "Bat", "Sim", "Wow", "Cow", "Dim",
    "Ant", "Art", "Ask", "Bad", "Bag",
    "Bar", "Bat", "Bed", "Bet", "Bit",
    "Bot", "But", "Buy", "Cab", "Cap",
    "Car", "Cat", "Cot", "Cut", "Dad",
    "Day", "Dig", "Dot", "Dry", "Dub",
    "Due", "Dug", "Ear", "Eat", "Egg",
    "End", "Era", "Eve", "Eye", "Fan",
    "Far", "Fat", "Fix", "Fly", "Fog",
    "For", "Fox", "Fun", "Gem", "Get",
    "Gig", "Gin", "God", "Got", "Gun",
    "Gut", "Hat", "Haw", "Hey", "Hit",
    "Hot", "How", "Hum", "Jam", "Jet",
    "Jog", "Joy", "Jug", "Key", "Kid",
    "Kin", "Kit", "Let", "Lie", "Lip",
    "Log", "Low", "Man", "Map", "Mat",
    "Mix", "Mop", "Not", "Now", "Nut",
    "Oar", "Odd", "Off", "Ohm", "Oil",
    "Old", "Ony", "Opt", "Our", "Out",
    "Owl", "Own", "Pad", "Pal", "Pan",
    "Pat", "Pen", "Pet", "Pie", "Pig",
    "Pin", "Pit", "Pop", "Pot", "Pro",
    "Pug", "Pun", "Put", "Rad", "Ram",
    "Rat", "Ray", "Red", "Rep", "Rib",
    "Rig", "Rip", "Rod", "Rug", "Run",
    "Sad", "Sag", "Sat", "Saw", "Say",
    "Set", "Sew", "She", "Shy", "Sip",
    "Sit", "Sky", "Sly", "Sob", "Son",
    "Sun", "Tap", "Tar", "Tat", "Tie",
    "Tip", "Top", "Toy", "Try", "Tub",
    "Tug", "Use", "Van", "Vat", "Vet",
    "Vex", "Vet", "Wag", "War", "Was",
    "Way", "Web", "Wet", "Who", "Why",
    "Won", "Wow", "Yap", "Yen", "Yes",
    "Yet", "You", "Zip"
  ];

  late String wordToPronounce; // The current word to pronounce
  int _livesLeft; // Remaining lives
  int _letterIndex = 0; // Tracks progress in revealing the word
  int _accuracy = 0; // Last pronunciation accuracy score

  double _totalAccuracy = 0; // Sum of all accuracy scores
  int _wordsPlayed = 0; // Number of words played
  Map<String, double> wordPerformance = {}; // Stores accuracy for each word

  // Stream controllers to notify UI about game events
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

  // Constructor initializes the game
  HangmanGame() : _livesLeft = maxLives {
    _onWin = StreamController<Null>.broadcast();
    _onLose = StreamController<Null>.broadcast();
    _onLivesChange = StreamController<int>.broadcast();
    _onWordChange = StreamController<String>.broadcast();
    _onProgressChange = StreamController<int>.broadcast();
    _onAccuracyChange = StreamController<int>.broadcast();

    _selectNewWord(); // Pick a random word at the start
  }

  // Starts a new game by resetting values
  void newGame() {
    _livesLeft = maxLives;
    _letterIndex = 0;
    _accuracy = 0;
    _totalAccuracy = 0;
    _wordsPlayed = 0;
    wordPerformance.clear();

    _selectNewWord(); // Pick a new word for each new game

    _onLivesChange.add(_livesLeft);
    _onProgressChange.add(0);
    _onWordChange.add(wordForDisplay);
    _onAccuracyChange.add(_accuracy);
  }

  // Selects a new random word from the word pool
  void _selectNewWord() {
    final random = Random();
    wordToPronounce = wordPool[random.nextInt(wordPool.length)];
  }

  // Simulates pronunciation attempt
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

  // Returns the word with guessed letters revealed and remaining letters as underscores
  String get wordForDisplay {
    return wordToPronounce.substring(0, _letterIndex) +
        '_' * (wordToPronounce.length - _letterIndex);
  }

  // Simulates a pronunciation accuracy percentage (0-100)
  int _simulatePronunciationAccuracy() {
    Random random = Random();
    return random.nextInt(101);
  }

  // Updates accuracy data for the current word
  void _updateWordAccuracy(String word, int accuracy) {
    wordPerformance[word] = accuracy.toDouble();
    _totalAccuracy += accuracy;
    _wordsPlayed++;
  }

  // Calculates the average pronunciation accuracy
  double get averageAccuracy => _wordsPlayed == 0 ? 0 : _totalAccuracy / _wordsPlayed;
}
