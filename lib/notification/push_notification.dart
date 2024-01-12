import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/global.dart';
import 'package:date/view/tab/user_detail.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

class PushNotificationSystems {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('Title : ${message.notification?.title}');
      print('Body : ${message.notification?.body}');
    }
  }

  Future<void> initNotification() async {
    await messaging.requestPermission();
    final dcmToken = await messaging.getToken();
    if (kDebugMode) {
      print("Token: $dcmToken");
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    }
  }

  Future whenNotificationReceived(BuildContext context) async {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        openAppshowAndShowNotificationData(remoteMessage.data["userID"],
            remoteMessage.data['senderID'], context);
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        openAppshowAndShowNotificationData(remoteMessage.data["userID"],
            remoteMessage.data['senderID'], context);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        openAppshowAndShowNotificationData(remoteMessage.data["userID"],
            remoteMessage.data['senderID'], context);
      }
    });
  }

  openAppshowAndShowNotificationData(receiverID, senderID, context) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(senderID)
        .get()
        .then((snapshot) {
      String profileImage = snapshot.data()!['name'].toString();
      String name = snapshot.data()!['name'].toString();
      String age = snapshot.data()!['age'].toString();
      String city = snapshot.data()!['city'].toString();
      String country = snapshot.data()!['country'].toString();
      String profession = snapshot.data()!['profession'].toString();
      showDialog(
          context: context,
          builder: (context) {
            return notificationDialogBox(senderID, profileImage, name, age,
                city, country, profession, context);
          });
    });
  }

  notificationDialogBox(
      senderId, profileImage, name, age, city, country, profession, context) {
    return Dialog(
      child: GridTile(
          child: Padding(
        padding: EdgeInsets.all(2),
        child: SizedBox(
          height: 300,
          child: Card(
            color: Colors.blue.shade200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  image: DecorationImage(image: NetworkImage(profileImage))),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name + " " + age.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Expanded(
                            child: Text(
                          city + "," + country.toString(),
                          maxLines: 4,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        )),
                        Spacer(),
                        Row(
                          children: [
                            Center(
                              child: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                    Get.to(UserDetailScreen(
                                      userID: senderId,
                                    ));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  child: Text("View Profile")),
                            ),
                            Center(
                              child: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent),
                                  child: Text("Close")),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }

  Future generateDeviceRegistrationToken() async {
    String? deviceToken = await messaging.getToken();
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserID)
        .update({"userDeviceToken": deviceToken});
  }
}
