import 'package:cloud_firestore/cloud_firestore.dart';

import 'message.dart';

// class Message {
//   final String id;
//   final String content;
//   final String type;
//   final String senderId;
//   final bool seen;
//   final Timestamp timestamp; // Assume you are using Firebase Timestamp for time

//   Message({
//     required this.id,
//     required this.content,
//     required this.seen,
//     required this.type,
//     required this.senderId,
//     required this.timestamp,
//   });

//   // Convert Message object to a JSON format
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'content': content,
//       'type': type,
//       'seen': seen,
//       'senderId': senderId,
//       'timestamp': timestamp,
//     };
//   }

//   // Create a Message object from a JSON object
//   factory Message.fromJson(Map<String, dynamic> json) {
//     return Message(
//       id: json['id'],
//       content: json['content'],
//       type: json['type'],
//       seen: json['seen'],
//       senderId: json['senderId'],
//       timestamp: json[
//           'timestamp'], // Ensure that the timestamp is correctly converted from Firebase Timestamp if required
//     );
//   }
//   factory Message.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     List<dynamic> messagesData = data['messages'] ?? [];

//     List<Message> messages = messagesData.map((msg) => Message.fromMap(msg)).toList();

//     return Chat(
//       id: doc.id,
//       memberIds: List<String>.from(data['memberIds']),
//       messages: messages,
//     );
// }

// chat_model.dart
class Chat {
  final String id;
  final List<String> memberIds;
  final List<Message> messages;
  final bool seen;

  Chat(
      {required this.id,
      required this.memberIds,
      required this.messages,
      required this.seen});
  factory Chat.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<dynamic> messagesData = data['messages'] ?? [];

    List<Message> messages =
        messagesData.map((msg) => Message.fromMap(msg)).toList();

    return Chat(
        id: doc.id,
        memberIds: List<String>.from(data['memberIds']),
        messages: messages,
        seen: data['seen']);
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberIds': memberIds,
      'messages': messages.map((message) => message.toMap()).toList(),
      'seen': seen
    };
  }
}
