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

class ChatListPage extends StatefulWidget {
  ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatController _chatController = ChatController();
  late String currentUserId;
  TextEditingController searchController = TextEditingController();
  List<Chat> filteredChats = [];
  List<Chat> allChats = [];
  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    print(filteredChats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterChats,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                labelText: 'Search Chats',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
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
                  allChats = snapshot.data!;
                  final chats =
                      filteredChats.isNotEmpty ? filteredChats : allChats;
                  return chats.isEmpty
                      ? Center(
                          child: Text('User not found'),
                        )
                      : ListView.builder(
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
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (!userSnapshot.hasData) {
                                  return ListTile(
                                    title: Text('Loading...'),
                                  );
                                } else {
                                  // Get the user data from the DocumentSnapshot
                                  Map<String, dynamic> userData =
                                      userSnapshot.data!.data()
                                          as Map<String, dynamic>;
                                  String userName = userData['name'];
                                  String userImage = userData['imageProfile'];

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    elevation: 1,
                                    margin: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.width *
                                                .04,
                                        vertical: 4),
                                    child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(userImage),
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
                                                    : Text(
                                                        'you have a picture'),
                                          ],
                                        ),
                                        trailing: Column(
                                          children: [
                                            Text(formatMessageTimestamp(
                                                lastMessage.timestamp
                                                    .toDate())),
                                            chat.seen
                                                ? Icon(Icons.done_all,
                                                    color: Colors
                                                        .pink) // Seen icon
                                                : lastMessage.senderId !=
                                                        currentUserId
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  Colors.pink,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .pink)),
                                                          child: Text(
                                                            'new',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      )
                                                    : Icon(Icons.done,
                                                        color: Colors.grey),
                                          ],
                                        ), // Unseen icon
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

  void _filterChats(String query) async {
    List<Chat> filtered = await _chatController.filterChatsByQuery(
      currentUserId,
      query,
      allChats,
    );

    setState(() {
      filteredChats = filtered;
    });
  }

  String formatMessageTimestamp(DateTime timestamp) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(timestamp);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        // Less than one hour, show minutes
        return '${difference.inMinutes}m ago';
      } else {
        // Less than one day, show hours
        return '${difference.inHours}h ago';
      }
    } else {
      // More than one day, show date
      return DateFormat('MMMM dd').format(timestamp);
    }
  }
}
