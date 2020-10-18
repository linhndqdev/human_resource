import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/screen/main_chat/chat/chat_bloc.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/info/orient_bloc.dart';
import 'package:human_resource/utils/common/const.dart';
import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:human_resource/utils/common/item_message_default_group_new.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/utils/widget/forward_show_message.dart';
import 'package:human_resource/utils/widget/item_show_time_widget.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/widget/quote_show_widget.dart';
import 'package:human_resource/utils/widget/reaction_widget.dart';
import 'package:human_resource/utils/widget/system_message/add_user_message.dart';
import 'package:human_resource/utils/widget/system_message/delete_user_message.dart';
import 'package:human_resource/utils/widget/system_message/leave_room_message.dart';
import 'package:human_resource/utils/widget/system_message/share_owner_message.dart';
import 'package:human_resource/utils/widget/system_message/user_join_mesage.dart';
import 'package:human_resource/utils/widget/text_content_message.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageItem extends StatefulWidget {
  final WsMessage message;
  final bool isShowTime;
  final double marginTop;
  final bool isShowAvatar;
  final bool isOwner; //Tin nhắn của tài khoản này
  final bool isShowDate;
  final bool isShowNewMessage;
  final WsRoomModel roomModel;
  final String userFullName;
  final bool isShowCheckBoxActionBar;
  final VoidCallback onClickStatus;
  final VoidCallback onLongPress;
  final bool isReadMessage;
  final String title;
  final String shortContent;
  final String sendTo;
  const MessageItem({
    Key key,
    this.message,
    this.isShowTime = true,
    this.marginTop = 0.0,
    this.isShowAvatar = false,
    this.isOwner = false,
    this.isShowDate = false,
    this.isShowNewMessage = false,
    this.roomModel,
    this.userFullName,
    this.isShowCheckBoxActionBar = false,
    this.onClickStatus,
    this.onLongPress,
    this.isReadMessage=false,
    this.title,
    this.shortContent,
    this.sendTo
  }) : super(key: key);

  @override
  _MessageItemState createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  OrientBloc orientBloc = OrientBloc();
  AppBloc appBloc;
  MessageDeleteModel messageDeleteModel = MessageDeleteModel();
  GlobalKey _messageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    bool isSystemMessage = widget.message.t == "au" ||
        widget.message.t == "uj" ||
        widget.message.t == "subscription-role-added" ||
        widget.message.t == "ru";
    if (widget.message.t != null && widget.message.t == "le") {
      isSystemMessage = true;
    }
    bool isCheck;
    if (widget.isShowCheckBoxActionBar) {
      if (widget.message.messageActionsModel.actionType == ActionType.DELETE) {
        isCheck = false;
      } else {
        isCheck = true;
      }
    } else {
      isCheck = false;
    }
    return GestureDetector(
      onLongPress: () {
        if (widget.roomModel.name != Const.BAN_TIN &&
            widget.roomModel.name != Const.FAQ &&
            !widget.roomModel.name.contains(Const.THONG_BAO)) {
          appBloc.mainChatBloc.chatBloc.getPositions(_messageKey);
          widget.onLongPress();
        }
      },
      child: Container(
        alignment: AlignmentDirectional.center,
        margin: EdgeInsets.only(top: widget.marginTop),
        child: Column(
          crossAxisAlignment: isSystemMessage
              ? CrossAxisAlignment.center
              : widget.isOwner
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.isShowDate)
              Align(
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: prefix0.accentColor,
                    borderRadius: BorderRadius.circular(
                        SizeRender.renderBorderSize(context, 5.0)),
                  ),
                  margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(36.0)),
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
              ),
            _buildTypeMessage(),
