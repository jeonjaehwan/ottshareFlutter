import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum BankType {
  KAKAObank,
  NH,
  KB,
  SHINHAN,
  WOORI,
  SAEMAEUL,
  BUSAN,
  IBK,
  TOS,
  etc
}

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

  Future<void> _registerUser(BuildContext context) async {
    final String apiUrl = 'http://10.0.2.2:8080/api/users/join';

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

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // 회원가입 성공
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('회원가입 성공'),
              content: Text('회원가입이 성공적으로 완료되었습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('확인'),
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
              title: Text('회원가입 실패'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('확인'),
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
            title: Text('오류 발생'),
            content: Text('회원가입 중 오류가 발생했습니다. 다시 시도해주세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
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
        title: Text('회원가입'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '이름',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: '아이디',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                ),
                obscureText: true,
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: '닉네임',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: '이메일',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: '휴대폰 번호',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _accountController,
                decoration: InputDecoration(
                  labelText: '계좌번호',
                ),
              ),
              SizedBox(height: 20.0),
              TextField(
                controller: _accountHolderController,
                decoration: InputDecoration(
                  labelText: '예금주',
                ),
              ),
              SizedBox(height: 20.0),
              DropdownButtonFormField<BankType>(
                value: _selectedBank,
                onChanged: (newValue) {
                  setState(() {
                    _selectedBank = newValue;
                  });
                },
                items: BankType.values.map((bank) {
                  return DropdownMenuItem<BankType>(
                    value: bank,
                    child: Text(bank.toString().split('.').last),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: '은행',
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _registerUser(context), // 회원가입 버튼 클릭 시 함수 호출
                    child: Text('회원가입'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('취소'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
