import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/global.dart';
import 'package:date/view/home/home_screen.dart';
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
        .doc(currentUserID)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          name = snapshot.data()!["name"];
          nameTextEditingController.text = name;
          age = snapshot.data()!["age"].toString();
          ageTextEditingController.text = age;
          phoneNo = snapshot.data()!["phoneNo"];
          city = snapshot.data()!["city"];
          country = snapshot.data()!["country"];
          profileHeading = snapshot.data()!["profileHeading"];
          lookingForInaPartner = snapshot.data()!["relationshipType"];
          height = snapshot.data()!["height"];
          weight = snapshot.data()!["width"];
          bodyType = snapshot.data()!["bodyType"];
          drink = snapshot.data()!["drink"];
          smoke = snapshot.data()!["smoke"];
          martialStatus = snapshot.data()!["martialStatus"];
          haveChildren = snapshot.data()!["haveChildren"];
        });
      }
    });
  }

  updateUserData(
    String name,
  ) async {
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
    uploadImages();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .update({
      'name': name,
      'urlImage1': urlsList[0].toString(),
      'urlImage2': urlsList[1].toString(),
      'urlImage3': urlsList[2].toString(),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () async {},
                            icon: Icon(
                              Icons.image_outlined,
                              color: Colors.grey,
                              size: 30,
                            )),
                        SizedBox(
                          width: 15,
                        ),
                        IconButton(
                            onPressed: () async {},
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 50,
                      child: CustomTextField(
                        isObsecure: false,
                        editingController: profileHeadingTextEditingController,
                        labelText: "Profile Heading",
                        iconData: Icons.text_fields,
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
                        editingController: imagePartnerTextEditingController,
                        labelText: "What you're looking for in a partner",
                        iconData: Icons.face,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Appearance Info:",
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
                        editingController: heightTextEditingController,
                        labelText: "Height",
                        iconData: Icons.insert_chart,
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
                        editingController: widthTextEditingController,
                        labelText: "Width",
                        iconData: Icons.table_chart,
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
                        editingController: bodyTypeTextEditingController,
                        labelText: "Body Type",
                        iconData: Icons.type_specimen,
                      ),
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
                        editingController: martialStatusTextEditingController,
                        labelText: "Martial Status",
                        iconData: Icons.person_2,
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
                        editingController: haveChildrenTextEditingController,
                        labelText: "Do you have Children?",
                        iconData: CupertinoIcons.person_3_fill,
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
                        editingController: noChildrenTextEditingController,
                        labelText: "No of Children",
                        iconData: CupertinoIcons.person_3_fill,
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 50,
                      child: CustomTextField(
                        isObsecure: false,
                        editingController:
                            employmentStatusTextEditingController,
                        labelText: "Employment Status",
                        iconData:
                            CupertinoIcons.rectangle_stack_person_crop_fill,
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
                        editingController: incomeTextEditingController,
                        labelText: "Income",
                        iconData: CupertinoIcons.money_dollar_circle,
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
                        editingController: livingSituationTextEditingController,
                        labelText: "Living Situation",
                        iconData: CupertinoIcons.person_2_square_stack,
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
                            willingToRelocateTextEditingController,
                        labelText: "Willing to Relocate",
                        iconData: CupertinoIcons.person_2,
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
                        editingController: relationTypeTextEditingController,
                        labelText: "relationship You are looking for",
                        iconData: CupertinoIcons.person_2,
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
                        editingController: nationalityTextEditingController,
                        labelText: "Nationality",
                        iconData: Icons.flag_circle_outlined,
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
                        editingController: languageTextEditingController,
                        labelText: "Language Spoken",
                        iconData: CupertinoIcons.person_badge_plus_fill,
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 50,
                      child: CustomTextField(
                        isObsecure: false,
                        editingController: ethnicityTextEditingController,
                        labelText: "Ethnicity",
                        iconData: CupertinoIcons.eye,
                      ),
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
                                  )
                                : null;
                          } else {
                            Get.snackbar("Image File Missing", "fill");
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
