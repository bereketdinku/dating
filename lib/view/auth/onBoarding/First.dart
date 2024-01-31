import 'dart:io';

import 'package:date/controller/auth_controller.dart';
import 'package:flutter/material.dart';

import '../../../widgets/custom_text_field.dart';

class FirstPage extends StatefulWidget {
  FirstPage();

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    var authenticationController =
        AuthenticationController.authenticationController;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
              ),
              Text(
                "Profile details",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
              ),
              SizedBox(
                height: 30,
              ),
              authenticationController.imageFile == null
                  ? CircleAvatar(
                      radius: 80,
                      backgroundImage:
                          AssetImage('assets/images/profile_avatar.jpg'),
                      backgroundColor: Colors.black,
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                              fit: BoxFit.fitHeight,
                              image: FileImage(File(
                                  authenticationController.imageFile!.path)))),
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () async {
                        await authenticationController
                            .pickImageFileFromGallery();
                        setState(() {
                          authenticationController.imageFile;
                        });
                      },
                      icon: Icon(
                        Icons.image_outlined,
                        color: Colors.grey,
                        size: 30,
                      )),
                  SizedBox(
                    width: 15,
                  ),
                  IconButton(
                      onPressed: () async {
                        await authenticationController.captureImageFromPhone();
                        setState(() {
                          authenticationController.imageFile;
                        });
                      },
                      icon: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.grey,
                        size: 30,
                      ))
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                child: CustomTextField(
                  isObsecure: false,
                  editingController: authenticationController.nameController,
                  labelText: "name",
                  iconData: Icons.person,
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
                  editingController: authenticationController.emailController,
                  labelText: "email",
                  iconData: Icons.email_outlined,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                child: CustomTextField(
                  isObsecure: true,
                  editingController:
                      authenticationController.passwordController,
                  labelText: "******",
                  iconData: Icons.person,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
