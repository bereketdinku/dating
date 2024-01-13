import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:date/models/chat.dart'; // Import your Chat model or relevant model
import '../../controller/message_controller.dart';
import 'chat_page.dart'; // Import the ChatPage

class NewChatPage extends StatelessWidget {
  final ChatController _chatController = ChatController();

  NewChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Chat')),
      body: FutureBuilder<List<Map<String, dynamic>?>>(
        future: _chatController
            .getAllUsersExceptCurrent(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) => ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(users[index]!['imageProfile']),
              ),
              title: Text(users[index]!['name']),
              onTap: () async {
                // Generate a unique chat ID using the member IDs and UUID
                // Extract the user ID from the map
                String selectedUserId = users[index]!['id'];

                // Generate a unique chat ID using the member IDs and UUID
                String newChatId =
                    '${FirebaseAuth.instance.currentUser!.uid}_$selectedUserId${Uuid().v4()}';

                // Create a new chat using the provided details
                Chat newChat = Chat(
                  id: newChatId,
                  memberIds: [
                    FirebaseAuth.instance.currentUser!.uid,
                    users[index]!['id']
                  ],
                  messages: [],
                );

                // Create the new chat in Firestore
                await _chatController.createChat(newChat);

                // Navigate to the ChatPage with the newly created Chat object
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      chat: newChat,
                      currentUserId: FirebaseAuth.instance.currentUser!.uid,
                      uid: users[index]!['id'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
