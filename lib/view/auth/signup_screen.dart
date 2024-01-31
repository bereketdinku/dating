import "dart:io";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

import "../../controller/auth_controller.dart";
import "../../widgets/custom_text_field.dart";

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController ageTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController cityTextEditingController = TextEditingController();
  TextEditingController countryTextEditingController = TextEditingController();
  TextEditingController profileHeadingTextEditingController =
      TextEditingController();
  TextEditingController imagePartnerTextEditingController =
      TextEditingController();
  TextEditingController heightTextEditingController = TextEditingController();
  TextEditingController widthTextEditingController = TextEditingController();
  TextEditingController bodyTypeTextEditingController = TextEditingController();
  TextEditingController drinkTextEditingController = TextEditingController();
  TextEditingController smokeTextEditingController = TextEditingController();
  TextEditingController martialStatusTextEditingController =
      TextEditingController();
  TextEditingController haveChildrenTextEditingController =
      TextEditingController();
  TextEditingController noChildrenTextEditingController =
      TextEditingController();
  TextEditingController professionTextEditingController =
      TextEditingController();
  TextEditingController employmentStatusTextEditingController =
      TextEditingController();
  TextEditingController incomeTextEditingController = TextEditingController();
  TextEditingController livingSituationTextEditingController =
      TextEditingController();
  TextEditingController willingToRelocateTextEditingController =
      TextEditingController();
  TextEditingController relationTypeTextEditingController =
      TextEditingController();
  TextEditingController nationalityTextEditingController =
      TextEditingController();
  TextEditingController educationTextEditingController =
      TextEditingController();
  TextEditingController languageTextEditingController = TextEditingController();
  TextEditingController religionTextEditingController = TextEditingController();
  TextEditingController ethnicityTextEditingController =
      TextEditingController();
  TextEditingController _genderTextEditingController = TextEditingController();
  String? selectedGender;
  bool showProgressBar = false;
  var authenticationController =
      AuthenticationController.authenticationController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 90,
              ),
              const Text(
                "Create Account",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "to get Started Now.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
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
              const Text(
                "Personal Info:",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                child: CustomTextField(
                  isObsecure: false,
                  editingController: nameTextEditingController,
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
                  editingController: emailTextEditingController,
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
                  editingController: passwordTextEditingController,
                  labelText: "******",
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
                  editingController: ageTextEditingController,
                  labelText: "Age",
                  iconData: Icons.numbers,
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      alignment: Alignment.centerLeft,
                      hint: Text('Select Gender'),
                      value: selectedGender,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGender = newValue;
                          _genderTextEditingController.text =
                              selectedGender ?? 'Select Gender';
                        });
                      },
                      items: ['Male', 'Female']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
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
                  editingController: phoneTextEditingController,
                  labelText: "Phone",
                  iconData: Icons.phone,
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
                  editingController: cityTextEditingController,
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
                  editingController: countryTextEditingController,
                  labelText: "Country",
                  iconData: Icons.location_city,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Life style:",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                child: CustomTextField(
                  isObsecure: false,
                  editingController: drinkTextEditingController,
                  labelText: "Drink",
                  iconData: Icons.local_drink_outlined,
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
                  editingController: smokeTextEditingController,
                  labelText: "Smoke",
                  iconData: Icons.smoking_rooms,
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
                  editingController: professionTextEditingController,
                  labelText: "Profession",
                  iconData: Icons.business_center,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Background-cultural Values:",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
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
                  editingController: educationTextEditingController,
                  labelText: "Education",
                  iconData: Icons.history_edu_outlined,
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
                  editingController: religionTextEditingController,
                  labelText: "Religion",
                  iconData: CupertinoIcons.checkmark_seal_fill,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                width: MediaQuery.of(context).size.width - 30,
                height: 50,
                decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                child: InkWell(
                  onTap: () {
                    if (authenticationController.imageFile != null) {
                      if (nameTextEditingController.text.trim().isNotEmpty &&
                          emailTextEditingController.text.trim().isNotEmpty &&
                          passwordTextEditingController.text
                              .trim()
                              .isNotEmpty &&
                          ageTextEditingController.text.trim().isNotEmpty &&
                          phoneTextEditingController.text.trim().isNotEmpty &&
                          cityTextEditingController.text.trim().isNotEmpty &&
                          countryTextEditingController.text.trim().isNotEmpty &&
                          drinkTextEditingController.text.trim().isNotEmpty &&
                          smokeTextEditingController.text.trim().isNotEmpty &&
                          professionTextEditingController.text
                              .trim()
                              .isNotEmpty &&
                          educationTextEditingController.text
                              .trim()
                              .isNotEmpty &&
                          religionTextEditingController.text
                              .trim()
                              .isNotEmpty) {
                        setState(() {
                          showProgressBar = true;
                        });

                        authenticationController.createNewUser(
                            authenticationController.profileImage!,
                            ageTextEditingController.text.trim(),
                            nameTextEditingController.text.trim(),
                            emailTextEditingController.text.trim(),
                            passwordTextEditingController.text.trim(),
                            selectedGender!.toLowerCase(),
                            phoneTextEditingController.text.trim(),
                            cityTextEditingController.text.trim(),
                            countryTextEditingController.text.trim(),
                            professionTextEditingController.text.trim(),
                            religionTextEditingController.text.trim(), []);
                        setState(() {
                          showProgressBar = false;
                        });
                      } else {
                        Get.snackbar("Image File Missing", "fill");
                      }
                    } else {
                      Get.snackbar("Image File Missing",
                          "Please pick image from gallery or capture with camera");
                    }
                  },
                  child: Center(
                      child: Text(
                    "Register",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  )),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    " have an account?",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              showProgressBar == true
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
