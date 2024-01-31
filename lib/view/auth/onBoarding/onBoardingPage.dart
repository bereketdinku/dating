import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imageAssetPath;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imageAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          imageAssetPath,
          height: 300.0,
        ),
        SizedBox(height: 30.0),
        Text(
          title,
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.0),
          ),
        ),
      ],
    );
  }
}
