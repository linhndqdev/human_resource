import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';

class WebSocketRequest {
  static String requestConnect() {
    dynamic data = {
      "msg": "connect",
      "version": "1",
      "support": ["1"]
    };
    return jsonEncode(data);
  }

  static String loginAccessTokenMessage({@required String accessToken}) {
    dynamic data = {
      "msg": "method",
      "method": "login",
      "id": "42",
      "params": [
        {"resume": "$accessToken"}
      ]
    };
    return jsonEncode(data);
  }

  static String loginEmailPassMessage(
      {@required String userName, String pass}) {
    dynamic data = {
      "msg": "method",
      "method": "login",
      "id": "42",
      "params": [
        {
          "user": {"username": userName},/*$userName*/
          "password": "chat2020asgl"
        }
      ]
    };
    return jsonEncode(data);
  }

  static String getAllRoomMessage() {
    dynamic data = {
      "msg": "method",
      "method": "rooms/get",
      "id": "42",
      "params": [
        {"date": DateTime.now().millisecondsSinceEpoch}
      ]
    };
    return jsonEncode(data);
  }

  static String sendMessageToRoom({@required roomID, @required dynamic msg}) {
    dynamic data = {
      "msg": "method",
      "method": "sendMessage",
      "id": "42",
      "params": [
        {"rid": "$roomID", "msg": msg}
      ]
    };
    return jsonEncode(data);
  }

  static String subRoomByRoomIDMessage(
      {@required String roomID, @required String subID}) {
    dynamic data = {
      "msg": "sub",
      "id": "$subID",
      "name": "stream-room-messages",
      "params": ["$roomID", false]
    };
    return jsonEncode(data);
  }

  static String pongMessage() {
    dynamic data = {"msg": "pong"};
    return jsonEncode(data);
  }

  static String requestCreatePrivateRoom(
      String channelName, List<AddressBookModel> listUserInvited) {
    dynamic data;
    if (listUserInvited == null || listUserInvited.length == 0) {
      data = {
        "msg": "method",
        "method": "createPrivateGroup",
        "id": "89",
        "params": ["$channelName", []]
      };
    } else {
      List<String> userNames = List();
      listUserInvited?.forEach((user) {
        userNames.add(user.username);
      });
      data = {
        "msg": "method",
        "method": "createPrivateGroup",
        "id": "89",
        "params": ["$channelName", userNames]
      };
    }
    return jsonEncode(data);
  }

  static String requestSubUserStatus() {
    dynamic data = {
      "msg": "sub",
      "id": "subUserStatusID",
      "name": "stream-notify-logged",
      "params": ["user-status", false]
    };
    return jsonEncode(data);
  }

  static String requestSendTypingAction(
      {@required roomID, @required String userName, @required bool isTyping}) {
    dynamic data = {
      "msg": "method",
      "method": "stream-notify-room",
      "id": "42",
      "params": ["$roomID/typing", "$userName", isTyping]
    };
    return jsonEncode(data);
  }

  static String requestSubRoomEventTyping({@required String roomID}) {
    dynamic data = {
      "msg": "sub",
      "id": "42",
      "name": "stream-notify-room",
      "params": ["$roomID/typing", true]
    };
    return jsonEncode(data);
  }
}
