import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/common/const.dart';
import 'package:human_resource/utils/common/datetime_format.dart';

import 'loading_circle.dart';

class ItemShowTimeWidget extends StatefulWidget {
  final bool isOwner;
  final bool isCheck;
  final WsMessage message;
  final bool isSending;
  final bool isShowTime;
  final bool isSystemMessage;
  final WsRoomModel wsRoomModel;

  const ItemShowTimeWidget(
      {Key key,
      this.isShowTime,
      this.isSystemMessage,
      this.isSending,
      this.isOwner,
      this.isCheck,
      this.message,
      this.wsRoomModel})
      : super(key: key);

  @override
  _ItemShowTimeWidgetState createState() => _ItemShowTimeWidgetState();
}

class _ItemShowTimeWidgetState extends State<ItemShowTimeWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.isSending) {
      return Container(
        width: ScreenUtil().setWidth(10.0),
        height: ScreenUtil().setHeight(10.0),
        child: LoadingWidget(),
      );
    } else if (widget.isShowTime && !widget.isSystemMessage) {
      return Padding(
        padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(
                widget.wsRoomModel.name.contains(Const.BAN_TIN) ||
                        widget.wsRoomModel.name.contains(Const.THONG_BAO)
                    ? 0.0.h
                    : 60.2.h),
            left: widget.isCheck
                ? ScreenUtil().setWidth(widget.isOwner ? 0.0 : 256.9)
                : ScreenUtil().setWidth(widget.isOwner ? 0.0 : 181.9),
            right: ScreenUtil().setWidth(widget.isOwner ? 59.0 : 0.0)),
        child: Text(
          getTimeShow(),
          style: TextStyle(
            fontFamily: "Roboto-Regular",
            color: prefix0.blackColor.withOpacity(0.4),
            fontSize: ScreenUtil().setSp(30.0),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  String getTimeShow() {
    return DateTimeFormat.convertTimeMessageItem(widget.message.ts);
  }
}
