import 'package:flutter/material.dart';
import 'StartPage.dart';
import 'game_backend.dart'; // Import the backend

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures async operations work

  final backend = GameBackend();

  try {
    await backend.startServer(); // Start backend before launching UI
    print(" Backend started successfully.");
  } catch (e) {
    print(" Error starting backend: $e");
  }

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




