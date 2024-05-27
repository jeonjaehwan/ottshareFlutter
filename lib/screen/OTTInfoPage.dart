import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../models/userInfo.dart'; // UserInfo 모델 임포트

class OTTInfoPage extends StatefulWidget {
  final int? selectedOttIndex;
  final bool? isLeader;
  final UserInfo? userInfo; // UserInfo 추가

  OTTInfoPage({Key? key, this.selectedOttIndex, this.isLeader, this.userInfo}) : super(key: key);

  @override
  _OTTInfoPageState createState() => _OTTInfoPageState();
}

class _OTTInfoPageState extends State<OTTInfoPage> {
  final _ottAccountIdController = TextEditingController();
  final _ottAccountPasswordController = TextEditingController();

  void _submitInfo() async {
    // OTT 계정 정보를 가져옴
    String ottAccountId = _ottAccountIdController.text;
    String ottAccountPassword = _ottAccountPasswordController.text;


    // OTT 인덱스와 방장 여부
    int? selectedOttIndex = widget.selectedOttIndex;
    bool? isLeader = widget.isLeader;

    String ottTypeString;
    switch (selectedOttIndex) {
      case 0:
        ottTypeString = 'NETFLIX';
        break;
      case 1:
        ottTypeString = 'TVING';
        break;
      case 2:
        ottTypeString = 'WAVVE';
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTT selection')));
        return;
    }

    Map<String, dynamic> requestBody = {
      'ott': ottTypeString, // 선택된 OTT 서비스의 이름 전송
      'isLeader': isLeader,
      'userInfo': widget.userInfo?.toJson(), // userInfo가 null이 아닌 경우에만 toJson() 메서드 호출
      'ottId': ottAccountId,
      'ottPassword': ottAccountPassword,
    };

    // JSON으로 인코딩
    String requestBodyJson = jsonEncode(requestBody);

    // 서버로 POST 요청 보내기
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/waitingUser/save'),
      headers: {"Content-Type": "application/json"},
      body: requestBodyJson,
    );

    if (response.statusCode == 200) {
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('자동 매칭 실패')));
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OTT 계정 정보 입력"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _ottAccountIdController,
              decoration: InputDecoration(labelText: 'OTT 계정 아이디'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _ottAccountPasswordController,
              decoration: InputDecoration(labelText: 'OTT 계정 비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitInfo,
              child: Text('완료'),
            )
          ],
        ),
      ),
    );
  }
}
