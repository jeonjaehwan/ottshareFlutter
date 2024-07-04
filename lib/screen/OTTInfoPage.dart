import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../models/localhost.dart';
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

  @override
  void initState() {
    super.initState();
  }


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
      Uri.parse('http://${Localhost.ip}:8080/api/waitingUsers'),
      headers: {"Content-Type": "application/json"},
      body: requestBodyJson,
    );

    if (response.statusCode == 200) {
      context.pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('자동매칭이 시작되었습니다.\n잠시만 기다려주세요!'),
            actions: [
              TextButton(
                onPressed: () {
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('자동 매칭 실패')));
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OTT 계정 정보"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black54),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _ottAccountIdController,
              decoration: InputDecoration(
                  hintText: '아이디',
                  hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                  contentPadding: EdgeInsets.all(7)
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _ottAccountPasswordController,
              decoration: InputDecoration(
                  hintText: '비밀번호',
                  hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                  contentPadding: EdgeInsets.all(7)
              ),
              obscureText: true,
            ),
            SizedBox(height: 35),
            ElevatedButton(
              onPressed: _submitInfo,
              style: ElevatedButton.styleFrom(
                fixedSize: Size(MediaQuery.of(context).size.width,50),
                backgroundColor: Color(0xffffdf24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // 버튼 모서리를 둥글게 만듦
                ),
              ),
              child: Text('완료', style: TextStyle(fontSize: 18, color: Color(0xff1C1C1C))),
            ),
          ],
        ),
      ),
    );
  }
}
