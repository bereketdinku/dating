// import 'dart:convert';
// import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:date/controller/message_controller.dart';
// import 'package:date/global.dart';
// import 'package:date/widgets/chat_bubble.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// // import 'package:flutter_chat_ui/flutter_chat_ui.dart';
// // import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:get/get.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'package:mime/mime.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:path_provider/path_provider.dart';
// // import 'package:open_filex/open_filex.dart';
// import 'package:http/http.dart' as http;
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

// class ChatPage extends StatefulWidget {
//   final String uid;
//   const ChatPage({super.key, required this.uid});

//   @override
//   State<StatefulWidget> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final ChatController _chatController = Get.put(ChatController());
//   final TextEditingController _messageController = TextEditingController();
//   bool _showemoji = false;
//   String imageProfile = '';
//   String name = '';
//   retrieveUserInfo() async {
//     await FirebaseFirestore.instance
//         .collection("users")
//         .doc(widget.uid)
//         .get()
//         .then((snapshot) {
//       if (snapshot.exists) {
//         setState(() {
//           imageProfile = snapshot.data()!["imageProfile"];
//           name = snapshot.data()!["name"];
//         });
//       }
//     });
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     retrieveUserInfo();
//   }

//   void sendmessage() async {
//     if (_messageController.text.isNotEmpty) {
//       _chatController.sendMessage(widget.uid, _messageController.text);
//       _messageController.clear();
//       DocumentSnapshot snap = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.uid)
//           .get();
//       String token = snap['token'];
//       setState(() {
//         _showemoji = false;
//       });
//       sendPushMessage(token, _messageController.text, "new message");
//     }
//   }

