import 'package:flutter/material.dart';
import 'package:spello_frontend/util/play_button.dart';

class GameCard extends StatefulWidget {
  final String gameName;
  final String imageName;
  final String routeName;
  final bool isRecommended;
  final String description;

  const GameCard({
    super.key,
    required this.gameName,
    required this.imageName,
    required this.routeName,
    required this.isRecommended,
    required this.description,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Center(
          child: Container(
            height: screenHeight * 0.18,
            width: screenWidth * 0.80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(45),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF2E354E).withOpacity(0.7),
                  spreadRadius: 2,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
        ),

        // Positioned Game Image
        Positioned(
          left: screenWidth * 0.13,
          top: screenHeight * 0.022,
          child: Container(
            width: screenWidth * 0.25,
            height: screenWidth * 0.25,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                widget.imageName,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // Conditional "Recommended" Container
        if (widget.isRecommended)
          Positioned(
            left: screenWidth * 0.4,
            top: screenHeight * 0.14,
            child: Container(
              height: screenWidth * 0.06,
              width: screenWidth * 0.35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.red,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 13, right: 4),
                child: Text(
                  "Recommended",
                  style: TextStyle(
                    fontFamily: "Fredoka",
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ),
            ),
          ),

        // Positioned Game Name - Moving slightly right
        Positioned(
          left: screenWidth *
              0.45, // Increased from 0.43 to add more space from side
          top: screenHeight * 0.028,
          child: SizedBox(
            width: screenWidth * 0.43, // Adjusted width to fit within card
            child: Text(
              widget.gameName,
              style: TextStyle(
                fontSize: screenHeight * 0.022,
                fontFamily: "Fredoka",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Positioned Game Description - Increased spacing from game name
        Positioned(
          left: screenWidth * 0.45, // Same left alignment as game name
          top: screenHeight *
              0.07, // Increased from 0.055 to add more space from name
          child: SizedBox(
            width: screenWidth * 0.6, // Same width as game name
            child: Text(
              widget.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontFamily: "Fredoka",
                fontWeight: FontWeight.bold, // Changed to bold
                color:
                    Colors.grey[500], // Slightly darker for better readability
              ),
            ),
          ),
        ),

        // Positioned Play Button
        Positioned(
          right: screenWidth * 0.04,
          top: screenHeight * 0.12,
          child: PlayButton(onTap: widget.routeName),
        ),
      ],
    );
  }
}
