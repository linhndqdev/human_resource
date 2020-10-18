import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:human_resource/chat/screen/main_chat/layout/channel_action/pick_member_share_bloc.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter/cupertino.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';

import 'package:human_resource/home/meeting/action_meeting/add_member_bloc.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/common/const.dart';
import 'package:human_resource/utils/common/custom_size_render.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/utils/widget/custom_behavior.dart';
import 'package:human_resource/utils/widget/item_group_share_message.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';
import 'package:human_resource/model/asgl_user_model_extension.dart';

typedef OnBackScreen = Function(dynamic);
typedef OnPickedUser = Function(List<ASGUserModel>);
typedef OnInit = Function();

class PickMemberShareLayout extends StatefulWidget {
  final VoidCallback onBackLayout;
  final OnInit onInit;
  final List listMessagePicked;
  final WsRoomModel roomModel;
  final VoidCallback showPopupShared;

  const PickMemberShareLayout(
      {Key key,
      this.onBackLayout,
      this.onInit,
      this.listMessagePicked,
      this.roomModel,
      this.showPopupShared})
      : super(key: key);

  @override
  _PickMemberShareLayoutState createState() => _PickMemberShareLayoutState();
}

class _PickMemberShareLayoutState extends State<PickMemberShareLayout> {
  AppBloc appBloc;
  PickMemberShareBloc _pickMemberShareBloc = PickMemberShareBloc();
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocus = FocusNode();
  FocusNode _focus = FocusNode();
  TextEditingController _messageTextController = TextEditingController();

  @override
  void dispose() {
    appBloc.calendarBloc.refeshAllData();
    super.dispose();
  }

