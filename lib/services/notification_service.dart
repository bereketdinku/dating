import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final String fcmServerToken =
      "key=AAAAwe9tmkg:APA91bGI9ACjGc3NuMC4FHIDyP2SbNzdoBZsLCL3cy_Savr_8TJ51cxfJI3ROrwyqYgizOJT2KNlDmEbZJLUoWXS1LCFfTT4TYumembJkxNG6f8vpk1K9W-fd8PHJ7GgHVF8s6IcOewN"; // Replace with your FCM server token

  Future<void> sendNotificationToUser(
      String receiverID, String featureType, String senderName) async {
    String userDeviceToken = await _getUserDeviceToken(receiverID);
    if (userDeviceToken.isNotEmpty) {
      _notificationFormat(userDeviceToken, receiverID, featureType, senderName);
    }
  }

  Future<String> _getUserDeviceToken(String receiverID) async {
    String userDeviceToken = "";
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(receiverID)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
      if (userData.containsKey('userDeviceToken') &&
          userData['userDeviceToken'] != null) {
        userDeviceToken = userData['userDeviceToken'].toString();
      }
    }

    return userDeviceToken;
  }

  void _notificationFormat(String userDeviceToken, String receiverID,
      String featureType, String senderName) {
    Map<String, String> headerNotification = {
      "Content-Type": "application/json",
      'Authorization':
          'key=$fcmServerToken', // Ensure you include 'key=' before the server token
    };
    Map<String, dynamic> bodyNotification = {
      "body":
          "You have received a new $featureType from $senderName. Click to see.",
      "title": "New $featureType",
    };
    Map<String, dynamic> dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "userID": receiverID,
      "senderID": FirebaseAuth.instance.currentUser!.uid,
    };
    Map<String, dynamic> notificationOfficialFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": 'high',
      "to": userDeviceToken,
    };
    http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(notificationOfficialFormat),
    );
  }
}
