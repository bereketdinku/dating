import 'package:cloud_firestore/cloud_firestore.dart';

import 'message.dart';

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
