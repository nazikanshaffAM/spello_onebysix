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
      'isRecommended': true
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
              // Reduced Top Container
              Container(
                height: screenHeight * 0.22, // Reduced from 0.3
                decoration: const BoxDecoration(
                  color: Color(0xFF4C5679),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05), // Reduced spacing
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: screenWidth * 0.08),
                        CircleAvatar(
                          backgroundColor: Colors.white60,
                          radius: 22, // Reduced from 24
                          child: const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/start.png'),
                            backgroundColor: Colors.red,
                            radius: 18, // Reduced from 20
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
                                fontSize: screenHeight * 0.022, // Reduced size
                                color: Colors.white70,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.star,
                                    color: Colors.yellow,
                                    size: screenHeight * 0.018), // Reduced size
                                SizedBox(width: screenWidth * 0.01),
                                Text(
                                  "250",
                                  style: TextStyle(
                                    fontFamily: "Fredoka",
                                    fontSize:
                                        screenHeight * 0.018, // Reduced size
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01), // Reduced spacing
                    Text(
                      "Level 5",
                      style: TextStyle(
                        fontFamily: "Fredoka One",
                        fontSize: screenHeight * 0.035, // Reduced size
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Adjusted "Mini Games" Container (Overlapping)
              Positioned(
                top: screenHeight * 0.19, // Adjusted to overlap halfway
                left: screenWidth * 0.25, // Centered
                child: Container(
                  height: screenHeight * 0.05, // Reduced height
                  width: screenWidth * 0.5, // Reduced width
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
                    height: screenHeight * 0.038, // Adjusted inner container
                    width: screenWidth * 0.47, // Adjusted width
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFFFFC000),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Mini Games",
                      style: TextStyle(
                        fontFamily: "Fredoka One",
                        fontSize: screenWidth * 0.045, // Adjusted font size
                        color: Color(0xFF3A424F),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.05), // Adjusted spacing
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
