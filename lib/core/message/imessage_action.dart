import 'package:flutter/material.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/chat/chat_model/message_action_model.dart';

abstract class IMessageAction {
  //Detect image từ ảnh
  //Truyền lên fileID và nhận về text đã được detect từ trong image
  ///[imageFileID] : ID của file image trên server
  Future<void> detectImageToText(String imageFileID, OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback);

  ///Quote message action [ActionType] == [ActionType.QUOTE]
  Future<void> sendMessageWithAction(
      {@required MessageActionsModel messageActionsModel,
      String userQuoteID = "",
      WsRoomModel roomModel,
      @required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback});

  Future<void> sendMessageForwardToGroup(
      {MessageActionsModel messageActionsModel,
      WsRoomModel roomModel,
      WsAccountModel accountModel,
      OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback,
      bool isRequestBodyRoomName = false});
}
