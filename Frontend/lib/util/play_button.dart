import 'package:flutter/material.dart';

class PlayButton extends StatefulWidget {
  String onTap;
  PlayButton({super.key, required this.onTap});

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFFC000),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFD29338),
            offset: Offset(2, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          splashColor: Colors.orange.withOpacity(0.5),
          highlightColor: Colors.orange.withOpacity(0.7),
          onTap: () {
            Navigator.pushNamed(
                context, widget.onTap); // Replace with the correct route name
          },
          child: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}
