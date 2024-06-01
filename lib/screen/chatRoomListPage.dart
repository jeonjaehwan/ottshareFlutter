import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../models/userInfo.dart';


class ChatRoomListPage extends StatefulWidget {
  final UserInfo? userInfo;

  ChatRoomListPage({Key? key,  this.userInfo}) : super(key: key);

  @override
  _ChatRoomListPageState createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends State<ChatRoomListPage> {
  late UserInfo? userInfo;

  @override
  void initState() {
    super.initState();
    userInfo = widget.userInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            if (userInfo == null)
              Container(
                width: double.maxFinite,
                child: Text("로그인 해주세요", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500,),
                  textAlign: TextAlign.center,),
              )
          ],
        ),
      ),
    );
  }
}