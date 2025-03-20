import 'package:flutter/material.dart';
import 'package:spello_frontend/game1/screens/settings_page.dart';
import 'game_page.dart';
import 'how_to_play_page.dart';



class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/b5.jpg',
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildButton('NEW GAME', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Game1(),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    _buildButton('MAP', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(
                            onBackgroundSelected: (String newBackground) {
                              setState(() {}); //
                            },
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                    _buildButton('HOW TO PLAY', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HowtoPlayPage(),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 200,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0E3955),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 3,
        ),
        child: FittedBox(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 2,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}


