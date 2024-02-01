import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/global.dart';
import 'package:date/view/chat/chat_page.dart';
import 'package:date/view/tab/user_detail.dart';
import 'package:date/widgets/custom_app_bar.dart';
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
  bool favorite = false;
  String receiverToken = '';
  applyFilter() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Matching Filter"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('I am looking for a'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DropdownButton<String>(
                      items: ['Male', 'Female'].map((value) {
                        return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ));
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          chosenGender = value;
                        });
                      },
                      hint: Text("select gender"),
                      value: chosenGender,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("who's age equal or above"),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DropdownButton<String>(
                      items: ['20', '30', '40', '45'].map((value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          chosenAge = value;
                        });
                      },
                      hint: Text("select age"),
                      value: chosenAge,
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      profileController.getResults();

                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: Text(
                      'Done',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            );
          });
        });
  }

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

  retriveReceiver(String uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((dataSnapshot) {
      setState(() {
        receiverToken = dataSnapshot.data()!['userDeviceToken'].toString();
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
    return Scaffold(
        // appBar: CustomAppBar(title: 'DISCOVER'),
        body: Obx(() {
      return PageView.builder(
        itemCount: profileController.allUsersProfileList.length,
        controller: PageController(initialPage: 0, viewportFraction: 1),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final eachProfileInfo = profileController.allUsersProfileList[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: CachedNetworkImageProvider(
                              eachProfileInfo.imageProfile.toString()),
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
                                onPressed: () {
                                  applyFilter();
                                },
                                icon: Icon(
                                  Icons.filter_list,
                                  size: 30,
                                  color: Colors.pink,
                                )),
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () async {
                            await retriveReceiver(
                                eachProfileInfo.uid.toString());
                            profileController.ViewSentAndViewReceived(
                                eachProfileInfo.uid.toString(),
                                senderName,
                                receiverToken);
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
                                        eachProfileInfo.religion.toString(),
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ))
                                ],
                              ),
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
                                onTap: () async {
                                  setState(() {
                                    favorite = !favorite;
                                  });
                                  await retriveReceiver(
                                      eachProfileInfo.uid.toString());
                                  profileController
                                      .favoriteSentAndFavoriteReceived(
                                          eachProfileInfo.uid.toString(),
                                          senderName,
                                          receiverToken);
                                },
                                child: Icon(
                                  Icons.favorite,
                                  size: 65,
                                  color: Colors.pinkAccent,
                                )),
                            // GestureDetector(
                            //     onTap: () {
                            //       // Get.to(ChatPage(
                            //       //   uid: eachProfileInfo.uid.toString(),
                            //       // ));
                            //     },
                            //     child: Icon(
                            //       Icons.chat_bubble,
                            //       size: 65,
                            //       color: Colors.blue,
                            //     )),
                            GestureDetector(
                                onTap: () async {
                                  await retriveReceiver(
                                      eachProfileInfo.uid.toString());
                                  profileController.likeSentAndFavoriteReceived(
                                      eachProfileInfo.uid.toString(),
                                      senderName,
                                      receiverToken);
                                },
                                child: Icon(
                                  Icons.star,
                                  size: 80,
                                  color: Colors.purple,
                                ))
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }));
  }
}
