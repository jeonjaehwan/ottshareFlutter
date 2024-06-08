import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:ott_share/chatting/message.dart';
import 'package:ott_share/chatting/messageRequest.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../models/localhost.dart';
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
  late ChatMember? leader = widget.chatRoom.findLeader();
  late List<ChatMember> notLeaderList = [];
  List<Message> messages = [];

  late List<bool> isCheckboxDisabled;

  @override
  void initState() {
    super.initState();
    print("init loginUser = ${writer.userInfo.userId}");
    connect();
    loadInitialMessages();
    isCheckboxDisabled = widget.chatRoom.readers.map((reader) => reader.isChecked).toList();
    if (writer.chatMemberId != leader?.chatMemberId) {
      notLeaderList.add(writer);
    }
    notLeaderList.addAll(widget.chatRoom.readers.where((reader) => reader.chatMemberId != leader?.chatMemberId).toList());
  }


  void connect() {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://${Localhost.ip}:8080/websocket',
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
      callback: (frame) {},
    );
  }

  Future<void> loadInitialMessages() async {
    var initialMessages = await fetchMessages();

    for (var imessage in initialMessages) {
      Message message = Message.fromJson(imessage);

      setState(() {
        messages.add(message);
        scrollToBottom();
      });
    }
  }

  Future<List<dynamic>> fetchMessages() async {
    final response = await http.get(Uri.parse(
        'http://${Localhost.ip}:8080/chat/${chatRoom.chatRoomId}/messages'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      return data['content'];
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<void> _sendMessage() async {
    if (textController.text.isNotEmpty) {
      MessageRequest messageRequest = MessageRequest(
          chatRoom: chatRoom, writer: writer, content: textController.text);
      Map<String, dynamic> messageRequestJson = messageRequest.toJson();

      print("messageRequestJson = ${messageRequestJson}");
      stompClient.send(
        destination: '/app'
            '/chat/${chatRoom.chatRoomId}',
        body: jsonEncode(messageRequestJson),
      );

      setState(() {
        Message message = Message(
            content: textController.text, writer: writer, createdAt: "임시");
        messages.add(message);
        textController.clear();
      });
      scrollToBottom();
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("scrollController.hasClients = ${scrollController.hasClients}");
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  Future<void> sendCheckRequest(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('http://${Localhost.ip}:8080/api/ottShareRoom/${chatRoom.chatRoomId}/user/${userId}/check'),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        print("sharingId = ${userId} 회원 체크 성공");
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('체크 요청 실패')));
    }
  }

  Widget createChatBox(
      BuildContext context, Message message, ChatMember writer) {
    final ChatMember messageWriter = message.writer;

    if (messageWriter.chatMemberId == writer.chatMemberId) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
              maxHeight: 200,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Text(
                message.content,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 16),
                softWrap: true,
                maxLines: null,
                overflow: TextOverflow.visible,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ],
      );
    } else {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children at the top
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Text(
                    messageWriter.userInfo.nickname,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                    maxHeight: 300,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Text(
                      message.content,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16.0),
                      softWrap: true,
                      maxLines: null,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget createCheckBox(BuildContext context, ChatMember writer, int index) {

    if (writer.isLeader == true) {
        return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 10,
            ),
            if (isCheckboxDisabled[index])
              Container(
                width: 40,
                child: CheckboxListTile(
                  // activeColor: Color(0xffffdf24),
                  value: true,
                  // onChanged: (bool? value) {
                  //   setState(() {
                  //     notLeaderList[index].isChecked = true;
                  //   });
                  // },
                  onChanged: null,
                ),
              )
            else
              Container(
                height: 52,
                width: 40,
                child: CheckboxListTile(
                  activeColor: Color(0xffffdf24),
                  value: notLeaderList[index].isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      notLeaderList[index].isChecked = value ?? false;
                    });
                  },
                ),
              ),
            // SizedBox(width: 5),
            Container(
              width: MediaQuery.of(context).size.width * 0.18,
              child: Text(
                '${notLeaderList[index].userInfo.nickname}',
                style: TextStyle(fontSize: 16),
              ),
            ),
            // SizedBox(width: 3),
            Container(
              height: 35,
              child: ElevatedButton(
                onPressed: () {
                  print("체크 상태 : ${notLeaderList[index].isChecked}");
                  if (isCheckboxDisabled[index] == true) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Text("이미 체크된 회원입니다."),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                context.pop(); // 다이얼로그 닫기
                              },
                              child: Align(
                                alignment:
                                Alignment.center, // 텍스트를 가운데 정렬
                                child: Text('확인'),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor: Color(0xffffdf24),
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    if (notLeaderList[index].isChecked == true) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text("OTT 계정 정보가 해당 회원에게 나타납니다.\n요금 납부 여부를 꼭 확인해주세요!"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  isCheckboxDisabled[index] = true;
                                  // 체크해달라고 요청
                                  sendCheckRequest(notLeaderList[index].chatMemberId);
                                  context.pop();
                                },
                                child: Align(
                                  alignment:
                                  Alignment.center, // 텍스트를 가운데 정렬
                                  child: Text('저장'),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: Color(0xffffdf24),
                                  foregroundColor: Colors.black,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.pop(); // 다이얼로그 닫기
                                },
                                child: Align(
                                  alignment:
                                  Alignment.center, // 텍스트를 가운데 정렬
                                  child: Text('취소'),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: Color(0xffE6E6E6),
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ],
                          );
                        },
                      );

                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text("체크를 하고 저장해주세요."),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  context.pop(); // 다이얼로그 닫기
                                },
                                child: Align(
                                  alignment:
                                  Alignment.center, // 텍스트를 가운데 정렬
                                  child: Text('확인'),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: Color(0xffffdf24),
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                  
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(50, 6),
                  foregroundColor: Color(0xff1C1C1C),
                  backgroundColor: Colors.white,
                  textStyle: TextStyle(
                      fontSize: 17),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.black12, width: 2)
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),

                child: Text('저장'),
              ),
            ),
            SizedBox(width: 7),
            Container(
              height: 35,
                child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text('이유 없이 강퇴할 경우, 불이익이 있을 수 있습니다.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  context.pop();
                                  kickMember(context, notLeaderList[index].chatMemberId);
                                },
                                child: Align(
                                  alignment:
                                  Alignment.center, // 텍스트를 가운데 정렬
                                  child: Text('강퇴'),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: Color(0xffffdf24),
                                  foregroundColor: Colors.black,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.pop();
                                },
                                child: Align(
                                  alignment:
                                  Alignment.center, // 텍스트를 가운데 정렬
                                  child: Text('취소'),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  backgroundColor: Color(0xffE6E6E6),
                                  foregroundColor: Colors.black,
                                ),
                              ),
                            ],
                          );
                        },
                      );

                    },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(50, 6),
                    foregroundColor: Color(0xff1C1C1C),
                    backgroundColor: Colors.white,
                    textStyle: TextStyle(
                        fontSize: 17),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.black12, width: 2)
                    ),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text('강퇴'),
                )
            )
          ]
        );
      } else {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 10,
            ),
            Container(
              height: 52,
              width: 40,
              child: CheckboxListTile(
                activeColor: Color(0xffffdf24),
                value: notLeaderList[index].isChecked,
                onChanged: null,
              ),
            ),
            SizedBox(width: 5),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Text(
                '${notLeaderList[index].userInfo.nickname}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffffdf24),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('${chatRoom.ottType} 채팅방'),
          backgroundColor: Colors.transparent,
          // backgroundColor: Color(0xffffdf24),
          shadowColor: Color(0xffffdf24),
          surfaceTintColor: Color(0xffffdf24),
          scrolledUnderElevation: 0,
          centerTitle: true,
        ),
        body: Column(
          children: <Widget>[
            if (writer.chatMemberId == leader!.chatMemberId || writer.isChecked)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child:
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    width: double.infinity,
                    height: 65,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Row(
                      children: [
                        Icon(Icons.announcement_outlined, color: Colors.black),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            "${chatRoom.ottType} 아이디 : ${chatRoom.ottId}"
                                "\n${chatRoom.ottType} 비밀번호 : ${chatRoom.ottPassword}",
                            style: TextStyle(color: Colors.black, fontSize: 17),
                          ),
                        ),
                      ],
                    ),
                  ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ListView.separated(
                    padding: EdgeInsets.all(2),
                    shrinkWrap: true,
                    controller: scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return createChatBox(context, messages[index], writer);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 5,
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
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(),
                ),
              ),
              onTap: () {
                // textField클릭했을 때, 스크롤 맨 아래로 가게
                Future.delayed(Duration(milliseconds: 400), () {
                  scrollController.jumpTo(scrollController.position.maxScrollExtent);
                });
              },
              onSubmitted: (_) => _sendMessage(),
              maxLines: null,
            ),
          ],
        ),
        endDrawer: SafeArea(
          child: Drawer(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // 모든 모서리를 각지게 설정합니다.
            ),
            width: MediaQuery.of(context).size.width * 0.75,
            backgroundColor: Colors.white,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 15),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          decoration: BoxDecoration(
                              color: Colors.black87,
                            borderRadius: BorderRadius.circular(10)
                          ),
                          height: 32,
                          child: Text('방장', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w500, color: Colors.white)),
                        ),
                        SizedBox(width: 15),
                        Container(
                          alignment: Alignment.center,
                          height: 30,
                          child: Text('${leader!.userInfo.nickname}', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 30),
                  Container(
                      height: 45,
                      child: Text("요금 납부", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                  ),
                  Expanded(
                    child: ListView.separated(
                        itemCount: notLeaderList.length,
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              SizedBox(width: 10),
                              createCheckBox(context, writer, index),// 간격 추가
                              // Expanded(
                              //   child: Text(
                              //     '${notLeaderList[index].userInfo.nickname}',
                              //     style: TextStyle(fontSize: 16),
                              //   ),
                              // ),
                            ],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 10,
                          );
                        }),
                  ),
                  // 방 나가기 버튼
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Text('채팅방을 나가시겠어요?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    exitRoom(context);
                                  },
                                  child: Align(
                                    alignment:
                                    Alignment.center, // 텍스트를 가운데 정렬
                                    child: Text('나가기'),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: Color(0xffffdf24),
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.pop();
                                  },
                                  child: Align(
                                    alignment:
                                    Alignment.center, // 텍스트를 가운데 정렬
                                    child: Text('취소'),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: Color(0xffE6E6E6),
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(110,50),
                        foregroundColor: Color(0xff1C1C1C),
                        textStyle: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                        backgroundColor: Color(0xffffdf24),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('방 나가기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ) );
  }

  Future<void> kickMember(BuildContext context, int chatMemberId) async {
    print("방이랑 회원 정보 = ${chatMemberId} + ${chatRoom.chatRoomId}");
    
    final String apiUrl = 'http://${Localhost.ip}:8080/api/ottShareRoom/${chatRoom.chatRoomId}/user/${chatMemberId}/kick';

    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    print("response.statusCode = ${response.statusCode}");
    print("response.body = ${response.body}");

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('해당 회원이 강제퇴장되었습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  // 다시 멤버 가져오기

                  context.pop();
                },
                child: Align(
                  alignment:
                  Alignment.center, // 텍스트를 가운데 정렬
                  child: Text('확인'),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Color(0xffffdf24),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          );
        },
      );
    } else {
      print("강퇴 오류");
    }
  }

  // Future<void> getChatRoom() async{
  //   var url = Uri.parse(
  //       'http://${Localhost.ip}:8080/api/ottShareRoom/${userInfo!.userId}');
  //   var response =
  //   await http.get(url, headers: {"Content-Type": "application/json"});
  //   Map<String, dynamic> json = jsonDecode(response.body);
  //
  //   ChatRoom chatRoom = ChatRoom.fromJson(json, userInfo!);
  //
  // }

  Future<void> exitRoom(BuildContext context) async {

    final String apiUrl = 'http://${Localhost.ip}:8080/api/ottShareRoom/${chatRoom.chatRoomId}/user/${writer.chatMemberId}/leave';

    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    print("response.statusCode = ${response.statusCode}");
    print("response.body = ${response.body}");


    if (response.statusCode == 200) {

      context.go("/autoMatching?selectedIndex=0");

    } else {
      print("방 나가기 오류");
    }
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    stompClient.deactivate();
    super.dispose();
  }
}
