import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../models/localhost.dart';
import '../models/loginStorage.dart';

import '../api/google_signin_api.dart';
import '../models/userInfo.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();


  Future<void> _login(BuildContext context) async {

    final String apiUrl = 'http://${Localhost.getIp()}:8080/api/users/loginProc';

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


      if (response.statusCode == 200) {
        final userInfoJson = jsonDecode(response.body);
        UserInfo userInfo = UserInfo.fromJson(userInfoJson);
        await LoginStorage.saveUserId(userInfo.userId); // 로그인 성공 시 사용자 ID 저장

        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text('로그인 성공'),
              content: Text('로그인이 성공적으로 완료되었습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                    context.go("/home?isLoggedIn=true", extra: userInfo);
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
              title: Text('로그인 실패'),
              content: Text('아이디 또는 비밀번호가 잘못되었습니다.'),
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
      print(error);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('네트워크 오류'),
            content: Text('로그인 중 오류가 발생했습니다. 네트워크 상태를 확인해주세요.'),
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
                      context.push('/findId');
                    },
                    child: Text('아이디 찾기'),
                  ),
                  SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      context.push('/findPassword');
                    },
                    child: Text('비밀번호 찾기'),
                  ),
                  SizedBox(width: 12),
                  TextButton(
                    onPressed: () {
                      context.push('/signUp');
                    },
                    child: Text('회원가입'),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _getGoogleLoginButton(context),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _getKakaoLoginButton(context)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _getGoogleLoginButton(BuildContext context) {
    return Center( // Center 위젯 추가
      child: InkWell(
        onTap: () {
          _loginWithGoogle(context);
        },
        child: Card(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
          elevation: 2,
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset('assets/google_login.png', height: 40, width: 300,),
            ],),
          ),
        ),
      ),
    );
  }


  Widget _getKakaoLoginButton(BuildContext context) {
    return InkWell(
      onTap: () {
        _loginWithKakao(context);
      },
      child: Card(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        elevation: 2,
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset('assets/kakao_login.png', height: 40, width: 270,),
            const SizedBox(
              width: 30,
            ),
          ],),
        ),
      ),
    );
  }


  Future<void> _loginWithGoogle(BuildContext context) async {
    final user = await GoogleSignInApi.login();

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('로그인에 실패했습니다.')));
    } else {
      // 회원 정보 추출
      print('구글 사용자 정보 요청 성공'
          '\n회원번호: ${user.id}'
          '\n닉네임: ${user.displayName}'
          '\n이메일: ${user.email}');

      // 서버에 회원 정보 전송 후 회원가입 진행

      UserInfo userInfo = UserInfo(
        userId: 0,
          username: user.id,
          nickname: user.displayName.toString(),
          email: user.email,
          name: user.displayName.toString(),
          password: "password",
          phoneNumber: "phoneNumber",
          bank: "bank",
          account: "account",
          accountHolder: "accountHolder", role: "role",
          isShareRoom: false);

      // 메인페이지로 이동
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('로그인 성공'),
            content: Text('로그인이 성공적으로 완료되었습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop(); // 다이얼로그 닫기
                  context.go("/home?userInfo=${userInfo}&isLoggedIn=true");
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _loginWithKakao(BuildContext context) async {
    // 키 해시값 확인
    print(await KakaoSdk.origin);

    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk().then((value) async {

          // 회원 정보 추출
          User user = await UserApi.instance.me();
          print('카카오 사용자 정보 요청 성공'
              '\n회원번호: ${user.id}'
              '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
              '\n이메일: ${user.kakaoAccount?.email}');

          // 서버에 회원 정보 전송

          // 메인페이지로 이동
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('로그인 성공'),
                content: Text('로그인이 성공적으로 완료되었습니다.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop(); // 다이얼로그 닫기
                      context.go("/home?selectedIndex=0&isLoggedIn=true");
                    },
                    child: Text('확인'),
                  ),
                ],
              );
            },
          );
        });
      } catch (error) {
        print('카카오톡으로 로그인 실패1 $error');

        // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
        // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          await UserApi.instance.loginWithKakaoAccount().then((value) async {

            User user = await UserApi.instance.me();
            print('카카오 사용자 정보 요청 성공'
                '\n회원번호: ${user.id}'
                '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
                '\n이메일: ${user.kakaoAccount?.email}');

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('로그인 성공'),
                  content: Text('로그인이 성공적으로 완료되었습니다.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        context.pop(); // 다이얼로그 닫기
                        context.go("/home?selectedIndex=0&isLoggedIn=true");
                      },
                      child: Text('확인'),
                    ),
                  ],
                );
              },
            );
          });
        } catch (error) {
          print('카카오계정으로 로그인 실패2 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount().then((value) async {

          User user = await UserApi.instance.me();
          print('카카오 사용자 정보 요청 성공'
              '\n회원번호: ${user.id}'
              '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
              '\n이메일: ${user.kakaoAccount?.email}');

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('로그인 성공'),
                content: Text('로그인이 성공적으로 완료되었습니다.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop(); // 다이얼로그 닫기
                      context.go("/home?selectedIndex=0&isLoggedIn=true");
                    },
                    child: Text('확인'),
                  ),
                ],
              );
            },
          );
        });
      } catch (error) {
        print('카카오계정으로 로그인 실패3 $error');
      }
    }
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
