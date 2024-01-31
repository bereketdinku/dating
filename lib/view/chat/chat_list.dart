import 'package:date/models/chat.dart';
import 'package:date/models/message.dart';
import 'package:date/view/chat/chat_page.dart';
import 'package:date/view/chat/new_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:intl/intl.dart';

import '../../controller/message_controller.dart';

class ChatListPage extends StatelessWidget {
  final ChatController _chatController = ChatController();

  ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    TextEditingController searchController = TextEditingController();
    List<Chat> filteredChats = [];
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextField(
          //     controller: searchController,
          //     // onChanged: _filterChats,
          //     decoration: InputDecoration(
          //       labelText: 'Search Chats',
          //       prefixIcon: Icon(Icons.search),
          //     ),
          //   ),
          // ),
          Expanded(
            child: StreamBuilder<List<Chat>>(
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
                      Chat chat = chats[index];
                      Message lastMessage = chat.messages.isNotEmpty
                          ? chat.messages.last
                          : Message(
                              id: '',
                              content: '',
                              seen: false,
                              type: '',
                              senderId: '',
                              timestamp: Timestamp.now());
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
                            Map<String, dynamic> userData = userSnapshot.data!
                                .data() as Map<String, dynamic>;
                            String userName = userData['name'];
                            String userImage = userData['imageProfile'];

                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 1,
                              margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * .04,
                                  vertical: 4),
                              child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(userImage),
                                  ),
                                  title: Text(userName),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      lastMessage.type == 'text'
                                          ? Text('${lastMessage.content}')
                                          : lastMessage.senderId ==
                                                  currentUserId
                                              ? Text('you sent a picture')
                                              : Text('you have a picture'),
                                      Text(DateFormat('MMMM dd').format(
                                          lastMessage.timestamp.toDate())),
                                    ],
                                  ),
                                  trailing: chat.seen == true
                                      ? Icon(Icons.done_all,
                                          color: Colors.blue) // Seen icon
                                      : Icon(Icons.done,
                                          color: Colors.grey), // Unseen icon
                                  // Add more details or customize the ListTile as needed

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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(NewChatPage());
        },
        child: Icon(Icons.chat),
      ),
    );
  }
  // void _filterChats(String query) {
  //   setState(() {
  //     filteredChats = _chatController.filterChatsByQuery(
  //       FirebaseAuth.instance.currentUser!.uid,
  //       query,
  //     );
  //   });
  // }
}
