import 'package:flutter/material.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/model/asgl_user_model_extension.dart';
import 'add_member_screen.dart';

//Callback được sử dụng như này:
// dynamic ở đây có thể thay thế = List<Participaint>()
typedef OnResultData = Function(dynamic);
typedef OnBack = Function(dynamic);
typedef OnInit = Function();

class CreateMeetingManagerMember extends StatefulWidget {
  //final EditParticipantsModel editParticipantsModel;
//  final List<ParticipantModel> participant;
  final OnBack onBack;
  final OnResultData resultData;
  final OnInit onInit;
  final List<ASGUserModel> listUserModel;
  final ManagerCreateMeetingBloc bloc;

  CreateMeetingManagerMember(
      {this.onBack,
      this.resultData,
      this.onInit,
      this.listUserModel,
      this.bloc});

  @override
  _CreateMeetingManagerMemberState createState() =>
      _CreateMeetingManagerMemberState();
}

class _CreateMeetingManagerMemberState
    extends State<CreateMeetingManagerMember> {
  AppBloc appBloc;

  @override
  void initState() {
    widget.bloc.setData(widget.listUserModel);
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return Stack(
      children: <Widget>[
        Scaffold(
            appBar: AppBar(
              backgroundColor: prefix0.accentColor,
              title: Text(
                "Quản lý thành viên",
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(60),
                    color: prefix0.whiteColor,
                    fontFamily: 'Roboto-Bold'),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  widget.onBack(widget.listUserModel);
                },
              ),
              elevation: 0,
              centerTitle: true,
            ),
            body: Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Container(
                            color: Color(0xff959ca7).withOpacity(0.05),
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(40),
                                bottom: ScreenUtil().setHeight(42),
                                left: ScreenUtil().setWidth(56)),
                            margin: EdgeInsets.only(
                              bottom: ScreenUtil().setHeight(29),
                            ),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Thành viên tham dự: ".toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Roboto-Regular',
                                    fontSize: ScreenUtil().setSp(50),
                                    color: Color(0xff959ca7),
                                  ),
                                ),
                                StreamBuilder(
                                    initialData:
                                    widget.bloc.listMember,
                                    stream: widget.bloc
                                        .listMemberStream.stream,
                                    builder: (context, snapshot) {
                                      return Text(
                                        snapshot.data.length.toString(),
                                        style: TextStyle(
                                          fontFamily: 'Roboto-Bold',
                                          fontSize: ScreenUtil().setSp(50),
                                          color: prefix0.blackColor333,
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          ),
                          Positioned(
                            top: ScreenUtil().setHeight(28.0),
                            right: ScreenUtil().setWidth(59),
                            child: InkWell(
                              onTap: () {
                                widget.bloc.showAddMemberScreen();
                              },
                              child: Image.asset(
                                "asset/images/ic_addMember.png",
                                width: ScreenUtil().setWidth(92.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      StreamBuilder<List<ASGUserModel>>(
                          initialData: widget.bloc.listMember,
                          stream:
                          widget.bloc.listMemberStream.stream,
                          builder: (context, snapshot) {
                            return Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
//                              physics: AlwaysScrollableScrollPhysics(),
                                itemCount: snapshot.data.length,
                                itemBuilder: (buildContex, index) {
                                  ASGUserModel userModel = snapshot.data[index];
                                  return Container(
                                    margin: EdgeInsets.only(
                                      bottom: ScreenUtil().setHeight(37),
                                      left: ScreenUtil().setWidth(60),
                                    ),
                                    child: Stack(
                                      children: <Widget>[
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            CustomCircleAvatar(
                                              userName: userModel.username,
                                              position: ImagePosition.GROUP,
                                              size: 114.0,
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: ScreenUtil()
                                                      .setWidth(60)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    userModel.full_name,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Roboto-Regular',
                                                      fontSize: ScreenUtil()
                                                          .setSp(50),
                                                      color:
                                                          prefix0.blackColor333,
                                                    ),
                                                  ),
                                                  Text(
                                                    userModel.getDepartment(),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Roboto-Regular',
                                                      fontSize: ScreenUtil()
                                                          .setSp(40),
                                                      color: Color(0xff959ca7),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  top: ScreenUtil()
                                                      .setHeight(10)),
                                              child: Icon(
                                                Icons.brightness_1,
                                                color: Color(0xff959ca7),
                                                size: ScreenUtil().setWidth(34),
                                              ),
                                            )
                                          ],
                                        ),
                                        Positioned(
                                          top: ScreenUtil().setHeight(10),
                                          right: ScreenUtil().setWidth(75),
                                          child: InkWell(
                                            onTap: () {
                                              widget.bloc
                                                  .removeUser(userModel);
                                            },
                                            child: Container(
                                                width:
                                                    ScreenUtil().setWidth(60),
                                                height:
                                                    ScreenUtil().setWidth(60),
                                                decoration: BoxDecoration(
                                                    color: Color(0xffe10606),
                                                    shape: BoxShape.circle),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.close,
                                                    color: prefix0.white,
                                                    size: ScreenUtil()
                                                        .setWidth(47.4),
                                                  ),
                                                )),
                                          ),
                                        ) //đấu x đỏ
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                      SizedBox(
                        height: ScreenUtil().setHeight(450.0),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    bottom: 0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: <Widget>[
                          ButtonTheme(
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: ScreenUtil().setHeight(163.0),
                              padding: EdgeInsets.only(
                                left: ScreenUtil().setWidth(129),
                                right: ScreenUtil().setWidth(128),
                              ),
                              child: new ButtonTheme(
                                child: RaisedButton.icon(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          ScreenUtil().setWidth(10.0))),
                                  elevation: 0.0,
                                  icon: Text(''),
                                  color: prefix0.accentColor,
                                  highlightColor: prefix0.accentColor,
                                  label: Text('Hoàn tất',
                                      style: TextStyle(
                                        fontFamily: 'Roboto-Bold',
                                        fontSize: ScreenUtil().setSp(60.0),
                                        color: prefix0.whiteColor,
                                      )),
                                  onPressed: () {
                                    widget.resultData(
                                        widget.bloc.listMember);
                                  },
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border(
                              top: BorderSide(
                                color: Color(0xfff2f2f2),
                                width: 1.0,
                              ),
                            )),
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.only(
                              top: ScreenUtil().setWidth(54),
                            ),
                            padding: EdgeInsets.only(
                              top: ScreenUtil().setWidth(46),
                              bottom: ScreenUtil().setWidth(41.6),
                              left: ScreenUtil().setWidth(129),
                              right: ScreenUtil().setWidth(128),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      Icons.brightness_1,
                                      color: Color(0xff3baae2),
                                      size: ScreenUtil().setWidth(34),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      child: Text(
                                        "Đã xác nhận",
                                        style: TextStyle(
                                            fontFamily: 'Roboto-Regular',
                                            color: Color(0xff959ca7)),
                                      ),
                                    )
                                  ],
                                ),
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        Icons.brightness_1,
                                        color: Color(0xff959ca7),
                                        size: ScreenUtil().setWidth(34),
                                      ),
                                      SizedBox(
                                        width: ScreenUtil().setWidth(20),
                                      ),
                                      Flexible(
                                        child: Text(
                                          "Chưa xác nhận",
                                          style: TextStyle(
                                              fontFamily: 'Roboto-Regular',
                                              color: Color(0xff959ca7)),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      Icons.brightness_1,
                                      color: Color(0xffe10606),
                                      size: ScreenUtil().setWidth(34),
                                    ),
                                    SizedBox(
                                      width: ScreenUtil().setWidth(20),
                                    ),
                                    Flexible(
                                      child: Text(
                                        "Từ chối",
                                        style: TextStyle(
                                            fontFamily: 'Roboto-Regular',
                                            color: Color(0xff959ca7)),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))
              ],
            )),
        StreamBuilder(
          initialData: false,
          stream: widget.bloc.showAddMemberStream.stream,
          builder: (buildContext, AsyncSnapshot<bool> showAddMemberSnap) {
            if (!showAddMemberSnap.data) {
              return Container();
            } else {
              return AddMemberMeetingScreen(
                onInit: () {
                  appBloc.backStateBloc.focusWidgetModel = FocusWidgetModel(
                      state:
                          isFocusWidget.ADD_MEMBER_FROM_CREATE_MANAGER_MEMBER);
                },
                mode: AddMemberScreenMode.CREATE,
                onBackScreen: (data) {
                  // print(data);
                  widget.bloc.showAddMemberStream.notify(false);
                },
                onPickedUser: (listUserPicked) {
                  widget.bloc.pickedUsers(listUserPicked);
                },
                listASGUserModel: widget.bloc.listMember,
              );
            }
          },
        ),
      ],
    );
  }
}

class ManagerCreateMeetingBloc {
  List<ASGUserModel> listMember = List();
  CoreStream<List<ASGUserModel>> listMemberStream = CoreStream();
  CoreStream<bool> showAddMemberStream = CoreStream();

  void setData(List<ASGUserModel> listUserModel) {
    listMember.clear();
    listMember.addAll(listUserModel);
    listMemberStream?.notify(listMember);
  }

  void pickedUsers(List<ASGUserModel> listUserPicked) {
    listMember.clear();
    listMember.addAll(listUserPicked);
    listMemberStream?.notify(listMember);
  }

  void removeUser(ASGUserModel userModel) {
    listMember?.removeWhere((user) => user.id == userModel.id);
    listMemberStream?.notify(listMember);
  }

  void showAddMemberScreen() {
    showAddMemberStream?.notify(true);
  }
}
