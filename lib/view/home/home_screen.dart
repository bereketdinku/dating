import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/api/notification.dart';
import 'package:date/global.dart';
import 'package:date/notification/push_notification.dart';
import 'package:date/view/chat/chat_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../tab/favorite.dart';
import '../tab/like.dart';
import '../tab/swipe.dart';
import '../tab/user_detail.dart';
import '../tab/view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? token = "";
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // PushNotificationSystems notificationSystems = PushNotificationSystems();
    // notificationSystems.generateDeviceRegistrationToken();
    // notificationSystems.whenNotificationReceived(context);
    getToken();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        token = token;

        print("my token $token");
      });
      saveToken(token!);
    });
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'userDeviceToken': token});
  }

  // initInfo() {
  //   var androidInitialize =
  //       const AndroidInitializationSettings('@mipmap/lovelogo');
  //   // var iosInitialize = const IOSInitializationSettings();
  //   var initializationSettings =
  //       InitializationSettings(android: androidInitialize);
  //   _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // }

  int screenIndex = 0;
  List tabList = [
    SwipeScreen(),
    ChatListPage(),
    FavoriteScreen(),
    LikeScreen(),
    UserDetailScreen(
      userID: FirebaseAuth.instance.currentUser!.uid,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (indexNumber) {
          setState(() {
            screenIndex = indexNumber;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white12,
        currentIndex: screenIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 30,
              ),
              label: ""),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.remove_red_eye,
                size: 30,
              ),
              label: ""),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.star,
                size: 30,
              ),
              label: ""),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
                size: 30,
              ),
              label: ""),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                size: 30,
              ),
              label: "")
        ],
      ),
      body: tabList[screenIndex],
    );
  }
}
