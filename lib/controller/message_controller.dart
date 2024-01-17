// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:date/global.dart';
// import 'package:date/models/message.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

// class ChatController extends ChangeNotifier {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
//   Future<void> sendMessage(String receiverId, String message) async {
//     final String currentUserId = _firebaseAuth.currentUser!.uid;
//     final Timestamp timestamp = Timestamp.now();

//     Message newMessage = Message(
//         senderId: currentUserId,
//         receiverId: receiverId,
//         message: message,
//         timestamp: timestamp);
//     List<String> ids = [currentUserId, receiverId];
//     ids.sort();
//     String chatRoomId = ids.join("_");
//   await  FirebaseFirestore.instance
//           .collection("chats")
//           .doc(FirebaseAuth.instance.currentUser!.uid)
//           .collection('messageSent')
//           .doc(receiverId)
//           .collection('messages')
//         .add(newMessage.toMap());
//         await  FirebaseFirestore.instance
//           .collection("chats")
//           .doc(FirebaseAuth.instance.currentUser!.uid)
//           .collection('messagereceived')
//           .doc(receiverId)
//           .collection('messages')
//         .add(newMessage.toMap());
//     // await _firebaseFirestore
//     //     .collection('chat_rooms')
//     //     .doc(currentUserId)
//     //     .collection('messages')
//     //     .add(newMessage.toMap());
//     // await _firebaseFirestore
//     //     .collection('chat_rooms')
//     //     .doc(receiverId)
//     //     .collection('messages')
//     //     .add(newMessage.toMap());
//   }

//   Stream<QuerySnapshot> getMessages(String userId) {
//     // List<String> ids = [userId, otherUserId];
//     // ids.sort();
//     // String chatRoomId = ids.join("_");
//     return _firebaseFirestore
//         .collection('chat_rooms')
//         .doc(userId)
//         .collection('messages')
//         .orderBy('timestamp', descending: false)
//         .snapshots();
//   }

//   Stream<QuerySnapshot> getMessageList() {
//     return _firebaseFirestore
//         .collection('chat_rooms')
//         .doc(FirebaseAuth.instance.currentUser!.uid)
//         .collection('messages')
//         .snapshots();
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/controller/profile_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';