  @override
  void initState() {
    widget.onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel.state =
        isFocusWidget.PICK_MEMBER_SHARE;
    return Scaffold(
      appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return Column(
      children: <Widget>[
        StreamBuilder(
            initialData: "",
            stream: _pickMemberShareBloc.countPickedStream.stream,
            builder: (buildContext, AsyncSnapshot<String> snapshotData) {
              if (snapshotData.data == "") {
                return Container();
              } else {
                return ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: Container(
                    margin: EdgeInsets.only(top: 59.0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child:
                              _buildListMemberPickedCreate(), // _buildListMemberPicked(),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }),
        SizedBox(height: ScreenUtil().setHeight(29)),
        _buildNumberMemberCreate(),
        SizedBox(height: ScreenUtil().setHeight(26)),
        StreamBuilder<FilterTabStreamModel>(
            initialData:
                FilterTabStreamModel(state: FilterMemberTabState.THEO_DANH_BA),
            stream: _pickMemberShareBloc.clickTabStream.stream,
            builder: (context, snapshot) {
              return Container(
                height: ScreenUtil().setHeight(148.0),
                color: Color(0xff959ca7).withOpacity(0.05),
                child: Row(
                  children: <Widget>[
                    SizedBox(width: ScreenUtil().setWidth(60.0)),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _searchController.clear();
                          _searchFocus.unfocus();
                          _pickMemberShareBloc
                              .changeTab(FilterMemberTabState.THEO_DANH_BA);
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text("THEO DANH BẠ",
                              style: TextStyle(
                                  color: snapshot.data.state ==
                                          FilterMemberTabState.THEO_DANH_BA
                                      ? Color(0xff005a88)
                                      : Color(0xff959ca7),
                                  fontSize: ScreenUtil().setSp(50.0),
                                  fontFamily: "Roboto-Regular")),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _searchController.clear();
                          _searchFocus.unfocus();
                          _pickMemberShareBloc
                              .changeTab(FilterMemberTabState.THEO_NHOM);
                        },
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Text("THEO NHÓM",
                              style: TextStyle(
                                  color: snapshot.data.state ==
                                          FilterMemberTabState.THEO_NHOM
                                      ? Color(0xff005a88)
                                      : Color(0xff959ca7),
                                  fontSize: ScreenUtil().setSp(50.0),
                                  fontFamily: "Roboto-Regular")),
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenUtil().setWidth(60.0))
                  ],
                ),
              );
            }),
        //theo nhóm và theo danh bạ
        Container(
          height: 1.0,
          width: MediaQuery.of(context).size.width,
          color: Color(0xff959ca7).withOpacity(0.4),
        ),
        //dòng kẻ màu đen
        SizedBox(height: ScreenUtil().setHeight(65)),
        //tìm theo tên
        Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  left: ScreenUtil().setWidth(60.0),
                  right: ScreenUtil().setWidth(59.0),
                  bottom: ScreenUtil().setHeight(56)),
              padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(46),
                  top: ScreenUtil().setHeight(29),
                  bottom: ScreenUtil().setHeight(34.9)),
              width: ScreenUtil().setWidth(961),
              decoration: BoxDecoration(
                color: Color(0xffe8e8e8),
                borderRadius: BorderRadius.circular(
                    SizeRender.renderBorderSize(context, 57.0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: Image.asset(
                      "asset/images/group_9898.png",
                      color: prefix0.blackColor333,
                      width: ScreenUtil().setWidth(58.0),
                      height: ScreenUtil().setHeight(58.0),
                    ),
                  ),
                  SizedBox(
                    width: ScreenUtil().setWidth(30.7),
                  ),
                  Expanded(
                      child: TextField(
                        cursorColor: prefix0.blackColor333,
                    focusNode: _searchFocus,
                    controller: _searchController,
                    onChanged: (inputChange) {
                      if (_pickMemberShareBloc.filterTabState ==
                          FilterMemberTabState.THEO_DANH_BA) {
                        _pickMemberShareBloc.searchUser(appBloc, inputChange);
                      } else {
                        _pickMemberShareBloc.searchGroup(appBloc, inputChange);
                      }
                    },
                    style: TextStyle(
                        color: prefix0.blackColor333,
                        fontFamily: 'Roboto-Regular',
                        fontSize: ScreenUtil().setSp(50)),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        border: InputBorder.none,
                        hintText: "Tìm theo tên",
                        hintStyle: TextStyle(
                            color: prefix0.blackColor333,
                            fontFamily: 'Roboto-Regular',
                            fontSize: ScreenUtil().setSp(50))),
                  ))
                ],
              ),
            ),
            Positioned(
                top: ScreenUtil().setHeight(38),
                right: ScreenUtil().setWidth(96.7),
                child: InkWell(
                  onTap: () {
                    _searchController.text = "";
                    appBloc.mainChatBloc.listGroupStream.notify(ListGroupModel(
                        state: ListGroupState.SHOW,
                        listGroupModel: appBloc.mainChatBloc.listGroups));
                  },
                  child: Image.asset(
                    "asset/images/ic_dismiss.png",
                    color: prefix0.blackColor333,
                    width: ScreenUtil().setWidth(49),
                  ),
                ))
          ],
        ),

        StreamBuilder<FilterTabStreamModel>(
            initialData:
                FilterTabStreamModel(state: FilterMemberTabState.THEO_DANH_BA),
            stream: _pickMemberShareBloc.clickTabStream.stream,
            builder: (context, snapshot) {
              return snapshot.data.state == FilterMemberTabState.THEO_DANH_BA
                  ? _buildListContact()
                  : _buildChildTabGroup();
            }),
        StreamBuilder(
            initialData: false,
            stream: _pickMemberShareBloc.showInputStream.stream,
            builder: (buildContext, AsyncSnapshot<bool> showInput) {
              if (showInput.data) {
                return _buildLineSend();
              }
              return Container();
            })
      ],
    );
  }

  _buildNumberMemberCreate() {
    return StreamBuilder(
        initialData: "",
        stream: _pickMemberShareBloc.countPickedStream.stream,
        builder: (buildContext, AsyncSnapshot<String> countMemberPickedSnap) {
          return Container(
            alignment: countMemberPickedSnap.data == ""
                ? Alignment.center
                : Alignment.centerLeft,
            margin: countMemberPickedSnap.data == ""
                ? EdgeInsets.zero
                : EdgeInsets.only(left: ScreenUtil().setWidth(60)),
            child: Text(
              countMemberPickedSnap.data != ""
                  ? countMemberPickedSnap.data
                  : "Chưa có thành viên nào được chọn.",
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0xff333333),
                  fontFamily: "Roboto-Regular",
                  fontSize: ScreenUtil().setSp(50)),
            ),
          );
        });
  }

  //Theo danh bạ
  _buildListContact() {
    return StreamBuilder(
        initialData: appBloc.calendarBloc.listASGLUserModel.length == 0
            ? null
            : appBloc.calendarBloc.listASGLUserModel,
        stream: appBloc.calendarBloc.listASGLUserStream.stream,
        builder:
            (buildContext, AsyncSnapshot<List<ASGUserModel>> snapshotData) {
          if (!snapshotData.hasData || snapshotData.data == null) {
            return Center(
              child: Loading(),
            );
          } else {
            return Expanded(
              child: ListView.builder(
                  addAutomaticKeepAlives: true,
                  itemCount: snapshotData.data.length,
                  itemBuilder: (itemContext, index) {
                    bool isPicked = false;
                    if (_pickMemberShareBloc.listUserPicked != null &&
                        _pickMemberShareBloc.listUserPicked.length > 0) {
                      ASGUserModel userModel =
                          _pickMemberShareBloc.listUserPicked.firstWhere(
                              (user) =>
                                  user.username ==
                                  snapshotData.data[index].username,
                              orElse: () => null);

                      if (userModel != null) {
                        isPicked = true;
                      }
                    }

                    return _buildItemInListContact(
                        snapshotData.data[index],
                        snapshotData.data[index].getDepartment() ??
                            "Không xác định",
                        isPicked);
                  }),
            );
          }
        });
  }

  _buildItemInListContact(
      ASGUserModel userModel, String department, bool isAdded) {
    return InkWell(
      onTap: () {
        _searchController.clear();
        _searchFocus.unfocus();
        _pickMemberShareBloc.pickedOrRemoveUser(context, userModel.username);
      },
      child: Column(
        children: <Widget>[
          SizedBox(height: ScreenUtil().setHeight(24)),
          Row(
            children: <Widget>[
              SizedBox(width: ScreenUtil().setWidth(59.0)),
              CustomCircleAvatar(
                userName: userModel.username,
                size: 114.0,
                position: ImagePosition.GROUP,
              ),
              SizedBox(width: ScreenUtil().setWidth(60.0)),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      userModel.full_name ?? "Không xác định",
                      style: prefix0.textStyleOldMsg,
                    ),
                    SizedBox(height: ScreenUtil().setHeight(6)),
                    Text(department,
                        style: TextStyle(
                            color: Color(0xff959ca7),
                            fontSize: ScreenUtil().setSp(40),
                            fontFamily: "Roboto-Regular"))
                  ],
                ),
              ), //nội dung
              Center(
                child: Container(
                    height: ScreenUtil().setHeight(60),
                    child: isAdded
                        ? Image.asset("asset/images/ic_confirm_a_memmber.png")
                        : Image.asset("asset/images/ic_dismiss_member.png")),
              ), //ảnh cuối
              SizedBox(width: ScreenUtil().setWidth(59.0)),
              //nội dung chat và tên người
            ],
          ), //Nội dung chính
          SizedBox(height: ScreenUtil().setHeight(24)),
          Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(59),
                right: ScreenUtil().setWidth(60)),
            height: 1.0,
            decoration:
                BoxDecoration(color: Color(0xff959ca7).withOpacity(0.3)),
          ), //dòng kẻ
