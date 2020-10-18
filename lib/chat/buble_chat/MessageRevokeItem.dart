import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/utils/common/const.dart';
import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/utils/widget/forward_show_message.dart';
import 'package:human_resource/utils/widget/loading_circle.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/widget/quote_show_widget.dart';
import 'package:human_resource/utils/widget/reaction_widget.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageRevokeItem extends StatefulWidget {
  final WsMessage message;
  final bool isShowTime;
  final double marginTop;
  final bool isShowAvatar;
  final bool isOwner; //Tin nhắn của tài khoản này
  final bool isShowDate;
  final WsRoomModel roomModel;
  final String userFullName;

  const MessageRevokeItem({
    Key key,
    this.message,
    this.isShowTime = true,
    this.marginTop = 0.0,
    this.isShowAvatar = false,
    this.isOwner = false,
    this.isShowDate = false,
    this.roomModel,
    this.userFullName,
  }) : super(key: key);

  @override
  _MessageRevokeItemState createState() => _MessageRevokeItemState();
}

class _MessageRevokeItemState extends State<MessageRevokeItem> {
  AppBloc appBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return Container(
      alignment: AlignmentDirectional.center,
      margin: EdgeInsets.only(top: widget.marginTop),
      child: Column(
        crossAxisAlignment:
            widget.isOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: ScreenUtil().setHeight(10.0),
          ),
          widget.isShowDate
              ? Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: prefix0.accentColor,
                      borderRadius: BorderRadius.circular(
                          SizeRender.renderBorderSize(context, 5.0)),
                    ),
                    margin:
                        EdgeInsets.only(bottom: ScreenUtil().setHeight(36.0)),
                    padding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(65),
                      right: ScreenUtil().setWidth(65),
                      top: ScreenUtil().setHeight(25),
                      bottom: ScreenUtil().setHeight(25),
                    ),
                    child: Text(
                      DateTimeFormat.convertTimeToDateMonthYeah(
                          widget.message.ts),
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(30),
                          fontFamily: 'Roboto-Regular',
                          color: prefix0.whiteColor),
                    ),
                  ),
                )
              : Container(),
          //Show View thu hồi tin nhắn
          widget.isOwner ? buildRTL() : buildLTR(),
          widget.isShowTime
              ? SizedBox(
                  height: ScreenUtil().setHeight(1.0),
                )
              : Container(),
          widget.isShowTime
              ? Padding(
                  padding: EdgeInsets.only(
//                  top: ScreenUtil().setHeight(10.0),
                      left: ScreenUtil().setWidth(widget.isOwner ? 0.0 : 181.9),
                      right:
                          ScreenUtil().setWidth(widget.isOwner ? 59.0 : 0.0)),
                  child: Text(
                    getTimeShow(),
                    style: TextStyle(
                      fontFamily: "Roboto-Regular",
                      color: prefix0.blackColor.withOpacity(0.4),
                      fontSize: ScreenUtil().setSp(30.0),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  //Tin nhắn là của người dùng đang đăng nhập gửi
  Widget buildRTL() {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            child: textItemRevoke(true),
          ),
        ),
      ],
    );
  }

  //Tin nhắn của người khác gửi đến
  Widget buildLTR() {
    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: <Widget>[
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  (widget.userFullName != null && widget.userFullName != "") &&
                          widget.roomModel.roomType == RoomType.p &&
                          widget.roomModel.name != Const.FAQ &&
                          widget.roomModel.name != Const.BAN_TIN &&
                          widget.roomModel.name != Const.THONG_BAO
                      ? Container(
                          constraints: BoxConstraints(
                            maxWidth: ScreenUtil().setWidth(751),
                          ),
                          margin: EdgeInsets.only(
                              top: ScreenUtil().setHeight(12.0),
                              bottom: ScreenUtil().setHeight(6.0),
                              left: ScreenUtil().setWidth(182.0),
                              right: ScreenUtil().setWidth(59.0)),
                          child: Text(
                            widget.userFullName,
                            style: TextStyle(
                                fontFamily: 'Roboto-Bold',
                                fontSize: ScreenUtil().setSp(30.0),
                                color: prefix0.blackColor333),
                          ),
                        )
                      : Container(),
                  Container(
                    child: textItemRevoke(false),
                  )
                ],
              ),
            )),
      ],
    );
  }

  Widget buildAvatar() {
    if (widget.roomModel.roomType == RoomType.p) {
      return widget.isShowAvatar &&
              widget?.message?.skAccountModel?.userName != 'asglchat'
          ? Container(
              margin: EdgeInsets.only(left: ScreenUtil().setWidth(60.0)),
              child: CustomCircleAvatar(
                size: 80.0,
                userName: widget?.message?.skAccountModel?.userName,
                position: ImagePosition.GROUP,
              ),
            )
          : Container();
    } else {
      return widget.isShowAvatar &&
              widget?.message?.skAccountModel?.userName != 'asglchat'
          ? Container(
              margin: EdgeInsets.only(left: ScreenUtil().setWidth(60.0)),
              child: CustomCircleAvatar(
                  position: ImagePosition.GROUP,
                  size: 80.0,
                  userName: widget?.message?.skAccountModel?.userName),
            )
          : Container();
    }
  }

  Widget textItemRevoke(bool isRTL) {
    return ColumnSuper(
      alignment: isRTL?Alignment.centerRight:Alignment.centerLeft,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(maxWidth: 751.w, minWidth: 536.w),
          margin: EdgeInsets.only(
              left: !widget.isOwner ? 182.0.w : 0.0,
              right: widget.isOwner ? 59.0.w : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
                SizeRender.renderBorderSize(context, 10.0)),
            color: Color(0xff959ca7).withOpacity(0.3),
          ),
          padding: EdgeInsets.only(
              left: 22.0.w,
              right: 22.0.w,
              top: 14.1.h,
              bottom: 14.1.h
          ),
          child:Text(
            "Tin nhắn đã được thu hồi",
            style: TextStyle(
              fontSize: 45.sp,
              fontFamily: 'Roboto-Italic',
              color: Color(0xff959ca7),
            ),
          ),
        ),
      ],
    );
  }

  String getTimeShow() {
    return DateTimeFormat.convertTimeMessageItem(widget.message.ts);
  }
}
