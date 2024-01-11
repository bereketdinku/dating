import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/global.dart';
import 'package:date/view/settings/account_setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slider/carousel.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class UserDetailScreen extends StatefulWidget {
  String? userID;
  UserDetailScreen({super.key, this.userID});
  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
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

  retrieveUserInfo() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userID)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        if (kDebugMode) {
          print(snapshot.data());
        }
        if (snapshot.data()!["urlImage1"] != null) {
          setState(() {
            urlImage1 = snapshot.data()!["urlImage1"];
            urlImage2 = snapshot.data()!["urlImage2"];
            urlImage3 = snapshot.data()!["urlImage3"];
            urlImage4 = snapshot.data()!["urlImage4"];
            urlImage5 = snapshot.data()!["urlImage5"];
          });
        }
        setState(() {
          name = snapshot.data()!["name"];
          age = snapshot.data()!["age"].toString();
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveUserInfo();
    if (kDebugMode) {
      print("name" + name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "User Profile",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          // automaticallyImplyLeading: widget.userID==currentUserID?false:true,
          leading: widget.userID != currentUserID
              ? IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Icon(
                    Icons.arrow_back_outlined,
                    size: 30,
                  ))
              : Container(),
          actions: [
            widget.userID == currentUserID
                ? Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Get.to(AccountSettingScreen());
                          },
                          icon: Icon(
                            Icons.settings,
                            size: 30,
                          )),
                      IconButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                          },
                          icon: Icon(
                            Icons.logout,
                            size: 30,
                          ))
                    ],
                  )
                : Container()
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Padding(
                    padding: EdgeInsets.all(2),
                    child: Carousel(
                      indicatorBarColor: Colors.black.withOpacity(0.3),
                      autoScrollDuration: Duration(seconds: 2),
                      animationPageDuration: Duration(milliseconds: 500),
                      activateIndicatorColor: Colors.black,
                      animationPageCurve: Curves.easeIn,
                      indicatorBarHeight: 30,
                      indicatorHeight: 10,
                      indicatorWidth: 10,
                      unActivatedIndicatorColor: Colors.grey,
                      stopAtEnd: true,
                      items: [
                        Image.network(
                          urlImage1,
                          fit: BoxFit.cover,
                        ),
                        Image.network(
                          urlImage2,
                          fit: BoxFit.cover,
                        ),
                        Image.network(
                          urlImage3,
                          fit: BoxFit.cover,
                        ),
                        Image.network(
                          urlImage4,
                          fit: BoxFit.cover,
                        ),
                        Image.network(
                          urlImage5,
                          fit: BoxFit.cover,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Personal Info",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(
                  color: Colors.black,
                  thickness: 2,
                ),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(20),
                  child: Table(
                    children: [
                      TableRow(children: [
                        Text(
                          "Name:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          name,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        )
                      ])
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
