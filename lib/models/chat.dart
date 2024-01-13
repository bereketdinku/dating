import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String content;
  final String senderId;
  final Timestamp timestamp; // Assume you are using Firebase Timestamp for time

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
  });

  // Convert Message object to a JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'timestamp': timestamp,
    };
  }

  // Create a Message object from a JSON object
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      senderId: json['senderId'],
      timestamp: json[
          'timestamp'], // Ensure that the timestamp is correctly converted from Firebase Timestamp if required
    );
  }
}

// chat_model.dart
class Chat {
  final String id;
  final List<String> memberIds;
  final List<Message> messages;

  Chat({required this.id, required this.memberIds, required this.messages});
}