//          SizedBox(height: ScreenUtil().setHeight(35.5)),
        ],
      ),
    );
  }

  _buildListMemberPickedCreate() {
    List<dynamic> listPicked = List();
    if (_pickMemberShareBloc.listUserPicked.length > 0) {
      listPicked.addAll(_pickMemberShareBloc.listUserPicked);
    }
    if (_pickMemberShareBloc.listGroupPicked.length > 0) {
      listPicked.addAll(_pickMemberShareBloc.listGroupPicked);
    }
    return Container(
      padding: EdgeInsets.only(
        left: 60.0.w,
      ),
      height: 195.0.w,
      child: ScrollConfiguration(
          behavior: MyBehavior(),
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: listPicked.length,
            itemBuilder: (BuildContext context, int index) {
              if (listPicked[index] is ASGUserModel) {
                return _buildItemItemUserPicked(listPicked[index]);
              } else {
                return _buildItemGroupPicked(listPicked[index] as WsRoomModel);
              }
            },
          )),
    );
  }

  _buildItemGroupPicked(WsRoomModel roomModel) {
    String userName = roomModel.skAccountModel.userName;
    return Container(
      width: 160.0.w,
      height: 160.0.h,
      margin: EdgeInsets.only(right: ScreenUtil().setWidth(47.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            children: <Widget>[
              CustomCircleAvatar(
                size: 160.0,
                userName: userName,
                position: ImagePosition.GROUP,
              ),
              Positioned(
                right: ScreenUtil().setWidth(8.0),
                top: 0,
                child: InkWell(
                  onTap: () {
                    _pickMemberShareBloc.removeGroup(roomModel);
                  },
                  child: Container(
                    child: Icon(Icons.close,
                        color: Colors.white, size: ScreenUtil().setSp(31.3)),
                    width: ScreenUtil().setWidth(40.0),
                    height: ScreenUtil().setWidth(40.0),
                    decoration: BoxDecoration(
                      color: Color(0xff333333),
                      shape: BoxShape.circle,
                      border: new Border.all(
                        color: Color(0xffffffff),
                        width: SizeRender.renderBorderSize(context, 1.0),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  _buildItemItemUserPicked(ASGUserModel userModel) {
    return Container(
      width: 160.0.w,
      height: 160.0.h,
      margin: EdgeInsets.only(right: ScreenUtil().setWidth(47.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Stack(
            children: <Widget>[
              CustomCircleAvatar(
                size: 160.0,
                userName: userModel?.username ?? "",
                position: ImagePosition.GROUP,
              ),
              Positioned(
                right: ScreenUtil().setWidth(8.0),
                top: 0,
                child: InkWell(
                  onTap: () {
                    _pickMemberShareBloc.pickedOrRemoveUser(
                        context, userModel.username);
                  },
                  child: Container(
                    child: Icon(Icons.close,
                        color: Colors.white, size: ScreenUtil().setSp(31.3)),
                    width: ScreenUtil().setWidth(40.0),
                    height: ScreenUtil().setWidth(40.0),
                    decoration: BoxDecoration(
                      color: Color(0xff333333),
                      shape: BoxShape.circle,
                      border: new Border.all(
                        color: Color(0xffffffff),
                        width: SizeRender.renderBorderSize(context, 1.0),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  _buildChildTabGroup() {
    ListGroupModel listGroupModel;
    if (appBloc.mainChatBloc.listGroups.length == 0) {
      listGroupModel = ListGroupModel(state: ListGroupState.NO_DATA);
    } else {
      listGroupModel = ListGroupModel(
          state: ListGroupState.SHOW,
          listGroupModel: appBloc.mainChatBloc.listGroups);
    }
    return Expanded(
      child: StreamBuilder(
        initialData: listGroupModel,
        stream: appBloc.mainChatBloc.listGroupStream.stream,
        builder: (streamBuildContext, AsyncSnapshot<ListGroupModel> snapshot) {
          List<WsRoomModel> roomModels = List();
          if (snapshot.data.listGroupModel != null &&
              snapshot.data.listGroupModel.length > 0) {
            roomModels.addAll(snapshot.data.listGroupModel);
          }
          roomModels?.removeWhere((room) => room.name == Const.BAN_TIN);
          roomModels?.removeWhere((room) => room.name == Const.FAQ);
          roomModels
              ?.removeWhere((room) => room.name.contains(Const.THONG_BAO));
          roomModels?.removeWhere((room) => room.id == widget.roomModel.id);
          _pickMemberShareBloc.setListGroup(roomModels);
          return StreamBuilder(
              initialData: _pickMemberShareBloc.listRoom,
              stream: _pickMemberShareBloc.listRoomStream.stream,
              builder:
                  (listContext, AsyncSnapshot<List<WsRoomModel>> snapshotData) {
                if (snapshotData.data.length == 0) {
                  return Center(
                    child: Text(
                      "Hiện không có nhóm nào để chọn",
                      style: TextStyle(
                          fontSize: 45.0.sp,
                          color: prefix0.blackColor333,
                          fontFamily: "Roboto-Regular"),
                    ),
                  );
                }
                return ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: GridView.count(
                      padding: EdgeInsets.only(left: 60.0.w, right: 56.0.h),
                      crossAxisSpacing: 35.0.w,
//                          mainAxisSpacing: 56.0.h,
                      scrollDirection: Axis.vertical,
                      childAspectRatio: ScreenUtil().setWidth(463.0) /
                          ScreenUtil().setHeight(564.0),
                      physics: AlwaysScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      children: snapshotData.data.map((wsRoomModel) {
                        WsRoomModel roomModel = _pickMemberShareBloc
                            .listGroupPicked
                            ?.firstWhere((room) => wsRoomModel.id == room.id,
                                orElse: () => null);
                        return ItemGroup(
                          defaultPicked: null != roomModel,
                          roomModel: wsRoomModel,
                          onPickAllMemberOnRoom: (bool isPicked,
                              List<RestUserModel> listGroupMember) {
                            if (isPicked) {
                              _pickMemberShareBloc.addGroup(wsRoomModel);
                            } else {
                              _pickMemberShareBloc.removeGroup(wsRoomModel);
                            }
                          },
                        );
                      }).toList()),
                );
              });
        },
      ),
    );
  }

  _buildAppbar() {
    return AppBar(
      elevation: 0.0,
      backgroundColor: prefix0.accentColor,
      title: Container(
        width: MediaQuery.of(context).size.width,
        height: 178.5.h,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: 0,
              child: InkWell(
                child: Container(
                  padding: EdgeInsets.only(
                      left: 60.w, right: 59.w, bottom: 66.2.h, top: 60.h),
                  child: Image.asset(
                    "asset/images/ic_meeting_back_white.png",
                    color: prefix0.white,
                    width: ScreenUtil().setWidth(49.9),
                  ),
                ),
                onTap: () {
                  widget.onBackLayout();
                },
              ),
            ),
            Center(
              child: StreamBuilder<FilterTabStreamModel>(
                  initialData: FilterTabStreamModel(
                      state: FilterMemberTabState.THEO_DANH_BA),
                  stream: _pickMemberShareBloc.clickTabStream.stream,
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data.state == FilterMemberTabState.THEO_DANH_BA
                          ? "Chọn thành viên"
                          : "Chọn nhóm",
                      style: TextStyle(
                          fontFamily: "Roboto-Bold",
                          fontWeight: FontWeight.bold,
                          color: prefix0.asgBackgroundColorWhite,
                          fontSize: ScreenUtil()
                              .setSp(60.0, allowFontScalingSelf: false)),
                    );
                  }),
            )
          ],
        ),
      ),
      titleSpacing: 0.0,
    );
  }

  _buildButtonOpenOrClose(bool isOpen) {
    return Container(
      margin: EdgeInsets.only(
        left: ScreenUtil().setWidth(60.0),
        right: ScreenUtil().setWidth(29),
      ),
      child: InkWell(
          onTap: () async {},
          child: Container(
            width: ScreenUtil().setWidth(129.0),
            height: ScreenUtil().setHeight(129.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !isOpen ? prefix0.grey1Color : prefix0.orangeColor),
            child: !isOpen
                ? Icon(Icons.add, color: prefix0.accentColor)
                : Icon(
                    Icons.chevron_left,
                    color: prefix0.whiteColor,
                  ),
          )),
    );
  }

  _buildLineSend() {
    return Container(
        alignment: Alignment.center,
        padding:
            EdgeInsets.only(bottom: 38.6.w, right: ScreenUtil().setWidth(59.0)),
        decoration: BoxDecoration(
          color: prefix0.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildButtonOpenOrClose(false),
            Expanded(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: 129.0.h,
                ),
                decoration: BoxDecoration(
                  color: Color(0xffe8e8e8),
                  borderRadius: BorderRadius.circular(
                      SizeRender.renderBorderSize(context, 65.0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(
                      width: ScreenUtil().setWidth(57.7),
                    ),
                    Flexible(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 5.6.h,
                        ),
                        Text(
                          "Chia sẻ ${widget.listMessagePicked.length} tin nhắn",
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: prefix0.color959ca7,
                              fontSize: 25.0.sp,
                              fontFamily: "Roboto-Regular"),
                        ),
                        SizedBox(
                          height: 1.9.h,
                        ),
                        Container(
                          height: 0.5,
                          color: prefix0.blackColor,
                        ),
                        Container(
                          constraints: BoxConstraints(
                              minHeight: 129.0.h, maxHeight: 350.0.h),
                          child: TextField(
                            focusNode: _focus,
                            cursorColor: prefix0.blackColor333,
                            onChanged: (data) {},
                            style: TextStyle(
                              fontFamily: "Roboto-Regular",
                              fontSize: ScreenUtil().setSp(50.0),
                              color: prefix0.blackColor333,
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            controller: _messageTextController,
                            maxLines: null,
                            textAlign: TextAlign.start,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "Nhập nội dung của bạn",
                              hintStyle: TextStyle(
                                fontFamily: "Roboto-Regular",
                                fontSize: ScreenUtil().setSp(50.0),
                                color: Color(0xff9a9ca4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                    StreamBuilder(
                        initialData: false,
                        stream: appBloc
                            .mainChatBloc.chatBloc.blockSendActionStream.stream,
                        builder: (buildContext,
                            AsyncSnapshot<bool> blockSendSnapshot) {
                          if (blockSendSnapshot.data) {
                            return Container(
                              margin: EdgeInsets.only(
                                  bottom: ScreenUtil().setHeight(18),
                                  top: ScreenUtil().setHeight(20),
                                  right: ScreenUtil().setWidth(24)),
                              child: InkWell(
                                onTap: () {},
                                child: Image.asset(
                                  "asset/images/action/ic_block_send_quote.png",
                                  width: ScreenUtil().setHeight(91),
                                ),
                              ),
                            );
                          }
                          return Container(
                            margin: EdgeInsets.only(
                                bottom: ScreenUtil().setHeight(20),
                                top: ScreenUtil().setHeight(20),
                                right: ScreenUtil().setWidth(24)),
                            child: InkWell(
                              onTap: () {
                                _sendMsg();
                              },
                              child: Image.asset(
                                "asset/images/ic_senchatmsg.png",
                                width: ScreenUtil().setHeight(89),
                              ),
                            ),
                          );
                        })
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  void _sendMsg() {
    if (_messageTextController.text.trim().toString() == "") {
      Toast.showShort("Vui lòng nhập nội dung của bạn");
    } else {
      widget.showPopupShared();
      _pickMemberShareBloc.shareMessageWith(
          context,
          _messageTextController.text.toString().trim(),
          widget.listMessagePicked);
      appBloc.mainChatBloc.chatBloc.disableShare();
    }
  }
}
