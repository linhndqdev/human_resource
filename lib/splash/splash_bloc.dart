import 'package:flutter/material.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/model/auth_model.dart';
import 'package:human_resource/utils/common/cache_helper.dart';

class SplashBloc {
//  void checkAuth(BuildContext context) async {
//    await Future.delayed(Duration(seconds: 3));
//    AppBloc appBloc = BlocProvider.of(context);
//    bool isRememberPass = await CacheHelper.getStateRememberPass();
//    if (isRememberPass) {
//      String userName = await CacheHelper.getUserName();
//      String password = await CacheHelper.getPassword();
//      if(userName == null || userName == ""){
//        appBloc.authBloc.requestLogin();
//      }else if(password == null || password == ""){
//        appBloc.authBloc.requestLogin();
//      }else{
//        bool isConnecWebSocket = WebSocketHelper.getInstance().isConnected;
//        if(isConnecWebSocket) {
//          String jwt = await CacheHelper.getAccessToken();
//          if(jwt!= null && jwt!=""){
//            appBloc.authBloc.loginChat(context, userName, password);
//          }else {
//            appBloc.authBloc.loginWith(context, userName, password);
//          }
//        }else{
//          appBloc.authBloc.requestLogin();
//        }
//      }
//    } else {
//      Future.delayed(Duration(seconds: 2), () {
//        appBloc.authBloc.authStream.notify(
//          AuthenticationModel(AuthState.REQUEST_LOGIN, false, null),
//        );
//      });
//    }
//  }
}
