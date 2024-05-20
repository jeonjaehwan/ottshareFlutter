import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ott_share/chatting/chatMember.dart';
import 'package:ott_share/chatting/drawer.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:anydrawer/anydrawer.dart';
import 'package:http/http.dart' as http;
import '../models/loginStorage.dart';
import 'chatRoom.dart';

class ChatRoomPage extends StatefulWidget {
  final dynamic currentUserInfoJson;
  final ChatRoom chatRoom;

  ChatRoomPage({Key? key, required this.currentUserInfoJson, required this.chatRoom})
      : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _controller = TextEditingController();
  final scrollController = ScrollController();
  final AnyDrawerController controller = AnyDrawerController();
  late WebSocketChannel channel;
  late ChatRoom chatRoom;
  late ChatMember writer;
  List<String> messages = ['하이', '헬로', '하하']; // List to store messages
  // late List<Message> messages;

  @override
  void initState() {
    super.initState();
    String websocketURL = 'ws://localhost:8080/websocket';
    channel = WebSocketChannel.connect(Uri.parse(websocketURL));
    channel.stream.listen((message) {
      setState(() {
        messages.add(jsonDecode(
            message)['message']); // Assume message is properly formatted
        if (messages.length > 10) {
          messages.removeAt(
              0); // Remove the oldest message to maintain only 10 messages
        }
      });
    });
    loadInitialMessages();
    chatRoom = widget.chatRoom;
    writer = chatRoom.writer;
    // messages = chatRoom.messages;
  }

  Future<void> loadInitialMessages() async {
    var initialMessages = await fetchMessages();
    setState(() {
      messages.addAll(initialMessages.map((e) => e['message']));
      // Ensure only the latest 10 messages are kept if more than 10 messages are loaded
      if (messages.length > 10) {
        messages = messages.take(10).toList();
      }
    });
  }

  Future<List<dynamic>> fetchMessages() async {
    final response = await http.get(Uri.parse(
        'http://localhost:8080/chat/${chatRoom.chatRoomId}/messages'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['content']; // Access the 'content' part of the page
    } else {
      throw Exception('Failed to load messages');
    }
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      // int? currentUserId = await LoginStorage.getUserId();
      // if (currentUserId == null) {
      //   print("No user logged in.");
      //   return;
      // }

      print('ottShareRoomJson: ${widget.currentUserInfoJson}');

      var messageRequest = {
        'ottRoomMemberResponse': widget.currentUserInfoJson,
        'message': _controller.text
      };

      var stompFrame = 'SEND\n'
              'content-type:application/json;charset=UTF-8\n\n' +
          jsonEncode(messageRequest) +
          '\u0000';

      channel.sink.add(stompFrame);
      setState(() {
        messages.add(_controller.text); // Add message at the end
        if (messages.length > 10) {
          messages.removeAt(0); // Maintain only the latest 10 messages
        }
      });
      _controller.clear();
    }
  }

  Widget chatBox = Row(

  );

  void _showDrawer() {
    showDrawer(
      context,
      builder: (context) => const CheckDrawer(),
      config: const DrawerConfig(
        side: DrawerSide.right,
        closeOnClickOutside: true,
        closeOnEscapeKey: true,
        closeOnResume: true, // (Android only)
        closeOnBackButton: true, // (Requires a route navigator)
        backdropOpacity: 0.5,
        borderRadius: 24,
      ),
      onClose: () {
        debugPrint('Drawer closed');
      },
      onOpen: () {
        debugPrint('Drawer opened');
      },
      controller: controller,
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffffdf24),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('채팅방'),
          backgroundColor: Color(0xffffdf24),
          centerTitle: true,
          elevation: 0.0,
          actions: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _showDrawer;
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
              child: Align(
                alignment: Alignment.topCenter,
                child: ListView.separated(
                  reverse: true,
                  shrinkWrap: true,
                  controller: scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              child: Text(
                                writer.nickname,
                                textAlign: TextAlign.right,
                                style: TextStyle(fontSize: 17.0),
                              ),
                            ),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.65,
                                maxHeight: 300,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(
                                  messages[index],
                                  textAlign: TextAlign.left, style: TextStyle(fontSize: 20.0),
                                  softWrap: true,
                                  maxLines: null,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 45,
                          width: 10,
                        ),
                        Container(
                          height: 65,
                          child: const CircleAvatar(
                            radius: 23,
                            backgroundImage:
                                AssetImage('assets/wavve_logo.png'),
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 20,
                      // color: Colors.yellow,
                    );
                  },
                ),
              ),
            )),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                    icon: Icon(Icons.send), onPressed: () => _sendMessage()),
              ),
              onSubmitted: (_) => _sendMessage(),
              maxLines: null,
            ),

          ],

        ));
  }

  @override
  void dispose() {
    controller.dispose();
    channel.sink.close();
    super.dispose();
  }
}
