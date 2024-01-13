// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:date/models/chat.dart';

// class ChatService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Stream<List<Chat>> getChatsForUser(String userId) {
//     return _firestore
//         .collection('chats')
//         .where('participants', arrayContains: userId)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs
//           .map((doc) => Chat(
//               id: doc.id, participants: List<String>.from(doc['participants'])))
//           .toList();
//     });
//   }

//   Stream<List<Message>> getMessagesForChat(String chatId) {
//     return _firestore
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .orderBy('timestamp')
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs
//           .map((doc) => Message(
//                 id: doc.id,
//                 senderId: doc['senderId'],
//                 message: doc['message'],
//                 timestamp: (doc['timestamp'] as Timestamp).toDate(),
//               ))
//           .toList();
//     });
//   }

//   Future<void> sendMessage(
//       String chatId, String senderId, String message) async {
//     await _firestore
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .add({
//       'senderId': senderId,
//       'message': message,
//       'timestamp': Timestamp.now(),
//     });
//   }

//   String generateChatId(String userId1, String userId2) {
//     List<String> userIds = [userId1, userId2];
//     userIds.sort(); // Sort the user IDs to ensure consistency
//     return "${userIds[0]}_${userIds[1]}"; // Concatenate sorted user IDs
//   }
// }
