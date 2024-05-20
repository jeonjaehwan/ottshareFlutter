class ChatMember {

  int userId;
  String nickname;
  bool isLeader;
  bool isChecked;

  ChatMember({
    required this.userId,
    required this.nickname,
    required this.isLeader,
    required this.isChecked,
  });

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      userId: json['user']['id'] as int? ?? 0,
      nickname: json['user']['nickname'] as String? ?? '',
      isLeader: json['leader'] as bool? ?? false,
      isChecked: json['checked'] as bool? ?? false,
    );
  }

}