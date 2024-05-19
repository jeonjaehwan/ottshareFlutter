import 'chatMember.dart';

class Message {
  String content;
  ChatMember sender;
  String createdAt;

  Message({
    required this.content,
    required this.sender,
    required this.createdAt,
});

}