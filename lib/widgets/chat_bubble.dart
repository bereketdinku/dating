import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13), color: Colors.pinkAccent),
      child: Text(
        message,
        style: TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }
}
