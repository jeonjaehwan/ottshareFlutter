import 'package:http/http.dart';

import '../models/userInfo.dart';
import 'chatMember.dart';
import 'message.dart';

class ChatRoom {

  final int chatRoomId;

  late ChatMember writer;
  late List<ChatMember> readers;

  final String ottType;
  String ottId;
  String ottPassword;


  ChatRoom({
    required this.chatRoomId,
    required this.writer,
    required this.readers,
    required this.ottType,
    required this.ottId,
    required this.ottPassword
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json, UserInfo userInfo) {
    late ChatMember writer;
    List<ChatMember> readers = [];

    for (var ottRoomMemberResponse in json['ottRoomMemberResponses']) {
      if (ottRoomMemberResponse['user']['userId'] == userInfo.userId) {
        writer = ChatMember.fromJson(ottRoomMemberResponse);
        print("writer의 userInfoId = ${writer.userInfo.userId}");
      } else {
        readers.add(ChatMember.fromJson(ottRoomMemberResponse));
      }
    }

    return ChatRoom(
      chatRoomId: json['id'] as int? ?? 0,
      writer:  writer,
      readers: readers,
      ottType: json['ott'] as String? ?? '',
      ottId: json['ottId'] as String? ?? '',
      ottPassword: json['ottPassword'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {

    List<dynamic> readerResponses = [];
    for (var reader in readers) {
      readerResponses.add(reader.toJson());

    }
    return {
      'id': chatRoomId,
      'ottRoomMemberResponses': readerResponses,
      'ottRoomMemberResponse': writer.toJson(),
      'ott': ottType,
      'ottId': ottId,
      'ottPassword': ottPassword,
    };
  }

}