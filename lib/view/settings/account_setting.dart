import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/global.dart';
import 'package:date/view/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controller/auth_controller.dart';
import '../../services/interest.dart';
import '../../widgets/custom_text_field.dart';

class AccountSettingScreen extends StatefulWidget {
  const AccountSettingScreen({super.key});
  @override
  State<AccountSettingScreen> createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends State<AccountSettingScreen> {
  List<Interest> availableInterests = [
    Interest(name: 'Photography', image: 'assets/images/camera.png'),
    Interest(name: 'Shopping', image: 'assets/images/weixin-market.png'),
    Interest(name: 'Cooking', image: 'assets/images/noodles.png'),
    Interest(name: 'Tennis', image: 'assets/images/tennis.png'),
    Interest(name: 'Run', image: 'assets/images/sport.png'),
    Interest(name: 'Swimming', image: 'assets/images/ripple.png'),
    Interest(name: 'Art', image: 'assets/images/platte.png'),
    Interest(name: 'Traveling', image: 'assets/images/outdoor.png'),
    Interest(name: 'Extreme', image: 'assets/images/parachute.png'),
    Interest(name: 'Drink', image: 'assets/images/goblet-full.png'),
    Interest(name: 'Music', image: 'assets/images/music.png'),
    Interest(name: 'Video games', image: 'assets/images/game-handle.png'),
    // Add
  ];
  var authenticationController =
      AuthenticationController.authenticationController;
  bool uploading = false, next = false;

  final List<File> _image = [];
  List<String> urlsList = [];
  List interests = [];
  double val = 0;
  String name = "";
  String age = "";
  String phoneNo = "";
  String email = "";
  String password = "";
  String city = "";
  String country = "";
  String bio = '';

  String profession = "";

  String religion = "";
  String urlImage1 =
      "https://firebasestorage.googleapis.com/v0/b/date-50347.appspot.com/o/placeholder%2Fprofile_avatar.jpg?alt=media&token=97e0f9f5-d4c6-42b5-98f9-4e66783c50cb";
  String urlImage2 =
      "https://firebasestorage.googleapis.com/v0/b/date-50347.appspot.com/o/placeholder%2Fprofile_avatar.jpg?alt=media&token=97e0f9f5-d4c6-42b5-98f9-4e66783c50cb";
  String urlImage3 =
      "https://firebasestorage.googleapis.com/v0/b/date-50347.appspot.com/o/placeholder%2Fprofile_avatar.jpg?alt=media&token=97e0f9f5-d4c6-42b5-98f9-4e66783c50cb";
  String urlImage4 =
      "https://firebasestorage.googleapis.com/v0/b/date-50347.appspot.com/o/placeholder%2Fprofile_avatar.jpg?alt=media&token=97e0f9f5-d4c6-42b5-98f9-4e66783c50cb";
  String urlImage5 =
      "https://firebasestorage.googleapis.com/v0/b/date-50347.appspot.com/o/placeholder%2Fprofile_avatar.jpg?alt=media&token=97e0f9f5-d4c6-42b5-98f9-4e66783c50cb";
  String? selectedGender;
  chooseImage() async {
    XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image.add(File(pickedFile!.path));
    });
  }

  uploadImages() async {
    int i = 1;
    for (var img in _image) {
      setState(() {
        val = i / _image.length;
      });
      var refImage = FirebaseStorage.instance.ref().child(
          "images/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg");
      await refImage.putFile(img).whenComplete(() async {
        await refImage.getDownloadURL().then((urlImage) {
          urlsList.add(urlImage);
          i++;
        });
      });
    }
  }

  retrieveUserData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          name = snapshot.data()!["name"];
          authenticationController.nameController.text = name;
          age = snapshot.data()!["age"].toString();
          email = snapshot.data()!['email'].toString();
          authenticationController.emailController.text = email;
          authenticationController.ageController.text = age;
          selectedGender = snapshot.data()!['gender'].toString();
          phoneNo = snapshot.data()!["phoneNo"].toString();
          authenticationController.phoneController.text = phoneNo;
          city = snapshot.data()!["city"].toString();
          authenticationController.cityController.text = city;
          country = snapshot.data()!["country"].toString();
          authenticationController.countryController.text = country;

          religion = snapshot.data()!["religion"].toString();
          authenticationController.religionController.text = religion;
          profession = snapshot.data()!["profession"];
          authenticationController.professionController.text = profession;
          bio = snapshot.data()!["bio"];
          authenticationController.bioController.text = bio;
          List<String> interests =
              List<String>.from(snapshot.get('interests') ?? []);
          authenticationController.selectedInterests = interests;
        });
      }
    });
  }

  updateUserData(String name, String age, String phoneNo, String city,
      String country, String email, String? gender, List interests) async {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: SizedBox(
              height: 180,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.pink,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('Uploading images...')
                  ],
                ),
              ),
            ),
          );
        });
    await uploadImages();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'name': name,
      'age': int.parse(age),
      'city': city,
      'email': email,
      'gender': gender!.toLowerCase(),
      'urlImage1': urlsList[0].toString(),
      'urlImage2': urlsList[1].toString(),
      'urlImage3': urlsList[2].toString(),
      'urlImage4': urlsList[3].toString(),
      'urlImage5': urlsList[4].toString(),
      'interests': interests
    });
    Get.snackbar("Updated", "your account has been updated");
    Get.to(HomeScreen());
    setState(() {
      uploading = false;
      _image.clear();
      urlsList.clear();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveUserData();
  }

  @override
  Widget build(BuildContext context) {
    List<bool> selectedList =
        List.generate(availableInterests.length, (index) => false);
    return Scaffold(
      appBar: AppBar(
          title: Text(
            next ? "Profile Information" : "Choose 5 Images",
            style: TextStyle(color: Colors.black, fontSize: 22),
          ),
          actions: [
            next
                ? Container()
                : IconButton(
                    onPressed: () async {
                      if (_image.length == 5) {
                        setState(() {
                          uploading = false;
                          next = true;
                        });
                      } else {
                        Get.snackbar("5 images", 'please choose 5 images');
                      }
                    },
                    icon: Icon(
                      Icons.navigate_next_outlined,
                      size: 36,
                    ))
          ]),
      body: next
          ? SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
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
                        editingController:
                            authenticationController.nameController,
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
                        editingController:
                            authenticationController.emailController,
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
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 50,
                      child: CustomTextField(
                        isObsecure: false,
                        editingController:
                            authenticationController.ageController,
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
                        editingController:
                            authenticationController.phoneController,
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
                        editingController:
                            authenticationController.cityController,
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
                        editingController:
                            authenticationController.countryController,
                        labelText: "Country",
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
                        editingController:
                            authenticationController.professionController,
                        labelText: "Profession",
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
                            authenticationController.religionController,
                        labelText: "Religion",
                        iconData: CupertinoIcons.checkmark_seal_fill,
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
                            authenticationController.bioController,
                        labelText: "Bio",
                        iconData: CupertinoIcons.checkmark_seal_fill,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 50),
                      itemCount: availableInterests.length,
                      itemBuilder: (context, index) {
                        final isSelected = authenticationController
                            .selectedInterests
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
                            if (kDebugMode) {
                              print(authenticationController.selectedInterests);
                            }
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                                color: isSelected ? Colors.pink : Colors.white,
                                borderRadius: BorderRadius.circular(
                                    20)), // Adjust the height as needed

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  availableInterests[index].image,
                                  width: 30, // Adjust the width as needed
                                  height: 30, // Adjust the height as needed
                                ),
                                SizedBox(
                                    height: 4), // Adjust the spacing as needed
                                Text(
                                  availableInterests[index].name,
                                  style: TextStyle(
                                    fontSize:
                                        12, // Adjust the font size as needed
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 30,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.pink,
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: InkWell(
                        onTap: () {
                          if (authenticationController.nameController.text
                              .trim()
                              .isNotEmpty) {
                            _image.length > 0
                                ? updateUserData(
                                    authenticationController.nameController.text
                                        .trim(),
                                    authenticationController.ageController.text
                                        .trim(),
                                    authenticationController
                                        .phoneController.text
                                        .trim(),
                                    authenticationController.cityController.text
                                        .trim(),
                                    authenticationController
                                        .countryController.text
                                        .trim(),
                                    authenticationController
                                        .emailController.text
                                        .trim(),
                                    selectedGender,
                                    authenticationController.selectedInterests)
                                : null;
                          } else {
                            Get.snackbar("A Field is Empty",
                                "please fill out all field in text field");
                          }
                        },
                        child: Center(
                            child: Text(
                          "Update",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),
                    // showProgressBar == true
                    //     ? CircularProgressIndicator(
                    //         valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                    //       )
                    //     : Container()
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  child: GridView.builder(
                      itemCount: _image.length + 1,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3),
                      itemBuilder: (context, index) {
                        return index == 0
                            ? Container(
                                color: Colors.grey,
                                child: Center(
                                  child: IconButton(
                                      onPressed: () {
                                        if (_image.length < 5) {
                                          !uploading ? chooseImage() : null;
                                        } else {
                                          setState(() {
                                            uploading = true;
                                          });
                                          Get.snackbar("5 Images Chosen",
                                              "5 Images Already Selected");
                                        }
                                      },
                                      icon: Icon(Icons.add)),
                                ),
                              )
                            : Container(
                                margin: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: FileImage(_image[index - 1]),
                                        fit: BoxFit.cover)),
                              );
                      }),
                )
              ],
            ),
    );
  }
}
