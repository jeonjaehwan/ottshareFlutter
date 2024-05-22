
import '../models/userInfo.dart';

class ChatMember {

  final int chatMemberId;
  final UserInfo userInfo;
  bool isLeader = false;
  bool isChecked = false;

  ChatMember({
    required this.chatMemberId,
    required this.userInfo,
    required this.isLeader,
    required this.isChecked,
  });

  factory ChatMember.fromJson(Map<String, dynamic> json) {

    UserInfo userInfo = UserInfo.fromJson(json['user']);

    return ChatMember(
      chatMemberId: json['user']['id'] as int? ?? 0,
      userInfo: userInfo,
      isLeader: json['leader'] as bool? ?? false,
      isChecked: json['checked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': chatMemberId,
      'user': userInfo.toJson(),
      'leader': isLeader,
      'checked': isChecked,

    };
  }

}