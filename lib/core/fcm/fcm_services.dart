import 'dart:convert';

import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/core/fcm/fcm_action.dart';
import 'package:human_resource/utils/common/cache_helper.dart';
import 'package:http/http.dart' as Http;
import 'package:dio/dio.dart' as Dio;
import 'package:human_resource/utils/common/crypto_hex.dart';

class FCMServices extends FCMAction {
  @override
  Future<void> postTokenToServer({onResultData, onErrorApiCallback}) async {
    String jwt = await CacheHelper.getAccessToken();
    String fcmToken = await CacheHelper.getFCMToken();
    if (jwt.isNotEmpty && fcmToken.isNotEmpty) {
      await Http.post(Constant.SERVER_BASE + "/api/fcm/token",
          headers: {"Authorization": "Bearer $jwt"},
          body: {"token": "$fcmToken"}).then((response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 || statusCode > 400) {
          return null;
        } else {
          return response;
        }
      }).catchError((onError) {
        if (onError.toString().contains("SocketException")) {
          postTokenToServer();
        }
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        postTokenToServer();
        return null;
      });
    }
  }

  @override
  Future<void> sendFCMMessage({onResultData, onErrorApiCallback}) async {
    String jwt = await CacheHelper.getAccessToken();
    String fcmToken = await CacheHelper.getFCMToken();
    if (jwt.isNotEmpty && fcmToken.isNotEmpty) {
      Map<String, String> _header = {
        "Authorization": "Bearer $jwt",
        "Content-Type": "application/json"
      };
      await Dio.Dio()
          .post(Constant.SERVER_BASE + "/api/fcm/send",
              data: {},
              options: Dio.Options(
                  headers: _header, receiveTimeout: 60000, sendTimeout: 60000))
          .catchError((onError) {
        return null;
      }).timeout(Duration(seconds: 60), onTimeout: () {
        return null;
      });
    }
  }

  @override
  Future<void> removeToken({onResultData, onErrorApiCallback}) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt.isNotEmpty) {
      await Http.post(Constant.SERVER_BASE + "/api/fcm/token",
          headers: {"Authorization": "Bearer $jwt"},
          body: {"token": ""}).then((response) {
        final int statusCode = response.statusCode;
        if (statusCode < 200 || statusCode > 400) {
          return null;
        } else {
          return response;
        }
      }).catchError((onError) {
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        return null;
      });
    }
  }
  void sendFCMNormalMessageOnlyUser(WsRoomModel roomModel, String content, String userID) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    List<String> targetID = List();
    Map<String, dynamic> _body = {
      "event": "chat.send",
      "sender_id": '${accountModel.id}',
      "sender_token": '${accountModel.token}',
      "room_id": '${roomModel.id}',
      "target_ids": targetID,
      "content": content,
      "receiver_id": userID
    };
    String jwt = await CacheHelper.getAccessToken();
    Map<String, String> _header = {
      "Authorization": "Bearer $jwt",
      "Content-Type": "application/json"
    };
    Http.Response response = await Http.post(Constant.SERVER_BASE + "/api/fcm/notify",
        headers: _header, body: json.encode(_body))
        .then((rest) {
      if (rest.statusCode == 200) {
        return rest;
      }
      return null;
    }).catchError((onError) {
      return null;
    });
  }

  void sendFCMNormalMessage(WsRoomModel roomModel, String content) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    List<String> targetID = List();
    bool isRequestBodyWithRoomName = roomModel.roomType == RoomType.p;
    String roomName = isRequestBodyWithRoomName
        ? CryptoHex.deCodeChannelName(roomModel.name) ?? ""
        : "";
    String receiverID = roomModel.roomType == RoomType.d
        ? roomModel.id.replaceAll(accountModel.id, "")
        : "";
    Map<String, dynamic> _body = isRequestBodyWithRoomName
        ? {
            "event": "chat.send",
            "sender_id": '${accountModel.id}',
            "sender_token": '${accountModel.token}',
            "room_id": '${roomModel.id}',
            "room_name": roomName,
            "target_ids": targetID,
            "content": content,
          }
        : {
            "event": "chat.send",
            "sender_id": '${accountModel.id}',
            "sender_token": '${accountModel.token}',
            "room_id": '${roomModel.id}',
            "target_ids": targetID,
            "content": content,
            "receiver_id": receiverID
          };
    String jwt = await CacheHelper.getAccessToken();
    Map<String, String> _header = {
      "Authorization": "Bearer $jwt",
      "Content-Type": "application/json"
    };
    Http.Response response = await Http.post(Constant.SERVER_BASE + "/api/fcm/notify",
            headers: _header, body: json.encode(_body))
        .then((rest) {
          print(rest.body.toString());
      if (rest.statusCode == 200) {
        return rest;
      }
      return null;
    }).catchError((onError) {
      return null;
    });
  }

  ///[userQuoteID] nó sẽ chỉ khác null nếu là tin nhắn quote
  ///Nếu không phải tin nhắn quuote thì [userQuoteID] == ""
  ///Dùng cho tag quote và forward
  void sendMessageActionFCM(
      WsRoomModel roomModel, MessageActionsModel actionsModel, String chatEvent,
      {String userQuoteID = "",
      bool isRequestBodyWithRoomName = false,
      String roomID = "",
      String receiver_id = ""}) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    List<String> targetID = List();
    String content = "";
    if (chatEvent == "chat.tag") {
      actionsModel.mentions.mentions.forEach((user) {
        targetID.add(user.userID);
      });
    } else if (chatEvent == "chat.quote" && userQuoteID != "") {
      targetID.add(userQuoteID);
    } else if (chatEvent == "chat.share") {
      content = actionsModel.msg;
    }
    String roomName = isRequestBodyWithRoomName
        ? CryptoHex.deCodeChannelName(roomModel.name) ?? ""
        : "";
    String mRoomID = roomID != "" ? roomID : roomModel.id;
    Map<String, dynamic> _body =
        (chatEvent == "chat.tag" || chatEvent == "chat.quote")
            ? {
                "event": '$chatEvent',
                "sender_id": '${accountModel.id}',
                // chat user id của người thực hiện hành động
                "sender_token": '${accountModel.token}',
                "room_id": '$mRoomID',
                // id nhóm chat
                "target_ids": targetID
                // chat user id của những người nhận hành động
              }
            : chatEvent == "chat.share"
                ? {
                    "event": '$chatEvent',
                    "sender_id": '${accountModel.id}',
                    // chat user id của người thực hiện hành động
                    "sender_token": '${accountModel.token}',
                    "room_id": '$mRoomID',
                    // id nhóm chat
                    "target_ids": targetID,
                    "content": content,
                    "room_name": roomName,
                    "receiver_id": receiver_id
                    // chat user id của những người nhận hành động
                  }
                : {
                    "event": '$chatEvent',
                    "sender_id": '${accountModel.id}',
                    // chat user id của người thực hiện hành động
                    "sender_token": '${accountModel.token}',
                    "room_id": '$mRoomID',
                    // id nhóm chat
                    "target_ids": targetID,
                    "content": content
                    // chat user id của những người nhận hành động
                  };
    String jwt = await CacheHelper.getAccessToken();
    Map<String, String> _header = {
      "Authorization": "Bearer $jwt",
      "Content-Type": "application/json"
    };
    await Http.post(Constant.SERVER_BASE + "/api/fcm/notify",
            headers: _header, body: json.encode(_body))
        .then((rest) {
      if (rest.statusCode == 200) {
        return rest;
      }
      return null;
    }).catchError((onError) {
      return null;
    });
  }

  void sendMessageReactionFCM(
    List<String> target_ids,
    String room_id,
    Map options,
    bool isChatOneOne,
      String receiverId,
  ) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, dynamic> body;
    if(isChatOneOne){
      body = {
        "receiver_id":receiverId,
        "event": 'chat.reaction',
        "sender_id": '${accountModel.id}',
        "sender_token": '${accountModel.token}',
        "room_id": '$room_id',
        "target_ids": target_ids,
        "options": options
      };
    }else{
      body = {
        "event": 'chat.reaction',
        "sender_id": '${accountModel.id}',
        "sender_token": '${accountModel.token}',
        "room_id": '$room_id',
        "target_ids": target_ids,
        "options": options
      };
    }


    String jwt = await CacheHelper.getAccessToken();
    Map<String, String> _header = {
      "Authorization": "Bearer $jwt",
      "Content-Type": "application/json"
    };
    Http.Response response = await Http.post(Constant.SERVER_BASE + "/api/fcm/notify",
            headers: _header, body: json.encode(body))
        .then((rest) {
      if (rest.statusCode == 200) {
        return rest;
      }
      return null;
    }).catchError((onError) {
      return null;
    });
  }
}
