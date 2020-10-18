import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/info/orient_bloc.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/model/notification_model.dart';
import 'package:human_resource/utils/common/const.dart';
import 'package:human_resource/utils/common/datetime_format.dart';

typedef OnClickShowImage = Function();

class SpentWidget extends StatelessWidget {
  final OrientState orientState;

  const SpentWidget({Key key, this.orientState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppBloc appBloc = BlocProvider.of(context);
    WsRoomModel roomModel = _getRoomInfo(appBloc);
    return GestureDetector(
      onTap: () {
        appBloc?.homeBloc?.openOrientScreen(orientState);
      },
      child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(
            left: ScreenUtil().setWidth(60.0),
//            right: ScreenUtil().setHeight(59.5),
          ),
          child: Row(
//            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  bottom: ScreenUtil().setHeight(35.9),
                ),
                height: 203.1.h,
                width: 203.1.w,
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ScreenUtil().setWidth(12.0)),
                    color: Color(0xFF0005a88),
                    shape: BoxShape.rectangle),
                child: Center(
                  child: Image.asset(
                    orientState == OrientState.BAN_TIN
                        ? "asset/images/document.png"
                        : orientState == OrientState.THONG_BAO
                            ? "asset/images/ic_thongbao.png"
                            : "asset/images/ic_faq.png",
                    height: 79.4.h,
                    width: 71.8.w,
                  ),
                ),
              ),
              SizedBox(
                width: 52.5.w,
              ),
              roomModel != null && roomModel.lastMessage != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 704.9.w,
                          child: _buildTextMessage(roomModel),
                        ),
                        SizedBox(height: 10.0.h),
                        Container(
                          width: 704.9.w,
                          child: _buildTimeMessage(roomModel),
                        ),
                      ],
                    )
                  : Container(
                      alignment: Alignment.centerLeft,
                      height: 203.1.h,
                      child: Text(
                        orientState == OrientState.BAN_TIN
                            ? "Chưa có bản tin mới"
                            : orientState == OrientState.THONG_BAO
                                ? "Chưa có thông báo mới"
                                : "Chưa có thông tin mới",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 50.0.sp,
                          fontFamily: "Roboto-Regular",
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal,
                          color: Color(0xff0959ca7),
                        ),
                      ),
                    ),
            ],
          )),
    );
  }

  //Yêu cầu logic check time để hiển thị màu của ngày hiên tại
  bool getTitleColor() {
    return false;
  }

  WsRoomModel _getRoomInfo(AppBloc appBloc) {
    WsRoomModel roomModel;
    if (orientState == OrientState.BAN_TIN) {
      roomModel = appBloc.mainChatBloc.listGroups?.firstWhere(
          (room) => room.name == Const.BAN_TIN,
          orElse: () => null);
    } else if (orientState == OrientState.THONG_BAO) {
      roomModel = appBloc.mainChatBloc.listGroups?.firstWhere(
          (room) => room.name.contains(Const.THONG_BAO),
          orElse: () => null);
    } else if (orientState == OrientState.FAQ) {
      roomModel = appBloc.mainChatBloc.listGroups
          ?.firstWhere((room) => room.name == Const.FAQ, orElse: () => null);
    }
    return roomModel;
  }

  _buildTextMessage(WsRoomModel roomModel) {
    NotificationModel dataMsg;
    WsMessage message = roomModel.lastMessage;
    String msg = "";
    if (message == null) {
      msg = orientState == OrientState.BAN_TIN
          ? "Không có bản tin mới"
          : "Không có thông báo mới";
    } else {
//      dataMsg = NotificationModel.fromJson(json.decode(message.msg));
      msg = message.msg;
    }
    return Text(
      dataMsg == null ? msg : dataMsg.title,
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: 50.0.sp,
          fontFamily: "Roboto-Regular",
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.normal,
//                                      height: ScreenUtil().setHeight(1.22),
          color: Color(0xff0333333)),
    );
  }

  _buildTimeMessage(WsRoomModel roomModel) {
    if (roomModel == null) {
      return Container();
    } else if (roomModel.lastMessage == null) {
      return Container();
    } else if (roomModel.lastMessage.ts == null) {
      return Container();
    }
    String time =
        DateTimeFormat.convertTimeToDateMonthYeah(roomModel.lastMessage.ts);
    return Text(
      time ?? " ",
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: ScreenUtil().setSp(40.0),
          fontFamily: "Roboto-Regular",
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.normal,
          color: Color(0xff0959ca7)),
    );
  }
}
