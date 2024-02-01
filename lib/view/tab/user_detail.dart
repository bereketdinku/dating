import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/controller/profile_controller.dart';
import 'package:date/global.dart';
import 'package:date/view/auth/login_screen.dart';
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

class _UserDetailScreenState extends State<UserDetailScreen>
    with TickerProviderStateMixin {
  List interests = [];
  String name = '';
  String age = '';
  String phoneNo = '';
  String city = '';
  String country = "";
  String bio = '';
  String profilePicture = '';
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
  String eduation = '';
  String languageSpoken = "";
  String religion = '';
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
          print(snapshot.data()!['']);
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
          profilePicture = snapshot.data()!["imageProfile"];
          name = snapshot.data()!["name"];
          age = snapshot.data()!["age"].toString();
          phoneNo = snapshot.data()!["phoneNo"];
          bio = snapshot.data()!["bio"];
          city = snapshot.data()!["city"];
          country = snapshot.data()!["country"];
          interests = List<String>.from(snapshot.get('interests') ?? []);
          religion = snapshot.data()!["religion"];
          profession = snapshot.data()!['profession'];
        });
        print(bio);
      }
    });
  }

  final ProfileController _profileController = ProfileController();
  String favorited = '';
  String liked = '';
  String favorites = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveUserInfo();
    count();
    likeCount();
    favoritescount();
    if (kDebugMode) {
      print(bio);
    }
  }

  void count() async {
    int counted = await _profileController.getFavoriteCount(widget.userID);

    setState(() {
      favorited = counted.toString();
    });
  }

  void likeCount() async {
    int counted = await _profileController.getLikeCount(currentUserID);
    setState(() {
      liked = counted.toString();
    });
  }

  void favoritescount() async {
    int counted = await _profileController.getFavoritesCount(widget.userID);

    setState(() {
      favorites = counted.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 2, vsync: this);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "User Profile",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          // automaticallyImplyLeading: widget.userID==currentUserID?false:true,
          leading: widget.userID != FirebaseAuth.instance.currentUser!.uid
              ? InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
          actions: [
            widget.userID == FirebaseAuth.instance.currentUser!.uid
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
                          onPressed: () async {
                            try {
                              await FirebaseAuth.instance.signOut();
                              Get.offAll(LoginScreen());
                            } catch (e) {}
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
        body: widget.userID != FirebaseAuth.instance.currentUser!.uid
            ? Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Image.network(
                      profilePicture.toString(),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // buttonArrow(context),
                  scroll()
                ],
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage:
                            NetworkImage(profilePicture.toString()),
                        backgroundColor: Colors.black,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name + ',' + age,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Text(profession)
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                favorited,
                                style:
                                    TextStyle(color: Colors.pink, fontSize: 20),
                              ),
                              Text("Favorited")
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                liked == '' ? '0' : liked,
                                style:
                                    TextStyle(color: Colors.pink, fontSize: 20),
                              ),
                              Text("Liked")
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                favorites == '' ? '0' : liked,
                                style:
                                    TextStyle(color: Colors.pink, fontSize: 20),
                              ),
                              Text("Favorites")
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        child: TabBar(
                            labelColor: Colors.black,
                            controller: tabController,
                            isScrollable: true,
                            indicatorColor: Colors.pink,
                            tabs: [
                              Tab(
                                text: "About",
                              ),
                              Tab(
                                text: "Gallery",
                              )
                            ]),
                      ),
                      Container(
                        width: double.maxFinite,
                        height: 300,
                        child: TabBarView(controller: tabController, children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Location",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  Text(city + ',' + country)
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Profession",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  Text(profession)
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Bio",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  Text(bio)
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'Interests',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 22),
                              ),
                              Container(
                                height: 60, // Set the desired height
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount: interests.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          // color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Colors
                                                .pink, // Change the border color to pink
                                          ),
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              interests[index],
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.pink,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Padding(
                              padding: EdgeInsets.all(2),
                              child: Carousel(
                                indicatorBarColor:
                                    Colors.black.withOpacity(0.3),
                                autoScrollDuration: Duration(seconds: 2),
                                animationPageDuration:
                                    Duration(milliseconds: 500),
                                activateIndicatorColor: Colors.pink,
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
                        ]),
                      ),
                    ],
                  ),
                ),
              ));
  }

  buttonArrow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row buildInterestRow(List<dynamic> interests, int startIndex, int endIndex) {
    return Row(
      children: interests.sublist(startIndex, endIndex).map((interest) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 105,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.pink,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  interest.toString(), // Ensure interest is treated as a String
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.pink,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  scroll() {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 1.0,
      minChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 5,
                        width: 35,
                        color: Colors.black12,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name + ',' + age,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Center(child: Text(profession))
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(city + ',' + country),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          bio,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Interests',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        Container(
                          height: 180,
                          child: Column(
                            children: [
                              for (int i = 0; i < interests.length; i += 3)
                                buildInterestRow(
                                  interests,
                                  i,
                                  (i + 3 <= interests.length)
                                      ? i + 3
                                      : interests.length,
                                ), // Remaining rows
                            ],
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.4,
                          child: Padding(
                            padding: EdgeInsets.all(2),
                            child: Carousel(
                              indicatorBarColor: Colors.black.withOpacity(0.3),
                              autoScrollDuration: Duration(seconds: 2),
                              animationPageDuration:
                                  Duration(milliseconds: 500),
                              activateIndicatorColor: Colors.pink,
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
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ingredients(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 10,
            backgroundColor: Color(0xFFE3FFF8),
            child: Icon(
              Icons.done,
              size: 15,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            "4 Eggs",
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      ),
    );
  }

  steps(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 12,
            child: Text("${index + 1}"),
          ),
          Column(
            children: [
              SizedBox(
                width: 270,
                child: Text(
                  "Your recipe has been uploaded, you can see it on your profile. Your recipe has been uploaded, you can see it on your",
                  maxLines: 3,
                  style: Theme.of(context).textTheme.bodyText2!,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Image.asset(
                "assets/imges/Rectangle 219.png",
                height: 155,
                width: 270,
              )
            ],
          )
        ],
      ),
    );
  }
}
