import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import "package:http/http.dart" as http;
import '../models/person.dart';

class ProfileController extends GetxController {
  final Rx<List<Person>> usersProfileList = Rx<List<Person>>([]);
  List<Person> get allUsersProfileList => usersProfileList.value;
  getResults() {
    onInit();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    if (chosenAge == null || chosenGender == null) {
      usersProfileList.bindStream(FirebaseFirestore.instance
          .collection("users")
          .where("uid", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
          .map((QuerySnapshot queryDataSnapshot) {
        List<Person> profileList = [];
        for (var eachProfile in queryDataSnapshot.docs) {
          profileList.add(Person.fromDataSnapshot(eachProfile));
        }
        return profileList;
      }));
    } else {
      usersProfileList.bindStream(FirebaseFirestore.instance
          .collection("users")
          .where("uid", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where("age", isGreaterThanOrEqualTo: int.parse(chosenAge.toString()))
          .snapshots()
          .map((QuerySnapshot queryDataSnapshot) {
        List<Person> profileList = [];
        for (var eachProfile in queryDataSnapshot.docs) {
          profileList.add(Person.fromDataSnapshot(eachProfile));
        }
        return profileList;
      }));
    }
  }

  favoriteSentAndFavoriteReceived(String toUserID, String senderName) async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection('favoriteReceived')
        .doc(currentUserID)
        .get();

    if (document.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("favoriteReceived")
          .doc(currentUserID)
          .delete();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID)
          .collection('favoriteSent')
          .doc(toUserID)
          .delete();
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("favoriteReceived")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({});
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('favoriteSent')
          .doc(toUserID)
          .set({});
      sendNotificationToUser(toUserID, "favorite", senderName);
      Get.snackbar("Favorite successful", "Favorite Added successfully");
    }
  }

  likeSentAndFavoriteReceived(String toUserID, String senderName) async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection('likeReceived')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (document.exists) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("likeReceived")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('likeSent')
          .doc(toUserID)
          .delete();
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("likeReceived")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({});
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('likeSent')
          .doc(toUserID)
          .set({});
      sendNotificationToUser(toUserID, "like", senderName);
      Get.snackbar("Like successful", "Like Added successfully");
    }
  }

  ViewSentAndViewReceived(String toUserID, String senderName) async {
    var document = await FirebaseFirestore.instance
        .collection("users")
        .doc(toUserID)
        .collection('viewReceived')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (document.exists) {
      print('already in view list');
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(toUserID)
          .collection("viewReceived")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({});
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('viewSent')
          .doc(toUserID)
          .set({});
      sendNotificationToUser(toUserID, "view", senderName);
      Get.snackbar("View successful", "View Added successfully");
    }
  }

  sendNotificationToUser(receiverID, featureType, senderName) async {
    String userDeviceToken = "";
    await FirebaseFirestore.instance
        .collection("users")
        .doc()
        .get()
        .then((snapshot) {
      if (snapshot.data()!['userDeviceToken'] != null) {
        userDeviceToken = snapshot.data()!['userDeviceToken'].toString();
      }
    });
    notificationFormat(userDeviceToken, receiverID, featureType, senderName);
  }

  notificationFormat(userDeviceToken, receiverID, featureType, senderName) {
    Map<String, String> headerNotification = {
      "Content-Type": "application/jspn",
      'Authorization': fcmServerToken
    };
    Map bodyNotification = {
      "body":
          "you have received a new $featureType from $senderName. Click to see.",
      "title": "New $featureType"
    };
    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "userID": receiverID,
      "senderID": FirebaseAuth.instance.currentUser!.uid
    };
    Map notificationOfficialFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": 'high',
      "to": userDeviceToken
    };
    http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: headerNotification,
        body: jsonEncode(notificationOfficialFormat));
  }
}
