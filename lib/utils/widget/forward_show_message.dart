import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/animation/icon_status_message_animation.dart';
import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/reaction_widget.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:url_launcher/url_launcher.dart';

class ForwardShowMessage extends StatefulWidget {
  final WsMessage message;
  final List<BoxShadow> boxShadow;
  final Color color;
  final isHasUrl;
  final Color textColor;
  final bool isOwner;
  final bool isRTL;
  final VoidCallback showDetailReact;

  const ForwardShowMessage(
      {Key key,
      this.message,
      this.boxShadow,
      this.color,
      this.isHasUrl = false,
      this.textColor,
      this.isOwner,
      this.isRTL,
      this.showDetailReact})
      : super(key: key);

  @override
  _ForwardShowMessageState createState() => _ForwardShowMessageState();
}

class _ForwardShowMessageState extends State<ForwardShowMessage> {
  AppBloc appBloc;

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return Column(
      crossAxisAlignment:
          widget.isOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        for (MessageForwardModel model
            in widget.message?.messageActionsModel?.forwards)
          _buildItemForward(model),
        ColumnSuper(
            alignment:
                widget.isOwner ? Alignment.centerRight : Alignment.centerLeft,
            innerDistance: -23.0.h,
            outerDistance: 5.0,
            children: <Widget>[
              if (widget.message?.messageActionsModel?.forwards != null &&
                  widget.message.messageActionsModel.forwards.length > 0)
                Container(
                  margin: EdgeInsets.only(
                      left: 182.0.w, right: 67.6.w, top: 6.0.h, bottom: 23.0.h),
                  child: Text(
                    "Chia sẻ ${widget.message?.messageActionsModel?.forwards?.length ?? 0} tin nhắn",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontFamily: "Roboto-Regular",
                        fontSize: 25.0.sp,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: prefix0.color959ca7),
                  ),
                ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: ScreenUtil().setWidth(751),
                ),
                margin: EdgeInsets.only(
                  left: ScreenUtil().setWidth(182.0),
                  right: ScreenUtil().setWidth(59.0),
                ),
                padding: widget.message.file != null
                    ? EdgeInsets.zero
                    : EdgeInsets.only(
                        top: ScreenUtil().setHeight(21.0),
                        bottom: ScreenUtil().setHeight(21.0),
                        left: ScreenUtil().setWidth(25.6),
                        right: ScreenUtil().setWidth(25.6)),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(ScreenUtil().setWidth(25.0)),
                  boxShadow: widget.boxShadow,
                  color:
                      widget.isOwner ? prefix0.accentColor : Color(0xFFf8f8f8),
                ),
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: ScreenUtil().setWidth(
                        widget.message.reactions.isHasReact ? 250.0 : 80.0),
                    minHeight: ScreenUtil().setHeight(62.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      widget.isHasUrl
                          ? Linkify(
                              onOpen: (link) async {
                                if (await canLaunch(link.url)) {
                                  await launch(link.url);
                                } else {
                                  Toast.showShort("Không thể mở đường dẫn");
                                }
                              },
                              linkStyle: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontFamily: 'Roboto-Regular',
                                  color: widget.textColor,
                                  fontSize: ScreenUtil().setSp(45.0)),
                              text: widget.message.msg,
                              style: TextStyle(
                                  fontFamily: 'Roboto-Regular',
                                  color: widget.textColor,
                                  fontSize: ScreenUtil().setSp(45.0)),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: widget.isOwner
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                _editedIconOwner(),
                                StreamBuilder(
                                  initialData:
                                      appBloc.mainChatBloc.chatBloc.searchData,
                                  stream: appBloc.mainChatBloc.chatBloc
                                      .searchDataStream.stream,
                                  builder: (BuildContext searchContext,
                                      AsyncSnapshot<String> snapshot) {
                                    return Flexible(
                                      child: SubstringHighlight(
                                        text: widget
                                            .message.messageActionsModel.msg,
                                        term: snapshot?.data?.trim() ?? "",
                                        textStyleHighlight: TextStyle(
                                            fontFamily: 'Roboto-Regular',
                                            color: Colors.red,
                                            fontSize: ScreenUtil().setSp(42.0)),
                                        textStyle: TextStyle(
                                            fontFamily: 'Roboto-Regular',
                                            color: widget.textColor,
                                            fontSize: ScreenUtil().setSp(42.0)),
                                      ),
                                    );
                                  },
                                ),
                                _editedIconOther()
                              ],
                            ),
                    ],
                  ),
                ),
              ),
              widget.message.reactions.isHasReact
                  ? Container(
                      margin: EdgeInsets.only(
                          left: !widget.isOwner ? (182.0 + 75.0).w : 0.0,
                          right: widget.isOwner ? (75.0).w : 0.0),
                      child: ReactionWidgetShow(
                        message: widget.message,
                        showDetailReact: () {
                          widget.showDetailReact();
                        },
                      ),
                    )
                  : Container(),
            ])
      ],
    );
  }

  Widget _editedIconOwner() {
    if (widget.isOwner) {
      if (widget.message.messageActionsModel != null &&
          widget.message.messageActionsModel.isEdited) {
        return Container(
          margin: EdgeInsets.only(right: 12.0.w),
          child: Image.asset(
            "asset/images/action/ic_edit_owner.png",
            width: 27.0.w,
          ),
        );
      }
    }
    return Container();
  }

  Widget _editedIconOther() {
    if (!widget.isOwner) {
      if (widget.message.messageActionsModel != null &&
          widget.message.messageActionsModel.isEdited) {
        return Container(
          margin: EdgeInsets.only(left: 12.0.w),
          child: Image.asset(
            "asset/images/action/ic_edit_other.png",
            width: 27.0.w,
          ),
        );
      }
    }
    return Container();
  }

  TextStyle getTextStyle(Color textColor) {
    if (widget.message.messageActionsModel != null &&
        widget.message.messageActionsModel.actionType == ActionType.DELETE) {
      return TextStyle(
          fontFamily: 'Roboto-Italic',
          color: Color(0xff959ca7),
          fontSize: ScreenUtil().setSp(45.0));
    } else {
      return TextStyle(
          fontFamily: 'Roboto-Regular',
          color: textColor,
          fontSize: ScreenUtil().setSp(45.0));
    }
  }

  BorderRadius getBorder() {
    return widget.isOwner
        ? BorderRadius.only(
            topLeft: Radius.circular(35.0.w),
            topRight: Radius.circular(15.0.w),
            bottomLeft: Radius.circular(35.0.w),
            bottomRight: Radius.circular(15.0.w))
        : BorderRadius.only(
            topLeft: Radius.circular(15.0.w),
            topRight: Radius.circular(35.0.w),
            bottomLeft: Radius.circular(15.0.w),
            bottomRight: Radius.circular(35.0.w));
  }

  _buildItemForward(MessageForwardModel model) {
    return Container(
      margin:
          EdgeInsets.only(top: 10.0.h, right: widget.isOwner ? 59.0.w : 0.0),
      child: Row(
        mainAxisAlignment:
            widget.isOwner ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 182.0.w,
          ),
          if (widget.isOwner)
            Container(
              margin: EdgeInsets.only(right: 11.0.w),
              child: Image.asset(
                "asset/images/action/ic_check_forward.png",
                width: 32.0.w,
              ),
            ),
          Container(
              constraints: BoxConstraints(maxWidth: 751.0.w),
              decoration: BoxDecoration(
                  color: Color(0xFFe8e8e8), borderRadius: getBorder()),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 27.0.w,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 30.0.h),
                        child: Image.asset(
                          "asset/images/action/ic_quote_check.png",
                          width: 48.0.w,
                        ),
                      ),
                      Flexible(
                        child: Container(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            SizedBox(
                              height: 16.6.h,
                            ),
                            _buildItemForwardName(model),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                      text: model.contentMsg,
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 45.0.sp,
                                          fontWeight: FontWeight.normal,
                                          color: prefix0.blackColor333,
                                          fontFamily: "Roboto-Regular"))
                                ]),
                              ),
                            ),
                            SizedBox(
                              height: 9.0.h,
                            )
                          ],
                        )),
                      ),
                      SizedBox(
                        width: 43.0.w,
                      ),
                    ],
                  ),
                ],
              )),
          if (!widget.isOwner)
            Container(
              margin: EdgeInsets.only(left: 11.0.w),
              child: Image.asset(
                "asset/images/action/ic_forward_check_ltr.png",
                width: 32.0.w,
              ),
            ),
        ],
      ),
    );
  }

  _buildItemForwardName(MessageForwardModel model) {
    String fullName = "";
    if (model.ownerMsg == appBloc.authBloc.asgUserModel.username) {
      fullName = appBloc.authBloc.asgUserModel.full_name;
    } else {
      ASGUserModel userModel = appBloc.calendarBloc.listASGLUserModel
          ?.firstWhere((user) => model.ownerMsg == user.username,
              orElse: () => null);
      if (userModel != null) {
        fullName = userModel.full_name;
      }
    }
    String time = "";
    if (model.time != null && model.time != "") {
      try {
        time = DateTimeFormat.convertTimeMessageItem(int.parse(model.time));
      } catch (ex) {}
    }
    return Container(
        margin: EdgeInsets.only(bottom: 7.4.h),
        child: RichText(
          text: TextSpan(children: [
            if (fullName != "")
              TextSpan(
                  text: fullName + " ",
                  style: TextStyle(
                      fontFamily: "Roboto-Regular",
                      fontSize: 25.0.sp,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: prefix0.accentColor)),
            if (time != "")
              TextSpan(
                  text: time,
                  style: TextStyle(
                      fontFamily: "Roboto-Regular",
                      fontSize: 25.0.sp,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.normal,
                      color: prefix0.accentColor)),
          ]),
        ));
  }
}
