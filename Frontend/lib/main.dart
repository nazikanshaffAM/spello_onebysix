import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the services package
import 'package:spello_frontend/pages/HomePages/MainPages/dashboard.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/game_data_screen.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/game_page.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/help_center.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/homepage.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/notifications_page.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/onboarding_page.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/parental_control.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/settings.dart';
import 'package:spello_frontend/pages/HomePages/SubPages/page_under_construction.dart';
import 'package:spello_frontend/pages/LoginRelatedPages/RegistrationScreen.dart';
import 'package:spello_frontend/pages/LoginRelatedPages/login.dart';
import 'package:spello_frontend/config/config.dart';

import 'game1/screens/game_start_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Lock to portrait mode
    // DeviceOrientation.portraitDown, // Optional: Allow upside-down portrait
  ]).then((_) {
    runApp(const MyApp()); // Start your app
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF8092CC)),
      home: LoginPage(),
      // home: HomeScreen(
      //   userData: {'name': 'John Doe', 'email': 'johndoe@example.com'}),
      routes: {
        '/login': (context) => LoginPage(),
        '/startPractice': (context) => GamePage(
              userData: ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>? ??
                  {},
            ),
        '/parentalControl': (context) => ParentalControl(
              userData: ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>? ??
                  {},
            ),
        '/dashboard': (context) => Dashboard(
              baseUrl: Config.baseUrl,
              userData: ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>? ??
                  {},
            ),
        '/notifications': (context) => NotificationsPage(),
        '/game1': (context) => StartPage(),
        '/settings': (context) => Settings(
              userData: ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>? ??
                  {},
            ),
        '/helpCenter': (context) => HelpCenterPage(),
        '/game-data': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return GameDataScreen(
            userData: args?['userData'] ?? {},
            gameName: args?['gameName'] ?? 'Game',
          );
        },
      },
    );
  }
}
