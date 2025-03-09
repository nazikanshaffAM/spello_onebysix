import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the services package
import 'package:spello_frontend/pages/HomePages/MainPages/dashboard.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/game_page.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/onboarding_page.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/parental_control.dart';
import 'package:spello_frontend/pages/HomePages/SubPages/page_under_construction.dart';

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
      home: OnboardingPage(),
      routes: {
        '/startPractice': (context) => const GamePage(), // Placeholder for now
        '/parentalControl': (context) => ParentalControl(),
        '/dashboard': (context) => Dashboard(),
        '/notifications': (context) => PageUnderConstruction(),
        '/settings': (context) => PageUnderConstruction(),
        '/helpCenter': (context) => PageUnderConstruction(),
      },
    );
  }
}
