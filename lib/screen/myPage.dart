import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/userInfo.dart';

class MyPage extends StatefulWidget {
  final UserInfo? userInfo;
  final int? selectedIndex;

  MyPage({Key? key, required this.userInfo, this.selectedIndex})
      : super(key: key);

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

    late String text;
    late Widget childWidget;

    return Scaffold(
      body: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              text = '회원 수정';
              break;
            case 1:
              text = '회원 탈퇴';
              break;
            case 2:
              text = '자주 묻는 질문';
              break;
            case 3:
              text = '1:1 문의';
              break;
            default:
              text = '';
          }

          childWidget = Container(
            height: 60,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))),
            child: ListTile(
              title: Text(text, style: TextStyle(fontSize: 18)),
              onTap: () {},
            ),
          );

          return childWidget;
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
