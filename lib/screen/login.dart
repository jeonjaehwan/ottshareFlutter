import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../models/userInfo.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();


  Future<void> _login(BuildContext context) async {

    final String apiUrl = 'http://10.0.2.2:8080/api/users/loginProc';

    String username = _usernameController.text;
    String password = _passwordController.text;

    Map<String, String> data = {
      'username': username,
      'password': password,
    };

    print('아이디: $username');
    print('비밀번호: $password');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );
      print('response code=${response.statusCode}');


      if (response.statusCode == 200) {
        final userInfoJson = jsonDecode(response.body);
        UserInfo userInfo = UserInfo.fromJson(userInfoJson);
        print('Response body: ${response.body}');
        // 로그인 성공
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('로그인 성공'),
              content: Text('로그인이 성공적으로 완료되었습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // 다이얼로그 닫기
                    Navigator.pop(context, {'isLoggedIn': true, 'userInfo': userInfo}); // 로그인 페이지 닫고 성공 여부 반환
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
      } else {
        // 회원가입 실패
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('로그인 실패'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
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
            content: Text('로그인 중 오류가 발생했습니다. 다시 시도해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
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
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(ModalRoute.of(context)?.settings.name); // 현재 페이지의 경로를 출력

    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: SingleChildScrollView( // SingleChildScrollView 추가
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: '아이디'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: '비밀번호'),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _login(context); // _login 메서드 호출 시 context 전달
                },
                child: Text('로그인'),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/findId'); // 아이디 찾기
                    },
                    child: Text('아이디 찾기'),
                  ),
                  SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/findPassword'); // 비밀번호 찾기
                    },
                    child: Text('비밀번호 찾기'),
                  ),
                  SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signUp'); // 회원가입
                    },
                    child: Text('회원가입'),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SocialButton(
                    text: '구글',
                    onPressed: () {
                      _loginWithGoogle();
                    },
                  ),
                  SizedBox(width: 12),
                  SocialButton(
                    text: '네이버',
                    onPressed: () {
                      _loginWithNaver();
                    },
                  ),
                  SizedBox(width: 12),
                  SocialButton(
                    text: '페이스북',
                    onPressed: () {
                      _loginWithFacebook();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loginWithGoogle() async {
    // 구글 로그인 버튼을 눌렀을 때 SampleScreen 페이지로 이동
  }
  void _loginWithNaver() {
    print('네이버 소셜 로그인 버튼을 눌렀습니다.');
  }

  void _loginWithFacebook() {
    print('페이스북 소셜 로그인 버튼을 눌렀습니다.');
  }
}

class SocialButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  SocialButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
