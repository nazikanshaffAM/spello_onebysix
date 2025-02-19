import 'package:flutter/material.dart';

class EndingPage extends StatelessWidget {
  const EndingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF6B96AB),
      ),
      body: const Center(
        child: Text(
          'This is the ending page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
