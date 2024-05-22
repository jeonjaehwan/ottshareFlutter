import 'package:ott_share/chatting/chatMember.dart';
import 'package:ott_share/chatting/chatRoom.dart';

class MessageRequest {

  final ChatRoom chatRoom;
  final ChatMember writer;
  final String content;

  MessageRequest({
    required this.chatRoom,
    required this.writer,
    required this.content,
  });

  Map<String, dynamic> toJson() {

    return {
      'ottShareRoom': chatRoom.toJson(),
      'ottRoomMemberResponse': writer.toJson(),
      'message': content,
    };
  }
}