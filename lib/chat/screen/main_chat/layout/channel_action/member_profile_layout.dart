
import 'package:human_resource/chat/screen/main_chat/chat/layout_action_bloc.dart';
import 'package:human_resource/chat/screen/main_chat/layout/channel_action/member_profile_bloc.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/hive/hive_helper.dart';
import 'package:human_resource/core/platform/platform_helper.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/home/home_bloc.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/model/asgl_user_model_extension.dart';
typedef OnInit = Function();

class MemberProfileLayout extends StatefulWidget {
  final WsRoomModel
      roomModel; //Nó null thì ông lấy kiểu gì? Làm không đọc code à?
  final LayoutActionBloc layoutActionBloc;
  final OnInit onInit;
  final Map<String, dynamic> dataShow;
  final bool isScreenInChatLayout;

  const MemberProfileLayout(
      {@required this.roomModel,
      @required this.layoutActionBloc,
      this.onInit,
      this.dataShow,
      this.isScreenInChatLayout});

  @override
  _MemberProfileLayoutState createState() => _MemberProfileLayoutState();
}

class _MemberProfileLayoutState extends State<MemberProfileLayout> {
  AppBloc appBloc;
  MemberProfileBloc bloc = MemberProfileBloc();

  @override
  void initState() {
    if (widget.onInit != null) {
      widget.onInit();
    }
    super.initState();
    Future.delayed(Duration.zero, () {
      bloc.getData(context, widget.dataShow);
    });
  }

