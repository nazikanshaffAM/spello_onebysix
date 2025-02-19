import 'package:flutter/material.dart';
import 'ApiService.dart';


class GameRules extends StatefulWidget {
  @override
  _MovingImageGameState createState() => _MovingImageGameState();
}

class _MovingImageGameState extends State<GameRules> {
  double _position = 500; // Initial position (bottom)
  int _randomValue = 50; // Default value

  void fetchAndAnimate() async {
    int value = await ApiService.fetchRandomValue();

    setState(() {
      _randomValue = value;
      if (_randomValue >= 75) {
        _position = -50; // Move up and disappear
      } else {
        _position = 200; // Move halfway up, then drop back
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _position = 500;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Moving Image Game")),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: Image.asset('assets/images/ufo.png', width: 100),
          ),
          AnimatedPositioned(
            duration: Duration(seconds: 2),
            top: _position,
            left: MediaQuery.of(context).size.width / 2 - 50,
            child: Image.asset('assets/images/character.png', width: 100),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Random Value: $_randomValue", style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: fetchAndAnimate,
                  child: Text("Get Random & Animate"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
