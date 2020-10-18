import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/core/meeting/meeting_action.dart';
import 'package:http/http.dart' as Http;
import 'package:human_resource/utils/common/cache_helper.dart';

class MeetingService extends MeetingAction {
  @override
  Future<void> getRoomAvailableAtTime(
      {String dateTime,
      int meetingTimeLimit,
      resultData,
      onErrorApiCallback}) async {
    Map<String, String> params = {
      "start_at": dateTime,
      "duration": meetingTimeLimit.toString(),
    };
    String jwt = await CacheHelper.getAccessToken();
    if (jwt != null && jwt != "") {
      Map<String, String> _header = {"Authorization": "Bearer $jwt"};
      Uri uri =
          Uri.https(Constant.SERVER_BASE_NO_HTTP, "api/meeting-rooms", params);
      Http.Response response =
          await Http.get(uri, headers: _header).then((response) {
        int restStatus = response.statusCode;
        if (restStatus == 200) {
          return response;
        } else {
          onErrorApiCallback(ErrorType.RESPONSE_STATUS_FAILED);
          return null;
        }
      }).catchError((onError) {
        if (onError.toString().contains("SocketException")) {
          onErrorApiCallback(ErrorType.CONNECTION_ERROR);
        } else {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
        }
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        onErrorApiCallback(ErrorModel.netError);
        return null;
      });
      if (response != null) {
        if (response.body != null && response.body.toString() != "") {
          dynamic data = jsonDecode(response.body);
          if (data['success'] != null && data['success'].toString() == "true") {
            if (data['data'] != null && data['data'] != "") {
              resultData(data['data']);
            } else {
              onErrorApiCallback(ErrorType.OTHER_ERROR);
            }
          } else {
            onErrorApiCallback(ErrorType.OTHER_ERROR);
          }
        } else {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
        }
      }
    } else {
      onErrorApiCallback(ErrorType.JWT_FOUND);
    }
  }

