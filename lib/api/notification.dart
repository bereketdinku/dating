import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/view/chat/chat_list.dart';
import 'package:date/view/home/home_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

class FirebaseApi {
  // final _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final String? fcmToken = await _firebaseMessaging.getToken();
    print('Token: $fcmToken');
    initPushNotification();
  }

  void initPushNotification() {
    try {
      // Get initial message when the app is launched from a terminated state
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("Background Message: $message");
        handleMessage(message);
      });

      // Listen for messages when the app is in the foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print("Foreground Message: $message");
        }
        handleMessage(message);
      });

      // Get initial message when the app is launched from a terminated state
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          print("Initial Message: $message");
          handleMessage(message);
        }
      });
    } catch (e) {
      print("Error initializing push notifications: $e");
    }
  }

  // void showForegroundNotification(RemoteMessage message) async {
  //   try {
  //     const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //         AndroidNotificationDetails(
  //       'dbfood',
  //       'date',
  //       importance: Importance.max,
  //       priority: Priority.high,
  //     );
  //     const NotificationDetails platformChannelSpecifics =
  //         NotificationDetails(android: androidPlatformChannelSpecifics);

  //     await _flutterLocalNotificationsPlugin.show(
  //       0,
  //       message.notification?.title,
  //       message.notification?.body,
  //       platformChannelSpecifics,
  //       payload: 'item x',
  //     );
  //   } catch (e) {
  //     print("Error showing foreground notification: $e");
  //   }
  // }

  void handleMessage(RemoteMessage message) {
    try {
      // Your logic to handle the message goes here

      // Check if the app is in the foreground
      if (Get.overlayContext != null) {
        // Show a dialog when a notification is received in the foreground
        Get.snackbar(
          message.notification?.title ?? "Notification",
          message.notification?.body ?? "No body",
          // Set the position to the top
          snackPosition: SnackPosition.TOP,
          // Set the duration
          duration: Duration(seconds: 5),
          // Callback when the snackbar is dismissed
          // onClosed: (reason) {
          //   // If not pressed, handle it as a background notification
          //   if (reason == SnackDismissReason.swipe || reason == SnackDismissReason.timeout) {
          //     navigateToTargetPage(message.data);
          //   }
          // },
        );
      } else {
        // App is in the background, show the notification as a bar at the top
        Get.snackbar(
          "Notification",
          message.notification?.body ?? "No body",
          // Set the position to the top
          snackPosition: SnackPosition.TOP,
          // Set the duration
          duration: Duration(seconds: 5),
        );
      }
    } catch (e) {
      print("Error handling message: $e");
    }
  }

  /// Displays a dialog box with user details.
  Future<void> _showNotificationDialog(
      String receiverID, String senderID, BuildContext context) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(senderID)
          .get();
      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        _buildDialog(context, userData, senderID);
      }
    } catch (e) {
      print('Failed to fetch user details: $e');
    }
  }

  /// Builds and displays the dialog box.
  void _buildDialog(
    BuildContext context,
    Map<String, dynamic> userData,
    String senderID,
  ) {
    showDialog(
      context: context,
      builder: (context) => _notificationDialogBox(userData, senderID),
    );
  }

  /// Constructs the notification dialog box UI.
  Widget _notificationDialogBox(
      Map<String, dynamic> userData, String senderID) {
    // Extract user details from userData map
    // ... (extract data like name, age, city, country, profession)

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
                image: DecorationImage(
                    image: NetworkImage(userData['imageProfile']))),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData['name'] + " " + userData['age'].toString(),
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
                        userData['city'] + "," + userData['country'].toString(),
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
                                  // Get.to(UserDetailScreen(
                                  //   userID: senderId,
                                  // ));
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
    )));
  }
}

// Future<void> initPushNotification() async {
//   try {
//     // Get initial message when the app is launched from a terminated state
//     RemoteMessage? initialMessage =
//         await FirebaseMessaging.instance.getInitialMessage();

//     // Listen for messages when the app is in the foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print("Foreground Message: $message");
//       handleMessage(message);
//     });

//     // Listen for messages when the app is in the background and opened by tapping the notification
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print("Background Message: $message");
//       handleMessage(message);
//     });

//     if (initialMessage != null) {
//       // If there is an initial message, handle it
//       print("Initial Message: $initialMessage");
//       handleMessage(initialMessage);
//     }
//   } catch (e) {
//     print("Error initializing push notifications: $e");
//   }
// }

// void handleMessage(RemoteMessage message) {
//   try {
//     // Your logic to handle the message goes here
//     // Example: Navigate to the HomeScreen
//     Get.to(HomeScreen());
//   } catch (e) {
//     print("Error handling message: $e");
//   }
// }

// Future<void> sendPushNotification() async {
//   try {
//     final body = {
//       // "to":"AAAAwe9tmkg:APA91bGI9ACjGc3NuMC4FHIDyP2SbNzdoBZsLCL3cy_Savr_8TJ51cxfJI3ROrwyqYgizOJT2KNlDmEbZJLUoWXS1LCFfTT4TYumembJkxNG6f8vpk1K9W-fd8PHJ7GgHVF8s6IcOewN"

//       "to":
//           "fZV2AsGDSu-QmS1M6X1QPU:APA91bEbxq2g9yio67I2UKvsGLtklzlWufVRg0eDQ49Hftmuc4qQtzASb3deLA4_Wsb4owm5VOzHbKQzIiDQXWoHPbVojyYD-r7e_DDL_jpnB5pvUIEA_I76uQMf5byzv1N7JA1rAhYQ",
//       "notification": {"title": "new message", "body": "hi"}
//     };
//     var response = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
//         headers: {
//           HttpHeaders.contentTypeHeader: 'application/json',
//           HttpHeaders.authorizationHeader:
//               "key=AAAAwe9tmkg:APA91bGI9ACjGc3NuMC4FHIDyP2SbNzdoBZsLCL3cy_Savr_8TJ51cxfJI3ROrwyqYgizOJT2KNlDmEbZJLUoWXS1LCFfTT4TYumembJkxNG6f8vpk1K9W-fd8PHJ7GgHVF8s6IcOewN"
//         },
//         body: jsonEncode(body));
//   } catch (e) {}
// }
