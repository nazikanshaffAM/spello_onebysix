import 'package:flutter/material.dart';

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
        body: Column(children: [
          SizedBox(
            height: screenHeight * 0.1,
          ),
          Center(
            child: Container(
              height: screenHeight * 0.6,
              width: screenWidth * 0.8,
              color: Colors.white,
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 20,
                child: Image.asset("assets/images/notification.png"),
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.2,
          )
        ]));
  }
}
