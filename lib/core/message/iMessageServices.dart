import 'dart:convert';

import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/core/fcm/fcm_services.dart';
import 'package:human_resource/core/message/imessage_action.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/common/cache_helper.dart';
import 'package:http/http.dart' as Http;
import 'package:human_resource/utils/common/toast.dart';

class IMessageServices extends IMessageAction {
  @override
  Future<void> detectImageToText(String imageFileID, OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt == null || jwt == "") {
      onErrorApiCallback(ErrorType.JWT_FOUND);
    } else {
      Map<String, String> _body = {"img": "$imageFileID"};
      Http.Response response =
          await Http.post(Constant.SERVER_BASE + "/api/support/image-to-text",
                  headers: {
                    "Authorization": "Bearer $jwt",
                    "Content-Type": "application/x-www-form-urlencoded"
                  },
                  body: _body)
              .then((res) {
        if (res != null && res.statusCode == 200) {
          return res;
        } else {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
          return null;
        }
      }).catchError((onError) {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
        return null;
      });
      if (response != null && response.body != null) {
        try {
          dynamic data = json.decode(response.body);
          onResultData(data);
        } catch (ex) {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
        }
      }
    }
  }

  @override
  Future<void> sendMessageWithAction(
      {MessageActionsModel messageActionsModel,
      String userQuoteID = "",
      WsRoomModel roomModel,
      OnResultData onResultData,
      OnResultData onErrorApiCallback}) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
      "Content-type": "application/json"
    };
    Map<String, dynamic> body = {
      "message": {
        "rid": "${roomModel.id}",
        "msg": "${jsonEncode(messageActionsModel)}",
      }
    };
    Http.Response response = await Http.post(
            "${Constant.SERVER_BASE_CHAT}/api/v1/chat.sendMessage",
            headers: _header,
            body: json.encode(body))
        .then((response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        return null;
      } else {
        return response;
      }
    }).catchError((onError) {
      if (onError.toString().contains("SocketException")) {
        onErrorApiCallback(ErrorModel.netError);
      }
      return null;
    }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
      onErrorApiCallback(ErrorModel.netError);
      return null;
    });
    if (response != null && response.body != null) {
      dynamic data = jsonDecode(response.body.toString());
      if (data['success'] != null && data['success'].toString() == 'true') {
        onResultData(data);
        _sendFCMNotification(roomModel, messageActionsModel,
            userQuoteID: userQuoteID, roomID: "", receiver_id: "");
      } else {
        if (data['error'] != null && data['error'] != "") {
          onErrorApiCallback(data['error']);
        } else {
          onErrorApiCallback(ErrorModel.otherError);
        }
      }
    }
  }

  Future<void> revokeMessage(
      {MessageActionsModel messageActionsModel,
      String roomId,
      String msgId,
      OnResultData onResultData,
      OnResultData onErrorApiCallback}) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
      "Content-type": "application/json"
    };
    Map<String, dynamic> body = {
      "roomId": "$roomId",
      "msgId": "$msgId",
      "text": "${json.encode(messageActionsModel)}",
    };
    Http.Response response = await Http.post(
            "${Constant.SERVER_BASE_CHAT}/api/v1/chat.update",
            headers: _header,
            body: json.encode(body))
        .then((response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        return null;
      } else {
        return response;
      }
    }).catchError((onError) {
      if (onError.toString().contains("SocketException")) {
        onErrorApiCallback(ErrorModel.netError);
      }
      return null;
    }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
      onErrorApiCallback(ErrorModel.netError);
      return null;
    });
    if (response != null && response.body != null) {
      dynamic data = jsonDecode(response.body.toString());
      if (data['success'] != null && data['success'].toString() == 'true') {
        onResultData(data);
      } else {
        onErrorApiCallback(ErrorModel.otherError);
      }
    }
  }

  void _sendFCMNotification(
      WsRoomModel roomModel, MessageActionsModel messageActionsModel,
      {String userQuoteID = "",
      bool isRequestBodyRoomName = false,
      String roomID = "",
      String receiver_id = ""}) {
    String event = "";
    if (messageActionsModel.actionType == ActionType.QUOTE) {
      event = "chat.quote";
    } else if (messageActionsModel.actionType == ActionType.MENTION) {
      event = "chat.tag";
    } else if (messageActionsModel.actionType == ActionType.FORWARD) {
      event = "chat.share";
    }
    FCMServices fcmServices = FCMServices();
    fcmServices.sendMessageActionFCM(roomModel, messageActionsModel, event,
        userQuoteID: userQuoteID,
        isRequestBodyWithRoomName: isRequestBodyRoomName,
        receiver_id: receiver_id,
        roomID: roomID);
  }

  //Gửi tin nhắn forward đển các group
  @override
  Future<void> sendMessageForwardToGroup(
      {MessageActionsModel messageActionsModel,
      WsRoomModel roomModel,
      WsAccountModel accountModel,
      OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback,
      bool isRequestBodyRoomName = false,
      String roomID = ""}) async {
    String mRoomID = roomID != "" ? roomID : roomModel.id;
    Map<String, String> _header = {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
      "Content-type": "application/json"
    };
    Map<String, dynamic> body = {
      "message": {
        "rid": "$mRoomID",
        "msg": "${jsonEncode(messageActionsModel)}",
      }
    };
    Http.Response response = await Http.post(
            "${Constant.SERVER_BASE_CHAT}/api/v1/chat.sendMessage",
            headers: _header,
            body: json.encode(body))
        .then((response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        return null;
      } else {
        return response;
      }
    }).catchError((onError) {
      if (onError.toString().contains("SocketException")) {
        onErrorApiCallback(ErrorModel.netError);
      }
      return null;
    }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
      onErrorApiCallback(ErrorModel.netError);
      return null;
    });
    if (response != null && response.body != null) {
      dynamic data = jsonDecode(response.body.toString());
      if (data['success'] != null && data['success'].toString() == 'true') {
        onResultData(data);
        String receiverID = "";
        if (mRoomID != "" && mRoomID.contains(accountModel.id)) {
          receiverID = mRoomID.replaceAll(accountModel.id, "");
        }
        _sendFCMNotification(roomModel, messageActionsModel,
            userQuoteID: "",
            isRequestBodyRoomName: isRequestBodyRoomName,
            receiver_id: receiverID,
            roomID: mRoomID);
      } else {
        onErrorApiCallback(ErrorModel.otherError);
      }
    }
  }

  void sendMessageForwardToUser(
      {ASGUserModel userModel,
      MessageActionsModel messageActionsModel,
      WsAccountModel accountModel,
      bool isRequestBodyRoomName}) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      'X-Auth-Token': '${accountModel.token}',
      'X-User-Id': '${accountModel.id}',
      'Content-type': 'application/json',
    };
    Map<String, dynamic> _body = {"username": "${userModel.username}"};
    Http.Response _response = await Http.post(
            Constant.SERVER_BASE_CHAT + "/api/v1/im.create",
            headers: _header,
            body: json.encode(_body))
        .then((response) {
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
    if (_response != null) {
      if (_response.bodyBytes != null && _response.bodyBytes.length > 0) {
        dynamic data = json.decode(utf8.decode(_response.bodyBytes));
        if (data != null && data != "") {
          try {
            String roomID = data['room']['_id'];
            sendMessageForwardToGroup(
                isRequestBodyRoomName: false,
                roomID: roomID,
                accountModel: accountModel,
                messageActionsModel: messageActionsModel,
                onResultData: (result) {},
                onErrorApiCallback: (onError) {});
          } catch (ex) {}
        }
      }
    }
  }

  void updateMessage(
      {WsMessage message,
      WsRoomModel roomModel,
      OnResultData resultData,
      OnErrorApiCallback onErrorApiCallback}) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      'X-Auth-Token': '${accountModel.token}',
      'X-User-Id': '${accountModel.id}',
      'Content-type': 'application/json',
    };
    Map<String, dynamic> _body = {
      "roomId": "${roomModel.id}",
      "msgId": "${message.id}",
      "text": jsonEncode(message.messageActionsModel)
    };
    Http.Response _response = await Http.post(
            Constant.SERVER_BASE_CHAT + "/api/v1/chat.update",
            headers: _header,
            body: json.encode(_body))
        .then((response) {
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
    if (_response != null) {
      if (_response.bodyBytes != null && _response.bodyBytes.length > 0) {
        dynamic data = json.decode(utf8.decode(_response.bodyBytes));
        if (data != null &&
            data != "" &&
            data['success'] != null &&
            data['success'].toString() == "true") {
          Toast.showShort("Chỉnh sửa nội dung tin nhắn thành công.");
        } else {
          if (data['error'] != null && data['error'] != "") {
            onErrorApiCallback(data['error']);
          }
        }
      }
    }
  }

  Future<void> reactionMessage(
      WsRoomModel roomModel,
      WsMessage message,
      OnResultData resultData,
      OnErrorApiCallback onErrorApiCallback,
      String reactIconName,
      bool shouldReact) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    String emojj;
    switch (reactIconName) {
      case ":s_like:":
        emojj = "👍";
        break;
      case ":s_dislike:":
        emojj = "👎";
        break;
      case ":s_heart:":
        emojj = "❤️";
        break;
      case ":s_ok:":
        emojj = "🆗";
        break;
      case ":s_no:":
        emojj = "❌";
        break;
    }

    Map<String, String> mapOption = {
      "emoji": emojj,
    };

    Map<String, String> _header = {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
      "Content-type": "application/json"
    };
    String reactName = reactIconName.replaceAll(":", "");
    Map<String, dynamic> _body = {
      "messageId": "${message.id}",
      "emoji": reactName,
      "shouldReact": shouldReact,
    };

    Http.Response response = await Http.post(
            Constant.SERVER_BASE_CHAT + "/api/v1/chat.react",
            headers: _header,
            body: jsonEncode(_body))
        .then((res) {
      if (res.statusCode == 200) {
        return res;
      }
      return null;
    }).catchError((onError) {
      onErrorApiCallback(onError);
      return null;
    }).timeout(Duration(seconds: 60), onTimeout: () {
      onErrorApiCallback(ErrorType.TIME_OUT);
      return null;
    });
    if (response != null && response.body != null) {
      dynamic data = json.decode(response.body);
      if (data['success'] == true) {
        if (shouldReact) {
          //gửi notification
          FCMServices fcmServices = FCMServices();
          fcmServices.sendMessageReactionFCM(
              [message.skAccountModel.id],
              roomModel.id,
              mapOption,
              roomModel.roomType == RoomType.d,
              message.skAccountModel.id);
        }
      } else {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
    }
  }
}
