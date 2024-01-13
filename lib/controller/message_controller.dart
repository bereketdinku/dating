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
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Chat>> getChats(String userId) {
    return _firestore
        .collection('chats')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Chat(
                id: doc.id,
                memberIds: List<String>.from(doc['memberIds']),
                messages: []))
            .toList());
  }

  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message(
                id: doc.id,
                content: doc['content'],
                senderId: doc['senderId'],
                timestamp: doc['timestamp']))
            .toList());
  }

  Future<void> sendMessage(
      String chatId, String senderId, String content) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'content': content,
      'senderId': senderId,
      'timestamp': Timestamp.fromDate(DateTime.now().toUtc()),
    });
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
}
