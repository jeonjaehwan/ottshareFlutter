import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/userInfo.dart';


class MyPage extends StatefulWidget {

  final UserInfo? userInfo;
  final int? selectedIndex;

  MyPage({Key? key, required this.userInfo, this.selectedIndex}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {

  late UserInfo? userInfo;


  @override
  void initState() {
    super.initState();
    userInfo = widget.userInfo;
  }


  @override
  Widget build(BuildContext context) {
    print('my page user info = ${widget.userInfo}');

    return Scaffold(
      body: Container(
        child: Text("마이페이지")
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

}