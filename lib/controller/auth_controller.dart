import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../models/person.dart' as personModel;
import '../view/home/home_screen.dart';

class AuthenticationController extends GetxController {
  static AuthenticationController authenticationController = Get.find();
  late Rx<File?> pickedFile;
  XFile? imageFile;
  File? get profileImage => pickedFile.value;
  pickImageFileFromGallery() async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      Get.snackbar(
          "Profile Image", "you have successfully picked your profile image");
    }
    pickedFile = Rx<File?>(File(imageFile!.path));
  }

  captureImageFromPhone() async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      Get.snackbar("Profile Image",
          "you have successfully picked your profile image using camera");
    }
    pickedFile = Rx<File?>(File(imageFile!.path));
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    Reference reference = FirebaseStorage.instance
        .ref()
        .child("profile Images")
        .child(FirebaseAuth.instance.currentUser!.uid);
    UploadTask task = reference.putFile(imageFile);
    TaskSnapshot snapshot = await task;
    String downloadUrlOfImage = await snapshot.ref.getDownloadURL();
    return downloadUrlOfImage;
  }

  createNewUser(
    File imageProfile,
    String age,
    String name,
    String email,
    String password,
    String phoneNo,
    String city,
    String country,
    String drink,
    String smoke,
    String profession,
    String education,
    String languageSpoken,
    String religion,
  ) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      if (kDebugMode) {
        print("$userCredential");
      }
      String urlOfDownloadedImage = await uploadImageToStorage(imageProfile);
      personModel.Person person = personModel.Person(
        uid: FirebaseAuth.instance.currentUser!.uid,
        imageProfile: urlOfDownloadedImage,
        email: email,
        password: password,
        age: int.parse(age),
        phoneNo: phoneNo,
        name: name,
        city: city,
        country: country,
        drink: drink,
        education: education,
        languageSpoken: languageSpoken,
        profession: profession,
        publishedDateTime: DateTime.now().millisecondsSinceEpoch,
        smoke: smoke,
        religion: religion,
      );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(person.toJson());
      Get.snackbar(
          "Account Creation successful", "Account created successfully");
      Get.to(HomeScreen());
    } catch (errorMsg) {
      if (kDebugMode) {
        print("$errorMsg");
      }
      Get.snackbar("Account Creation unsuccessful", "$errorMsg");
    }
  }

  loginUser(String emailUser, String passwordUser) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailUser, password: passwordUser);
      Get.snackbar("Login Successfull", "logged-in successfully");

      Get.to(HomeScreen());
    } catch (error) {
      Get.snackbar("Login Unsuccessful",
          "Error occurred during signin authentication:${error}");
    }
  }

  createChatRoom(
      String chatRoomId, Map<String, dynamic> chatRoomInfoMap) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .get();
    if (snapshot.exists) {
      return true;
    } else {
      return FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(chatRoomId)
          .set(chatRoomInfoMap);
    }
  }

  Future addMessage(String chatRoomId, String messageId,
      Map<String, dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageId)
        .set(messageInfoMap);
  }

  updateLastMessageSend(
      String chatRoomId, Map<String, dynamic> lastMessageInfoMap) {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .update(lastMessageInfoMap);
  }

  Future<Stream<QuerySnapshot>> getChatRoomMessages(chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: true)
        .snapshots();
  }
  // Future<Stream<QuerySnapshot>> getChatRooms() async {
  //   String? myUsername = await SharedPreferenceHelper().getUserName();
  //   print(myUsername);
  //   return FirebaseFirestore.instance
  //       .collection("chatrooms")
  //       .orderBy("time", descending: true)
  //       .where("users", arrayContains: myUsername!)
  //       .snapshots();
  // }
}
