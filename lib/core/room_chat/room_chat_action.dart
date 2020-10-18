import 'package:flutter/material.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/core/api_services.dart';

abstract class RoomChatAction {
  //Xóa tin nhắn trực tiếp
  Future<void> closeDirectMessage(
      {@required String roomID,
      @required OnResultData resultData,
      @required OnErrorApiCallback onErrorApiCallback});

  //Cập nhật ảnh đại diện (user)
  Future<void> uploadAvatar(
      {@required String imgUrl,
      @required OnResultData resultData,
      @required OnErrorApiCallback onErrorApiCallback,});

  //Rời nhóm
  Future<void> leaveGroup(
      {@required String groupID,
      @required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback});

  //Xóa nhóm: Chỉ dành cho admin phòng
  Future<void> removeGroup(
      {@required String groupID,
      @required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback});

  //Xóa nhóm: Chỉ dành cho admin của nhóm
  Future<void> deleteGroup(
      {@required String groupID,
      @required WsAccountModel accountModel,
      @required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback});

}
