import 'package:flutter/material.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';

enum ItemDirectRoomState {
  LOADING,
  SHOW,
  ERROR,
}

class ItemDirectRoomModel {
  ItemDirectRoomState state;
  WsRoomModel roomModel;
  String error;

  ItemDirectRoomModel({@required this.state, this.roomModel, this.error});
}

class ItemRoomBloc {
  CoreStream<ItemDirectRoomModel> directRoomSub = CoreStream();
  CoreStream<String> showNameStream = CoreStream();

  dispose() {
    directRoomSub?.closeStream();
    showNameStream?.closeStream();
  }

  //Lấy thông tin người dùng trong hệ thống
  void getUserInfo(BuildContext context, String userName) async {
    AppBloc appBloc = BlocProvider.of(context);
    if (appBloc.mainChatBloc.listUserOnChatSystem != null &&
        appBloc.mainChatBloc.listUserOnChatSystem.length > 0) {
      AddressBookModel model = appBloc.mainChatBloc.listUserOnChatSystem
          ?.firstWhere((user) => user.username == userName, orElse: () => null);
      if (model == null) {
        showNameStream?.notify(userName);
      } else {
        showNameStream?.notify(model.name);
      }
    } else {
      ApiServices apiServices =
          ApiServices();
      await apiServices.getUserInfo(
          userName: userName,
          onResultData: (resultData) {
            showNameStream?.notify(resultData.name);
          },
          onErrorApiCallback: (errorCallBack) {
            showNameStream?.notify(userName);
          });
    }
  }
}
