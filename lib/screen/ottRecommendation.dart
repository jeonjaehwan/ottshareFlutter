import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import '../models/userInfo.dart';
import 'autoMatching.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          title: Text('OTT 추천'),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(1.0),
              child: Divider(height: 1.0, color: Colors.black)),
        ),
        body: Column(
          children: [
            Container(height: 150),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
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
                    child: StartPage())
              ],
            ),
            Container(height: 150)
          ],
        ));
  }
}

class StartPage extends StatefulWidget {
  final UserInfo? userInfo;

  const StartPage({Key? key, this.userInfo}) : super(key: key);

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  int pageCount = 1;
  String buttonText = '시작';
  bool isFirstQuestion = true;
  bool isQuestionSelected = false;
  late int _selectedIndex;
  var beforeResponseBody;

  late UserInfo? userInfo;

  @override
  void initState() {
    super.initState();
    userInfo = widget.userInfo; // null일 수 있음
  }


  Widget body = Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '양자택일 중 선택하여\n나에게 맞는\nOTT를 찾아보세요!',
          style: TextStyle(fontSize: 22),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        body,
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (pageCount == 1) {
                        buttonText = '다음';
                        var responseBody = await sendGetQuestionRequest(pageCount);
                        beforeResponseBody = responseBody;
                        setState(() => body = FirstQuestionPage(
                            key: UniqueKey(),
                            responseBody: responseBody,
                            isFirstQuestionCallback: (bool value) {
                              setState(() {
                                isFirstQuestion = value;
                                print('isFirstQuestion =  ${isFirstQuestion}');
                                isQuestionSelected = true;
                              });
                            }));
                        pageCount++;
                        isQuestionSelected = false;
                      } else if (pageCount == 17) {
                        print("page 17");
                        // autoMatching 페이지로 넘어가는 로직
                        setState(() {
                          _selectedIndex = 3;
                        });
                        Navigator.pushReplacementNamed(
                            context, '/autoMatching', arguments: {'selectedIndex': 0});
                      }
                      else {
                        if (isQuestionSelected) {
                          // 선택된 상태인지 확인
                          if (pageCount == 16) {
                            buttonText = '자동매칭 시작';
                            var result = await sendGetResultRequest();
                            setState(() {
                              body = ResultPage(
                                key: UniqueKey(),
                                result: result,
                              );
                            });
                          } else {
                            if (pageCount == 15) {
                              buttonText = '결과 확인';
                            }
                            await sendCountOttScoreRequest(beforeResponseBody);
                            var responseBody = await sendGetQuestionRequest(pageCount);
                            beforeResponseBody = responseBody;
                            setState(() {
                              body = FirstQuestionPage(
                                key: UniqueKey(),
                                responseBody: responseBody,
                                isFirstQuestionCallback: (bool value) {
                                  setState(() {
                                    isFirstQuestion = value;
                                    print(
                                        'isFirstQuestion =  ${isFirstQuestion}');
                                    isQuestionSelected = true;
                                  });
                                },
                              );
                            });
                            isQuestionSelected = false;
                          }
                          pageCount++;
                        } else {
                          // 선택된 상태가 없는 경우 경고창 표시
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('경고'),
                                content: Text('두 선택지 중 하나를 선택하세요.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('확인'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffffdf24),
                      foregroundColor: Colors.black,
                      minimumSize: Size(260, 35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(buttonText, style: TextStyle(fontSize: 22)),
                  )
                ],
              ),
            ))
      ],
    );
  }

  Future<dynamic> sendGetQuestionRequest(int pageCount) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/ottRecQuestions/${pageCount}'),
      headers: {"Content-Encoding": "utf-8"},
    );

    if (response.statusCode == 200) {
      // 성공 처리
      var responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      print('Success response: ${responseBody}'); // 성공 응답 본문 출력

      return responseBody;
    } else {
      // 실패 처리
      print('Failure response: ${response.body}'); // 실패 응답 본문 출력
    }
  }

  Future<dynamic> sendCountOttScoreRequest(dynamic responseBody) async {

    Map<String, dynamic> requestMap = {
      'isFirstQuestion': isFirstQuestion,
      'firstQuestion': responseBody['firstQuestion'],
      'secondQuestion': responseBody['secondQuestion'],
      'firstQuestionOttType' : responseBody['firstQuestionOttType'],
      'secondQuestionOttType': responseBody['secondQuestionOttType']
    };

    var body = jsonEncode(requestMap);

    print('Request body: $body'); // 요청 본문 출력

    await http.post(
      Uri.parse('http://10.0.2.2:8080/api/ottRecQuestions/${pageCount}'),
      headers: {
        "Content-Encoding": "utf-8",
        "Content-Type": "application/json"
      },
      body: body,
    );
  }

  Future<dynamic> sendGetResultRequest() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/ottRecQuestions/16'),
      headers: {"Content-Encoding": "utf-8"},
    );

    if (response.statusCode == 200) {
      // 성공 처리
      var responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      print('Success response: ${responseBody}'); // 성공 응답 본문 출력

      return responseBody;
    } else {
      // 실패 처리
      print('Failure response: ${response.body}'); // 실패 응답 본문 출력
    }

  }
}

class FirstQuestionPage extends StatefulWidget {
  final dynamic responseBody;
  Function(bool)? isFirstQuestionCallback;

  FirstQuestionPage({Key? key, this.responseBody, this.isFirstQuestionCallback})
      : super(key: key);

  @override
  _FirstQuestionPageState createState() => _FirstQuestionPageState();
}

class _FirstQuestionPageState extends State<FirstQuestionPage> {
  bool? isFirstQuestion;

  @override
  Widget build(BuildContext context) {
    ElevatedButton questionbox(String label, bool selected, bool firstQuestion) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            isFirstQuestion = firstQuestion;
          });
          widget.isFirstQuestionCallback?.call(firstQuestion);
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: selected ? Color(0xffffdf24) : Colors.white,
          foregroundColor: selected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Color(0xffffdf24), width: 2)),
        ),
        child: Container(
          height: 70,
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 17)),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Center(
              child: Text(
                '질문 ${widget.responseBody['id']}/15',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: 12),
          Container(
            width: 260,
            height: 65,
            child: Center(
              child: questionbox(
                  widget.responseBody['firstQuestion'].toString(),
                  isFirstQuestion == true,
                  true),
            ),
          ),
          SizedBox(height: 15),
          Container(
            width: 260,
            height: 65,
            child: Center(
              child: questionbox(
                  widget.responseBody['secondQuestion'].toString(),
                  isFirstQuestion == false,
                  false),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultPage extends StatefulWidget {
  final dynamic result;

  ResultPage({Key? key, this.result})
      : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10),
            width: 260,
            height: 200, // 이미지와 텍스트를 모두 표시할 수 있는 충분한 높이를 지정
            child: Column(
              children: [
                Text(
                  '당신에게 \n딱 맞는 OTT는?',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Container(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                    'assets/${widget.result.toString().toLowerCase()}_logo.png', // 이미지 경로 설정
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  widget.result ?? '결과 없음',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