//   void sendPushMessage(String token, String body, String title) async {
//     try {
//       await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
//           headers: <String, String>{
//             'Content-Type': 'application/json',
//             'Authorization':
//                 'key=BB0tx-tOn9-41yqiEjrl8euikMlX4nvL3zpwP_yVtPLDU8tbuXSqJy4kmsIeDZ'
//           },
//           body: jsonEncode(<String, dynamic>{
//             'priority': 'high',
//             'data': <String, dynamic>{
//               'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//               'status': 'done',
//               'body': body,
//               'title': title
//             },
//             'notification': <String, dynamic>{
//               'title': title,
//               "body": body,
//               'android_channel_id': "dbfood"
//             },
//             "to": token
//           }));
//     } catch (err) {}
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: SafeArea(
//         child: WillPopScope(
//           onWillPop: () {
//             if (_showemoji) {
//               setState(() {
//                 _showemoji = !_showemoji;
//               });
//               return Future.value(false);
//             } else {
//               return Future.value(true);
//             }
//           },
//           child: Scaffold(
//               appBar: AppBar(
//                 automaticallyImplyLeading: false,
//                 flexibleSpace: _appBar(),
//               ),
//               body: Column(
//                 children: [
//                   Expanded(child: _buildMessageList()),
//                   _buildMessageInput(),
//                   if (_showemoji)
//                     SizedBox(
//                       height: MediaQuery.of(context).size.height * .35,
//                       child: EmojiPicker(
//                         textEditingController: _messageController,
//                         config: Config(
//                             columns: 7,
//                             emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1)),
//                       ),
//                     )
//                 ],
//               )),
//         ),
//       ),
//     );
//   }

//   Widget _appBar() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         IconButton(
//             onPressed: () {
//               Get.back();
//             },
//             icon: Icon(
//               Icons.arrow_back,
//               color: Colors.black54,
//             )),
//         SizedBox(
//           width: 10,
//         ),
//         ClipRRect(
//           borderRadius:
//               BorderRadius.circular(MediaQuery.of(context).size.height * .3),
//           child: CachedNetworkImage(
//             width: MediaQuery.of(context).size.height * .05,
//             height: MediaQuery.of(context).size.height * .05,
//             imageUrl: imageProfile,
//             errorWidget: (context, url, error) => const CircleAvatar(
//               child: Icon(CupertinoIcons.person),
//             ),
//           ),
//         ),
//         SizedBox(
//           width: 10,
//         ),
//         Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               name,
//               style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.black54,
//                   fontWeight: FontWeight.w500),
//             )
//           ],
//         )
//       ],
//     );
//   }

//   Widget _buildMessageList() {
//     return StreamBuilder(
//         stream: _chatController.getMessages(currentUserID),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Text('Error${snapshot.error}');
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Text('Loading');
//           }
//           return ListView(
//             children: snapshot.data!.docs
//                 .map((document) => _buildMessageItem(document))
//                 .toList(),
//           );
//         });
//   }

//   Widget _buildMessageItem(DocumentSnapshot document) {
//     Map<String, dynamic> data = document.data() as Map<String, dynamic>;
//     var alignment = (data['senderId'] == currentUserID)
//         ? Alignment.centerRight
//         : Alignment.centerLeft;
//     return Container(
//         alignment: alignment,
//         child: Padding(
//           padding: EdgeInsets.all(8),
//           child: Column(
//               crossAxisAlignment: (data['senderId'] == currentUserID)
//                   ? CrossAxisAlignment.end
//                   : CrossAxisAlignment.start,
//               mainAxisAlignment: (data['senderId'] == currentUserID)
//                   ? MainAxisAlignment.end
//                   : MainAxisAlignment.start,
//               children: [ChatBubble(message: data['message'])]),
//         ));
//   }

//   Widget _buildMessageInput() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 25.0),
//       child: Card(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         child: Row(
//           children: [
//             IconButton(
//                 onPressed: () {
//                   setState(() {
//                     _showemoji = !_showemoji;
//                   });
//                 },
//                 icon: Icon(
//                   Icons.emoji_emotions,
//                 )),
//             Expanded(
//                 child: TextField(
//               onTap: () {
//                 if (_showemoji)
//                   setState(() {
//                     _showemoji = !_showemoji;
//                   });
//               },
//               keyboardType: TextInputType.multiline,
//               decoration: InputDecoration(hintText: 'Type something'),
//               controller: _messageController,
//               obscureText: false,
//             )),
//             IconButton(onPressed: () {}, icon: Icon(Icons.image)),
//             IconButton(onPressed: () {}, icon: Icon(Icons.camera_alt_rounded)),
//             MaterialButton(
//               padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
//               shape: CircleBorder(),
//               onPressed: sendmessage,
//               child: Icon(
//                 Icons.send,
//                 color: Colors.white,
//                 size: 25,
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:gallery_saver/gallery_saver.dart';
import '../../controller/message_controller.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../widgets/chat_bubble.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;
  final String currentUserId;
  final String uid;
  const ChatPage(
      {super.key,
      required this.chat,
      required this.currentUserId,
      required this.uid});

  @override
  // ignore: library_private_types_in_public_api
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatController _chatController = ChatController();
  bool _showEmojiPicker = false, _isUploading = false;
  String imageProfile = '';
  String name = '';
  String token = '';
  retrieveUserInfo() async {
    print('user widget:$widget.uid');
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          imageProfile = snapshot.data()!["imageProfile"];
          name = snapshot.data()!["name"];
          token = snapshot.data()!['userDeviceToken'];
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    retrieveUserInfo();
    _chatController.updateSeenStatusOnChatEnter(widget.chat.id);
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(widget.currentUserId);
    }
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
            child: WillPopScope(
                onWillPop: () {
                  if (_showEmojiPicker) {
                    setState(() {
                      _showEmojiPicker = !_showEmojiPicker;
                    });
                    return Future.value(false);
                  } else {
                    return Future.value(true);
                  }
                },
                child: Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    flexibleSpace: _appBar(),
                    leading: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            height: 55,
                            width: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  body: Column(
                    children: [
                      Expanded(child: _buildMessageList()),
                      if (_isUploading)
                        const Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 20),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))),
                      _buildMessageInput(),
                      if (_showEmojiPicker)
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .35,
                          child: EmojiPicker(
                            textEditingController: _messageController,
                            config: Config(
                                columns: 7,
                                emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1)),
                          ),
                        )
                    ],
                  ),
                ))));
  }

  Widget _appBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black54,
            )),
        SizedBox(
          width: 10,
        ),
        ClipRRect(
          borderRadius:
              BorderRadius.circular(MediaQuery.of(context).size.height * .3),
          child: CachedNetworkImage(
            width: MediaQuery.of(context).size.height * .05,
            height: MediaQuery.of(context).size.height * .05,
            imageUrl: imageProfile,
            errorWidget: (context, url, error) => const CircleAvatar(
              child: Icon(CupertinoIcons.person),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500),
            )
          ],
        )
      ],
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<Message>>(
      stream: _chatController.getMessages(widget.chat.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No Messages Yet'));
        }

        final messages = snapshot.data!;

        // Debug: Print messages to see if data is coming from the stream
        print('Received Messages: ${messages.length}');
        for (var message in messages) {
          print('Message Content: ${message.senderId}');
        }

        return ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var alignment = (messages[index].senderId == widget.currentUserId)
                  ? Alignment.centerRight
                  : Alignment.centerLeft;
              return InkWell(
                onTap: () {
                  _showButtomSheet(messages[index].type,
                      messages[index].content, messages[index].id);
                },
                child: Container(
                    alignment: alignment,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                          crossAxisAlignment: (messages[index].senderId ==
                                  FirebaseAuth.instance.currentUser!.uid)
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          mainAxisAlignment: (messages[index].senderId ==
                                  FirebaseAuth.instance.currentUser!.uid)
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            index == 0
                                ? Center(
                                    child: Text(DateFormat('MMMM dd').format(
                                        messages[index].timestamp.toDate())),
                                  )
                                : DateFormat('MMMM dd').format(
                                            messages[index - 1]
                                                .timestamp
                                                .toDate()) ==
                                        DateFormat('MMMM dd').format(
                                            messages[index].timestamp.toDate())
                                    ? Text('')
                                    : Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(DateFormat('MMMM dd')
                                              .format(messages[index]
                                                  .timestamp
                                                  .toDate())),
                                        ),
                                      ),
                            messages[index].type == 'text'
                                ? Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(13),
                                        color: (messages[index].senderId ==
                                                FirebaseAuth
                                                    .instance.currentUser!.uid)
                                            ? Colors.grey
                                            : Colors.pinkAccent),
                                    child: Text(
                                      messages[index].content,
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: CachedNetworkImage(
                                      width: 250,
                                      imageUrl: messages[index].content,
                                      placeholder: (context, url) =>
                                          const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.image, size: 70),
                                    ),
                                  ),
                            Text(DateFormat('hh:mm a')
                                .format(messages[index].timestamp.toDate())),
                            messages[index].seen
                                ? Icon(
                                    Icons.done_all_rounded,
                                    color: Colors.blue,
                                    size: 20,
                                  )
                                : Icon(
                                    Icons.done,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                          ]),
                    )),
              );
            }
            // ListTile(
            //   title: Text(messages[index].content),
            // ),

            );
      },
    );
  }

  void _showButtomSheet(String type, String content, String id) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * .015,
                    horizontal: MediaQuery.of(context).size.height * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),
              type == "text"
                  ? OptionsItem(
                      icon: Icon(
                        Icons.copy_all_outlined,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: "Copy Text",
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: content))
                            .then((value) {
                          Navigator.pop(context);
                          Get.snackbar("Text", "Text copied");
                        });
                      })
                  : OptionsItem(
                      icon: Icon(
                        Icons.download_rounded,
                        color: Colors.blue,
                      ),
                      name: "Save Image",
                      onTap: () async {
                        try {
                          var status = await Permission.storage.status;
                          if (status == PermissionStatus.granted) {
                            File imageFile =
                                await _chatController.downloadImage(content);
                            print(imageFile);
                            bool? success =
                                await GallerySaver.saveImage(imageFile.path);
                            Navigator.pop(context);

                            if (success == true) {
                              Get.snackbar(
                                "Image",
                                "Image saved to gallery successfully",
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            } else {
                              Get.snackbar(
                                "Image",
                                "Failed to save image to gallery",
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          } else {
                            await Permission.storage.request();
                          }
                        } catch (e) {
                          if (kDebugMode) {
                            print('Error saving image: $e');
                          }
                          Get.snackbar(
                            "Error",
                            "Failed to save image. Please check permissions.",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                    ),
              Divider(),
              OptionsItem(
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                    size: 26,
                  ),
                  name: "Delete Message",
                  onTap: () async {
                    await _chatController
                        .deleteMessage(
                            widget.chat.id, id, type == 'text' ? "" : content)
                        .then((value) {
                      Navigator.pop(context);
                    });
                  })
            ],
          );
        });
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Enter message',
                suffixIcon: IconButton(
                  icon: Icon(Icons.emoji_emotions),
                  onPressed: () {
                    setState(() {
                      _showEmojiPicker =
                          !_showEmojiPicker; // Toggle emoji picker visibility
                    });
                  },
                ),
              ),
            ),
          ),
          IconButton(
              onPressed: () async {
                await _chatController.pickImageFileFromGallery();
                // setState(() {
                //   _isUploading = true;
                // });
                await _chatController.sendMessageWithImage(
                  widget.chat.id,
                  FirebaseAuth.instance.currentUser!.uid,
                );
                // setState(() {
                //   _isUploading = false;
                // });
              },
              icon: Icon(Icons.image, color: Colors.blueAccent)),
          ElevatedButton(
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                _chatController.sendMessage(
                    widget.chat.id,
                    FirebaseAuth.instance.currentUser!.uid,
                    _messageController.text,
                    token);
                _messageController.clear();
                setState(() {
                  _showEmojiPicker = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
            child: Text(
              'Send',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return _showEmojiPicker
        ? EmojiPicker(
            textEditingController: _messageController,
            config: Config(
                columns: 7, emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1)),
          )
        : SizedBox
            .shrink(); // Returns an empty widget if emoji picker is not shown
  }
}

class OptionsItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const OptionsItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * .05,
            top: MediaQuery.of(context).size.width * .015,
            bottom: MediaQuery.of(context).size.height * .025),
        child: Row(
          children: [icon, Flexible(child: Text("  $name"))],
        ),
      ),
    );
  }
}
