import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/controller/message_controller.dart';
import 'package:date/global.dart';
import 'package:date/view/chat/chat_page.dart';
import 'package:date/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});
  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  bool isFavoriteSentClicked = true;
  List<String> viewSentList = [];
  List<String> viewReceivedList = [];
  List viewsList = [];
  final ChatController _chatController = Get.put(ChatController());
  getFavoriteListKeys() async {
    if (isFavoriteSentClicked) {
      var viewSentDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID.toString())
          .collection('viewSent')
          .get();

      for (int i = 0; i < viewSentDocument.docs.length; i++) {
        viewSentList.add(viewSentDocument.docs[i].id);
      }
      getKeyDataFromUsersCollection(viewSentList);
    } else {
      var favoriteReceivedDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUserID.toString())
          .collection('viewReceived')
          .get();
      for (int i = 0; i < favoriteReceivedDocument.docs.length; i++) {
        viewReceivedList.add(favoriteReceivedDocument.docs[i].id);
      }
    }
  }

  getKeyDataFromUsersCollection(List<String> keysList) async {
    var alluserDocument =
        await FirebaseFirestore.instance.collection("users").get();
    for (int i = 0; i < alluserDocument.docs.length; i++) {
      for (int k = 0; k < keysList.length; k++) {
        if (((alluserDocument.docs[i].data() as dynamic)["uid"]) ==
            keysList[k]) {
          viewsList.add(alluserDocument.docs[i].data());
          if (kDebugMode) {
            print(viewsList);
          }
        }
      }
    }
    setState(() {
      viewsList;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFavoriteListKeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    viewReceivedList.clear();
                    viewReceivedList = [];
                    viewSentList.clear();
                    viewSentList = [];
                    viewsList.clear();
                    viewsList = [];
                    setState(() {
                      isFavoriteSentClicked = true;
                    });
                    getFavoriteListKeys();
                  },
                  child: Text(
                    "My views",
                    style: TextStyle(
                        color:
                            isFavoriteSentClicked ? Colors.black : Colors.grey,
                        fontWeight: isFavoriteSentClicked
                            ? FontWeight.bold
                            : FontWeight.normal),
                  )),
              Text(
                " | ",
                style: TextStyle(color: Colors.grey),
              ),
              TextButton(
                  onPressed: () {
                    viewReceivedList.clear();
                    viewReceivedList = [];
                    viewSentList.clear();
                    viewSentList = [];
                    viewsList.clear();
                    viewsList = [];
                    setState(() {
                      isFavoriteSentClicked = false;
                    });
                    getFavoriteListKeys();
                  },
                  child: Text(
                    " view Me",
                    style: TextStyle(
                        color:
                            isFavoriteSentClicked ? Colors.grey : Colors.black,
                        fontWeight: isFavoriteSentClicked
                            ? FontWeight.normal
                            : FontWeight.bold),
                  ))
            ],
          ),
        ),
        body: viewsList.isEmpty
            ? const Center(
                child: Icon(
                  Icons.person_off_sharp,
                  color: Colors.black,
                  size: 60,
                ),
              )
            : _buildMessageList());
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
              // children: snapshot.data!.
              //     .map((document) => _buildMessageItem(document))
              //     .toList(),
              );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = (data['senderId'] == currentUserID)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    Timestamp timestamp = data['timestamp'];
    String formattedDate =
        DateFormat('yyyy-MM-dd – kk:mm').format(timestamp.toDate());
    return InkWell(
      onTap: () {
        // Get.to(ChatPage(uid: data['receiverId']));
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 1,
        margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * .04, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            child: Icon(CupertinoIcons.person),
          ),
          title: Text('Demo'),
          subtitle: Text(
            data['message'],
            maxLines: 1,
          ),
          trailing: Text(
            formattedDate,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
