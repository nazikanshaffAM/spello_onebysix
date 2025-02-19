import 'package:flutter/material.dart';
import 'StartPage.dart';

void main() {
  runApp(const VoiceGameApp());
}

class VoiceGameApp extends StatelessWidget {
  const VoiceGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Game',
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StartPage(),
    );
  }
}
