import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/core/fcm/fcm_services.dart';
import 'package:human_resource/core/room_chat/room_chat_action.dart';
import 'package:http/http.dart' as Http;
import 'package:human_resource/utils/common/local_notification.dart';
import 'package:path/path.dart' as PathLib;
import 'package:dio/dio.dart' as Dio;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class RoomChatServices extends RoomChatAction {
  @override
  Future<void> closeDirectMessage(
      {String roomID, resultData, onErrorApiCallback}) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
      "Content-type": "application/json",
    };
    Map<String, String> _body = {"roomId": "$roomID"};
    Http.Response response = await Http.post(Constant.SERVER_BASE_CHAT + "/api/v1/im.close",
            headers: _header, body: json.encode(_body))
        .then((res) {
      return res;
    }).catchError((onError) {
      if (onError.toString().contains("SocketException")) {
        onErrorApiCallback(ErrorType.CONNECTION_ERROR);
      } else {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
      return null;
    }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
      onErrorApiCallback(ErrorType.OTHER_ERROR);
      return null;
    });
    if (response != null && response.body != null) {
      dynamic data = json.decode(response.body);
      if (data['success'] != null && data['success'].toString() == "true") {
        resultData(data);
      } else {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
    }
  }

  Future<void> getCounts(
      {String roomID, resultData, onErrorApiCallback}) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
      "Content-type": "application/json",
    };
    Map<String, String> _body = {"roomId": "$roomID"};
    Uri uri = Uri.https(Constant.SERVER_CHAT_NO_HTTP, "api/v1/groups.counters", _body);
    Http.Response response = await Http.get(uri, headers: _header).then((res) {
      return res;
    }).catchError((onError) {
      if (onError.toString().contains("SocketException")) {
        onErrorApiCallback(ErrorType.CONNECTION_ERROR);
      } else {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
      return null;
    }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
      onErrorApiCallback(ErrorType.OTHER_ERROR);
      return null;
    });
    if (response != null && response.body != null && response.body != "") {
      try {
        dynamic data = json.decode(response.body);
        if (data['success'] != null && data['success'].toString() == "true") {
          resultData(data);
        } else {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
        }
      } catch (ex) {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
    } else {
      onErrorApiCallback(ErrorType.OTHER_ERROR);
    }
  }

  @override
  Future<void> uploadAvatar(
      {String imgUrl,
      String currentUserName,
      resultData,
      onErrorApiCallback,
      BuildContext context}) async {
    File file = File(imgUrl);
    String fileName = PathLib.basename(file.path);
    String extension = PathLib.extension(file.path).replaceAll(".", "");

    DateTime dateTime = DateTime.now();
    Dio.FormData formData = new Dio.FormData.fromMap({
      "image": new Dio.MultipartFile.fromBytes(file.readAsBytesSync(),
          filename: fileName, contentType: MediaType("image", extension))
    });
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    _showNotification(
      dateTime.millisecond,
      "Đang cập nhật ảnh đại diện...",
      "Vui lòng không tắt ứng dụng.",
    );
    var resultResponse = await Dio.Dio()
        .post("${Constant.SERVER_BASE_CHAT}/api/v1/users.setAvatar",
            data: formData,
            options: Dio.Options(headers: {
              'X-Auth-Token': accountModel.token,
              'X-User-Id': accountModel.id
            }))
        .then((resultResponse) {
      if (resultResponse != null) {
        if (resultResponse.statusCode == 200) {
          DefaultCacheManager manager = new DefaultCacheManager();
          try {
            manager.removeFile(
                "${Constant.SERVER_BASE_CHAT}/avatar/$currentUserName");
          } catch (ex) {} // data in cache.
          return resultResponse;
        } else {
          _showNotification(
              dateTime.millisecond,
              "Cập nhật ảnh đại diện thất bại.",
              "Xảy ra lỗi khi cập nhật ảnh đại diện. Vui lòng thử lại");
          onErrorApiCallback(ErrorType.OTHER_ERROR);
          return null;
        }
      } else {
        _showNotification(
            dateTime.millisecond,
            "Cập nhật ảnh đại diện thất bại.",
            "Xảy ra lỗi khi cập nhật ảnh đại diện. Vui lòng thử lại");
        onErrorApiCallback(ErrorType.OTHER_ERROR);
        return null;
      }
    }).catchError((onError) {
      _showNotification(dateTime.millisecond, "Cập nhật ảnh đại diện thất bại.",
          "Xảy ra lỗi khi cập nhật ảnh đại diện. Vui lòng thử lại");
      onErrorApiCallback(ErrorType.OTHER_ERROR);
      return null;
    });
    if (resultResponse != null) {
      if (resultResponse.data != null &&
          resultResponse.data != "" &&
          resultResponse.data['success'].toString() == "true") {
        _showNotification(dateTime.millisecond, "S-Connect",
            "Cập nhật ảnh đại diện hoàn tất.");
        resultData(resultResponse);
      } else {
        _showNotification(
            dateTime.millisecond,
            "Cập nhật ảnh đại diện thất bại.",
            "Xảy ra lỗi khi cập nhật ảnh đại diện. Vui lòng thử lại");
      }
    }
  }

  void _showNotification(int notificationID, String title, String body) {
    LocalNotification.getInstance().clearNotification(notificationID);
    LocalNotification.getInstance()
        .showNotificationWithNoBody(title, body, notificationID);
  }

  @override
  Future<void> leaveGroup(
      {String groupID, onResultData, onErrorApiCallback}) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
      "Content-type": "application/json",
    };
    Map<String, String> _body = {"roomId": "$groupID"};
    Http.Response response = await Http.post(Constant.SERVER_BASE_CHAT + "/api/v1/groups.leave",
            headers: _header, body: json.encode(_body))
        .then((res) {
      return res;
    }).catchError((onError) {
      if (onError.toString().contains("SocketException")) {
        onErrorApiCallback(ErrorType.CONNECTION_ERROR);
      } else {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
      return null;
    }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
      onErrorApiCallback(ErrorType.OTHER_ERROR);
      return null;
    });
    if (response != null && response.body != null) {
      dynamic data = json.decode(response.body);
      if (data['success'] != null && data['success'].toString() == "true") {
        onResultData(data);
      } else {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
    }
  }

  @override
  Future<void> removeGroup(
      {String groupID, onResultData, onErrorApiCallback}) async {}

  Future<void> getRoomInfo(WsRoomModel roomModel, WsAccountModel accountModel,
      OnResultData resultData, OnErrorApiCallback onErrorApiCallback) async {
    Map<String, String> _header = {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
    };
    Map<String, String> _params = {
      "roomId": "${roomModel.id}",
    };

    Uri uri = Uri.https(Constant.SERVER_CHAT_NO_HTTP, "api/v1/groups.info", _params);
    Http.Response response = await Http.get(uri, headers: _header).then((res) {
      return res;
    }).catchError((onError) {
      if (onError.toString().contains("SocketException")) {
        onErrorApiCallback(ErrorType.CONNECTION_ERROR);
      } else {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
      return null;
    }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
      onErrorApiCallback(ErrorType.OTHER_ERROR);
      return null;
    });
    if (response != null && response.body != null && response.body != "") {
      try {
        dynamic data = json.decode(response.body);
        if (data['success'] != null && data['success'].toString() == "true") {
          resultData(data);
        } else {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
        }
      } catch (ex) {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
    } else {
      onErrorApiCallback(ErrorType.OTHER_ERROR);
    }
  }

  @override
  Future<void> deleteGroup(
      {String groupID,
      WsAccountModel accountModel,
      onResultData,
      onErrorApiCallback}) async {
    Map<String, String> _header = {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
      "Content-type": "application/json"
    };
    Map<String, String> _params = {
      "roomId": "$groupID",
    };
    Http.Response response = await Http.post(Constant.SERVER_BASE_CHAT + "/api/v1/groups.delete",
            headers: _header, body: jsonEncode(_params))
        .then((res) {
      return res;
    }).catchError((onError) {
      onErrorApiCallback(ErrorType.OTHER_ERROR);
      return null;
    }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
      onErrorApiCallback(ErrorType.OTHER_ERROR);
      return null;
    });
    if (response != null && response.body != null) {
      dynamic data = json.decode(response.body);
      if (data['success'] != null && data['success'].toString() == "true") {
        onResultData(data);
      } else {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
    }
  }

  Future<void> swapOwnerGroup(
      {String groupID,
      String receivedOwnerUserID,
      WsAccountModel accountModel,
      onResultData,
      onErrorApiCallback}) async {
    Map<String, String> _header = {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
      "Content-type": "application/json"
    };
    Map<String, String> _params = {
      "roomId": "$groupID",
      "userId": "$receivedOwnerUserID",
    };
    Http.Response response = await Http.post(
            Constant.SERVER_BASE_CHAT + "/api/v1/groups.addOwner",
            headers: _header,
            body: jsonEncode(_params))
        .then((res) {
      return res;
    }).catchError((onError) {
      onErrorApiCallback(ErrorType.OTHER_ERROR);
      return null;
    }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
      onErrorApiCallback(ErrorType.OTHER_ERROR);
      return null;
    });
    if (response != null && response.body != null) {
      dynamic data = json.decode(response.body);
      if (data['success'] != null && data['success'].toString() == "true") {
        onResultData(data);
      } else {
        onErrorApiCallback(data);
      }
    }
  }

  Future<void> getUserRoles(WsAccountModel accountModel, String roomID,
      OnResultData onResultData, OnErrorApiCallback onErrorApiCallback) async {
    Map<String, String> _header = {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
    };
    Map<String, String> _params = {
      "roomId": "$roomID",
    };
    Uri uri = Uri.https(Constant.SERVER_CHAT_NO_HTTP, "api/v1/groups.roles", _params);
    Http.Response response = await Http.get(uri, headers: _header).then((res) {
      return res;
    }).catchError((onError) {
      onErrorApiCallback(ErrorType.OTHER_ERROR);
      return null;
    }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
      onErrorApiCallback(ErrorType.OTHER_ERROR);
      return null;
    });
    if (response != null && response.body != null) {
      dynamic data = json.decode(response.body);
      if (data['success'] != null && data['success'].toString() == "true") {
        onResultData(data);
      } else {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
    }
  }
}