import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/global.dart';
import 'package:date/view/tab/user_detail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/profile_controller.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});
  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  ProfileController profileController = Get.put(ProfileController());
  String senderName = "";
  readCurrentUserData() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .get()
        .then((dataSnapshot) {
      setState(() {
        senderName = dataSnapshot.data()!["name"].toString();
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Obx(() {
      return PageView.builder(
        itemCount: profileController.allUsersProfileList.length,
        controller: PageController(initialPage: 0, viewportFraction: 1),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final eachProfileInfo = profileController.allUsersProfileList[index];
          return DecoratedBox(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image:
                        NetworkImage(eachProfileInfo.imageProfile.toString()),
                    fit: BoxFit.cover)),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.filter_list,
                            size: 30,
                          )),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      profileController.ViewSentAndViewReceived(
                          eachProfileInfo.uid.toString(), senderName);
                      Get.to(UserDetailScreen(
                        userID: eachProfileInfo.uid.toString(),
                      ));
                    },
                    child: Column(
                      children: [
                        Text(
                          eachProfileInfo.name.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          eachProfileInfo.age.toString() +
                              "⦿" +
                              eachProfileInfo.city.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white30,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16))),
                                child: Text(
                                  eachProfileInfo.profession.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                )),
                            ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white30,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16))),
                                child: Text(
                                  eachProfileInfo.religion.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white30,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16))),
                                child: Text(
                                  eachProfileInfo.country.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                )),
                            ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white30,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16))),
                                child: Text(
                                  eachProfileInfo.ethnicity.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          profileController.favoriteSentAndFavoriteReceived(
                              eachProfileInfo.uid.toString(), senderName);
                        },
                        child: Image.asset(
                          "assets/images/favorite.png",
                          width: 60,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Image.asset(
                          "assets/images/favorite.png",
                          width: 60,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          profileController.likeSentAndFavoriteReceived(
                              eachProfileInfo.uid.toString(), senderName);
                        },
                        child: Image.asset(
                          "assets/images/like.png",
                          width: 60,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
      );
    }));
  }
}
