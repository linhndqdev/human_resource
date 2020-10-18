import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/meeting/model/participant_model.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/home/meeting/action_meeting/edit_meeting_bloc.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/common/const.dart';
import 'package:human_resource/utils/common/custom_size_render.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/utils/widget/custom_behavior.dart';
import 'package:human_resource/utils/widget/item_group_pick_member.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';

import 'add_member_bloc.dart';

enum AddMemberScreenMode {
  CREATE,
  EDIT,
}

typedef OnBackScreen = Function(dynamic);
typedef OnPickedUser = Function(List<ASGUserModel>);
typedef OnInit = Function();

class AddMemberMeetingScreen extends StatefulWidget {
  final DateTime datetimes;
  final AddMemberScreenMode mode;
  final OnBackScreen onBackScreen;
  final OnPickedUser onPickedUser;
  final EditMeetingBloc editMeetingBloc;
  final OnInit onInit;
  final List<ASGUserModel> listASGUserModel;

  AddMemberMeetingScreen({
    this.datetimes,
    this.mode,
    this.onBackScreen,
    this.onPickedUser,
    this.editMeetingBloc,
    this.onInit,
    this.listASGUserModel,
  });

  @override
  _AddMemberMeetingScreenState createState() => _AddMemberMeetingScreenState();
}

