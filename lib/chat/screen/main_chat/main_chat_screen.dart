import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/message/message_services.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/home/meeting/action_meeting/item_user_online.dart';
import 'package:human_resource/utils/common/build_item_badge_widget.dart';
import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:human_resource/utils/widget/custom_behavior.dart';
import 'package:human_resource/utils/widget/list_private_group.dart';
import 'package:human_resource/utils/widget/loading_indicator.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:human_resource/utils/widget/user_status_widget.dart';

class MainChatScreen extends StatefulWidget {
  const MainChatScreen({
    Key key,
  }) : super(key: key);

  @override
  _MainChatScreenState createState() => _MainChatScreenState();
}

class _MainChatScreenState extends State<MainChatScreen> {
  AppBloc appBloc;
  MessageDeleteModel messageDeleteModel = MessageDeleteModel();

  @override
  void initState() {
    super.initState();
    if (WebSocketHelper.getInstance().isLoginChat) {
      Future.delayed(Duration.zero, () async {
        appBloc.mainChatBloc.context = context;
        appBloc.mainChatBloc.getChatData();//lay list cac nhom chat
        appBloc.mainChatBloc.getAllUnReadMessage();
      });
    } else {
      Future.delayed(Duration.zero, () {
        appBloc.authBloc.allowGotoHome = false;
        appBloc.mainChatBloc.loginChat(context);
      });
    }
    Future.delayed(Duration.zero, () {
      appBloc.mainChatBloc.checkUserOnline(context);
    });
  }

  @override
  void dispose() {
    appBloc.mainChatBloc.cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return _buildLayoutchatNew();
  }

