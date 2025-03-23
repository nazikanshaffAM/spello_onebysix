import 'package:flutter/material.dart';
import 'package:spello_frontend/util/custom_elevated_button.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<String> notifications = [];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFF8092CC),
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(
            fontFamily: "Fredoka One",
            fontSize: screenWidth * 0.07,
          ),
        ),
        backgroundColor: const Color(0xFF3A435F),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.1,
            child: Image.asset(
              "assets/images/cloud.png",
              width: screenWidth * 0.3,
            ),
          ),
          Positioned(
            top: screenHeight * 0.15,
            right: screenWidth * 0.1,
            child: Image.asset(
              "assets/images/cloud.png",
              width: screenWidth * 0.25,
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.15,
            left: screenWidth * 0.2,
            child: Image.asset(
              "assets/images/cloud.png",
              width: screenWidth * 0.35,
            ),
          ),
          Column(
            children: [
              SizedBox(height: screenHeight * 0.1),
              Center(
                child: Container(
                  height: screenHeight * 0.6,
                  width: screenWidth * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white60,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFF3A435F),
                        radius: 60,
                        child: Image.asset("assets/images/notification.png"),
                      ),
                      SizedBox(height: screenHeight * 0.05),
                      Text(
                        "No notifications yet",
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Fredoka One",
                          color: Color(0xFF3A435F),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "Notifications will appear here",
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontStyle: FontStyle.italic,
                          fontFamily: "Fredoka",
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A435F),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.09),
                      CustomElevatedButton(
                        buttonLength: screenWidth * 0.4,
                        buttonHeight: screenHeight * 0.04,
                        buttonName: "Back",
                        primaryColor: 0xFFFFC000,
                        shadowColor: 0xFFD29338,
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
