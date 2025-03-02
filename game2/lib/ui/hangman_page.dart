import 'package:flutter/material.dart';
import 'package:hangman/ui/results_page.dart';
import '../engine/hangman.dart';

const List<String> progressImages = [
  'data_repo/img/progress_0.png',
  'data_repo/img/progress_1.png',
  'data_repo/img/progress_2.png',
  'data_repo/img/progress_3.png',
  'data_repo/img/progress_4.png',
  'data_repo/img/progress_5.png',
  'data_repo/img/progress_6.png',
  'data_repo/img/progress_7.png', // Losing stage (progress_7)
];

const String victoryImage = 'data_repo/img/victory.png';

const TextStyle activeWordStyle = TextStyle(
  fontSize: 30.0,
  letterSpacing: 5.0,
);

class HangmanPage extends StatefulWidget {
  final HangmanGame _engine;

  HangmanPage(this._engine);

  @override
  State<StatefulWidget> createState() => _HangmanPageState();
}

class _HangmanPageState extends State<HangmanPage> {
  bool _showNewGame = false;
  String _activeWord = '';
  String _activeImage = '';
  int _livesLeft = 7;
  int _accuracy = 0;
  String _feedbackMessage = '';
  bool _isGameOver = false;

  @override
  void initState() {
    super.initState();
    widget._engine.onWordChange.listen(this._updateWordDisplay);
    widget._engine.onLivesChange.listen(this._updateLives);
    widget._engine.onProgressChange.listen(this._updateProgress);
    widget._engine.onAccuracyChange.listen(this._updateAccuracy);
    widget._engine.onWin.listen(this._win);
    widget._engine.onLose.listen(this._lose);

    this._newGame();
  }

  void _updateWordDisplay(String word) {
    setState(() {
      _activeWord = word;
    });
  }

  void _updateLives(int lives) {
    setState(() {
      _livesLeft = lives;
      if (_livesLeft == 0) {
        _activeImage = progressImages[7];
      }
    });
  }

  void _updateProgress(int progress) {
    setState(() {
      _activeImage = progressImages[progress];
    });
  }

  void _updateAccuracy(int accuracy) {
    setState(() {
      _accuracy = accuracy;

      if (_accuracy >= 70) {
        _feedbackMessage = "Good job! Keep going!";
      } else {
        _feedbackMessage = "You got this! Try again harder.";
      }
    });
  }

  void _win([_]) {
    setState(() {
      _activeImage = victoryImage;
      _gameOver();
    });
  }

  void _lose([_]) {
    setState(() {
      _activeImage = progressImages[7];
      _isGameOver = true; // Disable further button presses when game is lost
    });

    Future.delayed(Duration(seconds: 1), () {
      _gameOver();
    });
  }

  void _gameOver([_]) {
    setState(() {
      _showNewGame = true;
    });

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

  void _newGame() {
    widget._engine.newGame();
    setState(() {
      _activeWord = '';
      _activeImage = '';
      _livesLeft = 7;
      _accuracy = 0;
      _feedbackMessage = '';
      _showNewGame = false;
      _isGameOver = false;
    });
  }

  void _simulatePronunciation() {
    if (!_isGameOver) {
      widget._engine.pronounceWord();
    }
  }

  Widget _renderProgressImage() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: Image.asset(
        _activeImage,
        key: ValueKey<String>(_activeImage), // Ensures the widget is replaced when the image changes
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _renderBottomContent() {
    if (_showNewGame) {
      return ElevatedButton(
        child: Text('New Game'),
        onPressed: this._newGame,
      );
    } else {
      return ElevatedButton(
        child: Text('Pronounce Word'),
        onPressed: _isGameOver ? null : _simulatePronunciation, // Disable button if game is over
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Hangman'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_activeImage.isNotEmpty) Expanded(child: _renderProgressImage()),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(_activeWord, style: activeWordStyle),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Lives: $_livesLeft'),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('Accuracy: $_accuracy%', style: TextStyle(fontSize: 18.0)),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                _feedbackMessage,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Center(child: this._renderBottomContent()),
            ),
          ],
        ),
      ),
    );
  }
}
