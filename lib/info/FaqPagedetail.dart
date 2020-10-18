import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/style.dart';
import 'package:human_resource/info/orient_bloc.dart';
import 'package:human_resource/utils/common/const.dart';
import 'package:flutter_screenutil/size_extension.dart';

class FaqScreen extends StatefulWidget {
  @override
  _FaqScreenState createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  AppBloc appBloc;
  ScrollController controller;
  WsRoomModel roomModel;
  OrientBloc orientBloc = OrientBloc();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      WsRoomModel model = appBloc.mainChatBloc.listGroups
          ?.firstWhere((r) => r.name.contains(Const.FAQ), orElse: () => null);
      appBloc.mainChatBloc.chatBloc
          .getChatHistory(context, model, controller: controller);
      appBloc?.mainChatBloc?.chatBloc?.readAllMessage(context, model);
      roomModel = model;
      orientBloc.loaddingStream.notify(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return Container(
      child: StreamBuilder(
        initialData: false,
        stream: orientBloc.loaddingStream.stream,
        builder: (buildContex, snapshot) {
          if (snapshot.data) {
            return Container(
              alignment: Alignment.center,
              child: Text(
                "Hiện tại không có nội dung FAQ nào",
                style: TextStyle(
                    color: blackColor333,
                    fontStyle: FontStyle.normal,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.normal,
                    fontSize: 50.0.sp),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
