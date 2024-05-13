import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatRoomPage extends StatefulWidget {
  final dynamic ottShareRoom; // 변수 이름을 명확하게 할당

  ChatRoomPage({Key? key, required this.ottShareRoom}) : super(key: key); // required 키워드 추가

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _controller = TextEditingController();
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    // 서버의 WebSocket 엔드포인트와 일치하는지 확인
    String websocketURL = 'ws://10.0.2.2:8080/websocket';
    print('Connecting to $websocketURL'); // 디버깅: 실제 URL 확인
    channel = WebSocketChannel.connect(
      Uri.parse(websocketURL),
    );
  }


  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      // STOMP 프레임 형식으로 메시지 구성
      var stompFrame = 'SEND\n'
          'destination:/app/chat/${widget.ottShareRoom['id']}\n'
          'content-type:application/json;charset=UTF-8\n\n' +
          jsonEncode({'content': _controller.text}) +
          '\u0000'; // NULL 문자로 프레임 종료

      channel.sink.add(stompFrame);
      _controller.clear();
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
