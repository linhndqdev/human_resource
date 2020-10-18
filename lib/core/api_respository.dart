
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_services.dart';

class ApiRepository {
  Future<http.Response> createGet(String baseUrl, String url) async {
    return http.get(baseUrl + url).then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
      }
      return response;
    });
  }

  Future<http.Response> createPostNoJWT(String baseUrl, String url,
      {body}) async {
    return http.post(baseUrl + url, body: body).then((http.Response response) {
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        return null;
      }
      return response;
    }).catchError((onError) {
      return null;
    });
  }

  Future<http.Response> createPostJWT(String baseUrl, String url, String jwt,
      {body}) async {
    return http
        .post(baseUrl + url,
            headers: {'Authorization': 'Bearer ' + jwt}, body: body)
        .then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        return null;
      }
      return response;
    }).catchError((onError) {
      return null;
    });
  }

  Future<http.Response> createGetJWT(String baseUrl, String url, String jwt,
  {@required OnErrorApiCallback<ErrorType> onErrorApiCallback}) async {
    return http
        .get(baseUrl + url, headers: {'Authorization': 'Bearer ' + jwt}).then(
            (http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode == 200) {
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
    }).timeout(Duration(seconds: 20), onTimeout: () {
      onErrorApiCallback(ErrorType.TIME_OUT);
      return null;
    });
  }

  Future<http.Response> createGetJWTWithParams(String baseUrl, String url,
      String jwt, Map<String, String> params) async {
    Uri uri;
    if (baseUrl.contains("https://")) {
      baseUrl = baseUrl.replaceFirst("https://", "");
      baseUrl = baseUrl.replaceFirst("/api", "");
      uri = Uri.https(baseUrl, url, params);
    } else if (baseUrl.contains("http://")) {
      baseUrl = baseUrl.replaceFirst("http://", "");
      baseUrl = baseUrl.replaceFirst("/api", "");
      uri = Uri.http(baseUrl, url, params);
    }

    return http.get(uri, headers: {'Authorization': 'Bearer ' + jwt}).then(
        (http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        return null;
      }
      return response;
    }).catchError((onError) {
      return null;
    }).timeout(Duration(seconds: _chatRequestTimeOut), onTimeout: () {
      return null;
    });
  }

  Future<http.Response> createPutWithJWT(String baseUrl, String url, String jwt,
      {body}) {
    return http
        .put(baseUrl + url,
            headers: {'Authorization': 'Bearer ' + jwt}, body: body)
        .then((response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        return null;
      }
      return response;
    }).catchError((onError) {
      return null;
    });
  }

  ///==========Chỉ sử dụng cho phần Chat==============///
  final int _chatRequestTimeOut = 20;

  Future<void> createGetWithAuthHeader(
      {@required String baseUrl,
      @required String endpoint,
      OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback,
      Map<String, String> header,
      Map<String, String> params}) async {
    Uri uri = Uri.https(baseUrl, endpoint, params);
    http.Response response = await http
        .get(
      uri,
      headers: header,
    )
        .then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        onErrorApiCallback(ErrorType.RESPONSE_STATUS_FAILED);
      }
      return response;
    }).catchError((onError) {
      onError.toString().contains("SocketException")
          ? onErrorApiCallback(ErrorType.CONNECTION_ERROR)
          : onErrorApiCallback(ErrorType.OTHER_ERROR);
      return null;
    }).timeout(Duration(seconds: _chatRequestTimeOut), onTimeout: () {
      onErrorApiCallback(ErrorType.TIME_OUT);
      return null;
    });
    if (response != null) {
      if (response.body != null && response.body != "") {
        dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data != null && data != "") {
          try {
            onResultData(data);
          } catch (ex) {
            onErrorApiCallback(ErrorType.CONVERT_DATA_ERROR);
          }
        } else {
          onErrorApiCallback(ErrorType.RESPONSE_BODY_NULL);
        }
      } else {
        onErrorApiCallback(ErrorType.RESPONSE_BODY_NULL);
      }
    }
  }

  Future<void> createPostWithAuthHeader(
      String baseUrl, dynamic url, Map<String, String> authHeader,
      {body,
      OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback}) async {
    var response = await http
        .post(baseUrl + url, headers: authHeader, body: body)
        .then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        onErrorApiCallback(ErrorType.RESPONSE_STATUS_FAILED);
      }
      return response;
    }).catchError((onError) {
      onError.toString().contains("SocketException")
          ? onErrorApiCallback(ErrorType.CONNECTION_ERROR)
          : onErrorApiCallback(ErrorType.OTHER_ERROR);
      return null;
    }).timeout(Duration(seconds: _chatRequestTimeOut), onTimeout: () {
      onErrorApiCallback(ErrorType.TIME_OUT);
      return null;
    });
    if (response != null) {
      if (response.body != null && response.body != "") {
        dynamic data = jsonDecode(response.body);
        if (data != null && data != "") {
          try {
            onResultData(data);
          } catch (ex) {
            onErrorApiCallback(ErrorType.CONVERT_DATA_ERROR);
          }
        } else {
          onErrorApiCallback(ErrorType.RESPONSE_BODY_NULL);
        }
      } else {
        onErrorApiCallback(ErrorType.RESPONSE_BODY_NULL);
      }
    }
  }
}
