import 'package:flutter/material.dart';
import 'package:spello_frontend/util/play_button.dart';

class GameCard extends StatefulWidget {
  final String gameName;
  final String imageName;
  final Function onTap;
  final bool isRecommended;

  const GameCard(
      {super.key,
      required this.gameName,
      required this.imageName,
      required this.onTap,
      required this.isRecommended});

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
            ),
          ),
        ),

        // Positioned Game Image
        Positioned(
          left: screenWidth * 0.13, // Moves right
          top: screenHeight * 0.022, // Moves up
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
            left: screenWidth * 0.4, // Moves right
            top: screenHeight * 0.14,
            child: Container(
              height: screenWidth * 0.06,
              width: screenWidth * 0.35,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30), color: Colors.red),
              child: Padding(
                padding: const EdgeInsets.only(left: 13, right: 4),
                child: Text(
                  "Recommended",
                  style: TextStyle(
                      fontFamily: "Fredoka",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.04),
                ),
              ),
            ),
          ),

        // Positioned Game Name
        Positioned(
          left: screenWidth * 0.43, // Moves right
          top: screenHeight * 0.028, // Moves up
          child: SizedBox(
            width: screenWidth * 0.45, // Limits width
            child: Text(
              widget.gameName,
              style: TextStyle(
                  fontSize: screenHeight * 0.022, // Bigger font
                  fontFamily: "Fredoka",
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // Positioned Play Button
        // Positioned Play Button
        Positioned(
          right: screenWidth * 0.04, // Move left
          top: screenHeight * 0.11, // Move down slightly
          child: PlayButton(onTap: widget.onTap),
        ),
      ],
    );
  }
}
