import 'package:flutter/material.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/meeting/model/meeting_model.dart';
import 'package:human_resource/core/meeting/model/participant_model.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:human_resource/home/meeting/action_meeting/show_detail_meeting_bloc.dart';
import 'package:human_resource/home/meeting/action_meeting/show_member_bloc.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';

typedef OnReloadData = Function(bool);
typedef OnBack = Function();
typedef OnInit = Function();

//Danh sách thành viên trong lịch họp
class ShowMemberMeetingLayout extends StatefulWidget {
  final MeetingModel meetingModel;
  final OnReloadData onReloadData;
  final OnBack onBack;
  final OnInit onInit;

//final ShowDetailMeetingBloc showDetailMeetingBloc;
  const ShowMemberMeetingLayout(
      {Key key, this.meetingModel, this.onReloadData, this.onBack, this.onInit})
      : super(key: key);

  @override
  _ShowMemberMeetingLayoutState createState() =>
      _ShowMemberMeetingLayoutState();
}

class _ShowMemberMeetingLayoutState extends State<ShowMemberMeetingLayout> {
  AppBloc appBloc;
  ShowMemberBloc _showMemberBloc = ShowMemberBloc();

//  enum ConfirmAction { CANCEL, ACCEPT }
  final TextStyle titleTextStyle = TextStyle(
      color: prefix0.color959ca7,
      fontSize: 50.sp,
      fontFamily: 'Roboto-Regular');
  final TextStyle contentTextStyle = TextStyle(
      color: prefix0.blackColor333,
      fontFamily: 'Roboto-Regular',
      fontSize: 50.sp);
  final OutlineInputBorder inputContentBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0.w),
    borderSide: BorderSide(color: prefix0.color959ca7, width: 1.0),
  );

  @override
  void dispose() {
    _showMemberBloc.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    _showMemberBloc.meetingModel = widget.meetingModel;
    return WillPopScope(
      onWillPop: () async {
        widget.onBack();
        return false;
      },
      child: Stack(
        children: <Widget>[
          Scaffold(
              appBar: AppBar(
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
                                left: 60.w,
                                right: 59.w,
                                bottom: 66.2.h,
                                top: 60.h),
                            child: Image.asset(
                              "asset/images/ic_meeting_back_white.png",
                              color: prefix0.white,
                              width: ScreenUtil().setWidth(49.9),
                            ),
                          ),
                          onTap: () {
                            widget.onBack();
                          },
                        ),
                      ),
                      Center(
                        child: Text(
                          "Thành viên tham dự",
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(60),
                              color: prefix0.whiteColor,
                              fontFamily: 'Roboto-Bold'),
                        ),
                      )
                    ],
                  ),
                ),
                titleSpacing: 0.0,
                elevation: 0,
                centerTitle: true,
              ),
              body: Stack(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height - 150.0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                              Text(
                                "${widget.meetingModel?.participants?.length ?? 0}",
                                style: TextStyle(
                                  fontFamily: 'Roboto-Bold',
                                  fontSize: ScreenUtil().setSp(50),
                                  color: prefix0.blackColor333,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: StreamBuilder(
                              initialData: _showMemberBloc.meetingModel,
                              stream: _showMemberBloc.meetingModelStream.stream,
                              builder: (buildContext,
                                  AsyncSnapshot<MeetingModel> snapshotData) {
                                return ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount:
                                        snapshotData.data.participants.length,
                                    shrinkWrap: true,
                                    addAutomaticKeepAlives: true,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemBuilder: (buildContext, index) {
                                      return _buildMember(widget
                                          .meetingModel.participants[index]);
                                    });
                              }),
                        ),
                        SizedBox(
                          height: 75.0.h,
                        ),
                        StreamBuilder(
                            initialData: widget.meetingModel,
                            stream: _showMemberBloc.meetingModelStream.stream,
                            builder: (buildContext,
                                AsyncSnapshot<MeetingModel> snapshotData) {
                              return _buildLineRequestAccept();
                            }),
                        SizedBox(
                          height: 36.0.h,
                        ),
                        StreamBuilder(
                            initialData: widget.meetingModel,
                            stream: _showMemberBloc.meetingModelStream.stream,
                            builder: (buildContext,
                                AsyncSnapshot<MeetingModel> snapshotData) {
                              return _buildButtonCreateSchedule();
                            }),
                      ],
                    ),
                  ),
                  Positioned(
                      bottom: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      Text(
                                        "Đã xác nhận",
                                        style: TextStyle(
                                            fontFamily: 'Roboto-Regular',
                                            color: Color(0xff959ca7)),
                                      ),
                                    ],
                                  ),
                                  Row(
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
                                      Text(
                                        "Chưa xác nhận",
                                        style: TextStyle(
                                            fontFamily: 'Roboto-Regular',
                                            color: Color(0xff959ca7)),
                                      ),
                                    ],
                                  ),
                                  Flexible(
                                      child: Row(
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
                                      Text(
                                        "Từ chối",
                                        style: TextStyle(
                                            fontFamily: 'Roboto-Regular',
                                            color: Color(0xff959ca7)),
                                      ),
                                    ],
                                  )),
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
              stream: _showMemberBloc.loadingStream.stream,
              builder: (buildContext, AsyncSnapshot<bool> loadingSnap) {
                if (!loadingSnap.data) {
                  return Container();
                } else {
                  return Loading();
                }
              })
        ],
      ),
    );
  }

  _buildMember(ParticipantModel participantModel) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ScreenUtil().setHeight(37),
        left: ScreenUtil().setWidth(60),
      ),
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CustomCircleAvatar(
                position: ImagePosition.GROUP,
                size: 114.0,
                userName: participantModel.id.toString(),
              ),
              Container(
                margin: EdgeInsets.only(left: ScreenUtil().setWidth(60)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      participantModel.name,
                      style: TextStyle(
                        fontFamily: 'Roboto-Regular',
                        fontSize: ScreenUtil().setSp(50),
                        color: prefix0.blackColor333,
                      ),
                    ),
                    Text(
                      getDepartment(participantModel),
                      style: TextStyle(
                        fontFamily: 'Roboto-Regular',
                        fontSize: ScreenUtil().setSp(40),
                        color: Color(0xff959ca7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
              top: ScreenUtil().setHeight(10),
              right: ScreenUtil().setWidth(75),
              child: _status(participantModel.accepted))
        ],
      ),
    );
  }

  Widget _status(int stateAccepted) {
    if (stateAccepted == 1) {
      return Container(
          width: 34.w,
          height: 34.w,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Color(0xff3baae2)));
    } else if (stateAccepted == 0) {
      return Container(
          width: 34.w,
          height: 34.w,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Color(0xff959ca7)));
    } else {
      return Container(
          width: 34.w,
          height: 34.w,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Color(0xffe10606)));
    }
  }

  _buildButtonCreateSchedule() {
    bool isAfterMeetingTime = _showMemberBloc.checkAfterMeetingTime();
    if (isAfterMeetingTime) {
      return Container();
    }
    _showMemberBloc.checkAcceptedMeeting(context);
    if (_showMemberBloc.stateAccepted == 1 ||
        widget?.meetingModel?.status?.id == 3) {
      return Container();
    }
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            child: InkWell(
              onTap: () {
                if (_showMemberBloc.stateAccepted == 0) {
                  _showDialogRefuse();
                }
              },
              child: Text(
                _showMemberBloc.stateAccepted == 2
                    ? "Đã từ chối tham dự"
                    : "Từ chối tham dự",
                style: TextStyle(
                    color: prefix0.colore10606,
                    fontFamily: 'Roboto-Regular',
                    fontSize: 50.sp),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showDialogRefuse() {
    DialogUtils.showDialogRequestAcceptOrRefuse(context,
        title: "Từ chối cuộc họp",
        message: "Xác nhận từ chối cuộc họp", onClickOK: () {
      _showMemberBloc.acceptOrRefuseMeeting(
          context, widget.onReloadData, widget.meetingModel, false);
    });
  }

  void _showDialogAccept() {
    DialogUtils.showDialogRequestAcceptOrRefuse(context,
        title: "Xác nhận tham dự",
        message: "Bạn có chắc chắn xác nhận tham dự cuộc họp?", onClickOK: () {
      _showMemberBloc.acceptOrRefuseMeeting(
          context, widget.onReloadData, widget.meetingModel, true);
    });
  }

  _buildLineRequestAccept() {
    bool isAfterMeetingTime = _showMemberBloc.checkAfterMeetingTime();
    if (isAfterMeetingTime) {
      return Container();
    }
    _showMemberBloc.checkAcceptedMeeting(context);
    if (_showMemberBloc.stateAccepted == 2 ||
        widget?.meetingModel?.status?.id == 3) {
      return Container();
    }
    return InkWell(
      splashColor: prefix0.white,
      onTap: () {
        if (_showMemberBloc.stateAccepted == 0) {
          _showDialogAccept();
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _showMemberBloc.stateAccepted == 1
              ? Image.asset(
                  "asset/images/ic_meeting_accepted.png",
                  color: prefix0.blackColor333,
                  width: 58.0.w,
                )
              : Image.asset(
                  "asset/images/outline-no_check_box.png",
                  width: 58.0.w,
                ),
          SizedBox(
            width: 36.0.w,
          ),
          Text(
            _showMemberBloc.stateAccepted == 1
                ? "Đã xác nhận tham dự cuộc họp"
                : "Xác nhận tham dự cuộc họp",
            style: contentTextStyle,
          )
        ],
      ),
    );
  }

  String getDepartment(ParticipantModel member) {
    List<Position> position = member?.positions;
    if (position != null && position.length > 0) {
      return position[0]?.department?.name ?? "Không xác định";
    } else {
      return "Không xác định";
    }
  }
}
