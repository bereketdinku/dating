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
import 'package:flutter/foundation.dart';
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
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message(
          // Build your Message object based on the document data
          id: doc.id,
          content: doc['content'],
          seen: doc['seen'],
          type: doc['type'],
          senderId: doc['senderId'],
          timestamp: doc['timestamp'],
        );
      }).toList();
    });
  }

  Future<Message> getMessageAndUpdateSeenStatus(
      String chatId, QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    try {
      // Check if the current user is the sender
      final isCurrentUserSender =
          doc['senderId'] == FirebaseAuth.instance.currentUser!.uid;

      // Determine the initial 'seen' status based on whether the current user is the sender
      final initialSeenStatus = isCurrentUserSender ? doc['seen'] : true;

      // Update 'seen' only if the sender is not the current user and the message is not seen
      if (!isCurrentUserSender && !initialSeenStatus) {
        // Call the updateMessageSeenStatus function to handle the update
        await updateMessageSeenStatus(chatId, doc.id);
      }

      // Retrieve the updated document after the update
      final updatedDoc = await doc.reference.get();

      // Create a Message object from the updated document
      final updatedMessage = Message(
        id: updatedDoc.id,
        content: updatedDoc['content'],
        type: updatedDoc['type'],
        seen: updatedDoc['seen'],
        senderId: updatedDoc['senderId'],
        timestamp: updatedDoc['timestamp'],
      );

      return updatedMessage;
    } catch (e) {
      print('Error getting and updating message: $e');
      rethrow;
    }
  }

  Future<void> updateMessageSeenStatus(String chatId, String messageId) async {
    try {
      final messageReference = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);

      final messageSnapshot = await messageReference.get();

      if (messageSnapshot.exists) {
        final isCurrentUserSender = messageSnapshot['senderId'] ==
            FirebaseAuth.instance.currentUser!.uid;

        // Update 'seen' only if the sender is not the current user and the message is not seen
        if (!isCurrentUserSender && !messageSnapshot['seen']) {
          await messageReference.update({'seen': true});
        }
      } else {
        if (kDebugMode) {
          print('Message does not exist.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating message seen status: $e');
      }
    }
  }

  Future<void> updateSeenStatusOnChatEnter(String chatId) async {
    try {
      final messagesReference =
          _firestore.collection('chats').doc(chatId).collection('messages');

      final messagesSnapshot = await messagesReference.get();

      // Prepare a batch to update "seen" status for all messages
      final batch = _firestore.batch();

      for (final messageDoc in messagesSnapshot.docs) {
        // Check if the message is not sent by the current user and not seen
        if (messageDoc['senderId'] != FirebaseAuth.instance.currentUser!.uid &&
            !messageDoc['seen']) {
          // Update "seen" status for the message in the batch
          batch.update(messageDoc.reference, {'seen': true});
        }
      }

      // Commit the batch to Firestore
      await batch.commit();
      await _firestore.collection('chats').doc(chatId).update({'seen': true});
    } catch (e) {
      print('Error updating seen status on chat enter: $e');
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

  // Future<void> addMessageToChat(String chatId, Message newMessage) async {
  //   try {
  //     // Reference to the specific chat document
  //     DocumentReference chatRef = _firestore.collection('chats').doc(chatId);

  //     // Get the existing chat data
  //     DocumentSnapshot chatSnapshot = await chatRef.get();
  //     if (chatSnapshot.exists) {
  //       // Get the current messages list
  //       List<dynamic> currentMessages = chatSnapshot['messages'];

  //       // Add the new message to the messages list
  //       currentMessages.add(newMessage.toJson());

  //       // Update the 'messages' field with the updated list
  //       await chatRef.update({'messages': currentMessages});

  //       print('Message added to chat successfully');
  //     } else {
  //       print('Chat does not exist');
  //       // Handle the case where the chat doesn't exist
  //     }
  //   } catch (error) {
  //     print('Error adding message to chat: $error');
  //     throw error; // Handle the error as per your requirement
  //   }
  // }

  Future<void> addMessageToChat(String chatId, Message newMessage) async {
    try {
      // Reference to the specific chat document
      DocumentReference chatRef = _firestore.collection('chats').doc(chatId);

      // Update the 'messages' field with a list containing the new message
      await chatRef.update({
        'messages': [newMessage.toJson()]
      });

      print('Message added to chat successfully');
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

  Future<List<Map<String, dynamic>?>> getUsersWithoutChat(
      String currentUserId) async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>?> usersList = [];

      for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
        if (userDoc.id != currentUserId) {
          // Check if the user does not have a chat
          bool doesNotHaveChat = await userDoesNotHaveChat(userDoc.id);

          if (doesNotHaveChat) {
            usersList.add({
              'id': userDoc.id,
              'name': userDoc['name'],
              'imageProfile': userDoc['imageProfile'],
            });
          }
        }
      }

      return usersList;
    } catch (error) {
      print('Error fetching users: $error');
      throw error;
    }
  }

  Future<bool> userDoesNotHaveChat(String userId) async {
    try {
      QuerySnapshot chatSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('memberIds', arrayContains: userId)
          .limit(1)
          .get();

      return chatSnapshot.docs.isEmpty;
    } catch (error) {
      print('Error checking if user has a chat: $error');
      throw error;
    }
  }

  Future<void> deleteMessage(
      String chatId, String messageId, String? imageUrl) async {
    try {
      // Delete the message entry from Firestore
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();

      // Delete the image from storage
      if (imageUrl != null) {
        await deleteImageFromStorage(imageUrl);
      }

      print('Message and associated image deleted successfully');
    } catch (error) {
      print('Error deleting message and image: $error');
      throw error; // Handle the error as per your requirement
    }
  }

  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      // Use your storage reference to delete the image
      // Replace 'your_storage_reference' with the actual reference to your storage
      // For example: FirebaseStorage.instance.ref().child('your_path').child('your_image.jpg').delete();
      // Ensure to handle your specific storage structure and naming conventions
      // See the Firebase Storage documentation for more details.

      // Example:
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();

      print('Image deleted from storage successfully');
    } catch (error) {
      print('Error deleting image from storage: $error');
      throw error; // Handle the error as per your requirement
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
