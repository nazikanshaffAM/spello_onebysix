import 'package:flutter/material.dart';
import 'screens/game_start_page.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();



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




