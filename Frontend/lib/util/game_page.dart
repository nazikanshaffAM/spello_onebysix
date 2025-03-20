import 'package:flutter/material.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/dashboard.dart';
import 'package:spello_frontend/util/game_card.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final List<Map<String, dynamic>> games = [
    {
      'name': 'Spelling Bee',
      'image': 'assets/images/game_one.png',
      'isRecommended': true,
      'route': '/dashboard'
    },
    {
      'name': 'Word Rush',
      'image': 'assets/images/game_two.png',
      'isRecommended': false,
      'route': '/dashboard'
    },
    {
      'name': 'ZIP & ZAP',
      'image': 'assets/images/game_three.png',
      'isRecommended': false,
      'route': '/dashboard'
    },
    {
      'name': ' Bee',
      'image': 'assets/images/game_one.png',
      'isRecommended': false,
      'route': '/dashboard'
    },
    {
      'name': 'Word ',
      'image': 'assets/images/game_two.png',
      'isRecommended': false,
      'route': '/dashboard'
    },
    {
      'name': 'ZIP ',
      'image': 'assets/images/game_three.png',
      'isRecommended': false,
      'route': '/dashboard'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.2,
            left: screenWidth * 0,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                "assets/images/cloud.png",
                width: screenWidth * 0.4,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.4,
            left: screenWidth * 0.8,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                "assets/images/cloud.png",
                width: screenWidth * 0.4,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.6,
            left: screenWidth * 0,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                "assets/images/cloud.png",
                width: screenWidth * 0.4,
              ),
            ),
          ),
          Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: screenHeight * 0.22,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4C5679),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: screenHeight * 0.05),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(width: screenWidth * 0.08),
                            CircleAvatar(
                              backgroundColor: Colors.white60,
                              radius: 30,
                              child: const CircleAvatar(
                                backgroundImage: AssetImage(
                                    'assets/images/profile_picture.png'),
                                backgroundColor: Colors.red,
                                radius: 25,
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tom Ford",
                                  style: TextStyle(
                                    fontFamily: "Fredoka",
                                    fontSize: screenHeight * 0.022,
                                    color: Colors.white70,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.yellow,
                                        size: screenHeight * 0.018),
                                    SizedBox(width: screenWidth * 0.01),
                                    Text(
                                      "250",
                                      style: TextStyle(
                                        fontFamily: "Fredoka",
                                        fontSize: screenHeight * 0.018,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          "Level 5",
                          style: TextStyle(
                            fontFamily: "Fredoka One",
                            fontSize: screenHeight * 0.035,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: screenHeight * 0.19,
                    left: screenWidth * 0.25,
                    child: Container(
                      height: screenHeight * 0.05,
                      width: screenWidth * 0.5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        height: screenHeight * 0.038,
                        width: screenWidth * 0.47,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color(0xFFFFC000),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Mini Games",
                          style: TextStyle(
                            fontFamily: "Fredoka One",
                            fontSize: screenWidth * 0.045,
                            color: Color(0xFF3A424F),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(right: screenWidth * 0.02),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: screenHeight * 0.025),
                      child: GameCard(
                        gameName: game['name']!,
                        imageName: game['image']!,
                        routeName: game['route']!,
                        isRecommended: game['isRecommended']!,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
