
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:ott_share/screen/FindPassword.dart';
import 'package:ott_share/screen/FindId.dart';
import 'package:ott_share/screen/Login.dart';
import 'package:ott_share/screen/SignUp.dart';
import 'package:ott_share/screen/autoMatching.dart';
import 'package:ott_share/screen/ottRecommendation.dart';
import 'package:http/http.dart' as http;

import 'models/userInfo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: 'b8d545024ec99b8ad44c04b522cab54f',
    javaScriptAppKey: 'a883fcabacb6ce410161d059b4dd1e75',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OTT 공유 앱',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        // '/': (context) => HomePage(),
        '/signUp': (context) => SignUpPage(),
        '/users/login': (context) => LoginPage(),
        '/findId': (context) => FindIdPage(),
        '/findPassword': (context) => FindPasswordPage(),
        '/ottRecommendation' : (context) => OttRecommendationPage(),
      },
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {

  final UserInfo? userInfo;

  const HomePage({Key? key, this.userInfo}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late UserInfo? userInfo;

  int _selectedIndex = 0;
  bool isLoggedIn = false; // 로그인 상태

  static const TextStyle optionStyle = TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold
  );

  final List<Widget> _widgetOptions = <Widget>[
    AutoMatchingPage(),
    OttRecommendationPage(),
    AutoMatchingPage(), //임시 페이지
    LoginPage(),
  ];

  void _onItemTapped(int index) async {
    // '로그인/로그아웃' 버튼을 탭했을 때의 로직
    if (index == 3) { // 로그인/로그아웃 탭 인덱스, 필요에 따라 조정하세요.
      if (!isLoggedIn) {
        // 로그인 페이지로 이동하고 결과를 기다립니다.
        final result = await Navigator.pushNamed(context, '/users/login');
        // 로그인 페이지에서 반환된 결과를 기반으로 상태를 업데이트합니다.
        if (result is Map<String, dynamic>) {
          setState(() {
            isLoggedIn = result['isLoggedIn'] ?? false;
            userInfo = result['userInfo'] as UserInfo?;
          });
        }
      } else {
        // 로그아웃 로직
        await logout();
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> logout() async {
    final url = Uri.parse('http://10.0.2.2:8080/api/users/logout');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      print('로그아웃 성공');
      setState(() {
        isLoggedIn = false;
      });
    } else {
      print('로그아웃 실패: ${response.body}');
    }
  }

  // 메인 위젯
  @override
  Widget build(BuildContext context) {

    List<BottomNavigationBarItem> bottomItems = [
      BottomNavigationBarItem(icon: Icon(Icons.share), label: '자동매칭'),
      BottomNavigationBarItem(icon: Icon(Icons.movie_filter), label: 'OTT 추천'),
      BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅방 기록'),
      BottomNavigationBarItem(icon: isLoggedIn ? Icon(Icons.person) : Icon(Icons.login), label: isLoggedIn ? '로그아웃' : '로그인'),
    ];

    return Scaffold(
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
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
  void initState() {
    //해당 클래스가 호출되었을떄
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

}

