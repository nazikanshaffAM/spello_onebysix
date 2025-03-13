import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/homepage.dart';
import 'package:spello_frontend/pages/OnboardingPages/onboarding_screen_one.dart';
import 'package:spello_frontend/pages/OnboardingPages/onboarding_screen_three.dart';
import 'package:spello_frontend/pages/OnboardingPages/onboarding_screen_two.dart';
import 'package:spello_frontend/util/custom_elevated_button.dart';

class OnboardingPage extends StatefulWidget {
  final Map<String, dynamic> userData; // Accept a map of user data

  const OnboardingPage({super.key, required this.userData});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // creating a controller to keep track of the page we are on
  PageController controller = PageController();
  
  // value to keep track of whether its last page or not
  bool onLastPage = false;
  
  // Store a local copy of userData to ensure data consistency
  late Map<String, dynamic> _userData;
  
  @override
  void initState() {
    super.initState();
    // Create a deep copy of the userData to prevent reference issues
    _userData = Map<String, dynamic>.from(widget.userData);
    
    // Debug prints to verify data is received correctly
    print('=' * 50 + ' ONBOARDING PAGE INITIALIZATION ' + '=' * 50);
    print('OnboardingPage received userData:');
    print('COMPLETE USER DATA: $_userData');
    
    // Verify all required fields exist
    final requiredKeys = ['name', 'email', 'age', 'gender'];
    for (final key in requiredKeys) {
      if (_userData.containsKey(key)) {
        print('✓ $key: ${_userData[key]}');
      } else {
        print('✗ MISSING KEY: $key');
        // Add default values for missing keys to prevent null errors
        switch (key) {
          case 'name':
            _userData[key] = 'User';
            break;
          case 'email':
            _userData[key] = '';
            break;
          case 'age':
            _userData[key] = '';
            break;
          case 'gender':
            _userData[key] = '';
            break;
        }
      }
    }
    print('=' * 100);
  }

  @override
  void dispose() {
    // Clean up controller when widget is disposed
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // PageView with the three onboarding screens
          PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: [
              OnboardingScreenOne(userData: _userData),
              OnboardingScreenTwo(userData: _userData),
              OnboardingScreenThree(userData: _userData),
            ],
          ),
          
          // Page indicator
          Positioned(
            bottom: screenHeight * 0.2,
            left: screenWidth * 0.4,
            child: SmoothPageIndicator(
              controller: controller,
              count: 3,
              effect: ExpandingDotsEffect(
                activeDotColor: Colors.white,
                dotColor: Colors.white.withOpacity(0.5),
                dotHeight: screenHeight * 0.01,
                dotWidth: screenWidth * 0.02,
                spacing: screenWidth * 0.02,
              ),
            ),
          ),
          
          // Navigation buttons (Skip/Next or Get Started)
          !onLastPage
              ? Positioned(
                  bottom: screenHeight * 0.1,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip button/text
                        GestureDetector(
                          onTap: () {
                            controller.jumpToPage(2);
                          },
                          child: Text(
                            "Skip",
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Next button
                        CustomElevatedButton(
                          buttonLength: screenWidth * 0.23,
                          buttonHeight: screenHeight * 0.05,
                          buttonName: "Next",
                          primaryColor: 0xFFFFC000,
                          shadowColor: 0xFFD29338,
                          textColor: Colors.white,
                          onPressed: () {
                            controller.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                          },
                        ),
                      ],
                    ),
                  ),
                )
              : Positioned(
                  bottom: screenHeight * 0.1,
                  left: screenWidth * 0.15,
                  child: CustomElevatedButton(
                    buttonLength: screenWidth * 0.7,
                    buttonHeight: screenHeight * 0.05,
                    buttonName: "Get Started",
                    primaryColor: 0xFFFFC000,
                    shadowColor: 0xFFD29338,
                    textColor: Colors.white,
                    onPressed: () {
                      // Debug print to check data before passing to HomePage
                      print('=' * 50 + ' NAVIGATING TO HOMEPAGE ' + '=' * 50);
                      print('User data being passed: $_userData');
                      
                      // Create a new copy of userData for HomePage to ensure data integrity
                      final homePageData = Map<String, dynamic>.from(_userData);
                      
                      // Use pushReplacement to avoid stacking screens
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(
                            userData: homePageData,
                          ),
                        ),
                      );
                      print('=' * 100);
                    },
                  ),
                )
        ],
      ),
    );
  }
}