  ASGUserModel userModel;

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    if (widget.onInit == null) {
      appBloc.backStateBloc.focusWidgetModel =
          FocusWidgetModel(state: isFocusWidget.MEMBER_PROFILE);
    }
    ASGUserModel userModel =
        HiveHelper.getOnlyUserFromListContact(widget.dataShow['user'].username);
    return WillPopScope(
      onWillPop: () async {
        appBloc.backStateBloc.focusWidgetModel =
            FocusWidgetModel(state: isFocusWidget.HOME);
        appBloc.homeBloc.changeActionMeeting(
          state: LayoutNotBottomBarState.NONE,
        );
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0.0,
            backgroundColor: Color(0xff005a88),
            title: Container(
              height: 178.5.h,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    child: InkWell(
                        onTap: () {
                          if (widget.layoutActionBloc != null) {
                            widget.layoutActionBloc.changeState(
                                LayoutActionState.ROOM_INFO,
                                data: widget.dataShow['owner']);
                          } else if (widget.isScreenInChatLayout) {
                            appBloc.mainChatBloc.openRoom(
                                appBloc, widget.dataShow['roomModel']);
                          } else {
                            appBloc.homeBloc.changeActionMeeting(
                              state: LayoutNotBottomBarState.NONE,
                            );
                          }
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
                            fit: BoxFit.contain,
                            color: prefix0.white,
                            width: ScreenUtil().setWidth(49.0),
                          ),
                        )),
                  ),
                  Center(
                    child: Text(
                      "Thông tin thành viên",
                      style: TextStyle(
                        fontSize: ScreenUtil().setSp(60.0),
                        fontFamily: "Roboto-Bold",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: StreamBuilder(
            initialData:
                MemberProfileModel(MemeberProfileState.SUCCESS, userModel),
            stream: bloc.memberProfileStream.stream,
            builder:
                (buildContext, AsyncSnapshot<MemberProfileModel> snapshotData) {
              switch (snapshotData.data.memberProfileState) {
                case MemeberProfileState.ERROR:
                  return Container(
                      margin: EdgeInsets.only(left: 35.0, right: 35.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              "Đã xảy ra lỗi khi lấy thông tin người dùng. Vui lòng nhấn nút \"Thử lại\"",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: prefix0.blackColor333,
                                  fontFamily: "Roboto-Regular",
                                  fontSize: 45.0.sp),
                            ),
                            SizedBox(
                              height: 20.0.h,
                            ),
                            RaisedButton(
                              color: prefix0.accentColor,
                              onPressed: () {
                                bloc.getData(context, widget.dataShow,
                                    isGetUserInfo: true);
                              },
                              child: Text("Thử lại",
                                  style: TextStyle(
                                      color: prefix0.white,
                                      fontFamily: "Roboto-Regular",
                                      fontSize: 45.0.sp)),
                            )
                          ],
                        ),
                      ));
                  break;
                case MemeberProfileState.LOADDING:
                  return Loading();
                  break;
                case MemeberProfileState.SUCCESS:
                  if (userModel == null) {
                    bloc.getData(context, widget.dataShow, isGetUserInfo: true);
                    return Loading();
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: ScreenUtil().setHeight(74.7)),
                        Center(
                          child: Container(
                              width: ScreenUtil().setHeight(346.7),
                              height: ScreenUtil().setHeight(344.2),
                              child: CircleAvatar(
                                child: CustomCircleAvatar(
                                  position: ImagePosition.GROUP,
                                  userName:
                                      (snapshotData.data.data as ASGUserModel)
                                          ?.username,
                                  size: 344.0,
                                ),
                                radius: 50.0,
                                backgroundColor: Colors.transparent,
                              )),
                        ),
                        //avatar
                        SizedBox(height: ScreenUtil().setHeight(36.3)),
                        Text(
                          (snapshotData.data.data as ASGUserModel)?.full_name ??
                              "Không xác định",
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(60.0),
                              fontFamily: "Roboto-Bold",
                              fontWeight: FontWeight.bold,
                              color: Color(0xff263238)),
                        ),
                        //Họ tên
                        SizedBox(height: ScreenUtil().setHeight(4.7)),
                        Text(
                          "ID: " +
                              (snapshotData.data.data as ASGUserModel).asgl_id,
                          style: new TextStyle(
                            fontFamily: 'Roboto',
                            color: Color(0xff959ca7),
                            fontSize: ScreenUtil().setSp(50.0),
                          ),
                        ),
                        //ID: ASGL-0053
                        SizedBox(height: ScreenUtil().setHeight(56.0)),
                        Container(
                          width: MediaQuery.of(context).size.width,
//              height: ScreenUtil().setHeight(148.0),
//              color: Color(0xff959ca7),
                          decoration: BoxDecoration(
                            color: Color(0xff959ca7).withOpacity(0.05),
                          ),
                          padding: EdgeInsets.only(
                              top: ScreenUtil().setHeight(44.0),
                              bottom: ScreenUtil().setHeight(43.0),
                              left: ScreenUtil().setWidth(60)),
                          child: Text(
                            "THÔNG TIN CÁ NHÂN",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: Color(0xff959ca7),
                              fontSize: ScreenUtil().setSp(50.0),
                            ),
                          ),
                        ),
                        //tiêu đề: thông tin cá nhân,
                        SizedBox(height: ScreenUtil().setHeight(7.5)),
                        //khoảng cách giữa các dòng là 110.0
                        _buildItemInfor(
                          "Họ tên",
                          (snapshotData.data.data as ASGUserModel)?.full_name ??
                              "Không xác định",
                        ),
                        _buildItemInfor(
                          "Mã nhân viên",
                          (snapshotData.data.data as ASGUserModel)?.asgl_id ??
                              "Không xác định",
                        ),
                        _buildItemInfor(
                          "Bộ phận",
                          (snapshotData.data.data as ASGUserModel)
                                  ?.getDepartment() ??
                              "Không xác định",
                        ),
                        _buildItemInfor(
                          "Chức danh",
                          (snapshotData.data.data as ASGUserModel)
                                  ?.getPosition() ??
                              "Không xác định",
                        ),
                        _buildItemInfor(
                          "Điện thoại",
                          (snapshotData.data.data as ASGUserModel)
                                  ?.getMobilePhone() ??
                              "Không xác định",
                        ),
                        _buildItemInfor(
                            "Email",
                            (snapshotData.data.data as ASGUserModel)
                                    ?.getEmail() ??
                                "Không xác định",
                            lastItem: true),
                        SizedBox(height: ScreenUtil().setHeight(90.0 - 7.0)),
                        //chỗ này do thiết kế dị quá, trừ áng chừng

                        //Đổi mật khẩu
//            SizedBox(height: ScreenUtil().setHeight(51.0)),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Color(0xff005a88),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(50),
                                      topLeft: Radius.circular(50)),
                                ),
