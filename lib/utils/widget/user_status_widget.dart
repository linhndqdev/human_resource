import 'dart:async';
import 'package:flutter/material.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/size_extension.dart';

class UserStatusWidget extends StatefulWidget {
  final AppBloc appBloc;
  final List<String> listDirectUser;
  final UserStatusModel model;

  const UserStatusWidget(
      {Key key, this.appBloc, this.listDirectUser, this.model})
      : super(key: key);

  @override
  _UserStatusWidgetState createState() => _UserStatusWidgetState();
}

class _UserStatusWidgetState extends State<UserStatusWidget> {
  _UserStatusBloc _bloc = _UserStatusBloc();
  AppBloc appBloc;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
//      _bloc.getUserStatus(context, widget.listDirectUser);
    });
    _startTimer();
  }

  @override
  void dispose() {
    _bloc.dispose();
    _timerUpdateStatus?.cancel();
    _timerUpdateStatus = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    String userNameGetStatus;
    String currentName = WebSocketHelper.getInstance().userName;
    widget.listDirectUser?.forEach((sName) {
      if (sName != currentName) {
        userNameGetStatus = sName;
      }
    });
    return Stack(
      children: <Widget>[
        CustomCircleAvatar(
          userName: userNameGetStatus,
          size: 131.0,
          position: ImagePosition.GROUP,
        ),
        Positioned(
          right: 0,
          bottom: 8.0.h,
          child: StreamBuilder(
              initialData: appBloc.mainChatBloc.listUserOnLine,
              stream: appBloc.mainChatBloc.listUserOnlineStream.stream,
              builder: (buildContext,
                  AsyncSnapshot<List<AddressBookModel>> snapshotData) {
                Color color = prefix0.greyColor;
                snapshotData?.data?.forEach((user) {
                  if (user.username == userNameGetStatus) {
                    if (user.status != "offline") {
                      color = prefix0.orangeColor;
                    }
                  }
                });
                return Container(
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: color),
                  width: 27.0.w,
                  height: 27.0.w,
                );
              }),
        ),
      ],
    );
  }

  Timer _timerUpdateStatus;

  void _startTimer() {
    _timerUpdateStatus = Timer.periodic(Duration(minutes: 1), (time) {
      _bloc.getUserStatus(widget.listDirectUser);
    });
  }
}

class UserStatusModel {
  UserStatusState state;
  String name;

  UserStatusModel(this.state, this.name);
}

class _UserStatusBloc {
  CoreStream<UserStatusModel> userStatusStream = CoreStream();

  void getUserStatus(List<String> listUserDirect) async {
    String currentName = WebSocketHelper.getInstance().userName;
    String userNameGetStatus = "";
    listUserDirect?.forEach((sName) {
      if (sName != currentName) {
        userNameGetStatus = sName;
      }
    });
    if (userNameGetStatus != null && userNameGetStatus != "") {
      ApiServices apiServices = ApiServices();
      await apiServices.getUserInfo(
          userName: userNameGetStatus,
          onResultData: (resultData) {
            UserStatusState state;
            if (resultData.status == "offline") {
              state = UserStatusState.OFFLINE;
            } else {
              state = UserStatusState.ONLINE;
            }
            UserStatusModel model =
                UserStatusModel(state, resultData?.name ?? userNameGetStatus);
            userStatusStream.notify(model);
          },
          onErrorApiCallback: (error) {
            UserStatusState state = UserStatusState.OFFLINE;
            UserStatusModel model = UserStatusModel(state, userNameGetStatus);
            userStatusStream.notify(model);
          });
    }
  }

  dispose() {
    userStatusStream?.closeStream();
  }
}
