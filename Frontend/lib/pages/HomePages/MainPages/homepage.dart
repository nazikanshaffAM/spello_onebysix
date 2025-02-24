import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Track which tile is tapped
  int? _tappedIndex;

  // Grid data
  final List<Map<String, dynamic>> gridItems = [
    {
      'icon': "assets/images/start.png",
      'label': 'Start Practice',
      'navigateTo': "/startPractice",
    },
    {
      'icon': "assets/images/parental_control.png",
      'label': 'Parental Control',
      'navigateTo': "/parentalControl",
    },
    {
      'icon': "assets/images/dashboard.png",
      'label': 'Dashboard',
      'navigateTo': "/dashboard",
    },
    {
      'icon': "assets/images/notification.png",
      'label': 'Notifications',
      'navigateTo': "/notifications",
    },
    {
      'icon': "assets/images/settings.png",
      'label': 'Settings',
      'navigateTo': "/settings",
    },
    {
      'icon': "assets/images/help_center.png",
      'label': 'Help Center',
      'navigateTo': "/helpCenter",
    },
  ];

  void _onTileTap(int index, BuildContext context) {
    setState(() {
      _tappedIndex = index;
    });

    // Wait for 100 milliseconds to show the color change
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _tappedIndex = null; // Reset color
      });

      // Navigate to respective screen
      Navigator.pushNamed(context, gridItems[index]['navigateTo']);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double responsiveFontSize = screenWidth * 0.043;
    final double responsivePadding = screenWidth * 0.04;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80), // Increased height
        child: AppBar(
          backgroundColor: const Color(0xFF4C5679),
          title: Text(
            'Home',
            style: TextStyle(
              fontFamily: "Fredoka One",
              color: Colors.white,
              fontSize: screenWidth * 0.09,
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsivePadding),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.03), // Moves grid down
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.only(
                    top: screenHeight * 0.02), // Extra padding on top
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: screenWidth * 0.04,
                  mainAxisSpacing: screenWidth * 0.04,
                  childAspectRatio: 1.0,
                ),
                itemCount: gridItems.length,
                itemBuilder: (context, index) {
                  final bool isTapped = (_tappedIndex == index);

                  return GestureDetector(
                    onTap: () => _onTileTap(index, context),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: isTapped
                            ? const Color(0xFFFFC000) // Tapped color
                            : const Color(0xFFFFFFFF), // Default color
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isTapped
                                ? const Color(0xFF3A4562) // Darker shade on tap
                                : const Color(0xFF4C5679), // Normal state
                            offset: const Offset(0, 5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            gridItems[index]["icon"],
                            width: screenWidth * 0.18,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            gridItems[index]['label'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(
                                  0xFF3A4562), // Slightly darker font color
                              fontSize: responsiveFontSize,
                              fontFamily: "Fredoka One",
                              height:
                                  1.2, // Adjust line spacing for 'Parental Control'
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
