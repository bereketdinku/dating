import 'package:date/models/chat.dart';
import 'package:date/view/chat/chat_page.dart';
import 'package:date/view/chat/new_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import '../../controller/message_controller.dart';

class ChatListPage extends StatelessWidget {
  final ChatController _chatController = ChatController();

  ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: Text('Chats')),
      body: StreamBuilder<List<Chat>>(
        stream: _chatController.getChats(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Display a user-friendly message when the chat list is empty
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('You have no chats yet.'),
                  ElevatedButton(
                    onPressed: () {
                      Get.to(NewChatPage());
                    },
                    child: Text('Start a New Chat'),
                  ),
                ],
              ),
            );
          } else {
            final chats = snapshot.data!;
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                // Get the ID of the other member in the chat
                String otherMemberId = chats[index]
                    .memberIds
                    .firstWhere((id) => id != currentUserId);

                // Retrieve the user information from Firestore
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(otherMemberId)
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (!userSnapshot.hasData) {
                      return ListTile(
                        title: Text('Loading...'),
                      );
                    } else {
                      // Get the user data from the DocumentSnapshot
                      Map<String, dynamic> userData =
                          userSnapshot.data!.data() as Map<String, dynamic>;
                      String userName = userData['name'];
                      String userImage = userData['imageProfile'];

                      // Display the chat member's name and image in the ListTile
                      // return ListTile(
                      //   leading: CircleAvatar(
                      //     backgroundImage: NetworkImage(userImage),
                      //   ),
                      //   title: Text(userName),
                      //   onTap: () => Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => ChatPage(
                      //         chat: chats[index],
                      //         currentUserId: currentUserId,
                      //         uid: otherMemberId,
                      //       ),
                      //     ),
                      //   ),
                      // );

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 1,
                        margin: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * .04,
                            vertical: 4),
                        child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(userImage),
                            ),
                            title: Text(userName),
                            onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      chat: chats[index],
                                      currentUserId: currentUserId,
                                      uid: otherMemberId,
                                    ),
                                  ),
                                )),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
