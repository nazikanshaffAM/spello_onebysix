import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final Function(String) onBackgroundSelected; // Callback function

  const SettingsPage({super.key, required this.onBackgroundSelected});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<String> backgroundImages = [
    "assets/images/b1.jpg",
    "assets/images/b2.jpg",
    "assets/images/b3.jpg",
    "assets/images/b4.jpg",
    "assets/images/b5.jpg",
    "assets/images/b6.jpg",
  ];

  String selectedBackground = "";

  @override
  void initState() {
    super.initState();
    _loadSelectedBackground();
  }

  // Load the saved background selection
  Future<void> _loadSelectedBackground() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedBackground = prefs.getString("selectedBackground") ?? backgroundImages[0];
    });
  }

  // Save the selected background
  Future<void> _saveSelectedBackground(String background) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedBackground", background);
    widget.onBackgroundSelected(background); // Notify the main screen
    setState(() {
      selectedBackground = background;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Background",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columns
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2, // Adjust aspect ratio for better fit
                    ),
                    itemCount: backgroundImages.length,
                    itemBuilder: (context, index) {
                      String background = backgroundImages[index];
                      return GestureDetector(
                        onTap: () {
                          _saveSelectedBackground(background);
                        },
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selectedBackground == background
                                      ? Colors.blue
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                image: DecorationImage(
                                  image: AssetImage(background),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              color: Colors.black.withOpacity(0.5),
                              child: Text(
                                "Background ${index + 1}",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
