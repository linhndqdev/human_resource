import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/meeting/model/meeting_model.dart';
import 'package:human_resource/core/meeting/model/meeting_room_model.dart';
import 'package:human_resource/core/meeting/model/participant_model.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/home/home_bloc.dart';
import 'package:human_resource/home/meeting/action_meeting/add_member_screen.dart';
import 'package:human_resource/home/meeting/calendar_meeting_bloc.dart';
import 'package:human_resource/home/meeting/manager_member.dart';
import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';
import 'package:intl/intl.dart';
import 'package:human_resource/core/back_state.dart';
import 'item_member_accept_meeting.dart';
import 'package:human_resource/home/meeting/action_meeting/edit_meeting_bloc.dart';

class EditMeetingScreen extends StatefulWidget {
  final EditMeettingModel dataMeeting;

  const EditMeetingScreen({Key key, this.dataMeeting}) : super(key: key);

  @override
  _EditMeetingScreenState createState() => _EditMeetingScreenState();
}

class _EditMeetingScreenState extends State<EditMeetingScreen> {
  AppBloc appBloc;

  EditMeetingBloc _editMeetingBloc = EditMeetingBloc(true);
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
    _editMeetingBloc.setMeetingDate(DateTime.now());
    Future.delayed(Duration.zero, () {
      _editMeetingBloc.getDetailMeeting(
          meetingID: widget.dataMeeting.meetingID.toString(),
          appBloc: appBloc,
          selectDays: widget.dataMeeting.selectDate,
          context: context);
      _editMeetingBloc.getListRoomAvailable(
          context: context, state: ActionChangeRoomState.INIT);
    });
  }

  @override
  void dispose() {
    _editMeetingBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.EDIT_MEETING);
    //Viết 1 cái callback truyền dữ liệu khi cập nhật thành viên trong manager để thay đổi dữ liệu trong edit
    return WillPopScope(
      onWillPop: () async {
        if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.EDIT_MEETING) {
          appBloc.homeBloc
              .changeActionMeeting(state: LayoutNotBottomBarState.NONE);
          appBloc.backStateBloc.focusWidgetModel = FocusWidgetModel(
              state: isFocusWidget.HOME); //đây là thằng khi được back về
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.EDIT_MEETING_MEMBER) {
          _editMeetingBloc.openEditPage(true);
          appBloc.backStateBloc.focusWidgetModel = FocusWidgetModel(
              state:
                  isFocusWidget.EDIT_MEETING); //đây là thằng khi được back về
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.EDIT_MEETING_ADD_MEMBER) {
          _editMeetingBloc.openManagerMember(true);
          appBloc.backStateBloc.focusWidgetModel = FocusWidgetModel(
              state: isFocusWidget
                  .EDIT_MEETING_MEMBER); //đây là thằng khi được back về
        }
        return false;
      },
      child: Stack(
        children: <Widget>[
          Scaffold(
            backgroundColor: prefix0.asgBackgroundColorWhite,
            appBar: _buildAppbar(),
            body: Stack(
              children: <Widget>[
                Container(
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
                        _buildMeetingCategory(),
                        SizedBox(
                          height: 13.5.h,
                        ),
                        FractionallySizedBox(
                            widthFactor: 1.0,
                            child: Container(
                              height: 1.0,
                              color: prefix0.color959ca7,
                            )),
                        SizedBox(
                          height: 78.5.h,
                        ),
                        _buildComponentPickTimeAndLimit(),
                        SizedBox(
                          height: 80.5.h,
                        ),
                        _buildComponentPickDateAndPlace(),
                        SizedBox(
                          height: 77.5.h,
                        ),
                        _buildComponentContent(),
                        SizedBox(
                          height: 78.5.h,
                        ),
                        StreamBuilder<int>(
                            initialData: 0,
                            stream: _editMeetingBloc.countMemberStream.stream,
                            builder: (context, snapshot) {
                              return Container(
                                  child: snapshot.data == 0
                                      ? _buildComponentNoMember()
                                      : _buildComponentHasMember(
                                          snapshot.data));
                            }),
//                          ? //['member'].length == 0?
//                      _buildComponentNoMember()
//                          :
////                  SizedBox(
////                    height: 78.0.h,
////                  ),
//                      _buildComponentHasMember(),
                        SizedBox(
                          height: 78.0.h,
                        ),
                        _buildButtonSelectMember(),
                        SizedBox(
                          height: 81.0.h,
                        ),
                        _buildLineRequestAccept(),
                        SizedBox(
                          height: 112.0.h,
                        ),
                        _buildButtonCreateSchedule(),
                        SizedBox(
                          height: 42.0.h,
                        ),
                        checkTimeCancelMeeting()
                            ? Center(
                                child: InkWell(
                                  onTap: () {
                                    _showDialogExit();
                                  },
                                  child: Text(
                                    "Huỷ cuộc họp",
                                    style: TextStyle(
                                        color: Color(0xffe10606),
                                        fontSize: 50.sp,
                                        fontFamily: "Roboto-Regular"),
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 327.6.h,
                        )
                      ],
                    ),
                  ),
                ),
                StreamBuilder(
                  initialData: true,
                  stream: _editMeetingBloc.loadingStream.stream,
                  builder: (buildContext, AsyncSnapshot<bool> loadingSnapshot) {
                    return Visibility(
                      child: Loading(),
                      visible: loadingSnapshot.data,
                    );
                  },
                ),
              ],
            ),
          ),
          StreamBuilder(
              initialData: ShowChildMenuModel(state: ShowChildMenuState.NONE),
              stream: _editMeetingBloc.showChildStream.stream,
              builder:
                  (buildContext, AsyncSnapshot<ShowChildMenuModel> snapshot) {
                switch (snapshot.data.state) {
                  case ShowChildMenuState.MANAGE_MEMBER:
                    return ManagerMember(
                      onInit: () {
                        appBloc.backStateBloc.focusWidgetModel =
                            FocusWidgetModel(
                                state: isFocusWidget.EDIT_MEETING_MEMBER);
                      },
                      onBack: (data) {
                        _editMeetingBloc.openEditPage(true);
                      },
                      resultData: (data) {
                        _editMeetingBloc.openEditPage(true);
                        // _editMeetingBloc.openManagerMember(false);

                        //Cập nhật data cho edit trong đây
                      },
                      editMeetingBloc: _editMeetingBloc,
                    );
                    break;
                  case ShowChildMenuState.ADD_MEMBER:
                    return AddMemberMeetingScreen(
                      onInit: () {
                        appBloc.backStateBloc.focusWidgetModel =
                            FocusWidgetModel(
                                state: isFocusWidget.EDIT_MEETING_ADD_MEMBER);
                      },
                      editMeetingBloc: _editMeetingBloc,
                      mode: AddMemberScreenMode.EDIT,
                      onBackScreen: (data) {
                        _editMeetingBloc.openManagerMember(true);
                      },
                      onPickedUser: (data) {},
                    );
                    break;
                  case ShowChildMenuState.NONE:
                    return Container();
                    break;
                  default:
                    return Container();
                    break;
                }
//              return snapshot.data
//                  ? ManagerMember(
//                      onBack: () {
//                        _editMeetingBloc.openManagerMember(false);
//                      },
//                      resultData: (data) {
//                        _editMeetingBloc.openManagerMember(false);
//
//                        //Cập nhật data cho edit trong đây
//                      },
//                    )
//                  : Container(); //truyền lít member ở đây
              })
        ],
      ),
    );
  }

  void _showDialogExit() {
    DialogUtils.showDialogRequestAcceptOrRefuse(context,
        title: "Hủy cuộc họp", message: "Xác nhận hủy cuộc họp", onClickOK: () {
      appBloc.mainChatBloc.showLayoutActionStream.notify(false);
      _editMeetingBloc.cancelMeeting(
          context,
          widget.dataMeeting.meetingID.toString(),
          appBloc,
          widget.dataMeeting.startTimeMeeting);
    });
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
                  appBloc.homeBloc.changeActionMeeting(
                      state: LayoutNotBottomBarState.NONE);
                },
              ),
            ),
            Center(
              child: Text(
                "Xem/Sửa lịch họp",
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
    );
  }

  _buildMeetingCategory() {
//    categoryController.value =
//        TextEditingValue(text: widget.dataMeeting.data.topic);
    return StreamBuilder<MeetingModel>(
        initialData: MeetingModel(topic: ""),
        stream: _editMeetingBloc.meetingStream.stream,
        builder: (context, snapshot) {
          categoryController.value =
              TextEditingValue(text: snapshot.data.topic);
          return TextFormField(
            controller: categoryController,
            cursorColor: prefix0.color959ca7,
            maxLines: null,
            textAlign: TextAlign.start,
            style: contentTextStyle,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: "Nhập chủ để cuộc họp",
              hintStyle: titleTextStyle,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
            ),
          );
        });
  }

  _buildComponentPickTimeAndLimit() {
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
              InkWell(
                onTap: () {
                  _pickTimeMeeting();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    StreamBuilder(
                      initialData: _editMeetingBloc.sMeetingTime,
                      stream: _editMeetingBloc.meetingTimeStream.stream,
                      builder:
                          (buildContext, AsyncSnapshot<String> timeSnapshot) {
                        return Text(
                          timeSnapshot.data ?? "",
                          style: TextStyle(
                              color: prefix0.blackColor333,
                              fontFamily: 'Roboto-Regular',
                              fontSize: 44.sp),
                        );
                      },
                    ),
                    Container(
                      child: Image.asset(
                        "asset/images/ic_pick_time_meeting.png",
                        width: 57.0.w,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16.4.h,
              ),
              FractionallySizedBox(
                  widthFactor: 1.0,
                  child: Container(
                    height: 1.0,
                    color: prefix0.color959ca7,
                  )),
            ],
          ),
        ),
        SizedBox(
          width: 76.0.w,
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              _pickTimeLimit();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "THỜI GIAN".toUpperCase(),
                  style: titleTextStyle,
                ),
                SizedBox(
                  height: 23.0.h,
                ),
                StreamBuilder(
                    initialData: 60,
                    stream: _editMeetingBloc.meetingTimeLimitStream.stream,
                    builder: (buildContext, AsyncSnapshot<int> snapshotData) {
                      return Text(
                        //
                        "${snapshotData.data} phút",
                        style: TextStyle(
                            color: prefix0.blackColor333,
                            fontFamily: 'Roboto-Regular',
                            fontSize: 44.sp),
                      );
                    }),
                SizedBox(
                  height: 16.4.h,
                ),
                FractionallySizedBox(
                    widthFactor: 1.0,
                    child: Container(
                      height: 1.0,
                      color: prefix0.color959ca7,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  GlobalKey _keyTextPlace = GlobalKey();
  String _selectedDate;
  DateTime _select_StartDate;

  _buildComponentPickDateAndPlace() {
//    String Original_roomName =
//        widget.dataMeeting.data.room.name; //['zoomName'].toString();
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "VÀO NGÀY",
                style: titleTextStyle,
              ),
              SizedBox(
                height: 23.0.h,
              ),
              InkWell(
                onTap: () {
                  _pickDateMeeting();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    StreamBuilder(
                        initialData: _editMeetingBloc.meetingDate,
                        //DateTimeFormat.formatMeetingDatePicker(
                        //_editMeetingBloc.meetingDate),
                        stream: _editMeetingBloc.meetingDateStream.stream,
                        builder: (buildContext,
                            AsyncSnapshot<DateTime> snapshotData) {
                          return Text(
                            DateTimeFormat.formatMeetingDatePicker(
                                snapshotData.data),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: prefix0.blackColor333,
                                fontFamily: 'Roboto-Regular',
                                fontSize: 44.sp),
                          );
                        }),
                    Container(
                      child: Image.asset(
                        "asset/images/ic_meeting_pick_date.png",
                        width: 57.0.w,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 16.4.h,
              ),
              FractionallySizedBox(
                  widthFactor: 1.0,
                  child: Container(
                    height: 1.0,
                    color: prefix0.color959ca7,
                  )),
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
                "ĐỊA ĐIỂM",
                style: titleTextStyle,
              ),
              SizedBox(
                height: 23.0.h,
              ),
              InkWell(
                onTap: () {
                  _pickMeetingRoom();
                },
                child: Row(
                  key: _keyTextPlace,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    StreamBuilder(
                        initialData: null,
                        stream: _editMeetingBloc.roomAvailableStream.stream,
                        builder: (buildContext,
                            AsyncSnapshot<MeetingRoomModel> snapShot) {
                          if (!snapShot.hasData || snapShot.data == null) {
                            return Container(
                              height: 58.0.h,
                            );
                          } else {
                            String roomName =
                                (_editMeetingBloc.listMeetingRoom == null ||
                                        _editMeetingBloc
                                                .listMeetingRoom.length ==
                                            0)
                                    ? "Hết phòng họp"
                                    : snapShot.data.name;
                            return Text(
                              roomName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: prefix0.blackColor333,
                                  fontFamily: 'Roboto-Regular',
                                  fontSize: 44.sp),
                            );
                          }
                        }),
                    Container(
                      child: Image.asset(
                        "asset/images/ic_meeitng_pick_place.png",
                        width: 48.0.w,
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 16.4.h,
              ),
              FractionallySizedBox(
                  widthFactor: 1.0,
                  child: Container(
                    height: 1.0,
                    color: prefix0.color959ca7,
                  )),
            ],
          ),
        ),
      ],
    );
  }

  _buildComponentContent() {
//    link

    return StreamBuilder<MeetingModel>(
        initialData: MeetingModel(description: ""),
        stream: _editMeetingBloc.meetingStream.stream,
        builder: (context, snapshot) {
          contentController.value =
              TextEditingValue(text: snapshot.data.description);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "NỘI DUNG",
                style: titleTextStyle,
              ),
              SizedBox(
                height: 21.5.h,
              ),
              Stack(
                children: <Widget>[
                  TextFormField(
                    controller: contentController,
                    minLines: 4,
                    maxLines: null,
                    textAlign: TextAlign.start,
                    style: contentTextStyle,
                    cursorColor:  prefix0.color959ca7,
                    decoration: InputDecoration(
                      hintText: "Nhập nội dung cuộc họp",
                      hintStyle: titleTextStyle,
                      contentPadding: EdgeInsets.only(
                          top: 53.5.h,
                          bottom: 72.5.h,
                          left: 47.5.w,
                          right: 47.5.w),
                      isDense: true,
                      border: inputContentBorder,
                      disabledBorder: inputContentBorder,
                      focusedBorder: inputContentBorder,
                      errorBorder: inputContentBorder,
                      enabledBorder: inputContentBorder,
                    ),
                  ),
                  Positioned(
                    bottom: 9.7.h,
                    right: 0.0,
                    child: RotationTransition(
                      turns: const AlwaysStoppedAnimation(-45 / 360),
                      child: Image.asset(
                        "asset/images/ic_meeitng_pick_place.png",
                        width: 40.0.w,
                        color: prefix0.color959ca7,
                      ),
                    ),
                  )
                ],
              )
            ],
          );
        });
  }

  //Danh sách thành viên tham dự
  _buildComponentNoMember() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "THÀNH VIÊN THAM DỰ",
          style: titleTextStyle,
        ),
        SizedBox(
          height: 35.0.h,
        ),
        Container(
          margin: EdgeInsets.only(left: 50.0.w, right: 78.0.w),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text:
                      "Chưa có thành viên nào được mời tham dự cuộc họp này. Vui lòng ",
                  style: contentTextStyle,
                ),
                TextSpan(
                  text: "Chọn thành viên",
                  style: TextStyle(
                      color: Color(0xFF3baae2),
                      fontFamily: 'Roboto-Regular',
                      fontSize: 50.sp),
                ),
                TextSpan(
                  text: " tham dự!",
                  style: contentTextStyle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildComponentHasMember(int count) {
//    _editMeetingBloc.listMember.clear();
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
            text: count.toString(),
            // "6",
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
        Flexible(
          child: StreamBuilder(
              initialData: _editMeetingBloc.listMember,
              stream: _editMeetingBloc.listMemberStream.stream,
              builder: (buildContext,
                  AsyncSnapshot<List<ParticipantModel>> memberSnap) {
                if (memberSnap.data.length == 0) {
                  return _buildComponentNoMember();
                }
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: _editMeetingBloc.listMember.length,
                    physics: NeverScrollableScrollPhysics(),
                    addAutomaticKeepAlives: true,
                    itemBuilder: (buildContext, index) {
                      if (index > 2) {
                        return Container();
                      }
                      return Container(
                        margin: EdgeInsets.only(bottom: 40.0.h),
                        child: ItemMemberAccept(
                            onRemoveUser: () {
                              ParticipantModel userModel =
                                  memberSnap?.data[index];
                              _editMeetingBloc.removeUser(
                                  data: userModel,
                                  context: context,
                                  appBloc: appBloc);
//                              if (_editMeetingBloc.listMember.length == 1) {
//                                appBloc.calendarBloc
//                                    .checkCreator_Thin(appBloc,
//                                        _editMeetingBloc.listMember[index].id)
//                                    .then((isCreator) {
//                                  if (isCreator) {
//                                    DialogUtils.showDialogResult(
//                                        context,
//                                        DialogType.FAILED,
//                                        "Bạn không thể xoá chính mình được");
//                                  }
//                                });
//                              } else if (_editMeetingBloc.listMember.length >
//                                  2) {
//                                appBloc.calendarBloc
//                                    .checkCreator_Thin(appBloc,
//                                        _editMeetingBloc.listMember[index].id)
//                                    .then((isCreator) {
//                                  if (isCreator) {
//                                    DialogUtils.showDialogResult(
//                                        context,
//                                        DialogType.FAILED,
//                                        "Bạn không thể xoá chính mình được");
//                                  } else {
//                                    ParticipantModel userModel =
//                                        memberSnap?.data[index];
//                                    _editMeetingBloc.removeUser(userModel);
//                                  }
//                                });
//                              } else {
//                                DialogUtils.showDialogResult(
//                                    context,
//                                    DialogType.FAILED,
//                                    "Bạn không thể xoá hết thành viên được");
//                              }
                            },
                            memberID: "${memberSnap?.data[index]?.id}",
                            fullName: memberSnap?.data[index].name ??
                                "Không xác định",
                            department: getDepartment(memberSnap?.data[index])),
                      );
                    });
              }),
        ),
//        Flexible(
//          child: ListView.builder(
//              shrinkWrap: true,
//              itemCount: widget.dataMeeting.data.participants.length,
//              physics: NeverScrollableScrollPhysics(),
//              addAutomaticKeepAlives: false,
//              itemBuilder: (buildContext, index) {
//                ParticipantModel data = widget.dataMeeting.data.participants[index];
//                _editMeetingBloc.listMember.add(data);
//                return Container(
//                    margin: EdgeInsets.only(bottom: 40.0.h),
//                    child: ItemMemberAccept(
//                        onRemoveUser: () {
//                          _editMeetingBloc.isRemove = true;
//                          _editMeetingBloc.removeUser(data);
//                        },
//                        memberID: "${ data.id}",
//                        fullName: data.name ??
//                            "Không xác định",
//                        department:
//                            "Không xác định"),
//
////                        memberID: data[index].id.toString(), // "asgl-0228",
////                        fullName: data[index].name, // "Nguyễn Hữu Bình",
////                        department: "Api đang chưa có phòng ban" //data[index].
//                    ); //"Phòng Công Nghệ"),
//
//              }),
//        ),
      ],
    );
  }

  _buildButtonSelectMember() {
    return StreamBuilder(
        initialData: _editMeetingBloc.meetingDate,
//        DateTimeFormat.formatMeetingDatePicker(
//            _editMeetingBloc.meetingDate),
        stream: _editMeetingBloc.meetingDateStream.stream,
        builder: (buildContext, AsyncSnapshot<DateTime> snapshotData) {
          return InkWell(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              _editMeetingBloc.openManagerMember(true);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                      top: 21.0.h,
                      bottom: 23.0.h,
                      left: 119.0.w,
                      right: 120.0.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(76.0.w),
                      color: prefix0.asgBackgroundColorWhite,
                      border: Border.all(
                          color: Color(0xFFe18c12),
                          width: 5.0.w,
                          style: BorderStyle.solid)),
                  child: Center(
                    child: Text(
                      "Quản lý thành viên",
                      style: contentTextStyle,
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  _buildLineRequestAccept() {
    return InkWell(
      splashColor: prefix0.white,
      onTap: () {
        _editMeetingBloc.changeRequestAcceptMeeting();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StreamBuilder(
            initialData: _editMeetingBloc.isRequestAccept,
            stream: _editMeetingBloc.requestAcceptMeetingStream.stream,
            builder: (buildContext, AsyncSnapshot<bool> snapshotData) {
              return snapshotData.data
                  ? Image.asset(
                      "asset/images/ic_meeting_accepted.png",
                      color: prefix0.blackColor333,
                      width: 58.0.w,
                    )
                  : Image.asset(
                      "asset/images/outline-no_check_box.png",
                      width: 58.0.w,
                    );
            },
          ),
          SizedBox(
            width: 36.0.w,
          ),
          Text(
            "Yêu cầu người tham dự xác nhận",
            style: contentTextStyle,
          )
        ],
      ),
    );
  }

  _buildButtonCreateSchedule() {
    return InkWell(
      onTap: () {
        List<int> _listParticipantID = List<int>();
//        List<String> _listsParticipantID = List<String>();
        var participants = _editMeetingBloc.listMember;
        for (int k = 0; k < participants.length; k++) {
          if (!_listParticipantID.contains(participants[k].id))
            _listParticipantID.add(participants[k].id);
//          _listsParticipantID.add(participants[k].name);
        }

        _editMeetingBloc.updateMeetingInfo(
            appBloc: appBloc,
            id: widget.dataMeeting.meetingID.toString(),
            chude: categoryController.text,
            noidung: contentController.text,
            context: context,
            lstParticipant: _listParticipantID,
            startAt: _select_StartDate);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Color(0xffe18c12),
                borderRadius: BorderRadius.circular(10.0.w)),
            padding: EdgeInsets.only(
              top: 38.0.h,
              bottom: 46.0.h,
              right: 290.0.h,
              left: 293.0.h,
            ),
            child: Center(
              child: Text(
                "Cập nhật",
                style: TextStyle(
                    fontSize: 60.sp,
                    color: prefix0.asgBackgroundColorWhite,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Roboto-Bold"),
              ),
            ),
          )
        ],
      ),
    );
  }

  //Chọn thời gian họp
  void _pickTimeMeeting() {
    FocusScope.of(context).requestFocus(FocusNode());
    DatePicker.showTimePicker(context,
        showSecondsColumn: false,
        theme: DatePickerTheme(
            containerHeight: 250.0,
            cancelStyle: TextStyle(
              color: prefix0.redColor,
              fontSize: 50.sp,
              fontFamily: 'Roboto-Regular',
            ),
            doneStyle: TextStyle(
              color: prefix0.accentColor,
              fontSize: 50.sp,
              fontFamily: 'Roboto-Regular',
            ),
            itemStyle: TextStyle(
              color: prefix0.blackColor333,
              fontSize: 50.sp,
              fontFamily: 'Roboto-Regular',
            )),
        showTitleActions: true, onConfirm: (time) {
      _editMeetingBloc.pickerTime(context, time);
    }, currentTime: DateTime.now(), locale: LocaleType.vi);
  }

  //Chọn thời lượng cuộc họp
  void _pickTimeLimit() {
    FocusScope.of(context).requestFocus(FocusNode());
    Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(
              initValue: _editMeetingBloc.meetingTimeLimit,
              items: listItemTimeLimit,
              columnFlex: 2,
              onFormatValue: (value) {
                return "$value  phút";
              }),
        ]),
        cancelText: "Hủy",
        cancelTextStyle: TextStyle(
          color: prefix0.redColor,
          fontSize: 50.sp,
          fontFamily: 'Roboto-Regular',
        ),
        confirmText: "Xác nhận",
        confirmTextStyle: TextStyle(
          color: prefix0.accentColor,
          fontSize: 50.sp,
          fontFamily: 'Roboto-Regular',
        ),
        onCancel: () {},
        hideHeader: true,
        textScaleFactor: 1.0,
        title: Text(
          "Chọn thời lượng cuộc họp",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: prefix0.blackColor333,
            fontSize: 50.sp,
            fontFamily: 'Roboto-Regular',
          ),
        ),
        onConfirm: (Picker picker, List<int> values) {
          _editMeetingBloc.pickLimitTime(context, listItemTimeLimit[values[0]]);
        }).showDialog(context);
  }

  void _pickDateMeeting() {
    FocusScope.of(context).requestFocus(FocusNode());
    DatePicker.showDatePicker(
      context,
      onConfirm: (time) {
        _editMeetingBloc.changeMeetingDate(context, time);
      },
      locale: LocaleType.vi,
      currentTime: _editMeetingBloc.meetingDate,
      theme: DatePickerTheme(
          containerHeight: 250.0,
          cancelStyle: TextStyle(
            color: prefix0.redColor,
            fontSize: 50.sp,
            fontFamily: 'Roboto-Regular',
          ),
          doneStyle: TextStyle(
            color: prefix0.accentColor,
            fontSize: 50.sp,
            fontFamily: 'Roboto-Regular',
          ),
          itemStyle: TextStyle(
            color: prefix0.blackColor333,
            fontSize: 50.sp,
            fontFamily: 'Roboto-Regular',
          )),
    );
  }

  void _pickMeetingRoom() async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (_editMeetingBloc?.listMeetingRoom != null) {
      if (_editMeetingBloc.listMeetingRoom.length == 1) {
        DialogUtils.showDialogResult(context, DialogType.SUCCESS,
            "Hiện tại chỉ có 1 phòng họp trống. Không thể chọn phòng họp khác");
      } else if (_editMeetingBloc.listMeetingRoom.length > 1) {
        final RenderBox renderBoxRed =
            _keyTextPlace.currentContext.findRenderObject();
        final Offset position = renderBoxRed.localToGlobal(Offset.zero);

        MeetingRoomModel meetingRoomModel = await showMenu(
            context: context,
            position: RelativeRect.fromLTRB(position.dx, position.dy + 10,
                position.dx + 1, position.dy + 1),
            items: _editMeetingBloc.listMeetingRoom.map((room) {
              return PopupMenuItem<MeetingRoomModel>(
                child: Row(
                  children: <Widget>[
                    room.id == _editMeetingBloc.meetingRoomPicked.id
                        ? Icon(
                            Icons.check_box,
                            color: prefix0.accentColor,
                            size: ScreenUtil().setWidth(60),
                          )
                        : Icon(
                            Icons.check_box_outline_blank,
                            size: ScreenUtil().setWidth(60),
                          ),
                    Flexible(
                        child: Text(
                      room.name,
                      style: TextStyle(
                          fontSize: 50.sp,
                          fontFamily: 'Roboto-Regular',
                          color:
                              room.id == _editMeetingBloc.meetingRoomPicked.id
                                  ? prefix0.accentColor
                                  : prefix0.blackColor333),
                    ))
                  ],
                ),
                value: room,
              );
            }).toList());
        if (meetingRoomModel != null) {
          _editMeetingBloc.pickMeetingRoom(meetingRoomModel);
        }
      }
    }
  }

  bool checkTimeCancelMeeting() {
    int now = DateTime.now().millisecondsSinceEpoch;
    int startDateTime = new DateFormat("yyyy-MM-dd hh:mm:ss")
        .parse(widget.dataMeeting.startTimeMeeting)
        .millisecondsSinceEpoch;
    if (startDateTime < now ||
        !widget.dataMeeting.statusMeeting.contains("new")) {
      return false;
    } else {
      return true;
    }
  }

  getDepartment(ParticipantModel model) {
    String department = "Không xác định";
    if (model != null &&
        model?.positions != null &&
        model.positions.length > 0) {
      department = model?.positions[0]?.department?.name ?? "Không xác định";
    }
    return department;
  }
}

const List<int> listItemTimeLimit = <int>[
  15,
  30,
  45,
  60,
  90,
  120,
  150,
  180,
  210,
  240,
  270,
  300,
  330,
  360,
  390,
  420,
  450,
  480,
  510,
  540,
  570,
  600,
  630,
  660,
  690,
  720
];
