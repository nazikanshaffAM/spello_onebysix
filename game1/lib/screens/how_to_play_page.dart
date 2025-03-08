import 'package:flutter/material.dart';

class HowtoPlayPage extends StatelessWidget {
  const HowtoPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How to play'),
        backgroundColor: const Color(0xFF6B96AB),
      ),
      body: const Center(
        child: Text(
          'need to implement',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