//            if (widget.isShowTime && !isSystemMessage)
//              SizedBox(
//                height: ScreenUtil().setHeight(10.0),
//              ),
            ItemShowTimeWidget(
              isOwner: widget.isOwner,
              message: widget.message,
              isSystemMessage: isSystemMessage,
              isCheck: isCheck,
              isShowTime: widget.isShowTime,
              isSending: widget.message.isSending,
              wsRoomModel: widget.roomModel,
            ),
            SizedBox(
              height: ScreenUtil().setHeight(13.8),
            )
          ],
        ),
      ),
    );
  }

  _buildTypeMessage() {
    //Nếu là tin nhắn hệ thống thông báo thêm người dùng vào phòng
    if (widget.message.t == "au") {
      return AddUserMessage(
        fullName: getUser(widget.message.msg),
        adminGroupFullname: getUser(widget.message.skAccountModel.userName),
      );
    } else if (widget.message.t == "uj") {
      //Nếu là tin nhắn thông báo người dùng tự tham gia vào phòng
      return UserJoinMessage(
        message: widget.message,
        userName: getUser(widget.message.msg),
      );
    } else if (widget.message.t == "ru") {
      //Nếu là tin nhắn người dùng bị xóa khỏi phòng
      return DeleteUserMessage(
        fullName: getUser(widget.message.msg),
        adminGroupFullname: getUser(widget.message.skAccountModel.userName),
      );
    } else if (widget.message.t == "le") {
      return LeaveRoomWidget(
        fullName: getUser(widget.message.msg),
      );
    } else if (widget.message.t == "subscription-role-added") {
      return SharedOwnerMessage(
        userFullName: getUser(widget.message.msg),
      );
    } else {
      //Nếu là tin nhắn bình thường
      return widget.isOwner ? buildRTL() : buildLTR();
    }
  }

  String getUser(String userName) {
    AppBloc appBloc = BlocProvider.of(context);
    if (userName == "asglchat") {
      return "ASGL ADMIN";
    } else if (userName == appBloc.authBloc.asgUserModel.username) {
      return appBloc.authBloc.asgUserModel.full_name;
    } else {
      AppBloc appBloc = BlocProvider.of(context);
      AddressBookModel model = appBloc.mainChatBloc.listUserOnChatSystem
          ?.firstWhere((user) => user.username == userName, orElse: () => null);
      if (model != null) {
        return model.name ?? userName;
      }
      return userName;
    }
  }

  //Tin nhắn là của người dùng đang đăng nhập gửi
  Widget buildRTL() {
    bool isCheckRTL;
    if (widget.isShowCheckBoxActionBar) {
      if (widget.message.messageActionsModel.actionType == ActionType.DELETE) {
        isCheckRTL = false;
      } else {
        isCheckRTL = true;
      }
    } else {
      isCheckRTL = false;
    }

    return Stack(
      children: <Widget>[
        isCheckRTL
            ? Positioned(
          bottom: 5.0,
          left: 60.w,
          child: InkWell(
            onTap: () {
              appBloc.mainChatBloc.chatBloc.pickMessage(widget.message);
            },
            child: StreamBuilder(
                initialData: appBloc.mainChatBloc.chatBloc
                    ?.mapMessagePicked[widget.message] ??
                    false,
                stream: appBloc.mainChatBloc.chatBloc
                    .chooseMultilMessageStream.stream,
                builder: (buildContext, snapShotData) {
                  bool isCheck;
                  if (appBloc.mainChatBloc.chatBloc
                      ?.mapMessagePicked[widget.message] !=
                      null) {
                    isCheck = appBloc.mainChatBloc.chatBloc
                        ?.mapMessagePicked[widget.message];
                  } else {
                    isCheck = false;
                  }

                  if (snapShotData.data) {
                    return isCheck
                        ? Image.asset(
                      'asset/images/ic_enable_radiobox.png',
                      height: 60.h,
                      width: 60.w,
                    )
                        : Image.asset(
                      'asset/images/ic_disable_radiobox.png',
                      height: 60.h,
                      width: 60.w,
                    );
                  } else {
                    return Image.asset(
                      'asset/images/ic_disable_radiobox.png',
                      height: 60.h,
                      width: 60.w,
                    );
                  }
                }),
          ),
        )
            : Container(),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            key: _messageKey,
            child: buildContentMessage(
                Alignment.bottomRight,
                prefix0.accentColor,
                [
                  BoxShadow(
                    spreadRadius: 0.0,
                    blurRadius: SizeRender.renderBorderSize(context, 25.0),
                    color: Color.fromRGBO(0, 0, 0, 0.16),
                    offset: Offset(
                      0.0, // horizontal, move right 10
                      ScreenUtil().setHeight(13), // vertical, move down 10
                    ),
                  )
                ],
                Colors.white,
                true),
          ),
        ),
      ],
    );
  }

  //Tin nhắn của người khác gửi đến
  Widget buildLTR() {
    bool isCheckLTR;
    if (widget.isShowCheckBoxActionBar) {
      if (widget.message.messageActionsModel.actionType == ActionType.DELETE) {
        isCheckLTR = false;
      } else {
        isCheckLTR = true;
      }
    } else {
      isCheckLTR = false;
    }
    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: <Widget>[
        Positioned(
          bottom: 0.0,
          left: isCheckLTR ? 70.w : 0,
          child: buildAvatar(),
        ),
        isCheckLTR
            ? Positioned(
                bottom: 5.0,
                left: 60.w,
                child: InkWell(
                  onTap: () {
                    appBloc.mainChatBloc.chatBloc.pickMessage(widget.message);
                  },
                  child: StreamBuilder(
                      initialData: appBloc.mainChatBloc.chatBloc
                              ?.mapMessagePicked[widget.message] ??
                          false,
                      stream: appBloc.mainChatBloc.chatBloc
                          .chooseMultilMessageStream.stream,
                      builder: (buildContext, snapShotData) {
                        bool isCheck;
                        if (appBloc.mainChatBloc.chatBloc
                                ?.mapMessagePicked[widget.message] !=
                            null) {
                          isCheck = appBloc.mainChatBloc.chatBloc
                              ?.mapMessagePicked[widget.message];
                        } else {
                          isCheck = false;
                        }

                        if (snapShotData.data) {
                          return isCheck
                              ? Image.asset(
                                  'asset/images/ic_enable_radiobox.png',
                                  height: 60.h,
                                  width: 60.w,
                                )
                              : Image.asset(
                                  'asset/images/ic_disable_radiobox.png',
                                  height: 60.h,
                                  width: 60.w,
                                );
                        } else {
                          return Image.asset(
                            'asset/images/ic_disable_radiobox.png',
                            height: 60.h,
                            width: 60.w,
                          );
                        }
                      }),
                ),
              )
            : Container(),
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(left: isCheckLTR ? 70.w : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if ((widget.userFullName != null &&
                          widget.userFullName != "") &&
                      widget.roomModel.roomType == RoomType.p &&
                      widget.roomModel.name != Const.FAQ &&
                      widget.roomModel.name != Const.BAN_TIN &&
                      widget.roomModel.name != Const.THONG_BAO)
                    Container(
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
                    ),
                  Container(
                    key: _messageKey,
                    child: buildContentMessage(
                        Alignment.bottomLeft,
                        widget.isShowNewMessage
                            ? prefix0.accentColor
                            : prefix0.grey1Color,
                        null,
                        widget.isShowNewMessage
                            ? prefix0.white
                            : prefix0.blackColor333,
                        false),
                  )
                ],
              ),
            )),
      ],
    );
  }

  //Hiển thị avatar
  ///widget.roomModel.roomType == RoomType.p => Nhóm private
  ///widget.roomModel.roomType == RoomType.d => Tin nhắn riêng tư
  ///widget.roomModel.name == Const.BAN_TIN => Dùng trong màn hình Bản tin
  ///widget.roomModel.name.contains(Const.THONG_BAO => Dùng trong màn hình Thông báo
  ///widget.roomModel.name == Const.FAQ => Dùng trong màn hình FAQ
  Widget buildAvatar() {
    if (widget.roomModel.roomType == RoomType.p) {
      if (widget.roomModel.name == Const.BAN_TIN) {
        return Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(63.1),
                top: ScreenUtil().setHeight(16.6)),
            child: Image.asset("asset/images/group_10128.png",
                width: ScreenUtil().setWidth(80.0),
                height: ScreenUtil().setHeight(80.0)));
      } else if (widget.roomModel.name.contains(Const.THONG_BAO)) {
        return Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(63.1),
                top: ScreenUtil().setHeight(16.6)),
            child: Image.asset("asset/images/group-10353@3x.png",
                width: ScreenUtil().setWidth(80.0),
                height: ScreenUtil().setHeight(80.0)));
      } else if (widget.roomModel.name == Const.FAQ) {
        return Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(63.1),
                top: ScreenUtil().setHeight(16.6)),
            child: Image.asset("asset/images/group_9906.png",
                width: ScreenUtil().setWidth(80.0),
                height: ScreenUtil().setHeight(80.0)));
      } else {
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
      }
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

  //Hiển thị nội dung tin nhắn
  //Tất cả các màn hình: BẢn tin, thông báo, tin nhắn riêng, tin nhắn nhóm đều dùng thằng này để hiển thị nội dung tin nhắn
  Widget buildContentMessage(Alignment timeAlign, Color color,
      List<BoxShadow> boxShadow, Color textColor, bool isRTL) {
    if (appBloc.authBloc.asgUserModel.username == widget.message.msg) {
      return Container();
    }
    bool isHasUrl = false;
    if (widget.message != null &&
        widget.message?.msg != null &&
        widget.message?.messageActionsModel?.actionType == ActionType.NONE) {
      isHasUrl = widget.message.msg.contains("https") ||
          widget.message.msg.contains("http");
    }

    if (widget.roomModel.name == Const.BAN_TIN) {
      OrientLayoutDetailDATAModel data = OrientLayoutDetailDATAModel(
          message: widget.message,
          isHasUrl: isHasUrl,
          wsRoomModel: widget.roomModel);
      return ItemMessageDefaultGroupNew(
        message: widget.message,
        isHasUrl: isHasUrl,
        wsRoomModel: widget.roomModel,
        onClickItem: () {
//          appBloc.mainChatBloc.chatBloc.layoutDetailStream.notify(
//              OrientLayoutDetailModel(isShowDetail: true, data: data));
             // print(widget.message.id);
        },
        isReadMessage: widget.isReadMessage,
        title: widget.title,
        shortContent: widget.shortContent,
      );
    }
    if (widget.roomModel.name.contains(Const.THONG_BAO)) {
      OrientLayoutDetailDATAModel data = OrientLayoutDetailDATAModel(
          message: widget.message,
          isHasUrl: isHasUrl,
          wsRoomModel: widget.roomModel,
          sendTo: widget.sendTo,
      );
      return ItemMessageDefaultGroupNew(
        message: widget.message,
        isHasUrl: isHasUrl,
        sendTo: widget.sendTo,
        wsRoomModel: widget.roomModel,
        isReadMessage: widget.isReadMessage,
        onClickItem: () {
//          appBloc.mainChatBloc.chatBloc.layoutDetailStream.notify(
//              OrientLayoutDetailModel(isShowDetail: true, data: data));
          //print(widget.message.id);
        },
        title: widget.title,
        shortContent: widget.shortContent,
      );
    }
    if (widget.message?.messageActionsModel != null &&
        widget.message?.messageActionsModel?.actionType == ActionType.QUOTE) {
      return _buildQuoteMessage(
          timeAlign, color, boxShadow, textColor, isHasUrl, isRTL);
    } else if (widget.message?.messageActionsModel != null &&
        widget.message?.messageActionsModel?.actionType == ActionType.FORWARD) {
      return ForwardShowMessage(
        color: color,
        message: widget.message,
        boxShadow: boxShadow,
        isHasUrl: isHasUrl,
        textColor: textColor,
        isOwner: widget.isOwner,
        showDetailReact: () {
          widget.onClickStatus();
        },
        isRTL: isRTL,
      );
    }

    return ColumnSuper(
      alignment: widget.isOwner ? Alignment.centerRight : Alignment.centerLeft,
      outerDistance: 10.0.h,
      innerDistance: -46.0.h,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              widget.isOwner ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 182.0.w,
            ),
            if (widget.isOwner &&
                widget.message.messageActionsModel != null &&
                widget.message.messageActionsModel.isEdited)
              Container(
                margin: EdgeInsets.only(right: 12.0.w),
                child: Image.asset(
                  "asset/images/action/ic_edit_owner.png",
                  width: 27.0.w,
                ),
              ),
            Container(
              constraints: BoxConstraints(
                maxWidth: ScreenUtil().setWidth(751),
              ),
              margin: EdgeInsets.only(
                bottom: ScreenUtil().setHeight(20.0),
              ),
              padding: widget.message.file != null
                  ? EdgeInsets.zero
                  : EdgeInsets.only(
                      top: ScreenUtil().setHeight(21.0),
                      bottom: ScreenUtil().setHeight(21.0),
                      left: ScreenUtil().setWidth(25.6),
                      right: ScreenUtil().setWidth(25.6)),
              decoration: BoxDecoration(
//                  borderRadius: getBorder(),
                //chỗ này mới Tân mới sửa lại theo zeplin
                borderRadius:
                    BorderRadius.circular(ScreenUtil().setWidth(40.0)),
                boxShadow: boxShadow,
                color: widget.isOwner
                    ? prefix0.accentColor
                    : widget.isShowNewMessage
                        ? prefix0.accentColor
                        : prefix0.white,
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
                      isHasUrl
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
                                  color: textColor,
                                  fontSize: ScreenUtil().setSp(45.0)),
                              text: widget.message.msg,
                              style: TextStyle(
                                  fontFamily: 'Roboto-Regular',
                                  color: textColor,
                                  fontSize: ScreenUtil().setSp(45.0)),
                            )
                          : TextContentMessage(
                              textColor: textColor,
                              message: widget.message,
                              isOwner: widget.isOwner,
                              wsRoomModel: widget.roomModel,
                            ),
                    ]),
              ),
            ),
            if (!widget.isOwner &&
                (widget.message.messageActionsModel != null &&
                    widget.message.messageActionsModel.isEdited))
              Container(
                margin: EdgeInsets.only(left: 12.0.w),
                child: Image.asset(
                  "asset/images/action/ic_edit_other.png",
                  width: 27.0.w,
                ),
              ),
            SizedBox(width: 59.0.w)
          ],
        ),
        widget.message.reactions.isHasReact
            ? Container(
                margin: EdgeInsets.only(
                    left: !widget.isOwner ? (182.0 + 30.0).w : 0.0,
                    right: widget.isOwner ? (75.0).w : 0.0),
                child: ReactionWidgetShow(
                  message: widget.message,
                  showDetailReact: () {
                    widget.onClickStatus();
                  },
                ),
              )
            : Container()
      ],
    );
  }

  Widget buildLineTimeAndStatus() {
    String time = DateTimeFormat.getHourAndMinuteFrom(widget.message.ts);
    return Container(
      height: ScreenUtil().setHeight(39.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            time,
            style: prefix0.text14BlackBold,
          )
        ],
      ),
    );
  }

  String getTimeShow() {
    return DateTimeFormat.convertTimeMessageItem(widget.message.ts);
  }

  Widget _buildQuoteMessage(Alignment timeAlign, Color color,
      List<BoxShadow> boxShadow, Color textColor, bool isHasUrl, bool isRTL) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: ScreenUtil().setWidth(751),
      ),
      margin: EdgeInsets.only(
        left: ScreenUtil().setWidth(182.0),
        right: ScreenUtil().setWidth(59.0),
        top: ScreenUtil().setHeight(10.0),
        bottom: ScreenUtil().setHeight(3.0),
      ),
      decoration: BoxDecoration(
        borderRadius: getBorder(),
        color: Colors.transparent,
      ),
      child: Container(
        constraints: BoxConstraints(
          minWidth: ScreenUtil().setWidth(250.0),
        ),
        child: ColumnSuper(
          outerDistance: 0.0,
          alignment:
              widget.isOwner ? Alignment.centerRight : Alignment.centerLeft,
          innerDistance: -60.0.h,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: widget.isOwner
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (widget.isOwner &&
                    widget.message.messageActionsModel != null &&
                    widget.message.messageActionsModel.isEdited)
                  Container(
                    margin: EdgeInsets.only(right: 12.0.w),
                    child: Image.asset(
                      "asset/images/action/ic_edit_owner.png",
                      width: 27.0.w,
                    ),
                  ),
                Flexible(
                  fit: FlexFit.loose,
                  child: QuoteShowWidget(
                    isOwner: widget.isOwner,
                    message: widget.message,
                  ),
                ),
                if (!widget.isOwner &&
                    (widget.message.messageActionsModel != null &&
                        widget.message.messageActionsModel.isEdited))
                  Container(
                    margin: EdgeInsets.only(left: 12.0.w),
                    child: Image.asset(
                      "asset/images/action/ic_edit_other.png",
                      width: 27.0.w,
                    ),
                  ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: widget.isOwner
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                isHasUrl
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
                            color: textColor,
                            fontSize: ScreenUtil().setSp(45.0)),
                        text: widget.message.msg,
                        style: TextStyle(
                            fontFamily: 'Roboto-Regular',
                            color: textColor,
                            fontSize: ScreenUtil().setSp(45.0)),
                      )
                    : ColumnSuper(
                        alignment: widget.isOwner
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        innerDistance: -23.0.h,
                        outerDistance: 5.0.h,
                        children: <Widget>[
                          Container(
                            constraints: BoxConstraints(
                              minWidth: ScreenUtil().setWidth(
                                  widget.message.reactions.isHasReact
                                      ? 250.0
                                      : 80.0),
                              minHeight: ScreenUtil().setHeight(62.0),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: getBorder(),
                              color: widget.isOwner
                                  ? prefix0.accentColor
                                  : Color(0xFFf8f8f8),
                            ),
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(20.0),
                                bottom: ScreenUtil().setHeight(20.0),
                                left: ScreenUtil().setWidth(25.6),
                                right: ScreenUtil().setWidth(25.6)),
                            child: _buildTextQuoteAndTag(textColor),
                          ),
                          widget.message.reactions.isHasReact
                              ? Container(
                                  margin: EdgeInsets.only(
                                      left: !widget.isOwner ? (75.0).w : 0.0,
                                      right: widget.isOwner ? (10.0).w : 0.0),
                                  child: ReactionWidgetShow(
                                    message: widget.message,
                                    showDetailReact: () {
                                      widget.onClickStatus();
                                    },
                                  ))
                              : Container(),
                        ],
                      )
              ],
            )
          ],
        ),
      ),
    );
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

  Widget customPositioned({Widget child}) {
    if (widget.isOwner) {
      return Positioned(
        child: child,
        bottom: 0.0,
        right: 0.0,
      );
    } else {
      return Positioned(
        child: child,
        bottom: 0.0,
        left: 0.0,
      );
    }
  }

  _buildTextQuoteAndTag(Color textColor) {
    if (widget?.message?.messageActionsModel?.mentions != null &&
        widget?.message?.messageActionsModel?.mentions?.mentions != null &&
        widget.message.messageActionsModel.mentions.mentions.length > 0) {
      List<TextSpan> listTextTagShow = List();
      List<TextSpan> listNormal = List();
      String msg = widget.message.messageActionsModel.msg;
      widget.message.messageActionsModel?.mentions?.mentions
          ?.forEach((userMention) {
        if (msg.contains(userMention.fullName)) {
          int index = msg.indexOf(userMention.fullName);
          TextSpan textSpan = TextSpan(
              text: userMention.fullName + " ",
              style: TextStyle(
                  color: prefix0.orangeColor,
                  fontFamily: 'Roboto-Regular',
                  fontSize: ScreenUtil().setSp(45.0)));
          listTextTagShow.add(textSpan);
          if (index != 0) {
            msg =
                msg.replaceFirst(userMention.fullName, ";com.asgl.pasrer.tag;");
          } else {
            msg = msg.replaceFirst(
                userMention.fullName, ";;com.asgl.pasrer.tag;");
          }
        }
      });
      List<String> contents = msg.split(";com.asgl.pasrer.tag;");
      if (contents != null && contents.length > 0) {
        contents?.forEach((content) {
          if (content.trim().toString() != "") {
            TextSpan textSpan = TextSpan(
                text: content + " ",
                style: TextStyle(
                    color:
                        widget.isOwner ? prefix0.white : prefix0.blackColor333,
                    fontFamily: 'Roboto-Regular',
                    fontSize: ScreenUtil().setSp(45.0)));
            listNormal.add(textSpan);
          }
        });
      }

      List<TextSpan> mergeList = List();
      if (listNormal == null || listNormal.length == 0) {
        mergeList.addAll(listNormal);
      } else {
        int size = listTextTagShow.length > listNormal.length
            ? listTextTagShow.length
            : listNormal.length;
        for (int i = 0; i < size; i++) {
          if (i < listNormal.length) {
            if (i == 0) {
              if (contents[0] != ";") {
                mergeList.add(listNormal[i]);
              }
            } else {
              mergeList.add(listNormal[i]);
            }
          }

          if (i < listTextTagShow.length) {
            mergeList.add(listTextTagShow[i]);
          }
        }
      }
      return RichText(text: TextSpan(children: mergeList));
    }
    return StreamBuilder(
      initialData: appBloc.mainChatBloc.chatBloc.searchData,
      stream: appBloc.mainChatBloc.chatBloc.searchDataStream.stream,
      builder: (BuildContext searchContext, AsyncSnapshot<String> snapshot) {
        return SubstringHighlight(
          text: widget.message.messageActionsModel.msg,
          term: snapshot?.data?.trim() ?? "",
          textStyleHighlight: TextStyle(
              fontFamily: 'Roboto-Regular',
              color: Colors.red,
              fontSize: ScreenUtil().setSp(45.0)),
          textStyle: getTextStyle(textColor),
        );
      },
    );
  }
}
