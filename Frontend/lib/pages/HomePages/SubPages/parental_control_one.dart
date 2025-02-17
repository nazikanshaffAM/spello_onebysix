import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:spello_frontend/util/custom_elevated_button.dart';

import '../../../util/parental_control_tile.dart';

class ParentalControlOne extends StatefulWidget {
  const ParentalControlOne({super.key});

  @override
  State<ParentalControlOne> createState() => _ParentalControlOneState();
}

class _ParentalControlOneState extends State<ParentalControlOne> {
  bool parentalToggle = false; // Holds the state of the toggle switch

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "PARENTAL CONTROL",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Fredoka One",
              fontSize: screenWidth * 0.06,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF3A435F),
      ),
      body: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.015,
          ), // Adds spacing above the toggle
          Center(
            child: Text(
              "Select the appropriate sounds",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.055, // Responsive font size
                  fontWeight: FontWeight.bold,
                  fontFamily: "Fredoka"),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.015,
          ), // Adds spacing below the toggle
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ControlPanelTiles(tileName: "P (pat)"),
                ControlPanelTiles(tileName: "B (bat)"),
                ControlPanelTiles(tileName: "T (top)"),
                ControlPanelTiles(tileName: "D (dog)"),
                ControlPanelTiles(tileName: "K (cat)"),
                ControlPanelTiles(tileName: "G (go)"),
                ControlPanelTiles(tileName: "M (man)"),
                ControlPanelTiles(tileName: "N (net)"),
                ControlPanelTiles(tileName: "NG (sing)"),
                ControlPanelTiles(tileName: "F (fan)"),
                ControlPanelTiles(tileName: "V (van)"),
                ControlPanelTiles(tileName: "S (sun)"),
                ControlPanelTiles(tileName: "Z (zoo)"),
                ControlPanelTiles(tileName: "SH (shoe)"),
                ControlPanelTiles(tileName: "ZH (measure)"),
                ControlPanelTiles(tileName: "L (lamp)"),
                ControlPanelTiles(tileName: "R (red)"),
                ControlPanelTiles(tileName: "TH (thin)"),
                ControlPanelTiles(tileName: "TH (this)"),
                ControlPanelTiles(tileName: "H (hat)"),
              ],
            ),
          ),
          SizedBox(
            height: screenHeight * 0.02,
          ),
          CustomElevatedButton(
              buttonLength: screenWidth * 0.7,
              buttonHeight: screenHeight * 0.055,
              buttonName: "Apply",
              primaryColor: 0xFFFFC000,
              shadowColor: 0xFFD29338,
              textColor: Colors.white,
              onPressed: () {}),
          SizedBox(
            height: screenHeight * 0.03,
          )
        ],
      ),
    );
  }
}
