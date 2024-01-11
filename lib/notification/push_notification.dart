import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PushNotification {
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

  openAppshowAndShowNotificationData(receiverID, senderID, context) async {}
}
