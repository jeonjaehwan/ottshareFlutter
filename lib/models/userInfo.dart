class UserInfo {
  final String username;
  final String nickname;
  final String email;
  final String name;
  final String password;
  final String phoneNumber;
  final String bank;
  final String account;
  final String accountHolder;
  final String role;
  final bool isShareRoom;

  UserInfo({
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
    return UserInfo(
      username: json['username'] as String? ?? '',  // 기본값으로 빈 문자열 제공
      nickname: json['nickname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      password: json['password'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      bank: json['bank'] as String? ?? '',
      account: json['account'] as String? ?? '',
      accountHolder: json['accountHolder'] as String? ?? '',
      role: json['role'] as String? ?? '',
      isShareRoom: json['isShareRoom'] as bool? ?? false,  // Boolean 값에 대해서는 false 기본값 제공
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'nickname': nickname,
      'email': email,
      'name': name,
      'password': password,
      'phoneNumber': phoneNumber,
      'bank': bank,
      'account': account,
      'accountHolder': accountHolder,
      'role': role,
      'isShareRoom': isShareRoom,
    };
  }
}