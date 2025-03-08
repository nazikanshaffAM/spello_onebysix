import 'package:flutter/material.dart';
import 'game_start_page.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

//this is a test backend that used to test the game and commented because no longer  use it
  //final backend = GameBackend();

  //try {
   // await backend.startServer(); // Start backend before launching UI
    //print(" Backend started successfully.");
  //} catch (e) {
    //print(" Error starting backend: $e");
  //}



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




