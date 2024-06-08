import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/bankType.dart';
import '../models/localhost.dart';


class SignUpPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignUpPage> {

  TextEditingController _nameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nicknameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _accountController = TextEditingController();
  TextEditingController _accountHolderController = TextEditingController();
  BankType? _selectedBank;


  @override
  void initState() {
    super.initState();
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


  Future<void> _registerUser(BuildContext context) async {
    final String apiUrl = 'http://${Localhost.ip}:8080/api/users/join';

    String name = _nameController.text;
    String username = _usernameController.text;
    String password = _passwordController.text;
    String nickname = _nicknameController.text;
    String email = _emailController.text;
    String phoneNumber = _phoneNumberController.text;
    String account = _accountController.text;
    String accountHolder = _accountHolderController.text;
    String bank = _selectedBank?.toString().split('.').last ?? '';

    Map<String, String> data = {
      'name': name,
      'username': username,
      'password': password,
      'nickname': nickname,
      'email': email,
      'phoneNumber': phoneNumber,
      'account': account,
      'accountHolder': accountHolder,
      'bank' : bank,
      'role' : 'USER'
    };

    print(jsonEncode(data));

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      print("response.statusCode = ${response.statusCode}");
      if (response.statusCode == 200) {
        // 회원가입 성공
        context.pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('회원가입이 완료되었습니다.'),
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
        // 회원가입 실패
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('회원가입이 실패하였습니다.'),
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
            content: Text('회원가입 중 오류가 발생했습니다.'),
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
        title: Text("회원가입", style: TextStyle(fontSize: 19),),
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
                decoration: InputDecoration(
                    hintText: '이메일 입력',
                    hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                    contentPadding: EdgeInsets.all(7)
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _phoneNumberController,
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
                onPressed: () => _registerUser(context),
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
                child: Text('회원가입', style: TextStyle(fontSize: 17),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
