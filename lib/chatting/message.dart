import 'chatMember.dart';

class Message {
  String content;
  ChatMember writer;
  String createdAt;

  Message({
    required this.content,
    required this.writer,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    ChatMember writer = ChatMember.fromJson(json['ottRoomMemberResponse']);
    String content = json['message'];

    return Message(
        content: content,
        writer: writer,
        createdAt: "임시");

  }

}