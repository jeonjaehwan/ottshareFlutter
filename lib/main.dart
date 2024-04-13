
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:ott_share/screen/FindPassword.dart';
import 'package:ott_share/screen/FindId.dart';
import 'package:ott_share/screen/Login.dart';
import 'package:ott_share/screen/SignUp.dart';
import 'package:ott_share/screen/homePage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: 'b8d545024ec99b8ad44c04b522cab54f',
    javaScriptAppKey: 'a883fcabacb6ce410161d059b4dd1e75',
  );
  runApp(MaterialApp(
    title: 'OTT 공유 앱',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    initialRoute: '/',
    routes: {
      '/': (context) => HomePage(),
      '/signUp': (context) => SignUpPage(),
      '/users/login': (context) => LoginPage(),
      '/findId': (context) => FindIdPage(),
      '/findPassword': (context) => FindPasswordPage(),
    },
  ));
}
