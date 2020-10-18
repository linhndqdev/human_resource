import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/core/fcm/fcm_services.dart';
import 'package:human_resource/core/message/message_action.dart';
import 'package:http/http.dart' as Http;
import 'package:human_resource/utils/common/const.dart';
import 'package:human_resource/utils/common/local_notification.dart';

import 'package:path/path.dart' as PathLib;
import 'package:dio/dio.dart' as Dio;
import 'package:http_parser/http_parser.dart';

class MessageServices extends MessageAction {
  WsRoomModel _roomModel;

  MessageServices setRoomModel({WsRoomModel roomModel}) {
    assert(roomModel != null, 'RoomModel of request is NULL or Empty');
    this._roomModel = roomModel;
    return this;
  }

  @override
  Future<void> sendFileMessage(
      {String filePath,
      @required String fullName,
      String senderUserName,
      OnResultData resultData,
      OnErrorApiCallback onErrorApiCallback,
      WsRoomModel roomModel}) async {
    File file = File(filePath);
    String fileName = PathLib.basename(file.path);
    String extension = PathLib.extension(file.path).replaceAll(".", "");
    String type;
    String subType;
    if (extension == "txt") {
      type = 'text';
      subType = 'plain';
    } else {
      type = 'application';
      subType = getRequestContentTypeFromExtensionFile(extension);
    }

    DateTime dateTime = DateTime.now();
    Dio.FormData formData = new Dio.FormData.fromMap({
      "file": new Dio.MultipartFile.fromBytes(file.readAsBytesSync(),
          filename: fileName, contentType: MediaType(type, subType))
    });
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    if (Platform.isIOS) {
      LocalNotification.getInstance().showNotificationSilent(
        dateTime.millisecond,
        "Đang tải lên: $fileName",
        "Vui lòng không tắt ứng dụng.",
      );
    }
    var resultResponse = await Dio.Dio().post(
        "${Constant.SERVER_BASE_CHAT}/api/v1/rooms.upload/${_roomModel.id}",
        data: formData,
        options: Dio.Options(headers: {
          'X-Auth-Token': accountModel.token,
          'X-User-Id': accountModel.id
        }), onSendProgress: (count, total) {
      if (Platform.isAndroid) {
        int percent = 0;
        if (total == 0) {
          percent = 1;
        } else {
          percent = ((count / total) * 100).round();
          if (percent < 1) {
            percent = 1;
          } else if (percent == 100) {
            percent = 99;
          }
        }
        LocalNotification.getInstance()
            .showUploadProcess(dateTime.millisecond, percent, fileName);
      }
    }).catchError((onError) {
      if (onError is Dio.DioError) {
        if (onError.error.toString().contains("Broken pipe")) {
          _showNotification(dateTime.millisecond, "Tải lên tập tin thất bại.",
              "Kết nối mạng quá yếu hoặc không ổn định. Vui lòng thử lại.");
        } else if (onError.error.toString().contains("SocketException")) {
          _showNotification(dateTime.millisecond, "Tải lên tập tin thất bại.",
              "Vui lòng kiểm tra kết nối mạng của bạn và thử lại.");
        } else {
          _showNotification(dateTime.millisecond, "Tải lên tập tin thất bại.",
              "Xảy ra lỗi khi tải lên tập tin $fileName. Vui lòng thử lại");
        }
      } else {
        _showNotification(dateTime.millisecond, "Tải lên tập tin thất bại.",
            "Xảy ra lỗi khi tải lên tập tin $fileName. Vui lòng thử lại");
      }
      onErrorApiCallback(ErrorType.OTHER_ERROR);
    });
    if (resultResponse != null) {
      if (resultResponse.statusCode == 200) {
        if (resultResponse.data != null &&
            resultResponse.data != "" &&
            resultResponse.data['success'].toString() == "true") {
          LocalNotification.getInstance()
              .clearNotification(dateTime.millisecond);
          LocalNotification.getInstance().showNotificationWithNoBody(
              "S-Connect",
              "Tải lên tập tin $fileName. thành công",
              dateTime.millisecond);
          FCMServices fcmServices = FCMServices();
          fcmServices.sendFCMNormalMessage(
              roomModel, "Đã gửi 1 tập tin đính kèm: $fileName");
          resultData(resultResponse);
        } else {
          _showNotification(dateTime.millisecond, "Tải lên tập tin thất bại.",
              "Xảy ra lỗi khi tải lên tập tin $fileName. Vui lòng thử lại");
        }
      } else {
        _showNotification(dateTime.millisecond, "Tải lên tập tin thất bại.",
            "Xảy ra lỗi khi tải lên tập tin $fileName. Vui lòng thử lại");
      }
    }
  }

