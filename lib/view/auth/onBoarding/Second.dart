import 'dart:io';

import 'package:date/controller/auth_controller.dart';
import 'package:flutter/material.dart';

import '../../../widgets/custom_text_field.dart';

class SecondPage extends StatefulWidget {
  SecondPage();

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    String selectedGender = 'Select Gender';
    var authenticationController =
        AuthenticationController.authenticationController;
    ValueNotifier<String> genderNotifier =
        ValueNotifier<String>('Select Gender');

    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 70,
            ),
            Text(
              "I am a",
              style: TextStyle(color: Colors.black, fontSize: 22),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<String>(
                      valueListenable: genderNotifier,
                      builder: (context, value, child) {
                        return DropdownButton<String>(
                          alignment: Alignment.centerLeft,
                          hint: Text('Select Gender'),
                          value: value,
                          onChanged: (String? newValue) {
                            genderNotifier.value = newValue ?? 'Select Gender';
                            authenticationController.genderController.text =
                                genderNotifier.value;
                          },
                          items: ['Select Gender', 'Male', 'Female']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 35,
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 50,
              child: CustomTextField(
                isObsecure: false,
                editingController: authenticationController.ageController,
                labelText: "Age",
                iconData: Icons.numbers,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 50,
              child: CustomTextField(
                isObsecure: false,
                editingController: authenticationController.phoneController,
                labelText: "Phone",
                iconData: Icons.phone,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 50,
              child: CustomTextField(
                isObsecure: false,
                editingController: authenticationController.cityController,
                labelText: "City",
                iconData: Icons.location_city,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 50,
              child: CustomTextField(
                isObsecure: false,
                editingController: authenticationController.countryController,
                labelText: "Country",
                iconData: Icons.location_city,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 50,
              child: CustomTextField(
                isObsecure: false,
                editingController: authenticationController.religionController,
                labelText: "Religion",
                iconData: Icons.business_center,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              height: 50,
              child: CustomTextField(
                isObsecure: false,
                editingController:
                    authenticationController.professionController,
                labelText: "Profession",
                iconData: Icons.business_center,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    ));
  }
}
