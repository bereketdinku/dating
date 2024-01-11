import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/controller/message_controller.dart';
import 'package:date/global.dart';
import 'package:date/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:mime/mime.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:open_filex/open_filex.dart';
import 'package:http/http.dart' as http;

class ChatPage extends StatefulWidget {
  final String uid;
  const ChatPage({super.key, required this.uid});

  @override
  State<StatefulWidget> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController _chatController = Get.put(ChatController());
  final TextEditingController _messageController = TextEditingController();

  void sendmessage() async {
    if (_messageController.text.isNotEmpty) {
      _chatController.sendMessage(widget.uid, _messageController.text);
      _messageController.clear();
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      String token = snap['token'];
      sendPushMessage(token, _messageController.text, "new message");
    }
  }

  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=BB0tx-tOn9-41yqiEjrl8euikMlX4nvL3zpwP_yVtPLDU8tbuXSqJy4kmsIeDZ'
          },
          body: jsonEncode(<String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title
            },
            'notification': <String, dynamic>{
              'title': title,
              "body": body,
              'android_channel_id': "dbfood"
            },
            "to": token
          }));
    } catch (err) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Chat'),
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_horiz,
                  size: 30,
                  color: Colors.white,
                ))
          ],
        ),
        body: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildMessageInput(),
          ],
        ));
  }

  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatController.getMessages(currentUserID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading');
          }
          return ListView(
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = (data['senderId'] == currentUserID)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Container(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
              crossAxisAlignment: (data['senderId'] == currentUserID)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisAlignment: (data['senderId'] == currentUserID)
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [ChatBubble(message: data['message'])]),
        ));
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.emoji_emotions,
                )),
            Expanded(
                child: TextField(
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(hintText: 'Type something'),
              controller: _messageController,
              obscureText: false,
            )),
            IconButton(onPressed: () {}, icon: Icon(Icons.image)),
            IconButton(onPressed: () {}, icon: Icon(Icons.camera_alt_rounded)),
            MaterialButton(
              padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
              shape: CircleBorder(),
              onPressed: sendmessage,
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 25,
              ),
            )
          ],
        ),
      ),
    );
  }
}
