import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/constant.dart';

import 'package:human_resource/utils/common/cache_helper.dart';
import 'package:http/http.dart' as Http;
import 'package:human_resource/utils/widget/dialog_utils.dart';

///Ngày khởi tạo: [Thứ bảy, 08-02-2020]
///Người tạo [Nguyễn Hữu Bình]

///[ErrorType] => return type of error if call api failed
///[ErrorType.JWT_FOUND] => Không có JWT
///[ErrorType.TIME_OUT] => Hết thời gian chờ kết quả: 12s
///[ErrorType.RESPONSE_STATUS_FAILED] => Response status code != 200
///[ErrorType.CONNECTION_ERROR] => Kết nối trả về lỗi có SocketException
///[ErrorType.OTHER_ERROR] => Các lỗi khác có thể xảy ra
///[ErrorType.RESPONSE_BODY_NULL] => Request thành công nhưng không có body data
///[ErrorType.DATA_ERROR] =>Lỗi nếu status != true && code !="00"
///[ErrorType.CONVERT_DATA_ERROR] =>Lỗi nếu convert dữ liệu từ json -> model bị lỗi

enum ErrorType {
  JWT_FOUND,
  TIME_OUT,
  RESPONSE_STATUS_FAILED,
  CONNECTION_ERROR,
  OTHER_ERROR,
  RESPONSE_BODY_NULL,
  DATA_ERROR,
  CONVERT_DATA_ERROR,
  UNAUTHORIZED
}

typedef OnErrorApiCallback<T> = Function(T);
typedef OnResultData<T> = Function(T);

const int TIME_OUT = 60;

class ApiServices {
  ///[_getError] => Trả về nội dung của lỗi nếu có trong respone nhận được từ server
  ///[data] => Json được convert từ response.body
  String _getError(Map<String, dynamic> data) {
    String message = "";
    if (data['errors'] != null && data['errors'] != "") {
      message = data['errors'];
    } else if (data['message'] != null && data['message'] != "") {
      message = data['message'];
    }
    return message;
  }

