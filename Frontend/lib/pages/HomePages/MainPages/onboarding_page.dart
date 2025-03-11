import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:spello_frontend/pages/HomePages/MainPages/homepage.dart';
import 'package:spello_frontend/pages/OnboardingPages/onboarding_screen_one.dart';
import 'package:spello_frontend/pages/OnboardingPages/onboarding_screen_three.dart';
import 'package:spello_frontend/pages/OnboardingPages/onboarding_screen_two.dart';
import 'package:spello_frontend/util/custom_elevated_button.dart';

class OnboardingPage extends StatefulWidget {
  final String name; // Add this line to accept the name

  const OnboardingPage({super.key, required this.name}); // Update constructor

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // creating a controller to keep track of the page we are on
  PageController controller = PageController();

  //value to keep track of whether its last page or not
  late bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    // Retrieve screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: const [
              OnboardingScreenOne(),
              OnboardingScreenTwo(),
              OnboardingScreenThree(),
            ],
          ),
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
          // Position the row at the bottom spanning the full width (or with horizontal padding)
          !onLastPage
              ? Positioned(
                  bottom: screenHeight * 0.1,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
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
                        // Smooth page indicator
                        // Next button (using your custom elevated button)
                        CustomElevatedButton(
                          buttonLength: screenWidth *
                              0.23, // dynamically adjust button width
                          buttonHeight: screenHeight *
                              0.05, // dynamically adjust button height
                          buttonName: "Next",
                          primaryColor: 0xFFFFC000,
                          shadowColor: 0xFFD29338,
                          textColor: Colors.white,
                          onPressed: () {
                            controller.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                            // Your button action goes here
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(
                              userData: {
                                'name':
                                    widget.name, // Pass the name to HomePage
                              },
                            ),
                          ),
                        );
                      }),
                )
        ],
      ),
    );
  }
}
