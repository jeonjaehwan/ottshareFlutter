import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ott_share/chatting/messageRequest.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import 'chatMember.dart';
import 'chatRoom.dart';

class ChatRoomPage extends StatefulWidget {
  final ChatRoom chatRoom;

  ChatRoomPage({Key? key, required this.chatRoom}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late StompClient stompClient;
  final TextEditingController textController = TextEditingController();
  final scrollController = ScrollController();
  late ChatRoom chatRoom = widget.chatRoom;
  late ChatMember writer = chatRoom.writer;
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    connect();
    loadInitialMessages();
  }

  void connect() {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://localhost:8080/websocket',
        onConnect: onConnect,
        onStompError: (dynamic error) => print(error.toString()),
        onWebSocketError: (dynamic error) => print(error.toString()),
      ),
    );

    stompClient.activate();
  }

  void onConnect(StompFrame frame) {
    stompClient.subscribe(
      destination: '/topic/messages/${chatRoom.chatRoomId}',
      callback: (frame) {
        setState(() {
          messages.add(jsonDecode(frame.body!)['message']);
          if (messages.length > 10) {
            messages.removeAt(0);
          }
        });
      },
    );
  }

  Future<void> loadInitialMessages() async {
    var initialMessages = await fetchMessages();
    setState(() {
      messages.addAll(initialMessages.map((e) => e['message']));
      if (messages.length > 10) {
        messages = messages.take(10).toList();
      }
    });
  }

  Future<List<dynamic>> fetchMessages() async {
    final response = await http.get(Uri.parse('http://localhost:8080/chat/${chatRoom.chatRoomId}/messages'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['content'];
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<void> _sendMessage() async {
    if (textController.text.isNotEmpty) {
      MessageRequest messageRequest = MessageRequest(chatRoom: chatRoom, writer: writer, message: textController.text);
      Map<String, dynamic> messageRequestJson = messageRequest.toJson();


      print("Original messageRequest.dart: $messageRequestJson");

      stompClient.send(
        destination: '/app/chat/${chatRoom.chatRoomId}',
        body: jsonEncode(messageRequestJson),
      );


      setState(() {
        messages.add(textController.text);
        if (messages.length > 10) {
          messages.removeAt(0);
        }
      });

      textController.clear();
    }
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
                                writer.userInfo.nickname,
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
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 20.0),
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
                            backgroundImage: AssetImage('assets/wavve_logo.png'),
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 20,
                    );
                  },
                ),
              ),
            ),
          ),
          TextField(
            controller: textController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _sendMessage(),
              ),
            ),
            onSubmitted: (_) => _sendMessage(),
            maxLines: null,
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(),
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    stompClient.deactivate();
    super.dispose();
  }
}