  //https://chatplatform.asgl.net.vn/api/v1/users.list?query={ "$or": [ {"status": "online"}, {"status": "busy"},{"status": "away"} ] }&count=9999&sort={"name":1}
  Future<void> getAllUserNotOfLine(
      {@required OnResultData onResultData,
      WsAccountModel accountModel,
      @required OnErrorApiCallback onErrorApiCallback}) async {
    Uri uri = Uri.https(Constant.SERVER_CHAT_NO_HTTP, "api/v1/users.list", {
      "query": json.encode({
        "\$or": [
          {"status": "online"},
          {"status": "busy"},
          {"status": "away"}
        ]
      }),
      "count": "9999",
      "sort": json.encode({"name": 1})
    });
    if (accountModel == null) {
      accountModel = WebSocketHelper.getInstance().wsAccountModel;
    }
    Http.Response _response = await Http.get(uri, headers: {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
    }).then((response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        onErrorApiCallback(ErrorModel(
            errorType: ErrorType.RESPONSE_STATUS_FAILED,
            errorMessage: "",
            isUsedTryIt: false));
        return null;
      } else {
        return response;
      }
    }).catchError((onError) {
      if (onError.toString().contains("SocketException")) {
        onErrorApiCallback(ErrorModel(
            errorType: ErrorType.CONNECTION_ERROR, isUsedTryIt: false));
      }
      return null;
    }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
      onErrorApiCallback(
          ErrorModel(errorType: ErrorType.TIME_OUT, isUsedTryIt: false));
      return null;
    });
    if (_response != null) {
      if (_response.bodyBytes != null && _response.bodyBytes.length > 0) {
        dynamic data = json.decode(utf8.decode(_response.bodyBytes));
        if (data != null && data != "") {
          try {
            onResultData(data['users']);
          } catch (ex) {
            onErrorApiCallback(ErrorModel(
                errorType: ErrorType.CONVERT_DATA_ERROR,
                errorMessage: "",
                isUsedTryIt: false));
          }
        } else {
          String message = _getError(data);
          onErrorApiCallback(ErrorModel(
              errorType: ErrorType.DATA_ERROR,
              errorMessage: message,
              isUsedTryIt: false));
        }
      } else {
        onErrorApiCallback(ErrorModel(
            errorType: ErrorType.RESPONSE_BODY_NULL,
            errorMessage: "",
            isUsedTryIt: false));
      }
    }
  }

  Future<void> getAllUserOnSystem(
      {@required OnResultData onResultData,
      WsAccountModel accountModel,
      @required OnErrorApiCallback onErrorApiCallback}) async {
    Uri uri = Uri.https(
        Constant.SERVER_CHAT_NO_HTTP, "api/v1/users.list", {"count": "9999"});
    if (accountModel == null) {
      accountModel = WebSocketHelper.getInstance().wsAccountModel;
    }
    Http.Response _response = await Http.get(uri, headers: {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
    }).then((response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        onErrorApiCallback(ErrorModel(
            errorType: ErrorType.RESPONSE_STATUS_FAILED,
            errorMessage: "",
            isUsedTryIt: false));
        return null;
      } else {
        return response;
      }
    }).catchError((onError) {
      if (onError.toString().contains("SocketException")) {
        onErrorApiCallback(ErrorModel(
            errorType: ErrorType.CONNECTION_ERROR, isUsedTryIt: false));
      }
      return null;
    }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
      onErrorApiCallback(
          ErrorModel(errorType: ErrorType.TIME_OUT, isUsedTryIt: false));
      return null;
    });
    if (_response != null) {
      if (_response.bodyBytes != null && _response.bodyBytes.length > 0) {
        dynamic data = json.decode(utf8.decode(_response.bodyBytes));
        if (data != null && data != "") {
          try {
            onResultData(data['users']);
          } catch (ex) {
            onErrorApiCallback(ErrorModel(
                errorType: ErrorType.CONVERT_DATA_ERROR,
                errorMessage: "",
                isUsedTryIt: false));
          }
        } else {
          String message = _getError(data);
          onErrorApiCallback(ErrorModel(
              errorType: ErrorType.DATA_ERROR,
              errorMessage: message,
              isUsedTryIt: false));
        }
      } else {
        onErrorApiCallback(ErrorModel(
            errorType: ErrorType.RESPONSE_BODY_NULL,
            errorMessage: "",
            isUsedTryIt: false));
      }
    }
  }

  Future<void> createDirectRoom(String username,
      {@required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback}) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      'X-Auth-Token': '${accountModel.token}',
      'X-User-Id': '${accountModel.id}',
      'Content-type': 'application/json',
    };
    Map<String, dynamic> _body = {"username": "$username"};
    Http.Response _response = await Http.post(
            Constant.SERVER_BASE_CHAT + "/api/v1/im.create",
            headers: _header,
            body: json.encode(_body))
        .then((response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        onErrorApiCallback(ErrorModel(
            errorType: ErrorType.RESPONSE_STATUS_FAILED,
            errorMessage: "",
            isUsedTryIt: false));
        return null;
      } else {
        return response;
      }
    }).catchError((onError) {
      if (onError.toString().contains("SocketException")) {
        onErrorApiCallback(ErrorModel(
            errorType: ErrorType.CONNECTION_ERROR,
            errorMessage: "",
            isUsedTryIt: false));
      }
      return null;
    }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
      onErrorApiCallback(ErrorModel(
          errorType: ErrorType.TIME_OUT, errorMessage: "", isUsedTryIt: false));
      return null;
    });
    if (_response != null) {
      if (_response.bodyBytes != null && _response.bodyBytes.length > 0) {
        dynamic data = json.decode(utf8.decode(_response.bodyBytes));
        if (data != null && data != "") {
          try {
            onResultData(data);
          } catch (ex) {
            onErrorApiCallback(ErrorModel(
                errorType: ErrorType.CONVERT_DATA_ERROR,
                errorMessage: "",
                isUsedTryIt: false));
          }
        } else {
          String message = _getError(data);
          onErrorApiCallback(ErrorModel(
              errorType: ErrorType.DATA_ERROR,
              errorMessage: message,
              isUsedTryIt: false));
        }
      } else {
        onErrorApiCallback(ErrorModel(
            errorType: ErrorType.RESPONSE_BODY_NULL,
            errorMessage: "",
            isUsedTryIt: false));
      }
    }
  }

  //Lấy về thông tin user theo user name
  Future<void> getUserInfo(
      {@required userName,
      @required OnResultData<RestUserModel> onResultData,
      @required OnErrorApiCallback onErrorApiCallback,
      WsAccountModel currentUser}) async {
    Map<String, String> querry = {'username': '$userName'};
    Uri uri =
        Uri.https(Constant.SERVER_CHAT_NO_HTTP, "api/v1/users.info", querry);
    WsAccountModel accountModel =
        currentUser ?? WebSocketHelper.getInstance().wsAccountModel;
    Http.Response response = await Http.get(uri, headers: {
      'X-Auth-Token': '${accountModel.token}',
      'X-User-Id': '${accountModel.id}'
    }).then((Http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        onErrorApiCallback(ErrorModel(
            errorType: ErrorType.RESPONSE_STATUS_FAILED,
            errorMessage: "",
            isUsedTryIt: false));
        return null;
      } else {
        return response;
      }
    }).catchError((onError) {
      if (onError.toString().contains("SocketException")) {
        onErrorApiCallback(ErrorModel(
            errorType: ErrorType.CONNECTION_ERROR, isUsedTryIt: false));
      }
      return null;
    }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
      onErrorApiCallback(
          ErrorModel(errorType: ErrorType.TIME_OUT, isUsedTryIt: false));
      return null;
    });
    if (response != null) {
      if (response.bodyBytes != null && response.bodyBytes.length > 0) {
        dynamic data = json.decode(utf8.decode(response.bodyBytes));
        if (data != null && data != "") {
          if (data['success']?.toString() == "true") {
            try {
              RestUserModel restUserModel =
                  RestUserModel.fromGetAllUser(data['user']);
              onResultData(restUserModel);
            } catch (ex) {
              onErrorApiCallback(ErrorModel(
                  errorType: ErrorType.CONVERT_DATA_ERROR,
                  errorMessage: "",
                  isUsedTryIt: false));
            }
          } else {
            String message = _getError(data);
            onErrorApiCallback(ErrorModel(
                errorType: ErrorType.DATA_ERROR,
                errorMessage: message,
                isUsedTryIt: false));
          }
        } else {
          onErrorApiCallback(ErrorModel(
              errorType: ErrorType.RESPONSE_BODY_NULL,
              errorMessage: "",
              isUsedTryIt: false));
        }
      }
    }
  }

  Future<void> createPrivateGroup(
      {@required String channelName,
      List<String> listMember,
      OnResultData resultData,
      OnErrorApiCallback onErrorApiCallback}) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      'X-Auth-Token': '${accountModel.token}',
      'X-User-Id': '${accountModel.id}',
      'Content-type': 'application/json'
    };
    Map<String, dynamic> body;
    if (listMember != null && listMember.length > 0) {
      body = {'name': channelName, 'members': listMember};
    } else {
      body = {'name': '$channelName'};
    }
    Http.Response response = await Http.post(
            Constant.SERVER_BASE_CHAT + "/api/v1/groups.create",
            headers: _header,
            body: jsonEncode(body))
        .then((Http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        onErrorApiCallback("Tạo phòng thất bại. Vui lòng thử lại.");
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
    if (response != null) {
      dynamic data = jsonDecode(response.body);
      if (data['success'] != null &&
          data['success'] != '' &&
          data['success'].toString() == 'true') {
        resultData(data);
      } else {
        if (data['errorType'] == 'error-duplicate-channel-name') {
          onErrorApiCallback("Tên phòng đã tồn tại. Vui lòng thử lại.");
        } else {
          onErrorApiCallback("Tạo phòng thất bại. Vui lòng thử lại.");
        }
      }
    }
  }

  Future<void> getAllUserOnGroup(WsRoomModel roomModel,
      {OnResultData resultData,
      OnErrorApiCallback onErrorApiCallback,
      WsAccountModel currentUer}) async {
    WsAccountModel accountModel =
        currentUer ??= WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      'X-Auth-Token': '${accountModel.token}',
      'X-User-Id': '${accountModel.id}',
    };
    Map<String, String> params = {
      'count': '99999',
      'roomName': '${roomModel.name}',
      'roomId': '${roomModel.id}'
    };

    Uri uri = Uri.https(
        Constant.SERVER_CHAT_NO_HTTP, "/api/v1/groups.members", params);
    Http.Response response =
        await Http.get(uri, headers: _header).then((Http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        onErrorApiCallback("Tạo phòng thất bại. Vui lòng thử lại.");
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
    if (response != null &&
        response.bodyBytes != null &&
        response.bodyBytes.length > 0) {
      dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['success'] != null &&
          data['success'] != '' &&
          data['success'].toString() == 'true') {
        resultData(data);
      } else {
        onErrorApiCallback("Tạo phòng thất bại. Vui lòng thử lại.");
      }
    }
  }

  Future<void> getLastMessageInRoom(WsRoomModel roomModel,
      {OnResultData resultData,
      OnErrorApiCallback onErrorApiCallback,
      WsAccountModel currentUer}) async {
    WsAccountModel accountModel =
        currentUer ??= WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      'X-Auth-Token': '${accountModel.token}',
      'X-User-Id': '${accountModel.id}',
    };
    Map<String, String> params = {
      'count': '1',
      //'roomName': '${roomModel.name}',
      'roomId': '${roomModel.id}'
    };

    Uri uri = Uri.https(
        Constant.SERVER_CHAT_NO_HTTP, "/api/v1/groups.history", params);
    Http.Response response =
        await Http.get(uri, headers: _header).then((Http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        onErrorApiCallback(
            "Lấy tin nhắn cuối cùng thất bại. Vui lòng thử lại.");
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
    if (response != null &&
        response.bodyBytes != null &&
        response.bodyBytes.length > 0) {
      dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['success'] != null &&
          data['success'] != '' &&
          data['success'].toString() == 'true') {
        resultData(data);
      } else {
        onErrorApiCallback(
            "Lấy tin nhắn cuối cùng thất bại. Vui lòng thử lại.");
      }
    }
  }

  Future<void> kickMember(WsRoomModel roomModel, RestUserModel restUser,
      {OnResultData resultData, OnErrorApiCallback onErrorApiCallback}) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      'X-Auth-Token': '${accountModel.token}',
      'X-User-Id': '${accountModel.id}',
      'Content-type': 'application/json',
    };
    Map<String, dynamic> body = {
      'roomId': '${roomModel.id}',
      'userId': '${restUser.id}',
    };
    Http.Response response = await Http.post(
            Constant.SERVER_BASE_CHAT + "/api/v1/groups.kick",
            headers: _header,
            body: jsonEncode(body))
        .then((Http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        onErrorApiCallback("Không thể xóa thành viên. Vui lòng thử lại.");
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
    if (response != null &&
        response.bodyBytes != null &&
        response.bodyBytes.length > 0) {
      dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['success'] != null &&
          data['success'] != '' &&
          data['success'].toString() == 'true') {
        resultData(data);
      } else {
        onErrorApiCallback("Không thể xóa thành viên. Vui lòng thử lại.");
      }
    }
  }

  Future<void> addMemberToGroup(WsRoomModel roomModel,
      WsAccountModel accountModel, AddressBookModel restUserModel,
      {OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback}) async {
    Map<String, String> _header = {
      'X-Auth-Token': '${accountModel.token}',
      'X-User-Id': '${accountModel.id}',
      'Content-type': 'application/json',
    };
    Map<String, dynamic> body = {
      'roomId': '${roomModel.id}',
      'userId': '${restUserModel.id}',
    };
    Http.Response response = await Http.post(
            Constant.SERVER_BASE_CHAT + "/api/v1/groups.invite",
            headers: _header,
            body: jsonEncode(body))
        .then((Http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        onErrorApiCallback("Không thể thêm thành viên. Vui lòng thử lại.");
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
    if (response != null &&
        response.bodyBytes != null &&
        response.bodyBytes.length > 0) {
      dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['success'] != null &&
          data['success'] != '' &&
          data['success'].toString() == 'true') {
        onResultData(data);
      } else {
        onErrorApiCallback("Không thể thêm thành viên. Vui lòng thử lại.");
      }
    }
  }

  Future<void> logOutChat(
      {OnResultData resultData, OnErrorApiCallback onErrorApiCallback}) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      'X-Auth-Token': '${accountModel.token}',
      'X-User-Id': '${accountModel.id}',
    };
    Http.Response response = await Http.post(
            Constant.SERVER_BASE_CHAT + "/api/v1/logout",
            headers: _header)
        .then((response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        onErrorApiCallback("Đăng xuất thất bại. Vui lòng thử lại.");
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
    if (response != null &&
        response.bodyBytes != null &&
        response.bodyBytes.length > 0) {
      dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['status'] != null &&
          data['status'] != '' &&
          data['status'].toString() == 'success') {
        resultData(data);
      } else {
        onErrorApiCallback("Đăng xuất thất bại. Vui lòng thử lại.");
      }
    }
  }

  Future<void> getAllGroup(
      {OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback}) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      'X-Auth-Token': '${accountModel.token}',
      'X-User-Id': '${accountModel.id}',
    };
    Map<String, String> params = {
      'offset': '0',
      'count': '9999',
    };
    Uri uri =
        Uri.https(Constant.SERVER_CHAT_NO_HTTP, "api/v1/groups.list", params);
    Http.Response response =
        await Http.get(uri, headers: _header).then((response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        onErrorApiCallback("Lỗi server");
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
    if (response != null &&
        response.bodyBytes != null &&
        response.bodyBytes.length > 0) {
      dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data['success'] != null && data['success'].toString() == 'true') {
        onResultData(data);
      }
    }
  }

  Future<void> loginASGL(
      {String account,
      String password,
      OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback}) async {
    Http.Response response =
        await Http.post(Constant.SERVER_BASE + "/api/auth/login", body: {
      "login": "$account",
      "password": "$password",
    }).then((response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        if (statusCode == 401) {
          onErrorApiCallback(ErrorModel.unAuthorized);
        } else if (statusCode == 403) {
          onErrorApiCallback(ErrorModel.banned);
        } else {
          onErrorApiCallback(ErrorModel.unAuthorized);
        }
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
      }
    }
  }

  Future<void> updatePassword({
    String asglID,
    String oldPassword,
    String newPassword,
    OnResultData onResultData,
    OnErrorApiCallback onErrorApiCallback,
  }) async {
    Http.Response response = await Http.post(
        Constant.SERVER_BASE + "/api/auth/password/change/$asglID",
        body: {
          "password": "$newPassword",
          "old_password": "$oldPassword",
        }).then((response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        if (statusCode == 401) {
          onErrorApiCallback(ErrorModel.unAuthorized);
        } else if (statusCode == 403) {
          onErrorApiCallback(ErrorModel.banned);
        } else {
          onErrorApiCallback(ErrorModel.unAuthorized);
        }
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
      }
    }
  }

  Future<void> leaveRoom(
      {WsRoomModel roomModel,
      OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback}) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      'X-Auth-Token': '${accountModel.token}',
      'X-User-Id': '${accountModel.id}',
      'Content-type': 'application/json',
    };
    Map<String, dynamic> body = {"roomId": "${roomModel.id}"};
    Http.Response response = await Http.post(
            Constant.SERVER_BASE_CHAT + "/api/v1/groups.leave",
            headers: _header,
            body: jsonEncode(body))
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
        onErrorApiCallback("Không thể rời nhóm. Vui lòng thử lại sau.");
      }
    }
  }

  _handleErrorApi(String string) {
    if (string.contains("SocketException")) {
      return ErrorType.CONNECTION_ERROR;
    } else {
      return ErrorType.OTHER_ERROR;
    }
  }

  Future<void> getListBlock(
      {OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback}) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt == null || jwt == "") {
      onErrorApiCallback(ErrorType.JWT_FOUND);
    } else {
      Map<String, String> _header = {"Authorization": "Bearer $jwt"};
      Http.Response response = await Http.get(
              Constant.SERVER_BASE + "/api/notification/blocks",
              headers: _header)
          .then((res) {
        return res;
      }).catchError((onError) {
        onErrorApiCallback(_handleErrorApi(onError.toString()));
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        onErrorApiCallback(ErrorType.TIME_OUT);
        return null;
      });
      if (response != null &&
          response.body != null &&
          response.body.toString() != "") {
        dynamic data = jsonDecode(response.body);
        if (data['success'] != null && data['success'].toString() == "true") {
          onResultData(data['data']);
        } else {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
        }
      } else {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
    }
  }

  Future<void> turnOffNotication(String roomID,
      {OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback}) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt == null || jwt == "") {
      onErrorApiCallback(ErrorType.JWT_FOUND);
    } else {
      Map<String, String> _header = {"Authorization": "Bearer $jwt"};
      Http.Response response = await Http.post(
              Constant.SERVER_BASE + "/api/notification/disable/" + roomID,
              headers: _header)
          .then((res) {
        return res;
      }).catchError((onError) {
        onErrorApiCallback(_handleErrorApi(onError.toString()));
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        onErrorApiCallback(ErrorType.TIME_OUT);
        return null;
      });
      if (response != null &&
          response.body != null &&
          response.body.toString() != "") {
        dynamic data = jsonDecode(response.body);
        if (data['success'] != null && data['success'].toString() == "true") {
          onResultData(data['data']);
        } else {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
        }
      } else {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
    }
  }

  Future<void> turnOnNotication(String roomID,
      {OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback}) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt == null || jwt == "") {
      onErrorApiCallback(ErrorType.JWT_FOUND);
    } else {
      Map<String, String> _header = {"Authorization": "Bearer $jwt"};
      Http.Response response = await Http.post(
              Constant.SERVER_BASE + "/api/notification/enable/" + roomID,
              headers: _header)
          .then((res) {
        return res;
      }).catchError((onError) {
        onErrorApiCallback(_handleErrorApi(onError.toString()));
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        onErrorApiCallback(ErrorType.TIME_OUT);
        return null;
      });
      if (response != null &&
          response.body != null &&
          response.body.toString() != "") {
        dynamic data = jsonDecode(response.body);
        if (data['success'] != null && data['success'].toString() == "true") {
          onResultData(data['data']);
        } else {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
        }
      } else {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
    }
  }

  Future<void> allowLoginWithQrData(BuildContext context, String qr,
      {OnResultData resultData, OnErrorApiCallback onErrorApiCallback}) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt != null && jwt.trim() != "") {
      Http.Response response =
          await Http.post(qr, headers: {"Authorization": "Bearer $jwt"})
              .then((res) {
        int statusCode = res.statusCode;
        if (statusCode == 200) {
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
        dynamic data = jsonDecode(response.body);
        resultData(data);
      } else {
        onErrorApiCallback("");
      }
    } else {
      AppBloc appBloc = BlocProvider.of(context);
      appBloc.authBloc.logOut(context);
    }
  }

  Future<void> getNewAndNotificationData({
    OnResultData onResultData,
    OnErrorApiCallback onErrorApiCallback,
    String typeId,
    String pagination,
    String size,
    String page,
  }) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt == null || jwt == "") {
      onErrorApiCallback(ErrorType.JWT_FOUND);
    } else {
      Map<String, String> _header = {"Authorization": "Bearer $jwt"};
      Map<String, String> params = {
        "type_id": "$typeId",
        "pagination": "true",
        "size": "15",
        "page":"$page"
      };
      Uri uri = Uri.https(
          Constant.SERVER_BASE_NO_HTTP, "api/staff/announcements", params);
      Http.Response response =
      await Http.get(uri, headers: _header).then((res) {
        return res;
      }).catchError((onError) {
        onErrorApiCallback(_handleErrorApi(onError.toString()));
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        onErrorApiCallback(ErrorType.TIME_OUT);
        return null;
      });
      if (response != null &&
          response.body != null &&
          response.body.toString() != "") {
        dynamic data = jsonDecode(response.body);
        if (data['success'] != null && data['success'].toString() == "true") {
          onResultData(data['data']);
        } else {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
        }
      } else {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
    }
  }

  Future<void> getOnlyNotificationData({
    OnResultData onResultData,
    OnErrorApiCallback onErrorApiCallback,
    String typeId,
    int size = 15,
  }) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt == null || jwt == "") {
      onErrorApiCallback(ErrorType.JWT_FOUND);
    } else {
      Map<String, String> _header = {"Authorization": "Bearer $jwt"};
      Map<String, String> params = {
        "type_id": "$typeId",
        "pagination": "true",
        "size": "$size",
      };
      Uri uri = Uri.https(
          Constant.SERVER_BASE_NO_HTTP, "api/staff/announcements", params);
      Http.Response response =
          await Http.get(uri, headers: _header).then((res) {
        return res;
      }).catchError((onError) {
        onErrorApiCallback(_handleErrorApi(onError.toString()));
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        onErrorApiCallback(ErrorType.TIME_OUT);
        return null;
      });
      if (response != null &&
          response.body != null &&
          response.body.toString() != "") {
        dynamic data = jsonDecode(response.body);
        if (data['success'] != null && data['success'].toString() == "true") {
          onResultData(data['data']);
        } else {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
        }
      } else {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
    }
  }
}

