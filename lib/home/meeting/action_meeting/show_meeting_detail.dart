import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/meeting/model/meeting_model.dart';
import 'package:human_resource/core/meeting/model/meeting_room_model.dart';
import 'package:human_resource/core/meeting/model/participant_model.dart';
import 'package:human_resource/home/meeting/action_meeting/create_meeting_screen.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/home/meeting/action_meeting/show_member_meeting.dart';
import 'package:human_resource/home/meeting/action_meeting/show_detail_meeting_bloc.dart';
import 'package:human_resource/utils/animation/buttom_calendar_meeting.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';
import 'dart:ui';
import '../../home_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'item_member_metting.dart';

//Xem thông tin lịch họp
//Không cho phép chinh sửa trong màn lịch họp
class ShowMeetingScreen extends StatefulWidget {
  final MeetingModel meetingModel;

  const ShowMeetingScreen({Key key, this.meetingModel}) : super(key: key);

  @override
  _ShowMeetingScreenState createState() => _ShowMeetingScreenState();
}

class _ShowMeetingScreenState extends State<ShowMeetingScreen>
    with TickerProviderStateMixin {
  ShowDetailMeetingBloc _showMeetingBloc = ShowDetailMeetingBloc();
  AppBloc appBloc;
  AnimationController _animationController;

//  BlocProvider.of(context);
  TextEditingController categoryController = TextEditingController();
  TextEditingController contentController = TextEditingController();
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
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      _showMeetingBloc.getMeetingDetail(context, widget.meetingModel, false);
    });
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _showMeetingBloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.DETAIL_MEETING);
    return WillPopScope(
      onWillPop: () async {
        if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.DETAIL_MEETING) {
          appBloc.homeBloc
              .changeActionMeeting(state: LayoutNotBottomBarState.NONE);
          appBloc.backStateBloc.focusWidgetModel =
              FocusWidgetModel(state: isFocusWidget.HOME);
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.DETAIL_MEETING_MEMBER) {
          _showMeetingBloc.showMemberStream?.notify(false);
          appBloc.backStateBloc.focusWidgetModel =
              FocusWidgetModel(state: isFocusWidget.DETAIL_MEETING);
        }
        return false;
      },
      child: Stack(
        children: <Widget>[
          Scaffold(
            backgroundColor: prefix0.asgBackgroundColorWhite,
            appBar: _buildAppbar(),
            body: _buildMeetingDetailLayout(),
          ),
          StreamBuilder(
              initialData: false,
              stream: _showMeetingBloc.showMemberStream.stream,
              builder: (buildContext, AsyncSnapshot<bool> showMemberDetail) {
                if (showMemberDetail.data) {
                  return ShowMemberMeetingLayout(
                    meetingModel: _showMeetingBloc.meetingModel,
                    onInit: () {
                      appBloc.backStateBloc.focusWidgetModel = FocusWidgetModel(
                          state: isFocusWidget.DETAIL_MEETING_MEMBER);
                    },
                    onReloadData: (isAccepted) {
                      _showMeetingBloc.updateData(
                          context, widget.meetingModel, isAccepted);
                    },
                    onBack: () {
                      _showMeetingBloc.showMemberStream?.notify(false);
                    },
                  );
                } else {
                  return Container();
                }
              })
        ],
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
                  appBloc.homeBloc
                      .changeActionMeeting(state: LayoutNotBottomBarState.NONE);
                },
              ),
            ),
            Center(
              child: Text(
                "Cuộc họp",
                style: TextStyle(
                    fontFamily: "Roboto-Bold",
                    fontWeight: FontWeight.bold,
                    color: prefix0.asgBackgroundColorWhite,
                    fontSize: ScreenUtil().setSp(60.0)),
              ),
            )
          ],
        ),
      ),
      centerTitle: true,
      titleSpacing: 0.0,
    );
  }

  //Todo: Xây dựng giao diện meeting detail trong hàm này
  ///Chú ý: Có thể tham khảo [CreateMeetingLayout]
  _buildMeetingDetailLayout() {
    return Stack(
      children: <Widget>[
        StreamBuilder(
            initialData: widget.meetingModel,
            stream: _showMeetingBloc.meetingModelStream.stream,
            builder: (buildContext, AsyncSnapshot<MeetingModel> snapshotData) {
              return Scaffold(
                body: Container(
                  padding: EdgeInsets.only(left: 60.5.h, right: 59.5.h),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 61.h,
                        ),
                        Text(
                          "Chủ đề".toUpperCase(),
                          style: titleTextStyle,
                        ),
                        SizedBox(
                          height: 17.0.h,
                        ),
                        _buildMeetingCategory(snapshotData.data.topic),
                        SizedBox(
                          height: 65.0.h,
                        ),
                        _buildComponentPickTimeAndLimit(
                            snapshotData.data.getStartTime(),
                            snapshotData.data.getTimeLimit()),
                        SizedBox(
                          height: 67.0.h,
                        ),
                        _buildComponentPickDateAndPlace(
                            snapshotData.data.getDate(),
                            snapshotData.data.room),
                        SizedBox(
                          height: 77.5.h,
                        ),
                        _buildComponentContent(snapshotData.data.description),
                        SizedBox(
                          height: 65.0.h,
                        ),
                        _buildComponentHasMember(
                            snapshotData.data.participants),
                        SizedBox(
                          height: 83.0.h,
                        ),
                        ButtomCalendarAnimation(_buildButtonSelectMember(),
                            onTap: () {
                          _OntapShowmember(snapshotData.data.participants);
                        }),
//                        ButtomCalendarAnimation(_buildButtonSelectMember(
//                            snapshotData.data.participants)),
                        SizedBox(
                          height: 78.0.h,
                        ),
                        _buildLineRequestAccept(snapshotData.data),
                        SizedBox(
                          height: 31.0.h,
                        ),
                        _buildButtonCreateSchedule(snapshotData.data),
                        SizedBox(
                          height: 839.6.h,
                        )
                      ],
                    ),
                  ),
                ),
              );
            }),
        StreamBuilder(
            initialData: false,
            stream: _showMeetingBloc.loadingStream.stream,
            builder: (buildContext, AsyncSnapshot<bool> snapshot) {
              if (snapshot.data) {
                return Loading();
              } else {
                return Container();
              }
            })
      ],
    );
  }

  _buildButtonCreateSchedule(MeetingModel meetingModel) {
    bool isAfterMeetingTime =
        _showMeetingBloc.checkAfterMeetingTime(meetingModel);
    if (isAfterMeetingTime) {
      return Container();
    }
    _showMeetingBloc.checkAccepted(context, meetingModel.participants);
    if (_showMeetingBloc.accepted == 1 || meetingModel.status.id == 3) {
      return Container();
    }
    return Center(
      child: Column(
        children: <Widget>[
          Container(
            child: InkWell(
              onTap: () {
                if (_showMeetingBloc.accepted == 0) _showDialogRefuse();
              },
              child: Text(
                _showMeetingBloc.accepted == 2
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

  _buildLineRequestAccept(MeetingModel meetingModel) {
    bool isAfterMeetingTime =
        _showMeetingBloc.checkAfterMeetingTime(meetingModel);
    if (isAfterMeetingTime) {
      return Container();
    }

    _showMeetingBloc.checkAccepted(context, meetingModel.participants);
    if (_showMeetingBloc.accepted == 2) {
      return Container();
    } else if (meetingModel?.status?.id == 3) {
      return Container();
    }
    return InkWell(
      splashColor: prefix0.white,
      onTap: () {
        if (_showMeetingBloc.accepted == 0) {
          _showDialogAccept();
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _showMeetingBloc.accepted == 1
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
            _showMeetingBloc.accepted == 0
                ? "Xác nhận tham dự cuộc họp"
                : "Đã xác nhận tham dự cuộc họp",
            style: contentTextStyle,
          )
        ],
      ),
    );
  }

  _OntapShowmember(List<ParticipantModel> participants) {
    if (participants != null && participants.length > 0) {
      _showMeetingBloc.showMemberStream.notify(true);
    } else {
      return Text(
        "Chưa có thành viên nào được mời tham dự cuộc họp này.",
        style: contentTextStyle,
      );
    }
  }

  _buildButtonSelectMember() {
//    if (participants != null && participants.length > 0) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              top: 21.0.h, bottom: 23.0.h, left: 119.0.w, right: 120.0.w),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(76.0.w),
              color: prefix0.asgBackgroundColorWhite,
              border: Border.all(
                  color: Color(0xFFe18c12),
                  width: 5.0.w,
                  style: BorderStyle.solid)),
          child: Center(
            child: Text(
              "Tất cả thành viên",
              style: contentTextStyle,
            ),
          ),
        )
      ],
    );
//      );
//    } else {
//      return Text(
//        "Chưa có thành viên nào được mời tham dự cuộc họp này.",
//        style: contentTextStyle,
//      );
//    }
  }

  //Danh sách thành viên tham dự
  _buildComponentHasMember(List<ParticipantModel> listMember) {
    int count = listMember != null ? listMember.length : 0;
    int itemCount = (count >= 3) ? 3 : count;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
            text: TextSpan(children: [
          TextSpan(
            text: "THÀNH VIÊN THAM DỰ: ",
            style: titleTextStyle,
          ),
          TextSpan(
            text: "$count",
            style: TextStyle(
                color: prefix0.blackColor333,
                fontSize: 50.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto-Bold'),
          ),
        ])),
        SizedBox(
          height: 50.0.h,
        ),
        itemCount > 0
            ? Flexible(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: itemCount,
                    physics: NeverScrollableScrollPhysics(),
                    addAutomaticKeepAlives: false,
                    itemBuilder: (buildContext, index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 40.0.h),
                        child: ItemMember(
                            memberID: listMember[index].id.toString(),
                            fullName: listMember[index].name,
                            accepted: listMember[index].accepted,
                            department: getDepartment(listMember[index])),
                      );
                    }),
              )
            : Container(),
      ],
    );
  }

  _buildMeetingCategory(String topic) {
    return Container(
      child: Text(
        topic,
        style: TextStyle(
            color: prefix0.blackColor333,
            fontFamily: 'Roboto-Regular',
            fontSize: 50.sp),
      ),
    );
  }

  _buildComponentPickTimeAndLimit(String startTime, String timeLimit) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Giờ bắt đầu".toUpperCase(),
                style: titleTextStyle,
              ),
              SizedBox(
                height: 23.0.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text(
                      startTime,
                      style: TextStyle(
                          color: prefix0.blackColor333,
                          fontFamily: 'Roboto-Regular',
                          fontSize: 44.sp),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          width: 76.0.w,
        ),
        Expanded(
          child: InkWell(
            onTap: () {
//              _pickTimeLimit();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "THỜI LƯỢNG".toUpperCase(),
                  style: titleTextStyle,
                ),
                SizedBox(
                  height: 23.0.h,
                ),
                Container(
                  child: Text(
                    timeLimit,
                    style: TextStyle(
                        color: prefix0.blackColor333,
                        fontFamily: 'Roboto-Regular',
                        fontSize: 44.sp),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildComponentPickDateAndPlace(String date, MeetingRoomModel place) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "vào ngày".toUpperCase(),
                style: titleTextStyle,
              ),
              SizedBox(
                height: 23.0.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Text(
                      date,
                      style: TextStyle(
                          color: prefix0.blackColor333,
                          fontFamily: 'Roboto-Regular',
                          fontSize: 44.sp),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          width: 76.0.w,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Địa điểm".toUpperCase(),
                style: titleTextStyle,
              ),
              SizedBox(
                height: 23.0.h,
              ),
              if (place != null &&
                  place.name != null &&
                  place.name.trim() != "") ...{
                Container(
                  child: Text(
                    place?.name,
                    style: TextStyle(
                        color: prefix0.blackColor333,
                        fontFamily: 'Roboto-Regular',
                        fontSize: 44.sp),
                  ),
                ),
              }
            ],
          ),
        ),
      ],
    );
  }

  _buildComponentContent(String description) {
    String content = "";
    TextAlign textAlign;
    Alignment alignment;
    if (description != null && description.trim().toString() != "") {
      content = description;
      textAlign = TextAlign.start;
      alignment = Alignment.topLeft;
    } else {
      content = "Không có nội dung";
      textAlign = TextAlign.center;
      alignment = Alignment.center;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "nội dung".toUpperCase(),
          style: titleTextStyle,
        ),
        SizedBox(
          height: 23.0.h,
        ),
        Container(
          alignment: alignment,
          child: Text(
            content,
            textAlign: textAlign,
            style: TextStyle(
                color: prefix0.blackColor333,
                fontFamily: 'Roboto-Regular',
                fontSize: 50.sp),
          ),
        )
      ],
    );
  }

  void _showDialogRefuse() {
    DialogUtils.showDialogRequestAcceptOrRefuse(context,
        title: "Từ chối cuộc họp",
        message: "Xác nhận từ chối cuộc họp", onClickOK: () {
      _showMeetingBloc.acceptOrRefuseMeeting(
          context, widget.meetingModel, false);
    });
  }

  void _showDialogAccept() {
    DialogUtils.showDialogRequestAcceptOrRefuse(context,
        title: "Xác nhận tham dự",
        message: "Bạn có chắc chắn xác nhận tham dự cuộc họp?", onClickOK: () {
      _showMeetingBloc.acceptOrRefuseMeeting(
          context, widget.meetingModel, true);
    });
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
