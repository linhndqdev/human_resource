import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/core/message/message_services.dart';
import 'package:human_resource/core/room_chat/room_chat_services.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/common/crypto_hex.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/member_count.dart';
import 'circle_avatar.dart';

class ItemGroup extends StatefulWidget {
  final WsRoomModel roomModel;

  const ItemGroup({Key key, this.roomModel}) : super(key: key);

  @override
  _ItemGroupState createState() => _ItemGroupState();
}

class _ItemGroupState extends State<ItemGroup>
    with AutomaticKeepAliveClientMixin {
  AppBloc appBloc;
  String groupname;
  ItemGroupBloc _bloc = ItemGroupBloc();

  @override
  void didUpdateWidget(ItemGroup oldWidget) {
    // TODO: implement didUpdateWidget

    if (oldWidget.roomModel.usersCount != widget.roomModel.usersCount) {
      Future.delayed(Duration.zero, () {
        if (widget.roomModel != null)
          _bloc.getMemberGroup(widget.roomModel);
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (widget.roomModel != null)
        _bloc.getMemberGroup(widget.roomModel);
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
      groupname = CryptoHex.deCodeChannelName(widget.roomModel.name);
//      _bloc.getGroupUnreadCount(context, widget.roomModel);
    } else {
      return Container();
    }

    return Container(
        height: 369.h + 195.w,
        width: 460.0.w,
        decoration: BoxDecoration(
            color: prefix0.white,
            borderRadius: BorderRadius.circular(
                SizeRender.renderBorderSize(context, 10.0)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 90, 136, 0.2),
                blurRadius: SizeRender.renderBorderSize(context, 8.0),
                offset: Offset(
                  0.0, // horizontal, move right 10
                  ScreenUtil().setHeight(2), // vertical, move down 10
                ),
              )
            ]),
        child: Center(
          child: InkWell(
            onTap: () {
              appBloc.mainChatBloc.openRoom(appBloc, widget.roomModel);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: ScreenUtil().setHeight(42.0),
                ),
                widget.roomModel != null
                    ? Center(
                        child: StreamBuilder(
                            initialData:
                                getDefaultUnreadCountData(widget.roomModel),
                            stream: appBloc
                                .mainChatBloc.countUnreadWithRoomIDStream.stream
                                .where((model) =>
                                    model.rid == widget.roomModel.id),
                            builder: (buildContext,
                                AsyncSnapshot<UnReadCountModel>
                                    countUnreadSnap) {
                              if (!countUnreadSnap.hasData ||
                                  countUnreadSnap.data == null ||
                                  countUnreadSnap.data.unreadCount == 0) {
                                return CustomCircleAvatar(
                                  userName:
                                      widget.roomModel.skAccountModel.userName,
                                  size: 160.0,
                                  position: ImagePosition.GROUP,
                                );
                              }
                              String sCount =
                                  countUnreadSnap.data.unreadCount < 99
                                      ? "${countUnreadSnap.data.unreadCount}"
                                      : "99+";
                              return Badge(
                                position:
                                    BadgePosition.topRight(top: 40, right: 0),
                                badgeContent: Text(
                                  sCount,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(30.0),
                                      fontFamily: "Roboto-Regular",
                                      color: Colors.white),
                                ),
                                child: CustomCircleAvatar(
                                  position: ImagePosition.GROUP,
                                  userName:
                                      widget.roomModel.skAccountModel.userName,
                                  size: 160.0,
                                ),
                              );
                            }),
                      )
                    : Container(),
                SizedBox(height: ScreenUtil().setHeight(10.0)),
                Padding(
                  padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(65.0),
                    right: ScreenUtil().setWidth(65.0),
                  ),
                  child: Text(
                    groupname ?? "Tạo nhóm mới",
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(50.0),
                        fontFamily: "Roboto-Regular",
                        fontWeight: FontWeight.normal,
                        color: Color(0xff333333)),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: ScreenUtil().setHeight(8.0)),
                widget.roomModel != null
                    ? StreamBuilder(
                        initialData: null,
                        stream: _bloc.listMemberStream.stream,
                        builder: (buildContext,
                            AsyncSnapshot<List<RestUserModel>> listSnapshot) {
                          int size = 0;
                          if (!listSnapshot.hasData ||
                              listSnapshot.data == null ||
                              listSnapshot.data.length == 0) {
                            return Container();
                          }
                          if (listSnapshot.data.length > 5)
                            size = 5;
                          else
                            size = listSnapshot.data.length;
                          return Container(
                            margin: EdgeInsets.only(
                              left: ScreenUtil().setWidth(106),
                              right: ScreenUtil().setWidth(106),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Stack(
                                  children: [
                                    for (int i = 0; i < size; i++)
                                      Container(
                                        width: ScreenUtil().setWidth(74.0),
                                        height: ScreenUtil().setHeight(75.0),
                                        margin: EdgeInsets.only(
//                                            top: ScreenUtil().setHeight(5.0),
                                          left: ScreenUtil().setWidth(i * 40.0),
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: ScreenUtil().setWidth(2.0),
                                          ),
                                        ),
                                        child: CustomCircleAvatar(
                                          position: ImagePosition.GROUP,
                                          size: 74.0,
                                          userName:
                                              listSnapshot.data[i].username,
                                        ),
                                      ),
                                  ],
                                )
                              ],
                            ),
                          );
                        })
                    : Container(),
                SizedBox(
                  height: 10.0.h,
                ),
                widget.roomModel != null
                    ? MemberCount(userCount: widget.roomModel.usersCount)
                    : Container(),
              ],
            ),
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class ItemGroupBloc {
  CoreStream<List<RestUserModel>> listMemberStream = CoreStream();
  CoreStream<int> unreadCountStream = CoreStream();

  void getMemberGroup(WsRoomModel roomModel) async {
    try {
      List<RestUserModel> listUserGroup = List();
      ApiServices apiServices =
          ApiServices();
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
