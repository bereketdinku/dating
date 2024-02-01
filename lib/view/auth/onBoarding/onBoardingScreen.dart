import 'package:date/view/auth/onBoarding/First.dart';
import 'package:date/view/auth/onBoarding/Second.dart';
import 'package:date/view/auth/onBoarding/Thrid.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controller/auth_controller.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List onboardingPages = [FirstPage(), SecondPage(), ThridPage()];

  @override
  Widget build(BuildContext context) {
    var authenticationController =
        AuthenticationController.authenticationController;
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingPages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return onboardingPages[index];
            },
          ),
          Positioned(
            bottom: 20.0,
            left: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingPages.length,
                (index) => buildDot(index, _currentPage == index),
              ),
            ),
          ),
          Positioned(
            bottom: 20.0,
            right: 20.0,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage == onboardingPages.length - 1) {
                  // Navigate to the next screen or perform any action
                  // when the user clicks on the "Get Started" button
                  if (authenticationController.selectedInterests != null &&
                      authenticationController.bioController.text
                          .trim()
                          .isNotEmpty) {
                    authenticationController.createNewUser(
                        authenticationController.profileImage!,
                        authenticationController.ageController.text.trim(),
                        authenticationController.nameController.text
                            .trim()
                            .toUpperCase(),
                        authenticationController.emailController.text.trim(),
                        authenticationController.passwordController.text.trim(),
                        authenticationController.genderController.text
                            .toLowerCase(),
                        authenticationController.phoneController.text.trim(),
                        authenticationController.cityController.text
                            .trim()
                            .toUpperCase(),
                        authenticationController.countryController.text
                            .trim()
                            .toUpperCase(),
                        authenticationController.professionController.text
                            .trim(),
                        authenticationController.religionController.text.trim(),
                        authenticationController.selectedInterests,
                        authenticationController.bioController.text.trim());
                  } else {
                    Get.snackbar('missing feild', "fill bio and interests");
                  }
                } else {
                  if (_currentPage == 0) {
                    if (authenticationController.imageFile == null &&
                        authenticationController.nameController.text
                            .trim()
                            .isEmpty &&
                        authenticationController.emailController.text
                            .trim()
                            .isEmpty &&
                        authenticationController.passwordController.text
                            .trim()
                            .isEmpty) {
                      Get.snackbar("missing file", "fill all");
                    } else {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    }
                  } else {
                    if (authenticationController.genderController.text
                            .trim()
                            .isEmpty &&
                        authenticationController.ageController.text
                            .trim()
                            .isEmpty &&
                        authenticationController.religionController.text
                            .trim()
                            .isEmpty &&
                        authenticationController.cityController.text
                            .trim()
                            .isEmpty &&
                        authenticationController.countryController.text
                            .trim()
                            .isEmpty &&
                        authenticationController.professionController.text
                            .trim()
                            .isEmpty) {
                      Get.snackbar("missing field", "fill all");
                    } else {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    }
                  }
                }
              },
              child: Text(
                _currentPage == onboardingPages.length - 1 ? "Sign Up" : "Next",
                style: TextStyle(fontSize: 16.0, color: Colors.pink),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, bool isActive) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 10.0,
        width: 10.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.pink : Colors.grey,
        ),
      ),
    );
  }
}
