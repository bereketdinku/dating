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
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/chat.dart';
import '../models/message.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProfileController _profileController = ProfileController();
  FirebaseStorage _storage = FirebaseStorage.instance;
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
          await updateSeenStatus(chatId);
        }
      }

      // Commit the batch to Firestore
      await batch.commit();
      // await _firestore.collection('chats').doc(chatId).update({'seen': true});
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

  Future<String> getUserNameFromMemberId(String memberId) async {
    try {
      // Retrieve the user information from Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(memberId)
          .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        String userName = userData['name'];
        return userName;
      } else {
        return 'Unknown User'; // Placeholder if user data doesn't exist
      }
    } catch (error) {
      print('Error retrieving user information: $error');
      throw error;
    }
  }

  Future<List<Chat>> filterChatsByQuery(
      String currentUserId, String query, List<Chat> chats) async {
    query = query.toLowerCase();

    List<Chat> filteredChats = [];

    await Future.wait(chats.map((chat) async {
      // Filter based on chat members' names
      for (String memberId in chat.memberIds) {
        String userName = await getUserNameFromMemberId(memberId);
        if (userName.toLowerCase().contains(query)) {
          filteredChats.add(chat);
          break; // Break out of the inner loop once a match is found
        }
      }

      // Add additional filtering logic if needed
    }));

    return filteredChats;
  }

  Future<void> addMessageToChat(String chatId, Message newMessage) async {
    try {
      // Reference to the specific chat document
      DocumentReference chatRef = _firestore.collection('chats').doc(chatId);

      // Update the 'messages' field with a list containing the new message
      await chatRef.update({
        'messages': [newMessage.toJson()],
        'seen': false
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
    String currentUserId,
  ) async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<Map<String, dynamic>?> usersList = [];

      for (QueryDocumentSnapshot userDoc in usersSnapshot.docs) {
        if (userDoc.id != currentUserId) {
          // Check if the current user does not have a chat with this user
          bool doesNotHaveChat =
              await currentUserDoesNotHaveChat(currentUserId, userDoc.id);

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

  Future<bool> currentUserDoesNotHaveChat(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      // Check if there's a chat where both users are members
      QuerySnapshot chatSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('memberIds', arrayContains: currentUserId)
          .limit(1)
          .get();

      // Filter locally to ensure both users are in the chat
      bool chatFound = chatSnapshot.docs
          .where((doc) => doc['memberIds'].contains(otherUserId))
          .isNotEmpty;

      return !chatFound;
    } catch (error) {
      print(
          'Error checking if current user has a chat with other user: $error');
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
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();

      print('Image deleted from storage successfully');
    } catch (error) {
      print('Error deleting image from storage: $error');
      throw error; // Handle the error as per your requirement
    }
  }

  Future<File> downloadImage(String imagePath) async {
    try {
      // Get the download URL for the image
      String downloadURL =
          await _storage.ref().child(imagePath).getDownloadURL();

      // Download the image using http
      http.Response response = await http.get(Uri.parse(downloadURL));

      // Save the file to a temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final File file = File('$tempPath/temp_image.jpg');
      await file.writeAsBytes(response.bodyBytes);

      return file;
    } catch (e) {
      print('Error downloading image: $e');
      throw e;
    }
  }

  Future<void> createChat(Chat newChat) async {
    try {
      // Add the new chat document to the Firestore 'chats' collection
      await _firestore.collection('chats').doc(newChat.id).set({
        'id': newChat.id,
        'memberIds': newChat.memberIds,
        'messages':
            newChat.messages.map((message) => message.toJson()).toList(),
        'seen': newChat
            .seen // Assuming you have a method toJson() in your Message model
      });
      print('Chat created successfully');
    } catch (error) {
      print('Error creating chat: $error');
      throw error; // Handle the error as per your requirement
    }
  }

  Future<void> updateSeenStatus(
    String chatId,
  ) async {
    try {
      // Update the 'seen' field in the Firestore document
      await _firestore.collection('chats').doc(chatId).update({
        'seen': true,
      });
      print('Seen status updated successfully');
    } catch (error) {
      print('Error updating seen status: $error');
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