class _AddMemberMeetingScreenState extends State<AddMemberMeetingScreen> {
  AppBloc appBloc;
  AddMemberMeetingBloc _addMemberMeetingBloc = AddMemberMeetingBloc();
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    appBloc.calendarBloc.refeshAllData();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.mode == AddMemberScreenMode.CREATE)
      _addMemberMeetingBloc.listUserPicked.addAll(widget.listASGUserModel);
    widget.onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return Scaffold(
      appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return Column(
      children: <Widget>[
        StreamBuilder(
//            initialData: widget.mode == AddMemberScreenMode.CREATE? _addMemberMeetingBloc.listUserPicked.length:widget.editMeetingBloc.listMember.length,
//            stream: widget.mode == AddMemberScreenMode.CREATE? _addMemberMeetingBloc.countPickedStream.stream:widget.editMeetingBloc.countMemberStream.stream,
            initialData: widget.mode == AddMemberScreenMode.CREATE
                ? _addMemberMeetingBloc.listUserPicked.length
                : widget.editMeetingBloc.listMember.length,
            stream: widget.mode == AddMemberScreenMode.CREATE
                ? _addMemberMeetingBloc.countPickedStream.stream
                : widget.editMeetingBloc.countMemberStream.stream,
            builder: (buildContext, AsyncSnapshot<int> snapshotData) {
              if (snapshotData.data == 0) {
                return Container();
              } else {
                return ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: Container(
                    margin: EdgeInsets.only(top: 59.0.h, right: 60.0.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: widget.mode == AddMemberScreenMode.CREATE
                              ? _buildListMemberPicked_CREAT()
                              : _buildListMemberPicked_EDIT(), // _buildListMemberPicked(),
                        ),
                        SizedBox(
                          width: 60.0.w,
                        ),
                        InkWell(
                          onTap: () {
                            _addMemberMeetingBloc.listChuaKiemTraTrung.clear();
                            widget.onPickedUser(
                                _addMemberMeetingBloc.listUserPicked);

                            if (widget.mode == AddMemberScreenMode.CREATE) {
                              widget.onBackScreen("");
                            } else {
                              widget.onBackScreen("");
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            child: Image.asset(
                              "asset/images/ic_add_member.png",
                              width: 123.0.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }),
        SizedBox(height: ScreenUtil().setHeight(29)),
        widget.mode == AddMemberScreenMode.CREATE
            ? _buildNumber_Member_CREATE()
            : _buildNumber_Member_Edit(),
        SizedBox(height: ScreenUtil().setHeight(26)),
        StreamBuilder<FilterTabStreamModel>(
            initialData:
                FilterTabStreamModel(state: FilterMemberTabState.THEO_DANH_BA),
            stream: _addMemberMeetingBloc.clickTabStream.stream,
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
                          _addMemberMeetingBloc
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
                          _addMemberMeetingBloc
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
//        Stack(
//          children: <Widget>[
//            Container(
//              margin: EdgeInsets.only(
//                  left: ScreenUtil().setWidth(60),
//                  right: ScreenUtil().setWidth(59),
//                  bottom: ScreenUtil().setHeight(56)),
//              padding: EdgeInsets.only(
//                  left: ScreenUtil().setWidth(46),
//                  top: ScreenUtil().setHeight(29),
//                  bottom: ScreenUtil().setHeight(34.9)),
//              width: ScreenUtil().setWidth(961),
//              decoration: BoxDecoration(
//                color: Color(0xffe8e8e8),
//                borderRadius: BorderRadius.circular(
//                    SizeRender.renderBorderSize(context, 57.0)),
//              ),
//              child: Row(
//                mainAxisSize: MainAxisSize.min,
//                children: <Widget>[
//                  Container(
//                    child: Image.asset(
//                      "asset/images/group_9898.png",
//                      color: prefix0.blackColor333,
//                      width: ScreenUtil().setWidth(58.0),
//                      height: ScreenUtil().setHeight(58.0),
//                    ),
//                  ),
//                  SizedBox(
//                    width: ScreenUtil().setWidth(30.7),
//                  ),
//                  Expanded(
//                      child: TextField(
//                    controller: _searchController,
//                    onChanged: (inputChange){
//                      _addMemberMeetingBloc.searchUser(appBloc, inputChange);
//                    },
//                    style: TextStyle(
//                        color: prefix0.blackColor333,
//                        fontFamily: 'Roboto-Regular',
//                        fontSize: ScreenUtil().setSp(50)),
//                    decoration: InputDecoration(
//                        contentPadding: EdgeInsets.zero,
//                        isDense: true,
//                        enabledBorder: InputBorder.none,
//                        disabledBorder: InputBorder.none,
//                        focusedBorder: InputBorder.none,
//                        border: InputBorder.none,
//                        hintText: "Tìm theo tên",
//                        hintStyle: TextStyle(
//                            color: prefix0.blackColor333,
//                            fontFamily: 'Roboto-Regular',
//                            fontSize: ScreenUtil().setSp(50))),
//                  ))
//                ],
//              ),
//            ),
//            Positioned(
//              top: ScreenUtil().setHeight(38),
//              right: ScreenUtil().setWidth(96.7),
//              child: Image.asset(
//                "asset/images/ic_dismiss.png",
//                color: prefix0.blackColor333,
//                width: ScreenUtil().setWidth(49),
//              ),
//            )
//          ],
//        ),
        //tìm theo tên

        StreamBuilder<FilterTabStreamModel>(
            initialData:
                FilterTabStreamModel(state: FilterMemberTabState.THEO_DANH_BA),
            stream: _addMemberMeetingBloc.clickTabStream.stream,
            builder: (context, snapshot) {
              return snapshot.data.state == FilterMemberTabState.THEO_DANH_BA
                  ?
                  //Khung tìm kiếm Theo danh bạ
                  Stack(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              left: ScreenUtil().setWidth(60),
                              right: ScreenUtil().setWidth(59),
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
                                controller: _searchController,
                                onChanged: (inputChange) {
                                  _addMemberMeetingBloc.searchUser(
                                      appBloc, inputChange);
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
                                appBloc.mainChatBloc.listGroupStream.notify(
                                    ListGroupModel(
                                        state: ListGroupState.SHOW,
                                        listGroupModel:
                                            appBloc.mainChatBloc.listGroups));
                              },
                              child: Image.asset(
                                "asset/images/ic_dismiss.png",
                                color: prefix0.blackColor333,
                                width: ScreenUtil().setWidth(49),
                              ),
                            ))
                      ],
                    )
                  :
                  //Khung tìm kiếm theo nhóm
                  Stack(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                              left: ScreenUtil().setWidth(60),
                              right: ScreenUtil().setWidth(59),
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
                                controller: _searchController,
                                onChanged: (inputChange) {
                                  _addMemberMeetingBloc.searchGroup(
                                      appBloc, inputChange);
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
                                appBloc.mainChatBloc.listGroupStream.notify(
                                    ListGroupModel(
                                        state: ListGroupState.SHOW,
                                        listGroupModel:
                                            appBloc.mainChatBloc.listGroups));
                              },
                              child: Image.asset(
                                "asset/images/ic_dismiss.png",
                                color: prefix0.blackColor333,
                                width: ScreenUtil().setWidth(49),
                              ),
                            ))
                      ],
                    );
            }),

        StreamBuilder<FilterTabStreamModel>(
            initialData:
                FilterTabStreamModel(state: FilterMemberTabState.THEO_DANH_BA),
            stream: _addMemberMeetingBloc.clickTabStream.stream,
            builder: (context, snapshot) {
              return snapshot.data.state == FilterMemberTabState.THEO_DANH_BA
                  ? _buildListContact()
                  : _buildGridGroup();
            }),
      ],
    );
  }

  _buildNumber_Member_CREATE() {
    return StreamBuilder(
        initialData: _addMemberMeetingBloc.listUserPicked.length,
        stream: _addMemberMeetingBloc.countPickedStream.stream,
        builder: (buildContext, AsyncSnapshot<int> countMemberPickedSnap) {
          return Container(
            alignment: countMemberPickedSnap.data == 0
                ? Alignment.center
                : Alignment.centerLeft,
            margin: countMemberPickedSnap.data == 0
                ? EdgeInsets.zero
                : EdgeInsets.only(left: ScreenUtil().setWidth(60)),
            child: Text(
              countMemberPickedSnap.data != 0
                  ? "${countMemberPickedSnap.data} thành viên"
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

  _buildNumber_Member_Edit() {
    return StreamBuilder(
        initialData: widget.editMeetingBloc.listMember.length,
        stream: widget.editMeetingBloc.countMemberStream.stream,
        builder: (buildContext, AsyncSnapshot<int> countMemberPickedSnap) {
          return Container(
            alignment: countMemberPickedSnap.data == 0
                ? Alignment.center
                : Alignment.centerLeft,
            margin: countMemberPickedSnap.data == 0
                ? EdgeInsets.zero
                : EdgeInsets.only(left: ScreenUtil().setWidth(60)),
            child: Text(
              countMemberPickedSnap.data != 0
                  ? "${countMemberPickedSnap.data} thành viên"
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

  _buildListContact() {
    return StreamBuilder(
        initialData: appBloc.calendarBloc.listASGLUserModel.length == 0
            ? null
            : appBloc.calendarBloc.listASGLUserModel,
        stream: appBloc.calendarBloc.listASGLUserStream.stream,
        builder:
            (buildContext, AsyncSnapshot<List<ASGUserModel>> snapshotData) {
          if (!snapshotData.hasData || snapshotData.data == null) {
            return Expanded(
              child: Center(
                child: Loading(),
              ),
            );
          } else {
            return Expanded(
              child: ListView.builder(
                  addAutomaticKeepAlives: true,
                  itemCount: snapshotData.data.length,
                  itemBuilder: (itemContext, index) {
                    bool isPicked = false;
                    if (widget.mode == AddMemberScreenMode.CREATE) {
                      if (_addMemberMeetingBloc.listUserPicked != null &&
                          _addMemberMeetingBloc.listUserPicked.length > 0) {
                        ASGUserModel userModel =
                            _addMemberMeetingBloc.listUserPicked.firstWhere(
                                (user) =>
                                    user.username ==
                                    snapshotData.data[index].username,
                                orElse: () => null);

                        if (userModel != null) {
                          isPicked = true;
                        }
                      }
                    } else {
                      if (widget.editMeetingBloc.listMember != null &&
                          widget.editMeetingBloc.listMember.length > 0) {
                        ParticipantModel userModel =
                            widget.editMeetingBloc.listMember.firstWhere(
                                (user) =>
                                    user.id == snapshotData.data[index].id,
                                orElse: () => null);

                        if (userModel != null) {
                          isPicked = true;
                        }
                      }
                    }

                    return _buildItemInListContact(
                        snapshotData.data[index],
                        snapshotData.data[index].position.name ??
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
        if (widget.mode == AddMemberScreenMode.CREATE)
          _addMemberMeetingBloc.pickedOrRemoveUser(context, userModel.username);
        else {
          widget.editMeetingBloc.pickedOrRemoveUser(
              context: context, id: userModel.id, appBloc: appBloc);
        }
      },
      child: Column(
        children: <Widget>[
          SizedBox(height: ScreenUtil().setHeight(24)),
          Row(
            children: <Widget>[
              SizedBox(width: ScreenUtil().setWidth(59.0)),
              CustomCircleAvatar(
                position: ImagePosition.GROUP,
                userName: userModel.username,
                size: 114.0,
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

  _buildListMemberPicked_CREAT() {
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
            itemCount: _addMemberMeetingBloc.listUserPicked.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildItemItemUserPicked(
                  1, _addMemberMeetingBloc.listUserPicked[index]);
            },
          )),
    );
  }

  _buildListMemberPicked_EDIT() {
    return Container(
      padding: EdgeInsets.only(
        left: 60.0.w,
      ),
      height: 195.0.w,
      child: ScrollConfiguration(
          behavior: MyBehavior(),
          child: StreamBuilder<List<ParticipantModel>>(
              initialData: widget.editMeetingBloc.listMember,
              stream: widget.editMeetingBloc.listMemberStream.stream,
              builder: (context, snapshot) {
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    //print(appBloc.calendarBloc.listASGLUserModel.length
                    //     .toString());
                    ParticipantModel snap = snapshot.data[index];
                    ASGUserModel userModel;
                    for (int kk = 0;
                        kk < appBloc.calendarBloc.listASGLUserModel.length;
                        kk++) {
                      ASGUserModel uu =
                          appBloc.calendarBloc.listASGLUserModel[kk];
                      if (uu.id == snap.id) {
                        userModel = uu;
                      }
                    }

//                    ASGUserModel userModel =
//                        appBloc.calendarBloc.listASGLUserModel.firstWhere(
//                            (user) => user.id == snapshot.data[index].id)??null;
                    if (userModel != null)
                      return _buildItemItemUserPicked(1, userModel);
                    else
                      return Container();
                  },
                );
              })),
    );
  }

  _buildItemItemUserPicked(int index, ASGUserModel userModel) {
    return Container(
      width: 160.0.w,
      height: 160.0.h,
      margin: EdgeInsets.only(right: ScreenUtil().setWidth(47.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          index == 0
              ? Container(
                  width: ScreenUtil().setWidth(160),
                  height: ScreenUtil().setHeight(160),
                  child: Image.asset(
                    "asset/images/ic_addchat.png",
//                  width: ScreenUtil().setWidth(160),
                    fit: BoxFit.fitWidth,
                  ),
                )
              : Stack(
                  children: <Widget>[
                    CustomCircleAvatar(
                      position: ImagePosition.GROUP,
                      size: 160.0,
                      userName: userModel?.username ?? "",
                    ),
                    Positioned(
                      right: ScreenUtil().setWidth(8.0),
                      top: 0,
                      child: InkWell(
                        onTap: () {
                          if (widget.mode == AddMemberScreenMode.CREATE)
                            _addMemberMeetingBloc.pickedOrRemoveUser(
                                context, userModel.username);
                          else
                            widget.editMeetingBloc.pickedOrRemoveUser(
                                context: context, id: userModel.id);
                        },
                        child: Container(
                          child: Icon(Icons.close,
                              color: Colors.white,
                              size: ScreenUtil().setSp(31.3)),
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

  _buildGridGroup() {
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
          snapshot.data.listGroupModel
              ?.removeWhere((room) => room.name == Const.BAN_TIN);
          snapshot.data.listGroupModel
              ?.removeWhere((room) => room.name == Const.FAQ);
          snapshot.data.listGroupModel
              ?.removeWhere((room) => room.name.contains(Const.THONG_BAO));
          switch (snapshot.data.state) {
            case ListGroupState.SHOW:
              return ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: GridView.count(
                      padding: EdgeInsets.only(left: 60.0.w, right: 56.0.h),
                      crossAxisSpacing: 35.0.w,
                      mainAxisSpacing: 56.0.h,
                      scrollDirection: Axis.vertical,
                      childAspectRatio:ScreenUtil().setWidth(463.0)/(369.h+195.w),
                      physics: AlwaysScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      children: snapshot.data.listGroupModel
                          .map(
                            (wsRoomModel) => ItemGroupPickMember(
                              roomModel: wsRoomModel,
                              onPickAllMemberOnRoom: (bool isPicked,
                                  List<RestUserModel> listGroupMember) {
                                if (widget.mode == AddMemberScreenMode.CREATE) {
                                  if (isPicked) {
                                    _addMemberMeetingBloc.pickedMember(
                                        appBloc, listGroupMember);
                                  } else {
                                    _addMemberMeetingBloc.removeMember(
                                        appBloc, listGroupMember);
                                  }
                                } else {
                                  if (isPicked) {
                                    widget.editMeetingBloc.pickedMember_inGroup(
                                        appBloc, listGroupMember, context);
                                  } else {
                                    widget.editMeetingBloc.removeMember_inGroup(
                                        appBloc, listGroupMember, context);
                                  }
                                }
                              },
                            ),
                          )
                          .toList()));
              break;
            default:
              return Expanded(
                child: Center(
                  child: Text("Đang cập nhật thông tin nhóm..."),
                ),
              );
              break;
          }
        },
      ),
    );
  }

  _buildAppbar() {
    return PreferredSize(
        child: AppBar(
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
                      if (widget.mode == AddMemberScreenMode.CREATE) {
                        widget.onBackScreen("");
                      } else {
                        widget.onBackScreen("");
                      }
                    },
                  ),
                ),
                Center(
                  child: Text(
                    "Chọn thành viên",
                    style: TextStyle(
                        fontFamily: "Roboto-Bold",
                        fontWeight: FontWeight.bold,
                        color: prefix0.asgBackgroundColorWhite,
                        fontSize: ScreenUtil()
                            .setSp(60.0, allowFontScalingSelf: false)),
                  ),
                )
              ],
            ),
          ),
          centerTitle: true,
          titleSpacing: 0.0,
        ),
        preferredSize: Size.fromHeight(ScreenUtil().setHeight(171)));
  }
}
