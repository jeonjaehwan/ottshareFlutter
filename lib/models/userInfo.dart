import 'package:ott_share/models/bankType.dart';

class UserInfo {
  final int userId; // Dart에서는 int 타입을 사용합니다.
  final String username;
  final String nickname;
  final String email;
  final String name;
  final String password;
  final String phoneNumber;
  final BankType bank;
  final String account;
  final String accountHolder;
  final String role;
  bool isShareRoom = false;

  UserInfo({
    required this.userId,
    required this.username,
    required this.nickname,
    required this.email,
    required this.name,
    required this.password,
    required this.phoneNumber,
    required this.bank,
    required this.account,
    required this.accountHolder,
    required this.role,
    required this.isShareRoom,
  });





  factory UserInfo.fromJson(Map<String, dynamic> json) {
    BankType bankType = BankTypeExtension.fromString(json['bank']);

    return UserInfo(
      userId: json['userId'] as int? ?? 0, // Long 대신 int를 사용하고, 기본값을 제공합니다.
      username: json['username'] as String? ?? '', // 기본값으로 빈 문자열 제공
      nickname: json['nickname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      password: json['password'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      bank: bankType ?? BankType.etc,
      account: json['account'] as String? ?? '',
      accountHolder: json['accountHolder'] as String? ?? '',
      role: json['role'] as String? ?? '',
      isShareRoom: json['shareRoom'] as bool? ?? false, // Boolean 값에 대해서는 false 기본값 제공
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'nickname': nickname,
      'email': email,
      'name': name,
      'password': password,
      'phoneNumber': phoneNumber,
      'bank': bank.toString().split('.').last ?? '',
      'account': account,
      'accountHolder': accountHolder,
      'role': role,
      'shareRoom': isShareRoom,
    };
  }

}