  @override
  Future<void> createMeeting(
      {String topic,
      String description,
      String startAt,
      int duration,
      int roomId,
      List<int> listParticipantID,
      onResultData,
      onErrorApiCallback}) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt == null || jwt == "") {
      //Chuyển ra màn hình login
      onErrorApiCallback(ErrorType.JWT_FOUND);
    } else {
      Map<String, String> _header = {
        "Authorization": "Bearer $jwt",
        "Content-Type": "application/json"
      };
      Map<String, dynamic> _body = {
        "topic": topic,
        "description": description,
        "start_at": startAt,
        "duration": duration,
        "room_id": roomId,
        "participant_ids": listParticipantID,
      };
      Http.Response response = await Http.post(
              Constant.SERVER_BASE + "/api/meetings",
              headers: _header,
              body: json.encode(_body))
          .then((response) {
        return response;
      }).catchError((onError) {
        onErrorApiCallback(_handleErrorApi(onError.toString()));
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        onErrorApiCallback(ErrorType.TIME_OUT);
        return null;
      });
      if (response != null && response.body != null) {
        dynamic data = json.decode(response.body);
        if (data != null && data != "") {
          if (data['success'] != null && data['success'].toString() == "true") {
            if (data['data'] != null && data['data'] != "") {
              onResultData(data['data']);
            } else {
              onErrorApiCallback(ErrorType.OTHER_ERROR);
            }
          } else {
            if (data['message'] != null && data['message'] != "") {
              onErrorApiCallback(data['message']);
            } else {
              onErrorApiCallback(ErrorType.DATA_ERROR);
            }
          }
        } else {
          onErrorApiCallback(ErrorType.DATA_ERROR);
        }
      }
    }
  }

  @override
  Future<void> deleteMeeting(
      {String meetingID, onResultData, onErrorApiCallback}) {
    // TODO: implement deleteMeeting
    return null;
  }

  @override
  Future<void> getDetailMeeting(
      {String meetingID, onResultData, onErrorApiCallback}) async {
    // TODO: implement getDetailMeeting

//    Map<String, String> params = {
//      "start_at": dateTime,
//      "duration": meetingTimeLimit.toString(),
//    };
    String jwt = await CacheHelper.getAccessToken();
    if (jwt != null && jwt != "") {
      Map<String, String> _header = {"Authorization": "Bearer $jwt"};
      Uri uri =
          Uri.https(Constant.SERVER_BASE_NO_HTTP, "api/meetings/" + meetingID);
      Http.Response response =
          await Http.get(uri, headers: _header).then((response) {
        return response;
      }).catchError((onError) {
        if (onError.toString().contains("SocketException")) {
          onErrorApiCallback(ErrorType.CONNECTION_ERROR);
        } else {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
        }
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        onErrorApiCallback(ErrorModel.netError);
        return null;
      });
      if (response != null) {
        if (response.body != null && response.body.toString() != "") {
          dynamic data = jsonDecode(response.body);
          if (data['success'] != null && data['success'].toString() == "true") {
            if (data['data'] != null && data['data'] != "") {
              onResultData(data['data']);
            } else {
              onErrorApiCallback(ErrorType.OTHER_ERROR);
            }
          } else {
            onErrorApiCallback(ErrorType.OTHER_ERROR);
          }
        } else {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
        }
      }
    } else {
      onErrorApiCallback(ErrorType.JWT_FOUND);
    }
//    return null;
  }

  //Viết api lấy dữ liệu tại đây
  @override
  Future<void> getMemberInfo(
      {@required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback,
      String userName}) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt == null || jwt == "") {
      onErrorApiCallback(ErrorType.JWT_FOUND);
    } else {
      Map<String, String> _header = {"Authorization": "Bearer $jwt"};
      Http.Response response = await Http.get(
              Constant.SERVER_BASE +
                  "/api/users?search=username:" +
                  userName +
                  "&searchFields=username:like",
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
          onResultData(data);
        } else {
          onErrorApiCallback("");
        }
      } else {
        onErrorApiCallback("");
      }
    }
  }

  @override
  Future<void> updateMeetingInfo(
      {String topic,
      String description,
      String startAt,
      int duration,
      int roomId,
      List<int> listParticipantID,
      onResultData,
      onErrorApiCallback}) {
    // TODO: implement updateMeetingInfo
    return null;
  }

  _handleErrorApi(String string) {
    if (string.contains("SocketException")) {
      return ErrorType.CONNECTION_ERROR;
    } else {
      return ErrorType.OTHER_ERROR;
    }
  }

  @override
  Future<void> getAllMember(
      {@required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback}) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt == null || jwt == "") {
      onErrorApiCallback(ErrorType.JWT_FOUND);
    } else {
      Map<String, String> _header = {"authorization": "Bearer $jwt"};
      Map<String, String> _params = {"pagination": "false"};
      Uri uri = Uri.https(Constant.SERVER_BASE_NO_HTTP, "api/users", _params);
      Http.Response response =
          await Http.get(uri, headers: _header).then((response) {
        int status = response != null ? response.statusCode : -1;
        if (status == 200) {
          return response;
        } else {
          onErrorApiCallback(ErrorType.RESPONSE_STATUS_FAILED);
          return null;
        }
      }).catchError((onError) {
        onErrorApiCallback(_handleErrorApi(onError.toString()));
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        onErrorApiCallback(ErrorType.TIME_OUT);
        return null;
      });
      if (response != null && response.body != null) {
        dynamic data = json.decode(response.body);
        if (data != null && data != "") {
          if (data['success'] != null && data['success'].toString() == "true") {
            if (data['data'] != null && data['data'] != "") {
              onResultData(data['data']);
            } else {
              onErrorApiCallback(ErrorType.OTHER_ERROR);
            }
          } else {
            onErrorApiCallback(ErrorType.OTHER_ERROR);
          }
        } else {
          onErrorApiCallback(ErrorType.DATA_ERROR);
        }
      } else {
        onErrorApiCallback(ErrorType.RESPONSE_BODY_NULL);
      }
    }
  }

  @override
  Future<void> getAllMeeting(
      {OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback}) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt == null || jwt == "") {
      onErrorApiCallback(ErrorType.JWT_FOUND);
    } else {
      Map<String, String> _header = {"Authorization": "Bearer $jwt"};
      Http.Response response = await Http.get(
              Constant.SERVER_BASE + "/api/meetings",
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

  Future<void> updateMeetingInfomation(
      {String id,
      String topic,
      String description,
      String start_at,
      int duration,
      int room_id,
      List<int> participant_ids,
      onResultData,
      onErrorApiCallback}) async {
    Map<String, dynamic> _body = {
      "topic": topic,
      "description": description,
      "start_at": start_at,
      "duration": duration,
      "room_id": room_id,
      "participant_ids": participant_ids,
    };
    String jwt = await CacheHelper.getAccessToken();
    if (jwt != null && jwt != "") {
      Map<String, String> _header = {
        "Authorization": "Bearer $jwt",
        "Content-Type": "application/json"
      };
      Uri uri = Uri.https(Constant.SERVER_BASE_NO_HTTP, "api/meetings/" + id);

      Http.Response response =
          await Http.put(uri, headers: _header, body: json.encode(_body))
              .then((response) {
        return response;
      }).catchError((onError) {
        onErrorApiCallback(_handleErrorApi(onError.toString()));
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        onErrorApiCallback(ErrorType.TIME_OUT);
        return null;
      });
      if (response != null && response.body != null) {
        dynamic data = json.decode(response.body);
        if (data != null && data != "") {
          if (data['success'] != null && data['success'].toString() == "true") {
            if (data['data'] != null && data['data'] != "") {
              onResultData(data['data']);
            } else {
              onErrorApiCallback(ErrorType.OTHER_ERROR);
            }
          } else {
            if (data['message'] != null && data['message'] != "") {
              onErrorApiCallback(data['message']);
            } else {
              onErrorApiCallback(ErrorType.DATA_ERROR);
            }
          }
        } else {
          onErrorApiCallback(ErrorType.DATA_ERROR);
        }
      }
    } else {
      onErrorApiCallback(ErrorType.JWT_FOUND);
    }
  }

  @override
  Future<void> acceptOrRefuseMeeting(
      {String meetingID,
      bool isAccept,
      onResultData,
      onErrorApiCallback}) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt == null || jwt == "") {
      onErrorApiCallback(ErrorType.JWT_FOUND);
    } else {
      Map<String, String> _header = {
        "Authorization": "Bearer $jwt",
        "Content-Type": "application/json"
      };
      Map<String, dynamic> _body = {"accept": isAccept};
      Http.Response response = await Http.post(
              Constant.SERVER_BASE + "/api/meetings/$meetingID/confirm",
              headers: _header,
              body: json.encode(_body))
          .then((res) {
        return res;
      }).catchError((onError) {
        onErrorApiCallback(_handleErrorApi(onError.toString()));
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        onErrorApiCallback(ErrorType.CONNECTION_ERROR);
        return null;
      });
      if (response != null && response.body != null && response.body != "") {
        dynamic data = json.decode(response.body);
        if (data != null && data != "") {
          if (data['success'] != null && data['success'].toString() == "true") {
            onResultData(data['data']);
          } else {
            if (data['message'] != null && data['message'] != "") {
              onErrorApiCallback(data['message']);
            } else {
              onErrorApiCallback(ErrorType.OTHER_ERROR);
            }
          }
        } else {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
        }
      }
    }
  }

  Future<void> cancelMeeting(
      {String meetingID, onResultData, onErrorApiCallback}) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt == null || jwt == "") {
      onErrorApiCallback(ErrorType.JWT_FOUND);
    } else {
      Map<String, String> _header = {
        "Authorization": "Bearer $jwt",
        "Content-Type": "application/json"
      };
      Uri uri = Uri.https(
          Constant.SERVER_BASE_NO_HTTP, "/api/meetings/$meetingID/cancel");
      Http.Response response = await Http.post(
        uri,
        headers: _header,
      ).then((res) {
        return res;
      }).catchError((onError) {
        onErrorApiCallback(_handleErrorApi(onError.toString()));
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        onErrorApiCallback(ErrorType.CONNECTION_ERROR);
        return null;
      });
      if (response != null && response.body != null && response.body != "") {
        dynamic data = json.decode(response.body);
        if (data != null && data != "") {
          if (data['success'] != null && data['success'].toString() == "true") {
            onResultData(data['data']);
          } else {
            if (data['message'] != null && data['message'] != "") {
              onErrorApiCallback(data['message']);
            } else {
              onErrorApiCallback(ErrorType.OTHER_ERROR);
            }
          }
        } else {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
        }
      }
    }
  }

  @override
  Future<void> attendMeeting(
      {String meetingID, onResultData, onErrorApiCallback}) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt == null || jwt == "") {
      onErrorApiCallback(ErrorType.JWT_FOUND);
    } else {
      Map<String, String> _header = {
        "Authorization": "Bearer $jwt",
        "Content-Type": "application/json"
      };
      Http.Response response = await Http.post(
        Constant.SERVER_BASE + "/api/meetings/$meetingID/attend",
        headers: _header,
      ).then((res) {
        return res;
      }).catchError((onError) {
        onErrorApiCallback(_handleErrorApi(onError.toString()));
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        onErrorApiCallback(ErrorType.CONNECTION_ERROR);
        return null;
      });
      if (response != null && response.body != null && response.body != "") {
        dynamic data = json.decode(response.body);
        if (data != null && data != "") {
          if (data['success'] != null && data['success'].toString() == "true") {
            onResultData(data['data']);
          } else {
            if (data['message'] != null && data['message'] != "") {
              onErrorApiCallback(data['message']);
            } else {
              onErrorApiCallback(ErrorType.OTHER_ERROR);
            }
          }
        } else {
          onErrorApiCallback(ErrorType.OTHER_ERROR);
        }
      } else {
        onErrorApiCallback(ErrorType.OTHER_ERROR);
      }
    }
  }
}

class bodyUpdate {
  String topic;
  String description;
  String start_at;
  int duration;
  List<int> participant_ids;

  bodyUpdate(this.topic, this.description, this.start_at, this.duration,
      this.participant_ids);

  Map<String, dynamic> TojsonData() {
    var map = new Map<String, dynamic>();
    map["topic"] = topic;
    map["description"] = description;
    map["start_at"] = start_at;
    map["duration"] = duration;
    map["participant_ids"] = participant_ids;
    return map;
  }
}
