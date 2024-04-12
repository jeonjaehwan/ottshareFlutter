
import 'package:flutter/material.dart';
import 'package:ott_share/screen/FindPassword.dart';
import 'package:ott_share/screen/FindId.dart';
import 'package:ott_share/screen/Login.dart';
import 'package:ott_share/screen/SignUp.dart';
import 'package:ott_share/screen/homePage.dart';

void main() {
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
