import 'package:flutter/material.dart';

class GameDataScreen extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String gameName;

  const GameDataScreen({
    Key? key, 
    required this.userData,
    required this.gameName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Debug print to check what data we received
    print("GameDataScreen received: userData=$userData, gameName=$gameName");

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$gameName Data",
          style: TextStyle(
            fontFamily: "Fredoka One", 
            fontSize: screenWidth * 0.06
          ),
        ),
        backgroundColor: const Color(0xFF3A435F),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background clouds
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.6,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                "assets/images/cloud.png",
                width: screenWidth * 0.4,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.3,
            right: screenWidth * 0.6,
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                "assets/images/cloud.png",
                width: screenWidth * 0.4,
              ),
            ),
          ),
          
          // Main content
          Center(
            child: Container(
              width: screenWidth * 0.9,
              padding: EdgeInsets.all(screenWidth * 0.05),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "$gameName Data",
                      style: TextStyle(
                        fontFamily: "Fredoka One",
                        fontSize: screenWidth * 0.06,
                        color: Color(0xFF3A435F),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  
                  // User data display - Add null checks for all fields
                  _buildDataRow(context, "Name", "${userData["name"] ?? "Not provided"}"),
                  _buildDataRow(context, "Email", "${userData["email"] ?? "Not provided"}"),
                  _buildDataRow(context, "Score", "${userData["score"] ?? "Not provided"}"),
                  _buildDataRow(context, "Level", "${userData["level"] ?? "Not provided"}"),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Button to return to games page
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A435F),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                          vertical: screenHeight * 0.015,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Back to Games",
                        style: TextStyle(
                          fontFamily: "Fredoka",
                          fontSize: screenWidth * 0.045,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDataRow(BuildContext context, String label, String value) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.015),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontFamily: "Fredoka",
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3A435F),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: "Fredoka",
                fontSize: 16,
                color: Color(0xFF3A435F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}