import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/localhost.dart';

class FindIdAndPasswordPage extends StatefulWidget {
  final int index;

  FindIdAndPasswordPage({Key? key, required this.index}) : super(key: key);

  @override
  _FindIdAndPasswordPageState createState() => _FindIdAndPasswordPageState();
}

class _FindIdAndPasswordPageState extends State<FindIdAndPasswordPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _certificationNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late int pageIndex;

  String title = '아이디 찾기';

  late TabController tabController = TabController(
    length: 2,
    vsync: this,
    initialIndex: pageIndex,

    // 탭 변경 애니메이션 시간
    animationDuration: const Duration(milliseconds: 800),
  );

  @override
  void initState() {
    super.initState();
    pageIndex = widget.index;
    if (pageIndex == 1) {
      title = '비밀번호 찾기';
    }
  }



  /**
   * 인증번호 전송
   */
  Future<void> _sendVerificationCode(BuildContext context) async {
    final String apiUrl = 'http://${Localhost.ip}:8080/api/users/send';

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
              content: Text('인증번호가 전송되었습니다.\n확인 후 입력해주세요.'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: Align(
                    alignment:
                    Alignment.center, // 텍스트를 가운데 정렬
                    child: Text('확인'),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color(0xffffdf24),
                    foregroundColor: Colors.black,
                  ),
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
              content: Text('인증번호 발송 실패'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: Align(
                    alignment:
                    Alignment.center, // 텍스트를 가운데 정렬
                    child: Text('확인'),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color(0xffffdf24),
                    foregroundColor: Colors.black,
                  ),
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
            content: Text('인증번호 전송 중 오류가 발생했습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Align(
                  alignment:
                  Alignment.center, // 텍스트를 가운데 정렬
                  child: Text('확인'),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Color(0xffffdf24),
                  foregroundColor: Colors.black,
                ),
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
    final String apiUrl = 'http://${Localhost.ip}:8080/api/users/find-username';

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
              content: Text('인증되었습니다.\n아이디 : ${message}'),
              // content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                    context.pop();
                  },
                  child: Align(
                    alignment:
                    Alignment.center, // 텍스트를 가운데 정렬
                    child: Text('확인'),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color(0xffffdf24),
                    foregroundColor: Colors.black,
                  ),
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
              content: Text('인증번호가 틀렸습니다. 다시 확인해주세요.'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: Align(
                    alignment:
                    Alignment.center, // 텍스트를 가운데 정렬
                    child: Text('확인'),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color(0xffffdf24),
                    foregroundColor: Colors.black,
                  ),
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
            content: Text('인증번호 확인 중 오류가 발생했습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Align(
                  alignment:
                  Alignment.center, // 텍스트를 가운데 정렬
                  child: Text('확인'),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Color(0xffffdf24),
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          );
        },
      );
    }
  }

  /**
   * 비밀번호 재설정 링크 전송
   */
  Future<void> _sendResetLink(BuildContext context) async {
    final String apiUrl = 'http://${Localhost.ip}:8080/api/users/find-password';

    String name = _nameController.text;
    String username = _usernameController.text;
    String email = _emailController.text;

    Map<String, String> data = {
      'name': name,
      'username': username,
      'email': email,
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
              content: Text('인증되었습니다.\n임시 비밀번호 : ${message}'),
              // content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                    context.pop();
                  },
                  child: Align(
                    alignment:
                    Alignment.center, // 텍스트를 가운데 정렬
                    child: Text('확인'),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color(0xffffdf24),
                    foregroundColor: Colors.black,
                  ),
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
              content: Text('인증에 실패하였습니다. 다시 확인해주세요.'),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: Align(
                    alignment:
                    Alignment.center, // 텍스트를 가운데 정렬
                    child: Text('확인'),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color(0xffffdf24),
                    foregroundColor: Colors.black,
                  ),
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
            content: Text('비밀번호 인증 중 오류가 발생했습니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop();
                },
                child: Align(
                  alignment:
                  Alignment.center, // 텍스트를 가운데 정렬
                  child: Text('확인'),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Color(0xffffdf24),
                  foregroundColor: Colors.black,
                ),
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontSize: 19),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black54),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: _tabBar(),
      //   body: Padding(
      //     padding: EdgeInsets.all(16.0),
      //     child:
      //   ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _certificationNumberController.dispose();
    tabController.dispose();
    _emailController.dispose();
    super.dispose();
  }


  Widget _tabBar() {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: "아이디"),
            Tab(text: "비밀번호"),
          ],
          labelColor: Colors.black,
          labelStyle: const TextStyle(
            fontSize: 16,
          ),
          unselectedLabelColor: Colors.grey,
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
          ),
          overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
    indicatorColor: Colors.black,
          indicatorWeight: 2,
          indicatorSize: TabBarIndicatorSize.tab,
          onTap: (index) {
            if (index == 0) {
              setState(() {
                title = "아이디 찾기";
              });
            } else {
              setState(() {
                title = "비밀번호 찾기";
              });
            }
            
          },
        ),
        Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("아이디를 찾기 위해\n휴대폰 번호를 인증해주세요", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: '이름 입력',
                            hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                            contentPadding: EdgeInsets.all(7)
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                                controller: _phoneNumberController,
                                decoration: InputDecoration(
                                    hintText: '휴대폰 번호 (숫자만 입력)',
                                    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                                    contentPadding: EdgeInsets.all(7)
                                ),
                              ),
                          ),
                          SizedBox(width: 15),
                          ElevatedButton(
                            onPressed: () {
                              _sendVerificationCode(context); // 인증번호 전송 로직 호출
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(MediaQuery.of(context).size.width * 0.23,50),
                              foregroundColor: Color(0xff1C1C1C),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.black12, width: 1.5)
                              ),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                            child: Text('인증번호'),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                                controller: _certificationNumberController,
                                decoration: InputDecoration(
                                    hintText: '인증번호 입력',
                                    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                                    contentPadding: EdgeInsets.all(7)
                                ),
                              ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              _checkConfirmationCode(context);
                            },
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size(MediaQuery.of(context).size.width * 0.23,50),
                                foregroundColor: Color(0xff1C1C1C),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: Colors.black12, width: 1.5)
                                ),
                                elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                            child: Text('인증확인'),
                          ),
                        ],
                      )
                    ],
                  ),
                )
                    ),
                Container(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                      child: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("비밀번호를 찾기 위해\n아이디와 이메일을 입력해주세요", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                                hintText: '이름 입력',
                                hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                                contentPadding: EdgeInsets.all(7)
                            ),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                                hintText: '아이디 입력',
                                hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                                contentPadding: EdgeInsets.all(7)

                            ),
                          ),
                          SizedBox(height: 12),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                                hintText: '이메일 입력',
                                hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                                contentPadding: EdgeInsets.all(7)
                            ),
                          ),
                          SizedBox(height: 23),
                          ElevatedButton(
                            onPressed: () {
                              _sendResetLink(context); // 비밀번호 재설정 링크 전송 로직 호출
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(MediaQuery.of(context).size.width * 0.4,50),
                              foregroundColor: Color(0xff1C1C1C),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.black12, width: 1.5)
                              ),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                            child: Text('비밀번호 찾기'),
                          ),
                        ],
                      )
                  ),
                )
              ],
            )
        )
      ],
    );
  }
}

