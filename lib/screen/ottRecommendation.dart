import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class OttRecommendationPage extends StatefulWidget {

  OttRecommendationPage({Key? key}) : super(key: key);

  @override
  _OttRecommendationPageState createState() => _OttRecommendationPageState();

}

class _OttRecommendationPageState extends State<OttRecommendationPage> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> ottRecommendStart() async {
    // API 요청
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/ottRecQuestions/1'),
      headers: {"Content-Encoding": "utf-8"},
    );

    if (response.statusCode == 200) {
      // 성공 처리
      var responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      print('Success response: ${responseBody}'); // 성공 응답 본문 출력
      // SecondPage() 화면으로 옮겨가기
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FirstQuestionPage(responseBody: responseBody),
        ),
      );
    } else {
      // 실패 처리
      print('Failure response: ${response.body}'); // 실패 응답 본문 출력
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('OTT 추천'),
      ),
      body: Center(
        child: Container(
          width: 330.0,
          height: 300,
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 205,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '양자택일 중 선택하여\n나에게 맞는\nOTT를 찾아보세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 23.0),
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: ottRecommendStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffffdf24),
                    foregroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('시작', style: TextStyle(fontSize: 22)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// 네비게이션바 사라지는 문제 해결하기
class FirstQuestionPage extends StatelessWidget {
  final dynamic responseBody;

  FirstQuestionPage({required this.responseBody});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('두 번째 페이지'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '두 번째 페이지입니다.',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'API 응답 데이터:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              '$responseBody',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

