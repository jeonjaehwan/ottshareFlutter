import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/localhost.dart';

class FindIdPage extends StatefulWidget {
  @override
  _FindIdPageState createState() => _FindIdPageState();
}

class _FindIdPageState extends State<FindIdPage> {
  String? ipAddress;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _certificationNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchIpAddress();
  }

  Future<void> fetchIpAddress() async {
    String? ip = await Localhost.getIp();
    setState(() {
      ipAddress = ip;
    });
  }

  /**
   * 인증번호 전송
   */
  Future<void> _sendVerificationCode(BuildContext context) async {
    final String apiUrl = 'http://${ipAddress}:8080/api/users/send';

    String name = _nameController.text;
    String phoneNumber = _phoneNumberController.text;

    Map<String, String> data = {
      'name': name,
      'phoneNumber': phoneNumber,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('인증번호 전송 성공'),
              content: Text('인증번호가 성공적으로 전송되었습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: Text('확인'),
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
              title: Text('인증번호 실패'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('오류 발생'),
            content: Text('인증번호 전송 중 오류가 발생했습니다. 다시 시도해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }

  /**
   * 인증번호 확인
   */
  Future<void> _checkConfirmationCode(BuildContext context) async {
    final String apiUrl = 'http://${ipAddress}:8080/api/users/find-username';

    String name = _nameController.text;
    String phoneNumber = _phoneNumberController.text;
    String certificationNumber = _certificationNumberController.text;

    Map<String, String> data = {
      'name': name,
      'phoneNumber': phoneNumber,
      'certificationNumber': certificationNumber
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(responseBody);
        final message = responseData['message'];
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('인증번호가 맞습니다'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                    context.pop();
                  },
                  child: Text('확인'),
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
              title: Text('인증번호가 틀렸습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error: $error');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('오류 발생'),
            content: Text('인증번호 확인 중 오류가 발생했습니다. 다시 시도해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('아이디 찾기'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '이름',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: '휴대폰 번호',
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _certificationNumberController,
                    decoration: InputDecoration(
                      labelText: '인증번호',
                    ),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    _sendVerificationCode(context); // 인증번호 전송 로직 호출
                  },
                  child: Text('전송'),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _checkConfirmationCode(context);
              },
              child: Text('아이디 찾기'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FindIdPage(),
  ));
}
