import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/screen/main_chat/chat/layout_action_bloc.dart';
import 'package:human_resource/chat/screen/main_chat/layout/channel_action/add_member_layout.dart';
import 'package:human_resource/chat/screen/main_chat/layout/channel_action/room_info_bloc.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/common/crypto_hex.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';

typedef OnInit = Function();

class RoomInfoLayout extends StatefulWidget {
  final WsRoomModel roomModel;
  final LayoutActionBloc layoutActionBloc;
  final bool isOwner;
  final OnInit onInit;

  const RoomInfoLayout(
      {Key key,
      @required this.roomModel,
      @required this.layoutActionBloc,
      this.onInit,
      this.isOwner = false})
      : super(key: key);

  @override
  _RoomInfoLayoutState createState() => _RoomInfoLayoutState();
}

enum WhyFarther {
  harder,
  smarter,
}

class _RoomInfoLayoutState extends State<RoomInfoLayout> {
  TextEditingController _searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  RoomInfoLayoutBloc bloc = RoomInfoLayoutBloc();
  bool isShowMenu = true;
  AppBloc appBloc;

  @override
  void initState() {
    widget.onInit();
    super.initState();
    Future.delayed(Duration.zero, () {
      bloc.getAllUserOnGroup(roomModel: widget.roomModel);
      bloc.getStatusNotification(widget.roomModel.id);
    });
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    String roomName = CryptoHex.deCodeChannelName(widget.roomModel.name);
    return Stack(
      children: <Widget>[
        Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              titleSpacing: 0.0,
              backgroundColor: prefix0.accentColor,
              title: Container(
                width: MediaQuery.of(context).size.width,
                height: 178.5.h,
                child: Stack(
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          widget.layoutActionBloc
                              .changeState(LayoutActionState.NONE);
                        },
                        child: Container(
                          height: 178.5.h,
                          padding: EdgeInsets.only(
                              left: 60.w,
                              right: 60.w,
                              bottom: 66.2.h,
                              top: 60.h),
                          child: Image.asset(
                            "asset/images/ic_meeting_back_white.png",
                            color: prefix0.white,
                            fit: BoxFit.contain,
                            width: ScreenUtil().setWidth(49.0),
                          ),
                        )),
                    Center(
                      child: Text(
                        "Thông tin nhóm",
                        style: TextStyle(
                            fontFamily: 'Roboto-Bold',
                            color: prefix0.white,
                            fontSize: 60.0.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              elevation: 0.0,
            ),
            body: GestureDetector(
                onTap: () {
                  if (searchFocus.hasFocus) {
                    _searchController.clear();
                    searchFocus.unfocus();
                    bloc.refreshData();
                  }
                },
                child: Stack(
                  children: <Widget>[
                    _buildMainLayout(roomName),
                    StreamBuilder(
                        initialData: true,
                        stream: bloc.loadingStream.stream,
                        builder:
                            (loadingContext, AsyncSnapshot<bool> snapshotData) {
                          return Visibility(
                              visible: snapshotData.data, child: Loading());
                        }),
                  ],
                ))),
        StreamBuilder(
            initialData: false,
            stream: bloc.showAddMemberStream.stream,
            builder: (buildContext, AsyncSnapshot<bool> showAddMember) {
              if (showAddMember.data) {
                appBloc.backStateBloc.hideLayoutWithStream =
                    bloc.showAddMemberStream;
                return AddMemberLayout(
                  roomModel: widget.roomModel,
                  layoutActionBloc: widget.layoutActionBloc,
                  listMember: bloc.listUserGroup,
                  onBack: (data) {
                    bloc.showAddMemberStream.notify(false);
                    if (data == true) {
                      bloc.getAllUserOnGroup(roomModel: widget.roomModel);
                    }
                  },
                );
              } else {
                return Container();
              }
            })
      ],
    );
  }

  _buildMainLayout(String roomName) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
//            _buildLineSearch(),
            // Hàm build ảnh đại diện nhóm
            _buildPictureGroup(),
            _BuildSearchmsg(),
            widget.isOwner
                ? Container(
                    margin: EdgeInsets.only(
                      top: ScreenUtil().setHeight(75.0),
                      left: ScreenUtil().setWidth(60.0),
                    ),
                    child: InkWell(
                      onTap: () {
                        bloc.showAddMemberStream.notify(true);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                              right: ScreenUtil().setWidth(75),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Color(0xFF005a88),
                              size: ScreenUtil().setWidth(74),
                            ),
                          ),
                          Container(
                            child: Text(
                              'Thêm thành viên',
                              style: TextStyle(
                                  fontFamily: "Roboto-Regular",
                                  color: Color(0xFF005a88),
                                  fontSize: 50.0.sp,
                                  fontWeight: FontWeight.normal),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Container(),
            Padding(
              padding: EdgeInsets.only(top: ScreenUtil().setHeight(97.9)),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(
                          top: ScreenUtil().setHeight(47.0),
                          bottom: ScreenUtil().setHeight(39.0),
                          left: ScreenUtil().setWidth(60.0),
//                            right: ScreenUtil().setWidth(59.0)),
                        ),
                        decoration: BoxDecoration(
                          color: prefix0.white,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text(
                              "THÀNH VIÊN NHÓM",
                              style: TextStyle(
                                  fontFamily: "Roboto-Regular",
                                  color: Color(0xFF959ca7),
                                  fontSize: ScreenUtil().setSp(50.0),
                                  fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(38.0),
            ),
            StreamBuilder(
                initialData: List<RestUserModel>(),
                stream: bloc.listUserGroupStream.stream,
                builder: (buildContext,
                    AsyncSnapshot<List<RestUserModel>> listUserSnapshot) {
                  if (!listUserSnapshot.hasData ||
                      listUserSnapshot.data == null ||
                      listUserSnapshot.data.length == 0) {
                    return Container(
                      height: 200.0,
                      alignment: Alignment.center,
                      child: Text(
                        "Không có thành viên nào",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(48.0),
                          fontFamily: 'Roboto-Regular',
                          color: prefix0.blackColor333,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(60.0),
                      right: ScreenUtil().setWidth(59.0),
                    ),
                    itemCount: listUserSnapshot.data.length,
                    addAutomaticKeepAlives: true,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (buildContext, index) {
                      return InkWell(
                        onTap: () {},
                        child:
                            //Lấy ra dánh sách user
                            _buildItemUser(listUserSnapshot.data[index], index),
                      );
                    },
                    separatorBuilder: (buildContext, index) {
                      return Divider(
                        color: prefix0.grey,
                      );
                    },
                  );
                }),

            /// Rời bỏ nhóm
            InkWell(
              onTap: () {
                DialogUtils.showDialogRequest(context,
                    title: "Rời nhóm",
                    message: "Bạn có chắc chắn muốn rời khỏi nhóm này?",
                    onClickOK: () {
                  bloc.getUserRoles(
                      context, widget.roomModel, widget.layoutActionBloc);
                  /*bloc.leaveRoom(
                        context, widget.roomModel, widget.layoutActionBloc);*/
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    width: ScreenUtil().setWidth(75.8),
                    height: ScreenUtil().setHeight(75.8),
                    child: Image.asset(
                      "asset/images/outroom.png",
                      color: Color(0xFFe10606),
                    ),
                  ),
                  SizedBox(
                    width: ScreenUtil().setWidth(73.2),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      right: ScreenUtil().setWidth(59.0),
                      top: ScreenUtil().setHeight(122.0),
                    ),
                    child: Text(
                      widget.isOwner ? "Xóa nhóm" : "Rời bỏ nhóm",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(50.0),
                        fontFamily: 'Roboto-Regular',
                        color: Color(0xFFe10606),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: ScreenUtil()
                  .setHeight(100), //chỗ này là bug nên Ngọc Anh sửa tạm cho đẹp
            ),
          ],
        ),
      ),
    );
  }

  //Tân sửa lại theo giao diện zeplin mới
  Widget _buildItemUser(RestUserModel restUserModel, int index) {
    AppBloc appBloc = BlocProvider.of(context);
    bool isAllowOpenMemberInfo = false;
    if (appBloc?.authBloc?.asgUserModel?.username == restUserModel?.username) {
      isAllowOpenMemberInfo = false;
    } else {
      isAllowOpenMemberInfo = true;
    }
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              CustomCircleAvatar(
                userName: restUserModel.username,
                size: 114.0,
                position: ImagePosition.GROUP,
              ),
              SizedBox(
                width: ScreenUtil().setWidth(47.0),
              ),
              Container(
                child: widget.roomModel.skAccountModel.id == restUserModel.id
                    ? Text(
                        restUserModel.name,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Roboto-Regular',
                            color: prefix0.blackColor333,
                            fontSize: ScreenUtil().setSp(50.0)),
                      )
                    : Text(
                        restUserModel.name,
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Roborto-Regular',
                          color: prefix0.blackColor333,
                          fontSize: ScreenUtil().setSp(50.0),
                        ),
                      ),
              ),
            ],
          ),
          isAllowOpenMemberInfo
              ? Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton<WhyFarther>(
                      onSelected: (val) {
                        if (val == WhyFarther.harder) {
                          //Gọi hàm lấy thông tin thành viên tại đây
                          widget.layoutActionBloc.changeState(
                              LayoutActionState.MEMBER_PROFILE,
                              data: {
                                "owner": widget.isOwner,
                                "user": restUserModel,
                                "roomId": widget.roomModel.id,
                                "openNotification": false
                              });
                        } else if (val == WhyFarther.smarter) {
                          AppBloc appBloc = BlocProvider.of(context);
                          if (appBloc.authBloc.asgUserModel.username ==
                              restUserModel.username) {
                            Toast.showShort("Admin không thể rời nhóm.");
                          } else {
                            DialogUtils.showDialogRemoveUserNewDesign(context,
                                fullName: restUserModel.name, onClickOK: () {
                              bloc.kickMember(widget.roomModel, restUserModel);
                            }, title: "Xóa thành viên");
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<WhyFarther>>[
                        PopupMenuItem<WhyFarther>(
                            value: WhyFarther.harder,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                'Thông tin thành viên',
                                style: TextStyle(
                                    fontFamily: "Roboto-Regular",
                                    color: prefix0.blackColor333,
                                    fontSize: ScreenUtil().setSp(40.0),
                                    fontWeight: FontWeight.normal),
                              ),
                            )),
                        if (widget.isOwner)
                          PopupMenuItem<WhyFarther>(
                              value: WhyFarther.smarter,
                              child: Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(
                                        right: ScreenUtil().setWidth(11),
                                      ),
                                      width: ScreenUtil().setWidth(52.0),
                                      height: ScreenUtil().setHeight(52.0),
                                      child: Image.asset(
                                          "asset/images/ic_cancel.png"),
                                    ),
                                    Flexible(
                                      child: Text(
                                        "Xóa khỏi nhóm",
                                        style: TextStyle(
                                            fontFamily: "Roboto-Regular",
                                            color: prefix0.blackColor333,
                                            fontSize: ScreenUtil().setSp(40.0),
                                            fontWeight: FontWeight.normal),
                                      ),
                                    )
                                  ],
                                ),
                              ))
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  _buildLayoutAction() {
    List<String> listData = ["Thông tin thành viên", "Xóa khỏi nhóm"];
    return PopupMenuButton(
        offset: Offset(0, 56),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(SizeRender.renderBorderSize(context, 10.0)),
          side: BorderSide.none,
        ),
        elevation: 10.0,
        onSelected: (titleSelected) {
          if (titleSelected == "Thông tin thành viên") {
          } else if (titleSelected == "Xóa khỏi nhóm") {}
        },
        icon: Icon(
          Icons.more_vert,
          color: prefix0.white,
        ),
        itemBuilder: (buildContext) {
          return listData.map(
            (title) {
              return PopupMenuItem(
                  value: title,
                  child: Text(
                    title,
                    style: TextStyle(
                        fontFamily: 'Roboto-Regular',
                        fontSize: ScreenUtil().setSp(42.0),
                        color: prefix0.blackColor333),
                  ));
            },
          ).toList();
        });
  }

  _BuildSearchmsg() {
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setHeight(75.0),
        left: ScreenUtil().setWidth(60.0),
      ),
      child: InkWell(
        onTap: () {
          widget.layoutActionBloc.changeState(LayoutActionState.NONE);
          appBloc.mainChatBloc.chatBloc.changeStateSearchMessage(true);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                right: ScreenUtil().setWidth(75),
              ),
              child: Icon(
                Icons.search,
                color: Color(0xFF005a88),
                size: ScreenUtil().setWidth(74),
              ),
            ),
            Container(
              child: Text(
                'Tìm kiếm tin nhắn',
                style: TextStyle(
                    fontFamily: "Roboto-Regular",
                    color: Color(0xFF005a88),
                    fontSize: 50.0.sp,
                    fontWeight: FontWeight.normal),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildPictureGroup() {
    String roomName = CryptoHex.deCodeChannelName(widget.roomModel.name);
    return Container(
      margin: EdgeInsets.only(
        top: ScreenUtil().setHeight(62.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              left: ScreenUtil().setWidth(65.5),
            ),
            child: CustomCircleAvatar(
              userName: widget.roomModel?.skAccountModel?.userName ?? "",
              size: 195.5,
              position: ImagePosition.GROUP,
            ),
          ),
          SizedBox(
            width: 55.5.w,
          ),
          Expanded(
            child: Container(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    roomName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 60.0.sp,
                        fontFamily: "Roboto-Regular",
                        color: prefix0.blackColor333,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          right: ScreenUtil().setWidth(11),
                        ),
                        width: ScreenUtil().setWidth(36.0),
                        height: ScreenUtil().setHeight(36.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Color(0xFFe18c12)),
//                  child: Icon(Icons.call, color: Colors.yellow),
                      ),
                      Text(
                        "Đang hoạt động",
                        style: TextStyle(
                            fontFamily: "Roboto-Regular",
                            color: prefix0.blackColor333,
                            fontSize: ScreenUtil().setSp(40.0),
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder(
              initialData: NotificationState.LOADING,
              stream: bloc.notificationStream.stream,
              builder: (enableNotifyContext,
                  AsyncSnapshot<NotificationState> notificationData) {
                return GestureDetector(
                  onTap: () {
                    if (notificationData.data != NotificationState.LOADING) {
                      _showDialogRequestDisableRoom(
                          notificationData.data == NotificationState.ENABLE
                              ? true
                              : false);
                    }
                  },
                  child: Container(
                    width: 91.0.w,
                    height: 91.0.w,
                    margin: EdgeInsets.only(right: 60.0.w),
                    decoration: BoxDecoration(
                      color: Color(0xFFe8e8e8),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      margin: EdgeInsets.all(22.0.h),
                      child: notificationData.data != NotificationState.LOADING
                          ? Image.asset(
                              notificationData.data == NotificationState.ENABLE
                                  ? "asset/images/ic_enable_notification.png"
                                  : "asset/images/ic_disable_notification.png",
                            )
                          : CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  prefix0.accentColor),
                            ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  void _showDialogRequestDisableRoom(bool currentState) {
    if (currentState) {
      DialogUtils.showDialogRequestChangeNotify(context, "Tắt thông báo",
          "Bạn có chắc muốn ", "tắt thông báo", " không?", onClickOK: () {
        bloc.changeRoomNotification(widget.roomModel, false);
      });
    } else {
      DialogUtils.showDialogRequestChangeNotify(context, "Tắt thông báo",
          "Bạn có chắc muốn ", "bật thông báo", " không?", onClickOK: () {
        bloc.changeRoomNotification(widget.roomModel, true);
      });
    }
  }
}