  _buildLayoutchatNew() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: Container(),
        titleSpacing: 0.0,
        centerTitle: true,
        backgroundColor: prefix0.accentColor,
        title: Text("Trò chuyện",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xffffffff),
                fontSize: ScreenUtil().setSp(60.0),
                fontFamily: "Roboto-Bold",
                fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<ListTabModel>(
          initialData: ListTabModel(tab: ListTabState.NHAN_TIN),
          stream: appBloc.mainChatBloc.listTabStream.stream,
          builder: (context, AsyncSnapshot<ListTabModel> snapListTab) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Color(0xff005a88),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(60.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: InkWell(
                                  onTap: () {
                                    appBloc.mainChatBloc.listTabStream.notify(
                                        ListTabModel(
                                            tab: ListTabState.NHAN_TIN));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 35.6.h),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text("Nhắn tin",
                                              textAlign: TextAlign.center,
                                              style: snapListTab.data.tab ==
                                                      ListTabState.NHAN_TIN
                                                  ? prefix0
                                                      .textStyle1TroChuyen_Focus
                                                  : prefix0
                                                      .textStyle1TroChuyen_UnFocus),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          StreamBuilder(
                                              initialData: appBloc
                                                  .mainChatBloc.unReadDirect,
                                              stream: appBloc
                                                  .mainChatBloc
                                                  .countUnreadDirectStream
                                                  .stream,
                                              builder: (buildContext,
                                                  AsyncSnapshot<int>
                                                      countAllUnreadDirect) {
                                                return countAllUnreadDirect
                                                            .data ==
                                                        0
                                                    ? Container(
                                                        decoration: snapListTab
                                                                    .data.tab ==
                                                                ListTabState
                                                                    .NHAN_TIN
                                                            ? prefix0
                                                                .boxDecorationTrochuyen_Focus
                                                            : prefix0
                                                                .boxDecorationTrochuyen_UnFocus,
                                                      )
                                                    : Container(
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        25.w)),
                                                            child: Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                      minWidth:
                                                                          50.w),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(7.w),
                                                              color: Colors
                                                                  .red[900],
                                                              child: Center(
                                                                child: Text(
                                                                  countAllUnreadDirect
                                                                      .data
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          30.sp),
                                                                ),
                                                              ),
                                                            )),
                                                      );
                                              })
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                            Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: InkWell(
                                  onTap: () {
                                    appBloc.mainChatBloc.listTabStream.notify(
                                        ListTabModel(tab: ListTabState.NHOM));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 35.6.h),
                                    child: Center(
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                          Text("Nhóm",
                                              textAlign: TextAlign.center,
                                              style: snapListTab.data.tab ==
                                                      ListTabState.NHOM
                                                  ? prefix0
                                                      .textStyle1TroChuyen_Focus
                                                  : prefix0
                                                      .textStyle1TroChuyen_UnFocus),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          StreamBuilder(
                                              initialData: appBloc
                                                  .mainChatBloc.unReadPrivate,
                                              stream: appBloc
                                                  .mainChatBloc
                                                  .countUnreadPrivateStream
                                                  .stream,
                                              builder: (buildContext,
                                                  AsyncSnapshot<int>
                                                      countAllUnreadPrivate) {
                                                return countAllUnreadPrivate
                                                            .data ==
                                                        0
                                                    ? Container(
                                                        decoration: snapListTab
                                                                    .data.tab ==
                                                                ListTabState
                                                                    .NHOM
                                                            ? prefix0
                                                                .boxDecorationTrochuyen_Focus
                                                            : prefix0
                                                                .boxDecorationTrochuyen_UnFocus,
                                                      )
                                                    : Container(
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        25.w)),
                                                            child: Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                      minWidth:
                                                                          50.w),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(7.w),
                                                              color: Colors
                                                                  .red[900],
                                                              child: Center(
                                                                child: Text(
                                                                  countAllUnreadPrivate
                                                                      .data
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          30.sp),
                                                                ),
                                                              ),
                                                            )),
                                                      );
                                              })
                                        ])),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      //3 tabs và 3 chấm tròn, bấm vào thì chấm tròn sẽ đổi màu
                      SizedBox(
                        height: ScreenUtil().setHeight(32.4),
                      ),
                      Container(
                        color: Color(0xff005a88),
                        margin: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(60.0)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                                child: Container(
                              height: ScreenUtil().setHeight(7.0),
                              decoration:
                                  snapListTab.data.tab == ListTabState.NHAN_TIN
                                      ? BoxDecoration(color: Colors.white)
                                      : BoxDecoration(color: Color(0xff005a88)),
                            )),
                            Flexible(
                                child: Container(
                              height: ScreenUtil().setHeight(7.0),
                              decoration:
                                  snapListTab.data.tab == ListTabState.NHOM
                                      ? BoxDecoration(color: Colors.white)
                                      : BoxDecoration(color: Color(0xff005a88)),
                            )),
                          ],
                        ),
                      ),
                      //gạch chân màu trắng, bấm vào tab nào thì cần đổi màu chân tab đó
                    ],
                  ),
                ), //3
                // tab header
                Expanded(
                  child: IndexedStack(
                    index: snapListTab.data.tab == ListTabState.NHAN_TIN
                        ? 0
                        : snapListTab.data.tab == ListTabState.NHOM ? 1 : 2,
                    children: <Widget>[
                      _buildLayoutDirectMessage(snapListTab),
                      ListPrivateGroup(),
                      Container()
                    ],
                  ),
                )
              ],
            );
          }),
    );
  }

  _buildLayoutDirectMessage(AsyncSnapshot snap) {
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: Column(
        children: <Widget>[
          Container(
            height: ScreenUtil().setHeight(148.0),
            color: Color(0xff959ca7).withOpacity(0.05),
            child: Row(
              children: <Widget>[
                SizedBox(width: ScreenUtil().setWidth(60.0)),
                Text("ĐANG TRỰC TUYẾN",
                    style: TextStyle(
                        color: Color(0xff959ca7),
                        fontSize: ScreenUtil().setSp(50.0),
                        fontFamily: "Roboto-Regular"))
              ],
            ),
          ),
          //title ĐANG TRỰC TUYẾN
          SizedBox(height: ScreenUtil().setHeight(43)),
          _buildListUserOnline(),
          SizedBox(height: ScreenUtil().setHeight(52.5)),
          Container(
            height: 1.0,
            width: MediaQuery.of(context).size.width,
            decoration:
                BoxDecoration(color: Color(0xff959ca7).withOpacity(0.5)),
          ),
          //đường gạch
          Container(
//                    margin: EdgeInsets.only(left: ScreenUtil().setWidth(23.9)),
            height: ScreenUtil().setHeight(148.0),
            color: Color(0xff959ca7).withOpacity(0.05),
            child: Row(
              children: <Widget>[
                SizedBox(width: ScreenUtil().setWidth(60.0)),
                Text("LIÊN LẠC GẦN ĐÂY",
                    style: TextStyle(
                        color: Color(0xff959ca7),
                        fontSize: ScreenUtil().setSp(50.0),
                        fontFamily: "Roboto-Regular"))
              ],
            ),
          ),
          Expanded(
            child: _buildListDirect(),
          ),
          //title Liên lạc gần đây
        ],
      ),
    );
  }

  _buildListUserOnline() {
    appBloc.mainChatBloc
        .updateListUserOnLine(appBloc.mainChatBloc.listUserOnChatSystem);
    return Container(
      margin: EdgeInsets.only(
        left: ScreenUtil().setWidth(60),
      ),
      height: ScreenUtil().setWidth(239),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 69.0.w),
            child: InkWell(
              onTap: () {
                appBloc.homeBloc.moveToAddressBook();
              },
              child: Container(
                alignment: Alignment.center,
                child: Image.asset(
                  "asset/images/ic_addchat.png",
                  width: ScreenUtil().setWidth(165.7),
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenUtil().setWidth(32.0)),
          Expanded(
            child: StreamBuilder(
                stream: appBloc.mainChatBloc.listUserOnlineStream.stream,
                initialData: appBloc.mainChatBloc.listUserOnLine,
                builder: (buildContext,
                    AsyncSnapshot<List<AddressBookModel>> snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data.length == 0) {
                    return Container(
                      margin: EdgeInsets.only(
                        bottom: 30.0,
                      ),
                      child: Text(
                        "Hiện chưa có người dùng trực tuyến.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: prefix0.accentColor,
                            fontFamily: "Roboto-Regular",
                            fontSize: 40.0.sp),
                      ),
                    );
                  } else {
                    return ScrollConfiguration(
                      behavior: MyBehavior(),
                      child: ListView.builder(
                        itemCount: snapshot.data.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (buildContext, index) {
                          return ItemUserOnline(
                              appBloc: appBloc,
                              addressBookModel: snapshot.data[index]);
                        },
                      ),
                    );
                  }
                }),
          )
        ],
      ),
    );
  }

  _buildListDirectNoData() {
    return Column(
      children: <Widget>[
        SizedBox(height: ScreenUtil().setHeight(115.6)),
        Image.asset("asset/images/ic_noMessage.png",
            width: ScreenUtil().setWidth(381.9),
            height: ScreenUtil().setHeight(354.7)),
        SizedBox(height: ScreenUtil().setHeight(53.7)),
        Text("Không có tin nhắn nào",
            style: TextStyle(
                color: Color(0xff333333),
                fontSize: ScreenUtil().setSp(50),
                fontFamily: "Roboto-Bold")),
        SizedBox(height: ScreenUtil().setHeight(14)),
        Container(
          height: ScreenUtil().setHeight(182.0),
          margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(116)),
          child: Text(
            "Bạn chưa có cuộc nhắn tin riêng nào, vui lòng chọn tên người dùng.",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: "Roboto-Regular",
                fontSize: ScreenUtil().setSp(50),
                color: Color(0xff333333)),
          ),
        ),
        SizedBox(height: ScreenUtil().setHeight(15)),
        InkWell(
          onTap: () {
            appBloc.homeBloc.clickItemBottomBar(4);
          },
          child: Text("Tạo nhắn tin mới",
              style: TextStyle(
                  color: Color(0xff005a88),
                  fontSize: ScreenUtil().setSp(50),
                  fontFamily: "Roboto-Regular")),
        ) //text Tạo tin nhắn mới
      ],
    );
  }

  //Todo: Danh sách tin nhắn trực tiếp nó nằm trong đây. Chỗ này đang chạy bình thường
  _buildListDirect() {
    ListGroupModel model = appBloc.mainChatBloc.listDirectRoom != null &&
            appBloc.mainChatBloc.listDirectRoom.length > 0
        ? ListGroupModel(
            state: ListGroupState.SHOW,
            listGroupModel: appBloc.mainChatBloc.listDirectRoom)
        : ListGroupModel(state: ListGroupState.NO_DATA);
    return StreamBuilder(
      initialData: model,
      stream: appBloc.mainChatBloc.listDirectStream.stream,
      builder: (streamBuildContext, AsyncSnapshot<ListGroupModel> snapshot) {
        switch (snapshot.data.state) {
          case ListGroupState.LOADING:
            return Container(
              height: 150.0,
              child: Center(
                child: LoadingIndicator(
                  color: prefix0.accentColor,
                ),
              ),
            );
            break;
          case ListGroupState.SHOW:
            if (appBloc.mainChatBloc.listDirectRoom == null ||
                appBloc.mainChatBloc.listDirectRoom.length == 0) {
              return _buildListDirectNoData();
            }
            return ListView.builder(
              itemCount: appBloc.mainChatBloc.listDirectRoom.length,
              shrinkWrap: true,
              physics: AlwaysScrollableScrollPhysics(),
              itemBuilder: (buildContext, index) {
                return InkWell(
                  child: _buildItemDirect(
                      appBloc.mainChatBloc.listDirectRoom[index]),
                  onTap: () {
                    appBloc.mainChatBloc.openRoom(
                        appBloc, appBloc.mainChatBloc.listDirectRoom[index]);
                  },
                );
              },
            );
            break;
          default:
            return _buildListDirectNoData();
            break;
        }
      },
    );
  }

  final SlidableController _slidableController = SlidableController();

  Widget _buildItemDirect(WsRoomModel data) {
    return Container(
      margin: EdgeInsets.only(
        left: ScreenUtil().setWidth(
          60.0,
        ),
      ),
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
                          SizedBox(height: ScreenUtil().setHeight(35.5)),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    right: ScreenUtil().setWidth(58)),
                                child: UserStatusWidget(
                                  appBloc: appBloc,
                                  listDirectUser: data.listUserDirect,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: _buildLineName(
                                              data.listUserDirect,
                                              data.lastMessage),
                                        ),
                                        Text(
                                            data?.lastMessage?.ts != null
                                                ? DateTimeFormat.getTimeFrom(
                                                    data?.lastMessage?.ts)
                                                : data.updatedAt != null
                                                    ? DateTimeFormat
                                                        .getTimeFrom(
                                                            data?.updatedAt)
                                                    : " ",
                                            style: TextStyle(
                                                color: Color(0xff959ca7),
                                                fontFamily: "Roboto-Regular",
                                                fontSize: 30.0.sp)),
                                        SizedBox(
                                            width: ScreenUtil().setWidth(59.0)),
                                      ],
                                    ),
                                    SizedBox(height: ScreenUtil().setHeight(6)),
                                    if (data.lastMessage != null) ...{
                                      _getSubTitle(
                                          data),
                                    } else ...{
                                      Flexible(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                child: Text(
                                                  "Chưa có tin nhắn nào",
                                                  textAlign: TextAlign.start,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: ScreenUtil()
                                                        .setSp(40.0),
                                                    color: Color(0xff959ca7),
                                                    fontFamily:
                                                        "Roboto-Regular",
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    },
                                  ],
                                ),
                              ), //nội dung chat và tên người
                            ],
                          ), //Nội dung chính
                        ],
                      ),
                    ),
                    secondaryActions: <Widget>[]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getSubTitle(WsRoomModel roomModel) {
    WsAccountModel currentAccount =
        WebSocketHelper.getInstance().wsAccountModel;
    bool unread = false;
    if (roomModel.lastMessage?.unread != null) {
      unread = roomModel.lastMessage.unread;
    } else {
      unread = false;
    }
    TextStyle textStyle =
        unread && roomModel.lastMessage.skAccountModel.id != currentAccount.id
            ? TextStyle(
                fontSize: ScreenUtil().setSp(40.0),
                color: Color(0xFF333333),
                fontFamily: "Roboto-Regular",
              )
            : TextStyle(
                fontSize: ScreenUtil().setSp(40.0),
                color: Color(0xff959ca7),
                fontFamily: "Roboto-Regular",
              );
    if (roomModel.lastMessage?.file != null) {
      String content = "";
      if (roomModel.lastMessage.skAccountModel.id == currentAccount.id) {
        content = "Bạn: ";
        if (roomModel.lastMessage.file.type.contains("audio")) {
          content += "đã gửi \[Audio\] ";
        } else if (roomModel.lastMessage.file.type.contains("image")) {
          content += "đã gửi \[Hình ảnh\] ";
        } else {
          content += "đã gửi \[Tập tin\] ";
        }
      } else {
        if (roomModel.lastMessage.file.type.contains("audio")) {
          content = "Đã gửi \[Audio\] ";
        } else if (roomModel.lastMessage.file.type.contains("image")) {
          content += "Đã gửi \[Hình ảnh\] ";
        } else {
          content += "Đã gửi \[Tập tin\] ";
        }
      }

      return _buildItemBadge(roomModel, textStyle, content);
    }
    String msg = roomModel.lastMessage?.msg ?? " ";
    if (roomModel.lastMessage?.messageActionsModel != null &&
        roomModel.lastMessage?.messageActionsModel?.actionType == ActionType.QUOTE) {
      msg = roomModel.lastMessage?.messageActionsModel?.msg;
    } else if (roomModel.lastMessage?.messageActionsModel != null &&
        roomModel.lastMessage?.messageActionsModel?.actionType == ActionType.DELETE) {
      msg = messageDeleteModel?.messageContent;
    } else if (roomModel.lastMessage?.messageActionsModel != null &&
        roomModel.lastMessage?.messageActionsModel?.actionType == ActionType.FORWARD) {
      msg = roomModel.lastMessage.messageActionsModel?.msg;
    } else if (roomModel.lastMessage?.messageActionsModel != null &&
        roomModel.lastMessage?.messageActionsModel?.actionType == ActionType.NONE) {
      if (roomModel.lastMessage?.messageActionsModel?.msg == null) {
        msg = roomModel.lastMessage.msg;
      } else {
        msg = roomModel.lastMessage.messageActionsModel.msg;
      }
    }
    if (roomModel.lastMessage != null) {
      if (roomModel.lastMessage.skAccountModel != null) {
        if (roomModel.lastMessage.skAccountModel.id == currentAccount.id) {
          msg = "Bạn: $msg";
        }
      } else {
        if (roomModel.lastMessage.reactions != null &&
            roomModel.lastMessage.reactions.sumUserReactions > 0) {
          msg = "Đã cập nhật cảm xúc";
        } else {
          msg = "...";
        }
      }
    } else {
      msg = "Chưa có tin nhắn nào";
    }
    return _buildItemBadge(roomModel, textStyle, msg);
  }

  _buildLineName(List<String> listUser, WsMessage message) {
    String name = "";
    bool statusRead = message != null &&
        message.unread &&
        message.skAccountModel?.id !=
            WebSocketHelper.getInstance().wsAccountModel.id;
    listUser?.forEach((usName) {
      if (usName != WebSocketHelper.getInstance().userName) {
        name = usName;
      }
    });
    if (appBloc.mainChatBloc.listUserOnChatSystem != null &&
        appBloc.mainChatBloc.listUserOnChatSystem.length > 0) {
      AddressBookModel model = appBloc.mainChatBloc.listUserOnChatSystem
          ?.firstWhere((user) => user.username == name, orElse: () => null);
      if (model != null) {
        name = model.name;
      }
    }

    return Text(
      name,
      style: statusRead ? prefix0.textStyleNewMsg : prefix0.textStyleOldMsg,
    );
  }

  UnReadCountModel getDefaultUnreadCountData(WsMessage message) {
    UnReadCountModel defaultInitData;
    if (appBloc.mainChatBloc.mapDataCountUnread.containsKey(RoomType.d)) {
      defaultInitData = appBloc.mainChatBloc.mapDataCountUnread[RoomType.d]
          .firstWhere((model) => model.rid == message.rid,
              orElse: () => UnReadCountModel("", message.rid, 0, ""));
    } else {
      defaultInitData = UnReadCountModel("", message.rid, 0, "");
    }

    return defaultInitData;
  }
  _buildItemBadge(WsRoomModel roomModel, TextStyle textStyle, String content) {
    return Flexible(
      child: BuildItemBadgeWidget(
        appBloc: appBloc,
        content: content,
        textStyle: textStyle,
        isListGroup: false,
        roomModel: roomModel,
      ),
    );
  }
}
