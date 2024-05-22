import 'package:ott_share/chatting/chatMember.dart';
import 'package:ott_share/chatting/chatRoom.dart';

class MessageRequest {

  final ChatRoom chatRoom;
  final ChatMember writer;
  final String message;

  MessageRequest({
    required this.chatRoom,
    required this.writer,
    required this.message,
  });

  Map<String, dynamic> toJson() {

    return {
      'ottShareRoom': chatRoom.toJson(),
      'ottRoomMemberResponse': writer.toJson(),
      'message': message,
    };
  }
}