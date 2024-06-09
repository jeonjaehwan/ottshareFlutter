import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/bankType.dart';
import '../models/localhost.dart';
import '../models/userInfo.dart';
import 'package:http/http.dart' as http;



class EditProfilePage extends StatefulWidget {
  final UserInfo? userInfo;

  const EditProfilePage({Key? key, required this.userInfo})
      : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late UserInfo? userInfo;

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _nicknameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _accountController;
  late TextEditingController _accountHolderController;
  late BankType? _selectedBank;

  @override
  void initState() {
    super.initState();
    userInfo = widget.userInfo;
    _nameController = TextEditingController(text: userInfo?.name ?? '');
    _usernameController = TextEditingController(text: userInfo?.username ?? '');
    _passwordController = TextEditingController();
    _nicknameController = TextEditingController(text: userInfo?.nickname ?? '');
    _emailController = TextEditingController(text: userInfo?.email ?? '');
    _phoneNumberController = TextEditingController(text: userInfo?.phoneNumber ?? '');
    _accountController = TextEditingController(text: userInfo?.account ?? '');
    _accountHolderController = TextEditingController(text: userInfo?.accountHolder ?? '');
    _selectedBank = userInfo?.bank;
  }

  Future<void> editUser(BuildContext context) async {
    final String apiUrl = 'http://${Localhost.ip}:8080/api/users/${userInfo?.userId}';

    String username = _usernameController.text;
    String password = _passwordController.text;
    String nickname = _nicknameController.text;
    String account = _accountController.text;
    String accountHolder = _accountHolderController.text;
    String bank = _selectedBank?.toString().split('.').last ?? '';


    Map<String, dynamic> data = {
      'id' : userInfo?.userId,
      'username': username,
      'password': password,
      'nickname': nickname,
      'account': account,
      'accountHolder': accountHolder,
      'bank' : bank,
    };

    print("수정 정보");
    print(jsonEncode(data));

    try {
      final response = await http.patch(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      print("response.statusCode = ${response.statusCode}");
      if (response.statusCode == 200) {
        context.pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('프로필이 수정되었습니다.'),
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
              content: Text('프로필 수정이 실패하였습니다.'),
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
            content: Text('프로필 수정 중 오류가 발생했습니다.'),
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
      appBar: AppBar(
        title: Text("프로필 수정", style: TextStyle(fontSize: 19),),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.black54),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text("개인정보 입력", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
              ),
              TextField(
                controller: _nameController,
                readOnly: true,
                style: TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                    hintText: '이름 입력',
                    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                    contentPadding: EdgeInsets.all(7)
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                    hintText: '아이디 입력',
                    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                    contentPadding: EdgeInsets.all(7)
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                    hintText: '비밀번호 입력',
                    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                    contentPadding: EdgeInsets.all(7)
                ),
                obscureText: true,
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                    hintText: '닉네임 입력',
                    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                    contentPadding: EdgeInsets.all(7)
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _emailController,
                readOnly: true,
                style: TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                    hintText: '이메일 입력',
                    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                    contentPadding: EdgeInsets.all(7)
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _phoneNumberController,
                readOnly: true,
                style: TextStyle(color: Colors.grey),
                decoration: InputDecoration(
                    hintText: '휴대폰번호 입력',
                    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                    contentPadding: EdgeInsets.all(7)
                ),
              ),
              SizedBox(height: 30.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Text("은행정보 입력", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
              ),
              TextField(
                controller: _accountController,
                decoration: InputDecoration(
                    hintText: '계좌번호 입력',
                    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                    contentPadding: EdgeInsets.all(7)
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _accountHolderController,
                decoration: InputDecoration(
                    hintText: '예금주 입력',
                    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                    contentPadding: EdgeInsets.all(7)
                ),
              ),
              SizedBox(height: 20.0),
              ButtonTheme(
                alignedDropdown: false,
                child: DropdownButtonFormField<BankType>(
                  value: _selectedBank,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedBank = newValue;
                    });
                  },
                  dropdownColor: Colors.white,
                  items: BankType.values.map((bank) {
                    return DropdownMenuItem<BankType>(
                      value: bank,
                      child: Text(
                        bank.toString().split('.').last,
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  isDense: true,
                  decoration: InputDecoration(
                    hintText: '은행 선택',
                    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                    contentPadding: EdgeInsets.all(7),
                  ),
                  icon: Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () => editUser(context),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.33,50),
                  foregroundColor: Color(0xff1C1C1C),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.black12, width: 1.5)
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: Text('수정', style: TextStyle(fontSize: 17),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _accountController.dispose();
    _accountHolderController.dispose();
    super.dispose();
  }
}
