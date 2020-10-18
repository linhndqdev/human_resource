import 'package:flutter/cupertino.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';

abstract class MessageAction {
  Future<void> sendTextMessage(
      {@required String message,
      OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback, WsRoomModel roomModel});

  Future<void> sendImageMessage(
      {OnResultData resultData,
      @required String fullName,
      String senderUserName,
      OnErrorApiCallback onErrorApiCallback});

  Future<void> sendFileMessage(
      {String filePath,
      String senderUserName,
      @required String fullName,
      OnResultData resultData,
      OnErrorApiCallback onErrorApiCallback, WsRoomModel roomModel});
}