import '../models/chat.dart';
import '../models/message.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProfileController _profileController = ProfileController();
  late Rx<File?> pickedFile;
  late Rx<User?> firebaseCurrentUser;
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

  Stream<List<Chat>> getChats(String userId) {
    // return _firestore
    //     .collection('chats')
    //     .where('memberIds', arrayContains: userId)
    //     .snapshots()
    //     .map((snapshot) => snapshot.docs
    //         .map((doc) => Chat(
    //             id: doc.id,
    //             memberIds: List<String>.from(doc['memberIds']),
    //             messages: []))
    //         .toList());

    try {
      return _firestore
          .collection('chats')
          .where('memberIds', arrayContains: userId)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs.map((chatDoc) {
          // Convert each chat document to a Chat object
          return Chat.fromFirestore(chatDoc);
        }).toList();
      });
    } catch (error) {
      print('Error fetching chats: $error');
      // You might want to handle the error differently based on your needs
      throw error;
    }
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

  Future<void> sendMessageWithImage(
    String chatId,
    String senderId,
  ) async {
    try {
      // Reference to the specific collection of messages within the chat
      String urlOfDownloadedImage = await uploadImageToStorage(profileImage!);

      CollectionReference messagesCollection =
          _firestore.collection('chats').doc(chatId).collection('messages');

      // Add the new message to the collection and get the automatically generated ID
      DocumentReference newMessageRef = await messagesCollection.add({
        'content': urlOfDownloadedImage,
        'type': 'image',
        'seen': false,
        'senderId': senderId,
        'timestamp': Timestamp.fromDate(DateTime.now().toUtc()),
      });

      // Get the automatically generated message ID
      String messageId = newMessageRef.id;
      Message newMessage = Message(
        id: newMessageRef.id,
        content: urlOfDownloadedImage,
        seen: false,
        type: 'image',
        senderId: FirebaseAuth.instance.currentUser!.uid,
        timestamp: Timestamp.now(),
      );

      await addMessageToChat(chatId, newMessage);

      print('Message added successfully with ID: $messageId');
    } catch (error) {
      print('Error adding message: $error');
      throw error; // Handle the error as per your requirement
    }
  }

  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final isCurrentUserSender =
                  doc['senderId'] == FirebaseAuth.instance.currentUser!.uid;
              final seen = isCurrentUserSender ? doc['seen'] : true;

              // Update 'seen' only if the sender is not the current user
              if (!isCurrentUserSender && !seen) {
                // doc.reference.update({'seen': true});
                updateMessageSeenStatus(chatId, doc.id);
              }

              return Message(
                id: doc.id,
                content: doc['content'],
                type: doc['type'],
                seen: seen,
                senderId: doc['senderId'],
                timestamp: doc['timestamp'],
              );
            }).toList());
  }

  Future<void> updateMessageSeenStatus(String chatId, String messageId) async {
    final messageReference = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    try {
      // Retrieve the current message
      DocumentSnapshot messageSnapshot = await messageReference.get();

      if (messageSnapshot.exists) {
        // Update 'seen' status only if it is false
        if (!messageSnapshot['seen']) {
          await messageReference.update({'seen': true});
          print('Message seen status updated successfully.');
        } else {
          print('Message already marked as seen.');
        }
      } else {
        print('Message does not exist.');
        // Handle the case where the message does not exist.
      }
    } catch (e) {
      print('Error updating message seen status: $e');
      // Handle the error as needed.
    }
  }

  Future<void> sendMessage(
      String chatId, String senderId, String content, String token) async {
    try {
      // Reference to the specific collection of messages within the chat
      CollectionReference messagesCollection =
          _firestore.collection('chats').doc(chatId).collection('messages');

      // Add the new message to the collection and get the automatically generated ID
      DocumentReference newMessageRef = await messagesCollection.add({
        'content': content,
        'type': 'text',
        'seen': false,
        'senderId': senderId,
        'timestamp': Timestamp.fromDate(DateTime.now().toUtc()),
      });

      // Get the automatically generated message ID
      String messageId = newMessageRef.id;
      Message newMessage = Message(
        id: newMessageRef.id,
        content: content,
        seen: false,
        type: 'text',
        senderId: FirebaseAuth.instance.currentUser!.uid,
        timestamp: Timestamp.now(),
      );

      await addMessageToChat(chatId, newMessage);
      sendPushNotification(token, content);
      print('Message added successfully with ID: $messageId');
    } catch (error) {
      print('Error adding message: $error');
      throw error; // Handle the error as per your requirement
    }
  }

  Future<void> addMessageToChat(String chatId, Message newMessage) async {
    try {
      // Reference to the specific chat document
      DocumentReference chatRef = _firestore.collection('chats').doc(chatId);

      // Get the existing chat data
      DocumentSnapshot chatSnapshot = await chatRef.get();
      if (chatSnapshot.exists) {
        // Get the current messages list
        List<dynamic> currentMessages = chatSnapshot['messages'];

        // Add the new message to the messages list
        currentMessages.add(newMessage.toJson());

        // Update the 'messages' field with the updated list
        await chatRef.update({'messages': currentMessages});

        print('Message added to chat successfully');
      } else {
        print('Chat does not exist');
        // Handle the case where the chat doesn't exist
      }
    } catch (error) {
      print('Error adding message to chat: $error');
      throw error; // Handle the error as per your requirement
    }
  }

  Future<List<Map<String, dynamic>?>> getAllUsersExceptCurrent(
      String currentUserId) async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      List<Map<String, dynamic>?> usersList = usersSnapshot.docs
          .map((doc) {
            if (doc.id != currentUserId) {
              return {
                'id': doc.id,
                'name': doc[
                    'name'], // Assuming 'name' is a field in your 'users' collection
                'imageProfile': doc[
                    'imageProfile'], // Assuming 'imageProfile' is a field in your 'users' collection
              };
            } else {
              return null;
            }
          })
          .where((user) => user != null)
          .toList();
      return usersList;
    } catch (error) {
      print('Error fetching users: $error');
      throw error;
    }
  }

  Future<void> createChat(Chat newChat) async {
    try {
      // Add the new chat document to the Firestore 'chats' collection
      await _firestore.collection('chats').doc(newChat.id).set({
        'id': newChat.id,
        'memberIds': newChat.memberIds,
        'messages': newChat.messages
            .map((message) => message.toJson())
            .toList(), // Assuming you have a method toJson() in your Message model
      });
      print('Chat created successfully');
    } catch (error) {
      print('Error creating chat: $error');
      throw error; // Handle the error as per your requirement
    }
  }

  Future<void> sendPushNotification(token, content) async {
    try {
      final body = {
        "to": token,
        // "fjcUE_ZqQrqsxhK6a4BqfC:APA91bE8VPBLKcRLoluzWZ_xoALhWXrK2K7jBCLpaGnZr4Lt-aT0BYDpnA53-zdVhYdG_27RS6TSSqF-FmyP8am_MtSTS6kJDP6V4OXqEdER4m0lr-j81isn7xYbxuEKEvgtvsIZZ7i6",
        "notification": {"title": "new message", "body": content}
      };
      var response = await post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:
              "key=AAAAwe9tmkg:APA91bGI9ACjGc3NuMC4FHIDyP2SbNzdoBZsLCL3cy_Savr_8TJ51cxfJI3ROrwyqYgizOJT2KNlDmEbZJLUoWXS1LCFfTT4TYumembJkxNG6f8vpk1K9W-fd8PHJ7GgHVF8s6IcOewN"
        },
        body: jsonEncode(body),
      );
    } catch (e) {
      // Handle errors here
    }
  }
}
