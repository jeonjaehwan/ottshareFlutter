import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:ott_share/screen/FindPassword.dart';
import 'package:ott_share/screen/FindId.dart';
import 'package:ott_share/screen/Login.dart';
import 'package:ott_share/screen/OTTInfoPage.dart';
import 'package:ott_share/screen/SignUp.dart';
import 'package:ott_share/screen/autoMatching.dart';
import 'package:ott_share/chatting/chatRoomPage.dart';
import 'package:ott_share/screen/ottRecommendation.dart';
import 'package:ott_share/models/loginStorage.dart';
import 'package:ott_share/screen/myPage.dart';

import 'package:http/http.dart' as http;

import 'api/google_signin_api.dart';
import 'chatting/chatMember.dart';
import 'chatting/chatRoom.dart';
import 'chatting/message.dart';
import 'models/userInfo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: 'b8d545024ec99b8ad44c04b522cab54f',
    javaScriptAppKey: 'a883fcabacb6ce410161d059b4dd1e75',
  );
  WidgetsFlutterBinding.ensureInitialized(); // 이 줄이 필수적으로 필요할 수 있습니다.
  await LoginStorage.init();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'OTT 공유 앱',
        routerConfig: GoRouter(initialLocation: "/", routes: [
          GoRoute(
            path: "/",
            builder: (context, state) => HomePage(),
          ),
          GoRoute(path: "/signUp", builder: (context, state) => SignUpPage()),
          GoRoute(
              path: "/users/login", builder: (context, state) => LoginPage()),
          GoRoute(path: "/findId", builder: (context, state) => FindIdPage()),
          GoRoute(
              path: "/findPassword",
              builder: (context, state) => FindPasswordPage()),
          GoRoute(
              path: "/autoMatching",
              builder: (context, state) {
                int selectedIndex =
                    int.parse(state.uri.queryParameters['selectedIndex']!);
                return HomePage(selectedIndex: selectedIndex);
              }),
          GoRoute(
              path: "/home",
              builder: (context, state) {
                bool isLoggedIn =
                    bool.parse(state.uri.queryParameters['isLoggedIn']!);
                UserInfo userInfo = state.extra as UserInfo;
                return HomePage(isLoggedIn: isLoggedIn, userInfo: userInfo);
              }),
          GoRoute(
              path: "/ottInfo",
              builder: (context, state) {
                int selectedOttIndex =
                    int.parse(state.uri.queryParameters['selectedOttIndex']!);
                bool isLeader =
                    bool.parse(state.uri.queryParameters['isLeader']!);
                UserInfo userInfo = state.extra as UserInfo;
                return OTTInfoPage(
                    selectedOttIndex: selectedOttIndex,
                    isLeader: isLeader,
                    userInfo: userInfo);
              }),
          GoRoute(
              path: "/chatRoom",
              builder: (context, state) {
                ChatRoom chatRoom = state.extra as ChatRoom;
                return ChatRoomPage(
                    chatRoom: chatRoom);
              }),
        ]),
    );
  }
}


class HomePage extends StatefulWidget {
  final UserInfo? userInfo;
  final int? selectedIndex;
  final bool? isLoggedIn; // 로그인 상태

  HomePage({Key? key, this.userInfo, this.selectedIndex, this.isLoggedIn})
      : super(key: key);

  @override
  State<HomePage> createState() =>
      _HomePageState(userInfo: userInfo, isLoggedIn: isLoggedIn);
}

class _HomePageState extends State<HomePage> {
  late UserInfo? userInfo;
  late bool? isLoggedIn;
  int _selectedIndex = 0;

  _HomePageState({this.userInfo, this.isLoggedIn});

  @override
  void initState() {
    super.initState();
    userInfo = widget.userInfo; // null일 수 있음
    isLoggedIn = widget.isLoggedIn ?? false;
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) async {
    // '로그인/로그아웃' 버튼을 탭했을 때의 로직
    if (index == 3) {
      // 로그인/로그아웃 탭 인덱스, 필요에 따라 조정하세요.
      if (isLoggedIn == false) {
        // 로그인 페이지로 이동하고 결과를 기다립니다.
        context.push('/users/login').then((result) {
          // 로그인 페이지에서 반환된 결과를 기반으로 상태를 업데이트합니다.
          if (result is Map<String, dynamic>) {
            setState(() {
              isLoggedIn = bool.parse(result['isLoggedIn']) ?? false;
              userInfo = result['userInfo'] as UserInfo?;
            });
          }
        });
      } else {
        // 마이페이지 이동 로직
        setState(() {
          _selectedIndex = index;
        });
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> logout() async {
    GoogleSignInApi.logout();
    // UserApi.instance.logout();
    setState(() {
      isLoggedIn = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그아웃 성공'),
          content: Text('로그아웃이 성공적으로 완료되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                // Navigator.pop(context, {'isLoggedIn': true, 'userInfo': userInfo}); // 로그인 페이지 닫고 성공 여부 반환
                context.go('/');
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 메인 위젯
  @override
  Widget build(BuildContext context) {


    String titleText = '';

    switch (_selectedIndex) {
      case 0:
        titleText = 'OTT 공유';
      case 1:
        titleText = 'OTT 추천';
      case 2:
        titleText = '채팅방 기록';
    }

    List<BottomNavigationBarItem> bottomItems = [
      BottomNavigationBarItem(icon: Icon(Icons.share), label: '자동매칭'),
      BottomNavigationBarItem(icon: Icon(Icons.movie_filter), label: 'OTT 추천'),
      BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅방 기록'),
      BottomNavigationBarItem(
          icon: isLoggedIn == true ? Icon(Icons.person) : Icon(Icons.login),
          label: isLoggedIn == true ? '마이페이지' : '로그인'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        backgroundColor: Color(0xffffdf24),
        centerTitle: true,
        elevation: 0.0,
        actions: [
          if (isLoggedIn == true)
            IconButton(icon: Icon(Icons.logout), onPressed: logout)
        ],
      ),
      body: SafeArea(
        child: <Widget>[
          AutoMatchingPage(userInfo: widget.userInfo),
          OttRecommendationPage(),
          AutoMatchingPage(userInfo: widget.userInfo),
          // ChatRoomPage(ottShareRoom: ottShareRoom, chatRoom: chatRoom), //임시 페이지
          MyPage(userInfo: widget.userInfo, selectedIndex: 3),
        ].elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: bottomItems,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xffffdf24),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
