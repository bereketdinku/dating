import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date/global.dart';
import 'package:date/view/chat/chat_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
            : Column(
                children: <Widget>[
                  Expanded(
                      child: Container(
                          height: 500,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                          child: Column(
                            children: [
                              Container(
                                height: 120,
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: viewsList.length,
                                    padding: EdgeInsets.only(left: 10),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return GestureDetector(
                                        onTap: () {
                                          Get.to(ChatPage(
                                              uid: viewsList[index]['uid']));
                                        },
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            CircleAvatar(
                                              radius: 35,
                                              backgroundImage: NetworkImage(
                                                  viewsList[index]
                                                      ['imageProfile']),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(viewsList[index]['city']),
                                            Text(
                                              'New',
                                              style: TextStyle(),
                                            )
                                          ],
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          )))
                ],
              ));
  }
}
