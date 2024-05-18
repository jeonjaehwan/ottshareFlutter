import 'chatMember.dart';
import 'message.dart';

class ChatRoom {

  int chatRoomId;
  ChatMember writer;
  List<ChatMember> readers;
  List<Message> messages;

  ChatRoom({
    required this.chatRoomId,
    required this.writer,
    required this.readers,
    required this.messages,
  });

}