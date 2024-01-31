import 'dart:io';

import 'package:date/controller/auth_controller.dart';
import 'package:flutter/material.dart';

import '../../../services/interest.dart';
import '../../../widgets/custom_text_field.dart';

class ThridPage extends StatefulWidget {
  ThridPage();

  @override
  State<ThridPage> createState() => _ThridPageState();
}

class _ThridPageState extends State<ThridPage> {
  List<Interest> availableInterests = [
    Interest(name: 'Photography', image: 'assets/images/camera.png'),
    Interest(name: 'Shopping', image: 'assets/images/weixin-market.png'),
    Interest(name: 'Cooking', image: 'assets/images/noodles.png'),
    Interest(name: 'Tennis', image: 'assets/images/voice.png'),
    Interest(name: 'Run', image: 'assets/images/voice.png'),
    Interest(name: 'Swimming', image: 'assets/images/voice.png'),
    Interest(name: 'Art', image: 'assets/images/voice.png'),
    Interest(name: 'Traveling', image: 'assets/images/voice.png'),
    Interest(name: 'Extreme', image: 'assets/images/voice.png'),
    Interest(name: 'Drink', image: 'assets/images/voice.png'),
    Interest(name: 'Music', image: 'assets/images/music.png'),
    Interest(name: 'Video games', image: 'assets/images/game-handle.png'),
    // Add
  ];
  @override
  Widget build(BuildContext context) {
    String? selectedGender;
    var authenticationController =
        AuthenticationController.authenticationController;
    List<bool> selectedList = List.generate(12, (index) => false);
    return Scaffold(
      appBar: AppBar(),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 50),
        itemCount: availableInterests.length,
        itemBuilder: (context, index) {
          final isSelected = authenticationController.selectedInterests
              .contains(availableInterests[index].name);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  authenticationController.selectedInterests
                      .remove(availableInterests[index].name);
                } else {
                  authenticationController.selectedInterests
                      .add(availableInterests[index].name);
                }
              });
            },
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  color: selectedList[index] ? Colors.pink : Colors.pink,
                  borderRadius:
                      BorderRadius.circular(20)), // Adjust the height as needed

              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    availableInterests[index].image,
                    width: 30, // Adjust the width as needed
                    height: 30, // Adjust the height as needed
                  ),
                  SizedBox(height: 4), // Adjust the spacing as needed
                  Text(
                    availableInterests[index].name,
                    style: TextStyle(
                      fontSize: 12, // Adjust the font size as needed
                      color: selectedList[index] ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
