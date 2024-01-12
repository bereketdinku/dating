import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/global.dart';
import 'package:date/view/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/custom_text_field.dart';

class AccountSettingScreen extends StatefulWidget {
  const AccountSettingScreen({super.key});
  @override
  State<AccountSettingScreen> createState() => _AccountSettingScreenState();
}

class _AccountSettingScreenState extends State<AccountSettingScreen> {
  bool uploading = false, next = false;
  final List<File> _image = [];
  List<String> urlsList = [];
  double val = 0;
  String name = "";
  String age = "";
  String phoneNo = "";
  String email = "";
  String password = "";
  String city = "";
  String country = "";
  String profileHeading = "";
  String lookingForInaPartner = "";

  String height = "";
  String weight = "";
  String bodyType = "";
  String drink = "";
  String smoke = "";
  String martialStatus = "";
  String haveChildren = "";
  String noOfChildren = "";
  String profession = "";
  String employmentStatus = "";
  String income = "";
  String livingSituation = "";
  String willingToRelocate = "";
  String relationshipYouAreLookingFor = "";
  String nationality = "";
  String eduation = "";
  String languageSpoken = "";
  String religion = "";
  String ethnicity = "";
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
          nameTextEditingController.text = name;
          age = snapshot.data()!["age"].toString();
          email = snapshot.data()!['email'].toString();
          emailTextEditingController.text = email;
          ageTextEditingController.text = age;
          selectedGender = snapshot.data()!['gender'].toString();
          phoneNo = snapshot.data()!["phoneNo"].toString();
          phoneTextEditingController.text = phoneNo;
          city = snapshot.data()!["city"].toString();
          cityTextEditingController.text = city;
          country = snapshot.data()!["country"].toString();
          countryTextEditingController.text = country;
          drink = snapshot.data()!["drink"].toString();
          drinkTextEditingController.text = drink;
          smoke = snapshot.data()!["smoke"].toString();
          smokeTextEditingController.text = smoke;
          religion = snapshot.data()!["religion"].toString();
          religionTextEditingController.text = religion;
          profession = snapshot.data()!["profession"];
          professionTextEditingController.text = profession;
        });
      }
    });
  }

  updateUserData(String name, String age, String phoneNo, String city,
      String country, String email, String? gender) async {
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
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text('uploading images...')
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
      'urlImage5': urlsList[4].toString()
    });
    Get.snackbar("Updated", "your account has been updated");
    Get.to(HomeScreen());
    setState(() {
      uploading = false;
      _image.clear();
      urlsList.clear();
    });
  }

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController ageTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController cityTextEditingController = TextEditingController();
  TextEditingController countryTextEditingController = TextEditingController();

  TextEditingController drinkTextEditingController = TextEditingController();
  TextEditingController smokeTextEditingController = TextEditingController();

  TextEditingController professionTextEditingController =
      TextEditingController();

  TextEditingController educationTextEditingController =
      TextEditingController();
  TextEditingController religionTextEditingController = TextEditingController();
  TextEditingController _genderTextEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveUserData();
  }

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(
                      height: 15,
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
                          color: Colors.white,
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

                    const Text(
                      "Background-cultural Values:",
                      style: TextStyle(
                          color: Colors.white,
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
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: InkWell(
                        onTap: () {
                          if (nameTextEditingController.text
                              .trim()
                              .isNotEmpty) {
                            _image.length > 0
                                ? updateUserData(
                                    nameTextEditingController.text.trim(),
                                    ageTextEditingController.text.trim(),
                                    phoneTextEditingController.text.trim(),
                                    cityTextEditingController.text.trim(),
                                    countryTextEditingController.text.trim(),
                                    emailTextEditingController.text.trim(),
                                    selectedGender)
                                : null;
                          } else {
                            Get.snackbar("A Field is Empty",
                                "please fill out all field in text field");
                          }
                        },
                        child: Center(
                            child: Text(
                          "update",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
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