  @override
  Future<void> sendImageMessage(
      {@required String imagePath,
      @required String fullName,
      String senderUserName,
      @required OnResultData resultData,
      @required OnErrorApiCallback onErrorApiCallback}) async {
    File file = File(imagePath);
    String fileName = PathLib.basename(file.path);
    String extension = PathLib.extension(file.path).replaceAll(".", "");

    DateTime dateTime = DateTime.now();
    Dio.FormData formData = new Dio.FormData.fromMap({
      "file": new Dio.MultipartFile.fromBytes(file.readAsBytesSync(),
          filename: fileName, contentType: MediaType("image", extension))
    });
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    if (Platform.isIOS) {
      LocalNotification.getInstance().showNotificationSilent(
        dateTime.millisecond,
        "Đang tải lên: $fileName",
        "Vui lòng không tắt ứng dụng.",
      );
    }
    var resultResponse = await Dio.Dio().post(
        "${Constant.SERVER_BASE_CHAT}/api/v1/rooms.upload/${_roomModel.id}",
        data: formData,
        options: Dio.Options(headers: {
          'X-Auth-Token': accountModel.token,
          'X-User-Id': accountModel.id
        }), onSendProgress: (count, total) {
      if (Platform.isAndroid) {
        int percent = 0;
        if (total == 0) {
          percent = 1;
        } else {
          percent = ((count / total) * 100).round();
          if (percent < 1) {
            percent = 1;
          } else if (percent == 100) {
            percent = 99;
          }
        }
        LocalNotification.getInstance()
            .showUploadProcess(dateTime.millisecond, percent, fileName);
      }
    }).then((resultResponse) {
      if (resultResponse != null) {
        if (resultResponse.statusCode == 200) {
          return resultResponse;
        } else {
          _showNotification(dateTime.millisecond, "Tải ảnh thất bại.",
              "Xảy ra lỗi khi tải lên $fileName. Vui lòng thử lại");
          return null;
        }
      }
      _showNotification(dateTime.millisecond, "Tải ảnh thất bại.",
          "Xảy ra lỗi khi tải lên $fileName. Vui lòng thử lại");
      return null;
    }).catchError((onError) {
      _showNotification(dateTime.millisecond, "Tải ảnh thất bại.",
          "Xảy ra lỗi khi tải lên $fileName. Vui lòng thử lại");
      return null;
    });
    if (resultResponse != null) {
      if (resultResponse.data != null &&
          resultResponse.data != "" &&
          resultResponse.data['success'].toString() == "true") {
        _showNotification(dateTime.millisecond, "Tải ảnh hoàn tất",
            "Tải lên $fileName. thành công");
        FCMServices fcmServices = FCMServices();
        fcmServices.sendFCMNormalMessage(_roomModel, "Đã gửi 1 hình ảnh");
        resultData(resultResponse);
      } else {
        _showNotification(dateTime.millisecond, "Tải ảnh thất bại.",
            "Xảy ra lỗi khi tải lên $fileName. Vui lòng thử lại");
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
    }
  }

  void _showNotification(int notificationID, String title, String body) {
    LocalNotification.getInstance().clearNotification(notificationID);
    LocalNotification.getInstance()
        .showNotificationWithNoBody(title, body, notificationID);
  }

  @override
  Future<void> sendTextMessage(
      {String message,
      OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback,
      WsRoomModel roomModel}) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
      "Content-type": "application/json"
    };
    Map<String, dynamic> body = {
      "message": {
        "rid": "${this._roomModel.id}",
        "msg": "$message",
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
        FCMServices fcmServices = FCMServices();
        fcmServices.sendFCMNormalMessage(roomModel, message);
      } else {
        String error = data['error'];
        if (error != null && error != "") {
          onErrorApiCallback(error);
        } else {
          onErrorApiCallback(ErrorModel.otherError);
        }
      }
    }
  }

  String getRequestContentTypeFromExtensionFile(String extension) {
    if (extension == "rar") {
      return 'x-rar-compressed';
    } else if (extension == "zip") {
      return 'zip';
    } else if (extension == "pdf") {
      return 'pdf';
    } else if (extension == "doc" || extension == "dot") {
      return 'msword';
    } else if (extension == 'docx') {
      return 'vnd.openxmlformats-officedocument.wordprocessingml.document';
    } else if (extension == 'ppt' ||
        extension == "pot" ||
        extension == "pps" ||
        extension == "ppa") {
      return 'vnd.ms-powerpoint';
    } else if (extension == 'pptx') {
      return 'vnd.openxmlformats-officedocument.presentationml.presentation';
    } else if (extension == 'xls' || extension == 'xlt' || extension == 'xla') {
      return 'vnd.ms-excel';
    } else if (extension == 'xlsx') {
      return 'vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    } else
      return '';
  }

  Future<Map<RoomType, List<UnReadCountModel>>> getAllUnReadMessage() async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Http.Response response = await Http.get(
        Constant.SERVER_BASE_CHAT + "/api/v1/subscriptions.get",
        headers: {
          "X-User-Id": "${accountModel.id}",
          "X-Auth-Token": "${accountModel.token}",
          "Content-type": "application/json",
        }).then((res) {
      if (res.statusCode == 200) {
        return res;
      } else {
        return null;
      }
    }).catchError((onError) {
      return null;
    }).timeout(Duration(seconds: 10), onTimeout: () {
      return null;
    });
    if (response != null && response.body != null) {
      try {
        dynamic data = json.decode(response.body.toString());
        if (data['success'] != null &&
            data['success'].toString() == "true" &&
            data['update'] != null &&
            data['update'] != "") {
          Iterable i = data['update'];
          Map<RoomType, List<UnReadCountModel>> mapModel = Map();
          mapModel[RoomType.d] = List<UnReadCountModel>();
          mapModel[RoomType.p] = List<UnReadCountModel>();
          i?.forEach((dynamic model) {
            UnReadCountModel unReadCountModel =
                UnReadCountModel.fromJson(model);
            if (unReadCountModel.t == "p") {
              if (unReadCountModel.roomName != Const.BAN_TIN &&
                  unReadCountModel.roomName != Const.FAQ &&
                  !unReadCountModel.roomName.contains(Const.THONG_BAO)) {
                mapModel[RoomType.p].add(unReadCountModel);
              }
            } else if (unReadCountModel.t == "d") {
              mapModel[RoomType.d].add(unReadCountModel);
            }
          });
          return mapModel;
        } else {
          return Map();
        }
      } catch (ex) {
        return Map();
      }
    } else {
      return Map();
    }
  }
}

class UnReadCountModel {
  String roomName;
  String rid;
  int unreadCount;
  String t;

  UnReadCountModel(this.roomName, this.rid, this.unreadCount, this.t);

  factory UnReadCountModel.fromJson(Map<String, dynamic> json) {
    return UnReadCountModel(
        json['name'], json['rid'], json['unread'], json['t']);
  }
}
