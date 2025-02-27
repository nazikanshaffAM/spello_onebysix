import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For platform channels (optional)
import 'StartPage.dart';
import 'game_backend.dart'; // Import the backend

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure async code runs

  final backend = GameBackend();
  await backend.startServer(); // Start backend before UI

  runApp(const VoiceGameApp());
}

class VoiceGameApp extends StatelessWidget {
  const VoiceGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StartPage(),
    );
  }
}
