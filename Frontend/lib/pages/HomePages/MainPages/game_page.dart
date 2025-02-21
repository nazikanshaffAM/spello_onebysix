import 'package:flutter/material.dart';
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
      'isRecommended': false
    },
    {
      'name': 'Word Rush',
      'image': 'assets/images/game_two.png',
      'isRecommended': false
    },
    {
      'name': 'ZIP & ZAP',
      'image': 'assets/images/game_three.png',
      'isRecommended': false
    },
    {
      'name': 'Spelling Bee',
      'image': 'assets/images/game_one.png',
      'isRecommended': true
    },
    {
      'name': 'Word Rush',
      'image': 'assets/images/game_two.png',
      'isRecommended': false
    },
    {
      'name': 'Letter Jumper',
      'image': 'assets/images/game_three.png',
      'isRecommended': false
    },
    {
      'name': 'Spelling Bee',
      'image': 'assets/images/game_one.png',
      'isRecommended': true
    },
    {
      'name': 'Word Rush',
      'image': 'assets/images/game_two.png',
      'isRecommended': false
    },
    {
      'name': 'Letter Jumper',
      'image': 'assets/images/game_three.png',
      'isRecommended': false
    },
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: screenHeight * 0.3,
                decoration: const BoxDecoration(
                  color: Color(0xFF4C5679),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.07),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: screenWidth * 0.08),
                        CircleAvatar(
                          backgroundColor: Colors.white60,
                          radius: 24,
                          child: const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/start.png'),
                            backgroundColor: Colors.red,
                            radius: 20,
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
                                fontSize: screenHeight * 0.025,
                                color: Colors.white70,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    color: Colors.yellow,
                                    size: screenHeight * 0.02),
                                SizedBox(width: screenWidth * 0.01),
                                Text(
                                  "250",
                                  style: TextStyle(
                                    fontFamily: "Fredoka",
                                    fontSize: screenHeight * 0.02,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      "Level 5",
                      style: TextStyle(
                        fontFamily: "Fredoka One",
                        fontSize: screenHeight * 0.045,
                        color: Colors.white,
                      ),
                    ),
                    // Text(
                    //   "Your Level",
                    //   style: TextStyle(
                    //     fontFamily: "Fredoka",
                    //     fontSize: screenHeight * 0.02,
                    //     color: Colors.white70,
                    //   ),
                    // ),
                  ],
                ),
              ),
              Positioned(
                top: screenHeight * 0.265,
                left: screenWidth * 0.2,
                child: Container(
                  height: screenHeight * 0.06,
                  width: screenWidth * 0.6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    height: screenHeight * 0.045,
                    width: screenWidth * 0.55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Color(0xFFFFC000),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Mini Games",
                      style: TextStyle(
                        fontFamily: "Fredoka One",
                        fontSize: screenWidth * 0.05,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.06),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(right: screenWidth * 0.02),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.03),
                  child: GameCard(
                    gameName: game['name']!,
                    imageName: game['image']!,
                    onTap: () {
                      print("Tapped on ${game['name']}");
                    },
                    isRecommended: game['isRecommended']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
