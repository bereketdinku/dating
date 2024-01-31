import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../global.dart';
import 'user_detail.dart';

class LikeScreen extends StatefulWidget {
  const LikeScreen({super.key});
  @override
  State<LikeScreen> createState() => _LikeScreenState();
}

class _LikeScreenState extends State<LikeScreen> {
  bool isFavoriteSentClicked = true;
  List<String> likeSentList = [];
  List<String> likeReceivedList = [];
  List likesList = [];

  getFavoriteListKeys() async {
    if (isFavoriteSentClicked) {
      var favoriteSentDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('likeSent')
          .get();

      for (int i = 0; i < favoriteSentDocument.docs.length; i++) {
        likeSentList.add(favoriteSentDocument.docs[i].id);
      }
      getKeyDataFromUsersCollection(likeSentList);
    } else {
      var favoriteReceivedDocument = await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('likeReceived')
          .get();
      for (int i = 0; i < favoriteReceivedDocument.docs.length; i++) {
        likeReceivedList.add(favoriteReceivedDocument.docs[i].id);
      }
      getKeyDataFromUsersCollection(likeReceivedList);
    }
  }

  getKeyDataFromUsersCollection(List<String> keysList) async {
    var alluserDocument =
        await FirebaseFirestore.instance.collection("users").get();
    for (int i = 0; i < alluserDocument.docs.length; i++) {
      for (int k = 0; k < keysList.length; k++) {
        if (((alluserDocument.docs[i].data() as dynamic)["uid"]) ==
            keysList[k]) {
          likesList.add(alluserDocument.docs[i].data());
          if (kDebugMode) {
            print(likesList);
          }
        }
      }
    }
    setState(() {
      likesList;
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
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    likeReceivedList.clear();
                    likeReceivedList = [];
                    likeSentList.clear();
                    likeSentList = [];
                    likesList.clear();
                    likesList = [];
                    setState(() {
                      isFavoriteSentClicked = true;
                    });
                    getFavoriteListKeys();
                  },
                  child: Text(
                    "My Likes",
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
                    likeReceivedList.clear();
                    likeReceivedList = [];
                    likeSentList.clear();
                    likeSentList = [];
                    likesList.clear();
                    likesList = [];
                    setState(() {
                      isFavoriteSentClicked = false;
                    });
                    getFavoriteListKeys();
                  },
                  child: Text(
                    " Like Me",
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
        body: likesList.isEmpty
            ? const Center(
                child: Icon(
                  Icons.person_off_sharp,
                  color: Colors.black,
                  size: 60,
                ),
              )
            : GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(8),
                children: List.generate(likesList.length, (index) {
                  return GridTile(
                      child: Padding(
                    padding: EdgeInsets.all(2),
                    child: Card(
                      color: Colors.blue.shade200,
                      child: GestureDetector(
                        onTap: () {
                          Get.to(UserDetailScreen(
                            userID: likesList[index]["uid"],
                          ));
                        },
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)),
                            image: DecorationImage(
                                image: NetworkImage(
                                    likesList[index]["imageProfile"]),
                                fit: BoxFit.cover),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Spacer(),
                                  Text(
                                    likesList[index]['name'].toString() +
                                        "" +
                                        likesList[index]['age'].toString(),
                                    style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      Expanded(
                                          child: Text(
                                        likesList[index]['city'].toString() +
                                            " ,",
                                        maxLines: 2,
                                        style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            color: Colors.black,
                                            fontSize: 14),
                                      )),
                                    ],
                                  ),
                                  Text(
                                    likesList[index]['country'].toString(),
                                    style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.black,
                                        fontSize: 14),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ));
                }),
              ));
  }
}
