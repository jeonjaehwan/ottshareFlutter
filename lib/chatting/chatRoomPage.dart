import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ott_share/chatting/chatMember.dart';
import 'package:ott_share/chatting/message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../models/loginStorage.dart';
import 'chatRoom.dart';  // Ensure this path is correct

class ChatRoomPage extends StatefulWidget {
  late final ChatRoom chatRoom;


  ChatRoomPage({Key? key, required this.chatRoom}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _controller = TextEditingController();
  final scrollController = ScrollController();
  late WebSocketChannel channel;
  List<String> messages = ['하이','헬로','하하'];  // List to store messages

  @override
  void initState() {
    super.initState();
    // String websocketURL = 'ws://localhost:8080/websocket';
    // channel = WebSocketChannel.connect(Uri.parse(websocketURL));
    // channel.stream.listen((message) {
    //   setState(() {
    //     messages.add(jsonDecode(message)['message']);  // Assume message is properly formatted
    //     if (messages.length > 10) {
    //       messages.removeAt(0);  // Remove the oldest message to maintain only 10 messages
    //     }
    //   });
    // });
    // loadInitialMessages();
    ChatMember writer = ChatMember(userId: 1, name: "writer", isLeader: true, isChecked: false);
    ChatMember reader1 = ChatMember(userId: 10, name: "reader1", isLeader: false, isChecked: false);
    ChatMember reader2 = ChatMember(userId: 5, name: "reader2", isLeader: false, isChecked: false);
    List<ChatMember> readers = [reader1, reader2];
    Message message1 = Message(content: "하이하이", sender: writer, createdAt: "2024-05-19");
    Message message2 = Message(content: "안녕하세요", sender: reader1, createdAt: "2024-05-19");
    Message message3 = Message(content: "반갑습니다", sender: reader1, createdAt: "2024-05-19");
    Message message4 = Message(content: "오랜만이에요", sender: reader2, createdAt: "2024-05-19");
    List<Message> messages = [message1, message2, message3, message4];

    widget.chatRoom = ChatRoom(chatRoomId: 1, writer: writer, readers: readers, messages: messages);
  }

  // Future<void> loadInitialMessages() async {
  //   var initialMessages = await fetchMessages();
  //   setState(() {
  //     messages.addAll(initialMessages.map((e) => e['message']));
  //     // Ensure only the latest 10 messages are kept if more than 10 messages are loaded
  //     if (messages.length > 10) {
  //       messages = messages.take(10).toList();
  //     }
  //   });
  // }

  // Future<List<dynamic>> fetchMessages() async {
  //   final response = await http.get(Uri.parse('http://localhost:8080/chat/${widget.ottShareRoom['id']}/messages'));
  //
  //   if (response.statusCode == 200) {
  //     var data = jsonDecode(response.body);
  //     return data['content'];  // Access the 'content' part of the page
  //   } else {
  //     throw Exception('Failed to load messages');
  //   }
  // }

  // void _sendMessage() async {
  //   if (_controller.text.isNotEmpty) {
  //     int? currentUserId = await LoginStorage.getUserId();
  //     if (currentUserId == null) {
  //       print("No user logged in.");
  //       return;
  //     }
  //
  //     var currentUserInfo = widget.ottShareRoom['ottRoomMemberResponses'].firstWhere(
  //             (response) => response['user']['id'] == currentUserId, orElse: () => null);
  //
  //     if (currentUserInfo == null) {
  //       print("Current user information not found.");
  //       return;
  //     }
  //
  //     var messageRequest = {
  //       'ottRoomMemberResponse': currentUserInfo,
  //       'message': _controller.text
  //     };
  //
  //     var stompFrame = 'SEND\n'
  //         'content-type:application/json;charset=UTF-8\n\n' +
  //         jsonEncode(messageRequest) +
  //         '\u0000';
  //
  //     channel.sink.add(stompFrame);
  //     setState(() {
  //       messages.add(_controller.text);  // Add message at the end
  //       if (messages.length > 10) {
  //         messages.removeAt(0);  // Maintain only the latest 10 messages
  //       }
  //     });
  //     _controller.clear();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('채팅방'),
        backgroundColor: Color(0xffffdf24),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ListView.separated(
                  reverse: true,
                  shrinkWrap: true,
                  controller: scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(messages[index]),
                      titleTextStyle: TextStyle(
                        fontSize: 20.0,
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 10,
                      color: Colors.yellow,
                    );
                },
                ),
              )
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Send a message',
              ),
              // onSubmitted: (_) => _sendMessage(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}