//                    width: ScreenUtil().setWidth(689),
                                height: ScreenUtil().setHeight(174),
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(width: ScreenUtil().setWidth(59)),
                                    widget.dataShow['openNotification']
                                        ? StreamBuilder(
                                            initialData:
                                                MemberNotificationModel(
                                                    MemberNotificationState
                                                        .SUCCESS,
                                                    null),
                                            //dữ liệu bắn từ member_profile_bloc không đi qua stream bloc = null
                                            stream: bloc
                                                .memberNotificationStream
                                                .stream,
                                            builder: (buildContent,
                                                AsyncSnapshot<
                                                        MemberNotificationModel>
                                                    snapshotMember) {
                                              switch (snapshotMember.data
                                                  .memberNotificationState) {
                                                case MemberNotificationState
                                                    .SUCCESS:
                                                  return Row(
                                                    children: <Widget>[
                                                      InkWell(
                                                        onTap: () {
                                                          _showDialogRequestDisableRoom(
                                                              true,
                                                              widget.dataShow[
                                                                  'roomId']);
                                                        },
                                                        child: Container(
                                                          width: ScreenUtil()
                                                              .setWidth(112),
                                                          height: ScreenUtil()
                                                              .setHeight(112),
                                                          child: CircleAvatar(
                                                            child: Container(
                                                              child:
                                                                  Image.asset(
                                                                "asset/images/ic_enable_notification_member.png",
                                                                fit: BoxFit
                                                                    .fitWidth,
                                                              ),
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          53.3),
                                                            ),
                                                            backgroundColor:
                                                                Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: ScreenUtil()
                                                              .setWidth(72)),
                                                    ],
                                                  );
                                                  break;
                                                case MemberNotificationState
                                                    .ERROR:
                                                  return Row(
                                                    children: <Widget>[
                                                      InkWell(
                                                        onTap: () {
                                                          _showDialogRequestDisableRoom(
                                                              false,
                                                              snapshotMember
                                                                  .data.data);
                                                        },
                                                        child: Container(
                                                          width: ScreenUtil()
                                                              .setWidth(112),
                                                          height: ScreenUtil()
                                                              .setHeight(112),
                                                          child: CircleAvatar(
                                                            child: Container(
                                                              child:
                                                                  Image.asset(
                                                                "asset/images/ic_disable_notification_member.png",
                                                                fit: BoxFit
                                                                    .fitWidth,
                                                              ),
                                                              width:
                                                                  ScreenUtil()
                                                                      .setWidth(
                                                                          53.3),
                                                            ),
                                                            backgroundColor:
                                                                Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: ScreenUtil()
                                                              .setWidth(72)),
                                                    ],
                                                  );
                                                  break;
                                                default:
                                                  return Container();
                                                  break;
                                              }
                                            },
                                          )
                                        : Container(),
                                    InkWell(
                                      onTap: () {
                                        bloc.openChatLayout(
                                            context,
                                            snapshotData.data.data.username,
                                            widget.layoutActionBloc);
                                      },
                                      child: Container(
                                        width: ScreenUtil().setWidth(112),
                                        height: ScreenUtil().setHeight(112),
                                        child: CircleAvatar(
                                          child: Container(
                                            child: Image.asset(
                                              "asset/images/ic_chat_member.png",
                                              fit: BoxFit.fitWidth,
                                            ),
                                            width: ScreenUtil().setWidth(53.3),
                                          ),
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: ScreenUtil().setWidth(92)),
                                    InkWell(
                                      onTap: () {
                                        _callPhoneWith(snapshotData.data.data
                                            as ASGUserModel);
                                      },
                                      child: Container(
                                        width: ScreenUtil().setWidth(112),
                                        height: ScreenUtil().setHeight(112),
                                        child: CircleAvatar(
                                          child: Container(
                                            child: Image.asset(
                                              "asset/images/ic_phone.png",
                                              fit: BoxFit.fitWidth,
                                            ),
                                            width: ScreenUtil().setWidth(53.3),
                                          ),
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: ScreenUtil().setWidth(132)),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                  break;
                default:
                  return Container();
                  break;
              }
            },
          )),
    );
  }

  _buildItemInfor(String title, String content, {bool lastItem = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(60.0),
              right: ScreenUtil().setWidth(59.0)),
          height: ScreenUtil().setHeight(110.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(title,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Color(0xff959ca7),
                    fontSize: ScreenUtil().setSp(50.0),
                  )),
              Flexible(
                child: Text(
                    content == null || content == ""
                        ? "Không xác định"
                        : content,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Color(0xff333333),
                      fontSize: ScreenUtil().setSp(50.0),
                    )),
              )
            ],
          ),
        ),
        !lastItem
            ? Container(
                margin: EdgeInsets.only(
                    left: ScreenUtil().setWidth(60.0),
                    right: ScreenUtil().setWidth(59.0)),
                height: 1.0,
                color: Color(0xff959ca7).withOpacity(0.15),
              )
            : Container()
      ],
    );
  }

  void _showDialogRequestDisableRoom(bool currentState, String roomID) {
    if (currentState) {
      DialogUtils.showDialogRequestChangeNotify(context, "Tắt thông báo",
          "Bạn có chắc muốn ", "tắt thông báo", " không?", onClickOK: () {
        bloc.turnOffNotification(roomID);
      });
    } else {
      DialogUtils.showDialogRequestChangeNotify(context, "Bật thông báo",
          "Bạn có chắc muốn ", "bật thông báo", " không?", onClickOK: () {
        bloc.turnOnNotification(roomID);
      });
    }
  }

  //Thực hiện cuộc gọi
  void _callPhoneWith(ASGUserModel data) {
    if (data != null && data.username != "") {
      PlatformHelper.createCallPhoneWith(
          context: context, userName: data.username);
    } else {
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Không tìm thấy số điện thoại người cần liên hệ.");
    }
  }
}
