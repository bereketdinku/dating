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
    }
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
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
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:date/global.dart';
// import 'package:date/view/tab/user_detail.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:get/get.dart';

// class PushNotificationManager {
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;

//   /// Initializes notification settings and requests permission.
//   Future<void> initializeNotifications() async {
//     try {
//       await _messaging.requestPermission();
//       String? token = await _messaging.getToken();
//       if (kDebugMode) {
//         print("Device Token: $token");
//         FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
//       }
//     } catch (e) {
//       print('Failed to initialize notifications: $e');
//     }
//   }

//   /// Handles background messages and prints them in debug mode.
//   Future<void> _handleBackgroundMessage(RemoteMessage message) async {
//     if (kDebugMode) {
//       print('Title: ${message.notification?.title}');
//       print('Body: ${message.notification?.body}');
//     }
//   }

//   /// Listens for incoming messages and displays them.
//   void listenForMessages(BuildContext context) {
//     _messaging
//         .getInitialMessage()
//         .then((message) => _processMessage(message, context));
//     FirebaseMessaging.onMessage
//         .listen((message) => _processMessage(message, context));
//     FirebaseMessaging.onMessageOpenedApp
//         .listen((message) => _processMessage(message, context));
//   }

//   /// Processes the received message and shows the dialog box.
//   void _processMessage(RemoteMessage? message, BuildContext context) {
//     if (message != null) {
//       _showNotificationDialog(
//           message.data["userID"], message.data['senderID'], context);
//     }
//   }

//   /// Displays a dialog box with user details.
//   Future<void> _showNotificationDialog(
//       String receiverID, String senderID, BuildContext context) async {
//     try {
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection("users")
//           .doc(senderID)
//           .get();
//       if (snapshot.exists) {
//         Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
//         _buildDialog(context, userData, senderID);
//       }
//     } catch (e) {
//       print('Failed to fetch user details: $e');
//     }
//   }

//   /// Builds and displays the dialog box.
//   void _buildDialog(
//     BuildContext context,
//     Map<String, dynamic> userData,
//     String senderID,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => _notificationDialogBox(userData, senderID),
//     );
//   }

//   /// Constructs the notification dialog box UI.
//   Widget _notificationDialogBox(
//       Map<String, dynamic> userData, String senderID) {
//     // Extract user details from userData map
//     // ... (extract data like name, age, city, country, profession)

//     return Dialog(
//         child: GridTile(
//             child: Padding(
//       padding: EdgeInsets.all(2),
//       child: SizedBox(
//         height: 300,
//         child: Card(
//           color: Colors.blue.shade200,
//           child: DecoratedBox(
//             decoration: BoxDecoration(
//                 image: DecorationImage(
//                     image: NetworkImage(userData['imageProfile']))),
//             child: Padding(
//               padding: EdgeInsets.all(8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     userData['name'] + " " + userData['age'].toString(),
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(
//                     height: 8,
//                   ),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.location_on_outlined,
//                         color: Colors.white,
//                         size: 16,
//                       ),
//                       SizedBox(
//                         width: 2,
//                       ),
//                       Expanded(
//                           child: Text(
//                         userData['city'] + "," + userData['country'].toString(),
//                         maxLines: 4,
//                         style: TextStyle(color: Colors.white, fontSize: 14),
//                       )),
//                       Spacer(),
//                       Row(
//                         children: [
//                           Center(
//                             child: ElevatedButton(
//                                 onPressed: () {
//                                   Get.back();
//                                   // Get.to(UserDetailScreen(
//                                   //   userID: senderId,
//                                   // ));
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.green),
//                                 child: Text("View Profile")),
//                           ),
//                           Center(
//                             child: ElevatedButton(
//                                 onPressed: () {
//                                   Get.back();
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.redAccent),
//                                 child: Text("Close")),
//                           )
//                         ],
//                       )
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     )));
//   }

//   /// Generates and stores the device registration token for the user.
//   Future<void> registerDeviceToken() async {
//     try {
//       String? deviceToken = await _messaging.getToken();
//       if (deviceToken != null) {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(currentUserID)
//             .update({"userDeviceToken": deviceToken});
//       }
//     } catch (e) {
//       print('Failed to generate device token: $e');
//     }
//   }
// }