///[errorType] == [ErrorType.DATA_ERROR] => [errorType] có dữ liệu trả về
///Các trường hợp [errorMessage] = ""
class ErrorModel {
  ErrorType errorType;
  String errorMessage;
  bool isUsedTryIt;
  final String _netErrorHasTryIt =
      "Không tìm thấy kết nối mạng trên thiết bị của bạn. Vui lòng kết nối mạng sau đó nhấn nút \"Thử lại\".";
  final String _netSlowHasTryIt =
      "Kết nối mạng của bạn quá yếu hoặc cần được gia hạn. Vui lòng đổi kết nối mạng sau đó nhấn nút \"Thử lại\".";
  final String _netErrorNoTryIt =
      "Không tìm thấy kết nối mạng trên thiết bị của bạn. Vui lòng kết nối mạng và thử lại.";
  final String _netSlowNoTryIt =
      "Kết nối mạng của bạn quá yếu hoặc cần được gia hạn. Vui lòng đổi kết nối mạng và thử lại.";
  final String _jwtExpired =
      "Phiên đăng nhập của bạn đã hết hạn. Vui lòng đăng nhập lại để tiếp tục sử dụng.";

  static String netError =
      "Kết nối mạng không ổn định hoặc cần được gia hạn. Vui lòng kiểm tra kết nối của bạn và thử lại";
  static String unAuthorized = "Thông tin xác thực không chính xác.";
  static String banned = "Bạn không đủ quyền hạn thực hiện hành động này.";
  static String notFindPackageInfo =
      "Không tìm thấy thông tin khóa học. Vui lòng thử lại";

  static String otherError = "Đã xảy ra lỗi bất ngờ. Xin vui lòng thử lại sau.";

  ErrorModel(
      {@required this.errorType,
      String errorMessage,
      @required this.isUsedTryIt}) {
    switch (errorType) {
      case ErrorType.CONNECTION_ERROR:
        this.errorMessage = isUsedTryIt ? _netErrorHasTryIt : _netErrorNoTryIt;
        break;
      case ErrorType.TIME_OUT:
        this.errorMessage = isUsedTryIt ? _netSlowHasTryIt : _netSlowNoTryIt;
        break;
      case ErrorType.JWT_FOUND:
        this.errorMessage = _jwtExpired;
        break;
      default:
        this.errorMessage = errorMessage;
        break;
    }
  }
}

enum GenderType {
  male,
  female,
}
