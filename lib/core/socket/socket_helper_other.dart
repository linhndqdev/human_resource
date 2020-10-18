import 'package:flutter/material.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/model/socket_notification.dart';
import 'package:laravel_echo/laravel_echo.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketHelperOther {
  static SocketHelperOther _instance;
  AppBloc appBloc;

  SocketHelperOther._internal();

  static SocketHelperOther get instance => _instance;
  static Echo _echo;

  static SocketHelperOther init() {
    if (_instance == null) {
      _instance = SocketHelperOther._internal();
    }
    return instance;
  }

  void connectSocketServer(AppBloc appBloc, String jwt, String userID) {
    this.appBloc = appBloc;
    _echo = new Echo({
      'broadcaster': 'socket.io',
      'client': io,
      'host': 'http://18.141.67.43:6001',
      "auth": {
        "headers": {"Authorization": "Bearer $jwt"}
      },
    });
    _echo.private('sconnect-dev-users-$userID').notification((resultCallBack) {
      _handleNotification(resultCallBack);
    });
//    echo.connect();
  }

  void _handleNotification(resultCallBack) {
    try {
      Map<String, dynamic> resultData = resultCallBack;
      if (resultData != null && resultData.containsKey("event")) {
        SKNotification notification = SKNotification.fromSocketJson(resultData);
        if (notification != null) {
          appBloc.notificationBloc.updateListNotification(notification);
        }
      }
    } catch (ex) {
      debugPrint(ex);
    }
  }

  void disconnect() {
    if (_echo != null && _echo.socket != null) {
      (_echo.socket as Socket).disconnect();
    }
  }
}
