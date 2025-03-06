import 'package:flutter/material.dart';

class Gameresults extends StatefulWidget {
  const Gameresults({super.key});

  @override
  State<Gameresults> createState() => _GameresultsState();
}

class _GameresultsState extends State<Gameresults> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: screenHeight * 0.1,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset('assets/images/start.png', width: 60),
                Positioned(
                  left: -70,
                  top: 30,
                  child: Image.asset('assets/images/start.png', width: 50),
                ),
                Positioned(
                  right: -70,
                  top: 30,
                  child: Image.asset('assets/images/start.png', width: 50),
                ),
              ],
            ),
          ),
          Positioned(
            top: screenHeight * 0.2,
            left: screenWidth * 0.1,
            child: Container(
              height: screenHeight * 0.6,
              width: screenWidth * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.red,
                border: Border.all(color: Colors.yellow, width: 5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRoundButton(Icons.replay),
                      _buildRoundButton(Icons.home),
                      _buildRoundButton(Icons.share),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundButton(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: () {},
      ),
    );
  }
}
