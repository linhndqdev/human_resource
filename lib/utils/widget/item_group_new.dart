import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/message/message_services.dart';
import 'package:human_resource/utils/common/build_item_badge_widget.dart';
import 'package:human_resource/utils/common/cache_helper.dart';
import 'package:human_resource/utils/common/crypto_hex.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/utils/common/datetime_format.dart';
import 'circle_avatar.dart';

class ItemGroupNew extends StatefulWidget {
  final WsRoomModel roomModel;

  const ItemGroupNew({Key key, this.roomModel}) : super(key: key);

  @override
  _ItemGroupNewState createState() => _ItemGroupNewState();
}

class _ItemGroupNewState extends State<ItemGroupNew>
    with AutomaticKeepAliveClientMixin {
  String myUname = "";
  MessageDeleteModel messageDeleteModel = MessageDeleteModel();
  final SlidableController _slidableController = SlidableController();
  AppBloc appBloc;
  String groupname;
  ItemGroupBloc _bloc = ItemGroupBloc();

  @override
  void didUpdateWidget(ItemGroupNew oldWidget) {
    if (widget.roomModel?.lastMessage == null &&
        widget.roomModel?.lastMessage?.id !=
            oldWidget.roomModel.lastMessage?.id) {
      Future.delayed(Duration.zero, () {
        _bloc.getLastMessage(widget.roomModel);
      });
    }
    if (oldWidget.roomModel.usersCount != widget.roomModel.usersCount) {
      Future.delayed(Duration.zero, () {
        if (widget.roomModel != null) _bloc.getMemberGroup(widget.roomModel);
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bloc?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      myUname = await CacheHelper.getUserName();
      if (widget.roomModel != null) _bloc.getMemberGroup(widget.roomModel);
    });
  }

  UnReadCountModel getDefaultUnreadCountData(WsRoomModel roomModel) {
    UnReadCountModel defaultInitData;
    if (appBloc.mainChatBloc.mapDataCountUnread.containsKey(RoomType.p)) {
      defaultInitData = appBloc.mainChatBloc.mapDataCountUnread[RoomType.p]
          .firstWhere((model) => model.rid == roomModel.id,
              orElse: () =>
                  UnReadCountModel(groupname ?? "", roomModel.id, 0, ""));
    } else {
      defaultInitData = UnReadCountModel(groupname ?? "", roomModel.id, 0, "");
    }
    return defaultInitData;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    appBloc = BlocProvider.of(context);

    if (widget.roomModel != null) {
      try {
        groupname = CryptoHex?.deCodeChannelName(widget.roomModel.name);
      } catch (e) {
        return Container();
      }

//      _bloc.getGroupUnreadCount(context, widget.roomModel);
    } else {
      return Container();
    }

    return InkWell(
      onTap: () {
        appBloc.mainChatBloc.openRoom(appBloc, widget.roomModel);
      },
      child: Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(
            left: ScreenUtil().setWidth(
              60.0,
            ),
            top: 20.h),
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      closeOnScroll: true,
                      controller: _slidableController,
                      actionExtentRatio: 0.20,
                      child: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Stack(
                                  overflow: Overflow.visible,
                                  children: <Widget>[
                                    Container(
                                      child: CustomCircleAvatar(
                                        userName: widget
                                            .roomModel.skAccountModel.userName,
                                        size: 131.0,
                                        position: ImagePosition.GROUP,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -5.h,
                                      child: Container(
                                        child: widget.roomModel != null
                                            ? StreamBuilder(
                                                initialData: null,
                                                stream: _bloc
                                                    .listMemberStream.stream,
                                                builder: (buildContext,
                                                    AsyncSnapshot<
                                                            List<RestUserModel>>
                                                        listSnapshot) {
                                                  int size = 0;
                                                  if (!listSnapshot.hasData ||
                                                      listSnapshot.data ==
                                                          null ||
                                                      listSnapshot
                                                              .data.length ==
                                                          0) {
                                                    return Container();
                                                  }
                                                  if (listSnapshot.data.length >
                                                      4)
                                                    size = 4;
                                                  else
                                                    size = listSnapshot
                                                        .data.length;
                                                  return Container(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Stack(
                                                          children: [
                                                            for (int i = 0;
                                                                i < size;
                                                                i++)
                                                              Container(
                                                                width: ScreenUtil()
                                                                    .setWidth(
                                                                        40.0),
                                                                height: ScreenUtil()
                                                                    .setWidth(
                                                                        40.0),
                                                                margin:
                                                                    EdgeInsets
                                                                        .only(
                                                                  top: ScreenUtil()
                                                                      .setHeight(
                                                                          5.0),
                                                                  left: ScreenUtil()
                                                                      .setWidth(i *
                                                                          30.0),
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .white,
                                                                    width: ScreenUtil()
                                                                        .setWidth(
                                                                            2.0),
                                                                  ),
                                                                ),
                                                                child:
                                                                    CustomCircleAvatar(
                                                                  position:
                                                                      ImagePosition
                                                                          .GROUP,
                                                                  size: 20.0,
                                                                  userName:
                                                                      listSnapshot
                                                                          .data[
                                                                              i]
                                                                          .username,
                                                                ),
                                                              ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                })
                                            : Container(),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: 58.w,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: _buildLineName(
                                                  widget.roomModel.lastMessage),
                                            ),
                                            Text(
                                                widget.roomModel?.lastMessage
                                                            ?.ts !=
                                                        null
                                                    ? DateTimeFormat
                                                        .getTimeFrom(widget
                                                            .roomModel
                                                            ?.lastMessage
                                                            ?.ts)
                                                    : widget.roomModel
                                                                .updatedAt !=
                                                            null
                                                        ? DateTimeFormat
                                                            .getTimeFrom(widget
                                                                .roomModel
                                                                ?.updatedAt)
                                                        : " ",
                                                style: TextStyle(
                                                    color: Color(0xff959ca7),
                                                    fontFamily:
                                                        "Roboto-Regular",
                                                    fontSize: 30.0.sp)),
                                            SizedBox(
                                                width: ScreenUtil()
                                                    .setWidth(59.0)),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                          height: ScreenUtil().setHeight(6)),
                                      Row(
                                        children: <Widget>[
                                          widget.roomModel.lastMessage != null
                                              ? _getSubTitle(
                                                  widget.roomModel.lastMessage)
                                              : _getSubTitleHasStream(
                                                  widget.roomModel.lastMessage),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                //nội dung chat và tên người
                              ],
                            ), //Nội dung chính
                            SizedBox(height: 5.h),
                          ],
                        ),
                      ),
                      secondaryActions: <Widget>[]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _getSubTitleHasStream(WsMessage message) {
    return StreamBuilder<WsMessage>(
        initialData: message,
        stream: _bloc.lastMessageStream.stream,
        builder: (context, snapshot) {
          return _getSubTitle(snapshot.data);
        });
  }

  Widget _getSubTitle(WsMessage message) {
    WsAccountModel currentAccount =
        WebSocketHelper.getInstance().wsAccountModel;
    if (message?.file != null) {
      String content = "";
      if (message.skAccountModel.id == currentAccount.id) {
        content = "Bạn: ";
        if (message.file.type.contains("audio")) {
          content += "đã gửi \[Audio\] ";
        } else if (message.file.type.contains("image")) {
          content += "đã gửi \[Hình ảnh\] ";
        } else {
          content += "đã gửi \[Tập tin\] ";
        }
      } else {
        if (message?.skAccountModel != null) {
          if (getNameSendMessage(message.skAccountModel.userName) != null &&
              getNameSendMessage(message.skAccountModel.userName) != "") {
            content =
                getNameSendMessage(message.skAccountModel.userName) + ": ";
          }
        }
        if (message.file.type.contains("audio")) {
          content = "Đã gửi \[Audio\] ";
        } else if (message.file.type.contains("image")) {
          content += "Đã gửi \[Hình ảnh\] ";
        } else {
          content += "Đã gửi \[Tập tin\] ";
        }
      }
      return checkReadAndUnreadSubtext(message, content);
    }
    String msg = message?.msg ?? " ";
//    if (message?.skAccountModel != null) {
//      if (getNameSendMessage(message.skAccountModel.userName) != null &&
//          getNameSendMessage(message.skAccountModel.userName) != "") {
//        msg = getNameSendMessage(message.skAccountModel.userName) +
//                ": " +
//                message?.msg ??
//            " ";
//      }
//    }
    try {
      if (message?.msg != null &&
          message?.msg != "" &&
          message.msg.contains("actions_message_com.asgl.human_resource")) {
        dynamic jsonMessageActionModel = jsonDecode(message?.msg);
        MessageActionsModel messageConver =
            MessageActionsModel.fromJson(jsonMessageActionModel);
        if (message?.messageActionsModel != null &&
            messageConver?.actionType == ActionType.QUOTE) {
          msg = message?.messageActionsModel?.msg ?? messageConver?.msg;
        } else if (message?.messageActionsModel != null &&
            messageConver?.actionType == ActionType.DELETE) {
          msg = "Tin nhắn đã được thu hồi";
        } else if (message?.messageActionsModel != null &&
            messageConver?.actionType == ActionType.FORWARD) {
          msg = message.messageActionsModel?.msg;
        } else if (message?.messageActionsModel != null &&
            messageConver?.actionType == ActionType.NONE) {
          if (message?.messageActionsModel?.msg == null ||
              message?.messageActionsModel?.msg?.trim() == "") {
            msg = message.msg;
          } else {
            msg = message.messageActionsModel.msg;
          }
        }

        if (message?.messageActionsModel?.actionType == ActionType.NONE) {
          if (message?.messageActionsModel?.msg == null ||
              message?.messageActionsModel?.msg?.trim() == "") {
            msg = messageConver.msg;
          } else {
            msg = message.messageActionsModel.msg;
          }
        }
      }
    } catch (e) {
      //print(e.toString());
    }
    if (message != null) {
      if (message.skAccountModel != null) {
        if (message.skAccountModel.id == currentAccount.id) {
          msg = "Bạn: $msg";
        } else if (msg == null)
          msg = "...";
        else {
          if (getNameSendMessage(message.skAccountModel.userName) != null &&
              getNameSendMessage(message.skAccountModel.userName) != "") {
            msg = getNameSendMessage(message.skAccountModel.userName) +
                ": " +
                msg;
          }
        }
      }

      if (message.reactions != null && message.reactions.sumUserReactions > 0) {
        var lstUsername = message.reactions.mapUserReacted.keys.toList();
        String username = lstUsername[0];
        var fullName = getNameSendMessage(username);
        if (fullName == null) {
          if (username == myUname) {
            msg = "Bạn: Đã thể hiện cảm xúc";
          } else {
            msg = "...";
          }
        } else {
          msg = fullName + ": Đã thể hiện cảm xúc";
        }
      }
    } else {
      msg = " ";
    }
    // appBloc.mainChatBloc.listLastMessage.add(message);
    return checkReadAndUnreadSubtext(message, msg);
  }

  Future<String> getUserNAme() async {
    return await CacheHelper.getUserName();
  }

  Widget checkReadAndUnreadSubtext(WsMessage message, String msg) {
    return widget.roomModel != null
        ? StreamBuilder(
            initialData: getDefaultUnreadCountData(widget.roomModel),
            stream: appBloc.mainChatBloc.countUnreadWithRoomIDStream.stream
                .where((model) => model.rid == widget.roomModel.id),
            builder: (buildContext,
                AsyncSnapshot<UnReadCountModel> countUnreadSnap) {
              if (!countUnreadSnap.hasData ||
                  countUnreadSnap.data == null ||
                  countUnreadSnap.data.unreadCount == 0) {
                TextStyle textStyle = TextStyle(
                  fontSize: ScreenUtil().setSp(40.0),
                  color: Color(0xff959ca7),
                  fontFamily: "Roboto-Regular",
                );
                return _buildItemBadge(message, textStyle, msg);
              } else {
                TextStyle textStyle = TextStyle(
                  fontSize: ScreenUtil().setSp(40.0),
                  color: Color(0xFF333333),
                  fontFamily: "Roboto-Regular",
                );
                return _buildItemBadge(message, textStyle, msg);
              }
            })
        : Container();
  }

  String getNameSendMessage(String idMember) {
    String nameUserSendMessage;
    appBloc?.mainChatBloc?.listUserOnChatSystem?.forEach((f) {
      if (idMember.contains(f.username)) {
        nameUserSendMessage = f.name;
      }
    });
    return nameUserSendMessage;
  }

  _buildLineName(WsMessage message) {
    return widget.roomModel != null
        ? StreamBuilder(
            initialData: getDefaultUnreadCountData(widget.roomModel),
            stream: appBloc.mainChatBloc.countUnreadWithRoomIDStream.stream
                .where((model) => model.rid == widget.roomModel.id),
            builder: (buildContext,
                AsyncSnapshot<UnReadCountModel> countUnreadSnap) {
              if (!countUnreadSnap.hasData ||
                  countUnreadSnap.data == null ||
                  countUnreadSnap.data.unreadCount == 0) {
                if (groupname.length >= 45) {
                  String xName = groupname.substring(0, 45);
                  return Text(
                    "$xName ...",
                    style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 45.sp,
                      fontFamily: "Roboto-Regular",
                    ),
                    maxLines: 2,
                  );
                } else {
                  return Text(
                    groupname,
                    style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 45.sp,
                      fontFamily: "Roboto-Regular",
                    ),
                    maxLines: 2,
                  );
                }
              } else {
                if (groupname.length >= 45) {
                  String xName = groupname.substring(0, 45);
                  return Text(
                    "$xName ...",
                    style: TextStyle(
                        color: Color(0xff005a88),
                        fontSize: 45.sp,
                        fontFamily: "Roboto-Bold"),
                    maxLines: 2,
                  );
                } else {
                  return Text(
                    groupname,
                    style: TextStyle(
                        color: Color(0xff005a88),
                        fontSize: 45.sp,
                        fontFamily: "Roboto-Bold"),
                    maxLines: 2,
                  );
                }
              }
            })
        : Container();
  }

  _buildItemBadge(WsMessage message, TextStyle textStyle, String content) {
    return Flexible(
        child: BuildItemBadgeWidget(
      appBloc: appBloc,
      content: content,
      textStyle: textStyle,
      roomModel: widget.roomModel,
      groupName: groupname,
    ));
  }
}

class ItemGroupBloc {
  CoreStream<List<RestUserModel>> listMemberStream = CoreStream();
  CoreStream<int> unreadCountStream = CoreStream();
  CoreStream<WsMessage> lastMessageStream = CoreStream();

  void dispose() {
    lastMessageStream?.closeStream();
    unreadCountStream?.closeStream();
    listMemberStream?.closeStream();
  }

  void getLastMessage(WsRoomModel roomModel) async {
    try {
      List<WsMessage> lastMessage = List<WsMessage>();
      ApiServices apiServices = ApiServices();
      await apiServices.getLastMessageInRoom(roomModel,
          resultData: (resultData) {
        try {
          Iterable iterable = resultData['messages'];
          if (iterable != null && iterable.length > 0) {
            // print('succsess');
            lastMessage = iterable
                .map((user) => WsMessage.fromDirectMessage(user))
                .toList();

            lastMessageStream.notify(lastMessage[0]);
          }
        } catch (ex) {
          lastMessageStream.notify(null);
        }
      }, onErrorApiCallback: (onError) {
        lastMessageStream.notify(null);
      });
    } catch (ex) {}
  }

  void getMemberGroup(WsRoomModel roomModel) async {
    try {
      List<RestUserModel> listUserGroup = List();
      ApiServices apiServices = ApiServices();
      await apiServices.getAllUserOnGroup(roomModel, resultData: (resultData) {
        try {
          Iterable iterable = resultData['members'];
          if (iterable != null && iterable.length > 0) {
            listUserGroup = iterable
                .map((user) => RestUserModel.fromGetAllUser(user))
                .toList();
            listMemberStream.notify(listUserGroup);
          }
        } catch (ex) {
          listMemberStream.notify(listUserGroup);
        }
      }, onErrorApiCallback: (onError) {
        listMemberStream.notify(listUserGroup);
      });
    } catch (ex) {}
  }
}
