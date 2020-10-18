import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:http/http.dart' as Http;
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/model/socket_notification.dart';
import 'package:human_resource/utils/common/cache_helper.dart';

class NotificationServices {
  Future<void> countUnReadNotification(
      OnResultData resultData, OnErrorApiCallback onErrorApiCallback) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt != null && jwt != "") {
      Map<String, String> header = {"Authorization": "Bearer $jwt"};
      Http.Response response = await Http.get(
              Constant.SERVER_BASE + "/api/notifications?read=false",
              headers: header)
          .then((res) {
        if (res?.statusCode == 200) {
          return res;
        } else {
          return null;
        }
      }).catchError((onError) {
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        return null;
      });
      if (response == null) {
        onErrorApiCallback(0);
      } else {
        if (response.body != null && response.body != "") {
          try {
            Map<String, dynamic> data = json.decode(response.body);
            debugPrint(data.toString());
            if (data.containsKey('data') &&
                data['data'].containsKey('meta') &&
                data['data']['meta'].containsKey('pagination') &&
                data['data']['meta']['pagination'].containsKey('total')) {
              resultData(data['data']['meta']['pagination']['total']);
            } else {
              resultData(0);
            }
          } catch (ex) {}
        } else {
          onErrorApiCallback(0);
        }
      }
    }
  }

  Future<void> getAllNotification(int currentPage, OnResultData resultData,
      OnErrorApiCallback onErrorApiCallback) async {
    String jwt = await CacheHelper.getAccessToken();
    if (jwt != null && jwt != "") {
      Map<String, String> header = {"Authorization": "Bearer $jwt"};
      Http.Response response = await Http.get(
              Constant.SERVER_BASE + "/api/notifications?page=$currentPage",
              headers: header)
          .then((res) {
        if (res?.statusCode == 200) {
          return res;
        } else {
          return null;
        }
      }).catchError((onError) {
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        return null;
      });
      if (response == null) {
        onErrorApiCallback(0);
      } else {
        if (response.body != null && response.body != "") {
          try {
            Map<String, dynamic> data = json.decode(response.body);
            debugPrint(data?.toString());
            if (data.containsKey('data') && data['data'] != null) {
              resultData(data['data']);
            } else {
              resultData(0);
            }
          } catch (ex) {
            onErrorApiCallback(0);
          }
        } else {
          onErrorApiCallback(0);
        }
      }
    }
  }

  void readNotification(SKNotification skNotification,
      {OnResultData resultData}) async {
    String jwt = await CacheHelper.getAccessToken();
    if (skNotification == null ||
        skNotification?.id == null ||
        skNotification?.id?.trim() == "") {
      return;
    }
    if (jwt != null && jwt != "") {
      Map<String, String> header = {"Authorization": "Bearer $jwt"};
      Http.Response response = await Http.post(
              Constant.SERVER_BASE +
                  "/api/notifications/${skNotification.id}/read",
              headers: header)
          .then((res) {
        if (res?.statusCode == 200) {
          return res;
        } else {
          return null;
        }
      }).catchError((onError) {
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        return null;
      });
      if (response != null) if (response.body != null && response.body != "") {
        try {
          Map<String, dynamic> data = json.decode(response.body);
          resultData(data['data']);
        } catch (ex) {}
      }
    }
  }

  Future<void> getDetailNotification(
      {dynamic notificationID,
      @required OnResultData resultData,
      @required OnErrorApiCallback onErrorApiCallback}) async {
    String jwt = await CacheHelper.getAccessToken();
    if (notificationID == null || notificationID?.toString()?.trim() == "") {
      onErrorApiCallback(null);
      return;
    }
    if (jwt != null && jwt != "") {
      Map<String, String> header = {"Authorization": "Bearer $jwt"};
      Http.Response response = await Http.get(
              Constant.SERVER_BASE + "/api/notifications/$notificationID",
              headers: header)
          .then((res) {
        if (res?.statusCode == 200) {
          return res;
        } else {
          onErrorApiCallback(null);
          return null;
        }
      }).catchError((onError) {
        onErrorApiCallback(null);
        return null;
      }).timeout(Duration(seconds: TIME_OUT), onTimeout: () {
        onErrorApiCallback(null);
        return null;
      });
      if (response != null) {
        if (response.body != null && response.body != "") {
          try {
            Map<String, dynamic> data = json.decode(response.body);
            resultData(data['data']);
          } catch (ex) {
            onErrorApiCallback(null);
          }
        }
      }
    }
  }
}
