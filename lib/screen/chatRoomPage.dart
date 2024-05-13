import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/loginStorage.dart';  // Ensure this path is correct

class ChatRoomPage extends StatefulWidget {
  final dynamic ottShareRoom;

  ChatRoomPage({Key? key, required this.ottShareRoom}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _controller = TextEditingController();
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    String websocketURL = 'ws://10.0.2.2:8080/websocket';
    channel = WebSocketChannel.connect(Uri.parse(websocketURL));
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      print("Text is not empty, trying to send a message.");
      int? currentUserId = await LoginStorage.getUserId();
      if (currentUserId == null) {
        print("No user logged in.");
        return;
      }

      var currentUserInfo = widget.ottShareRoom['ottRoomMemberResponses'].firstWhere(
              (response) => response['user']['id'] == currentUserId,
          orElse: () => null
      );

      if (currentUserInfo == null) {
        print("Current user information not found.");
        return;
      }

      var messageRequest = {
        'ottShareRoom': widget.ottShareRoom,
        'ottRoomMemberResponse': currentUserInfo,
        'message': _controller.text
      };

      // JSON으로 인코딩하기 전에 데이터를 출력
      print('Sending message with data: $messageRequest');

      var stompFrame = 'SEND\n'
          'destination:/app/chat/${widget.ottShareRoom['id']}\n'
          'content-type:application/json;charset=UTF-8\n\n' +
          jsonEncode(messageRequest) +
          '\u0000';

      channel.sink.add(stompFrame);
      _controller.clear();
    } else {
      print("Text is empty, no message to send.");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('채팅방'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                stream: channel.stream,
                builder: (context, snapshot) {
                  return ListView.builder(
                    reverse: true,
                    itemBuilder: (_, index) => ListTile(
                      title: Text(snapshot.data ?? ""),
                    ),
                    itemCount: snapshot.hasData ? 1 : 0,
                  );
                },
              ),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Send a message',
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ],
        ),
      ),
    );
  }
}
