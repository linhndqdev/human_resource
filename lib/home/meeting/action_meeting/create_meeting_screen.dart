import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/meeting/model/meeting_room_model.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/home/home_bloc.dart';
import 'package:human_resource/home/meeting/action_meeting/add_member_screen.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/animation/buttom_calendar_meeting.dart';
import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';
import 'create_meeting_bloc.dart';
import 'create_meeting_manager_member.dart';
import 'edit_meeting_bloc.dart';
import 'item_member_accept_meeting.dart';

class CreateMeetingLayout extends StatefulWidget {
  final DateTime initDate;

  const CreateMeetingLayout({Key key, this.initDate}) : super(key: key);

  @override
  _CreateMeetingLayoutState createState() => _CreateMeetingLayoutState();
}

class _CreateMeetingLayoutState extends State<CreateMeetingLayout> with TickerProviderStateMixin {
  AnimationController _animationController;
  AppBloc appBloc;
  CreateMeetingBloc _createMeetingBloc = CreateMeetingBloc(true);
  ManagerCreateMeetingBloc _managerCreateMeetingBloc =
      ManagerCreateMeetingBloc();
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
    _createMeetingBloc.setMeetingDate(widget.initDate);
    super.initState();
    Future.delayed(Duration.zero, () {
      _createMeetingBloc.getListRoomAvailable(context);
    });
    _animationController = AnimationController(
    vsync: this,
      duration: Duration(milliseconds: 2000),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _createMeetingBloc.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.NEW_MEETING);
    return WillPopScope(
      onWillPop: () async {
        if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.NEW_MEETING) {
          appBloc.homeBloc
              .changeActionMeeting(state: LayoutNotBottomBarState.NONE);
          appBloc.backStateBloc.focusWidgetModel = FocusWidgetModel(
              state: isFocusWidget.HOME); //đây là thằng khi được back về
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.NEW_MEETING_MEMBER) {
          _createMeetingBloc.hiddenAddMemberScreen();
          appBloc.backStateBloc.focusWidgetModel = FocusWidgetModel(
              state: isFocusWidget.NEW_MEETING); //đây là thằng khi được back về
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.MANAGER_MEETING) {
          appBloc.backStateBloc.focusWidgetModel =
              FocusWidgetModel(state: isFocusWidget.NEW_MEETING);
          _createMeetingBloc.showChildStream
              ?.notify(ShowChildMenuModel(state: ShowChildMenuState.NONE));
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.ADD_MEMBER_CREATE_MEETING) {
          _createMeetingBloc.hiddenAddMemberScreen();
          appBloc.backStateBloc.focusWidgetModel =
              FocusWidgetModel(state: isFocusWidget.NEW_MEETING);
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.ADD_MEMBER_FROM_CREATE_MANAGER_MEMBER) {
          appBloc.backStateBloc.focusWidgetModel =
              FocusWidgetModel(state: isFocusWidget.MANAGER_MEETING);
          _managerCreateMeetingBloc.showAddMemberStream.notify(false);
        }
        return null;
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
                        _buildListMemberPicked(),
                        SizedBox(
                          height: 78.0.h,
                        ),
                        ButtomCalendarAnimation(_buildButtonSelectMember(),
                            onTap: () {
                              _OnTapSelectmember();
                            }),
//                        ButtomCalendarAnimation(_buildButtonSelectMember()),
                        SizedBox(
                          height: 81.0.h,
                        ),
                          _buildLineRequestAccept(),

                        SizedBox(
                          height: 122.0.h,
                        ),
                        ButtomCalendarAnimation(_buildButtonCreateSchedule(),
                            onTap: () {
                              _onTapButton();
                            }),
                        SizedBox(
                          height: 433.6.h,
                        )
                      ],
                    ),
                  ),
                ),
                StreamBuilder(
                  initialData: true,
                  stream: _createMeetingBloc.loadingStream.stream,
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
              stream: _createMeetingBloc.showChildStream.stream,
              builder:
                  (buildContext, AsyncSnapshot<ShowChildMenuModel> snapshot) {
                switch (snapshot.data.state) {
                  case ShowChildMenuState.MANAGE_MEMBER:
                    return CreateMeetingManagerMember(
                      bloc: _managerCreateMeetingBloc,
                      listUserModel: _createMeetingBloc.listMember,
                      onInit: () {
                        appBloc.backStateBloc.focusWidgetModel =
                            FocusWidgetModel(
                                state: isFocusWidget.MANAGER_MEETING);
                      },
                      onBack: (data) {
                        _createMeetingBloc.showChildStream?.notify(
                            ShowChildMenuModel(state: ShowChildMenuState.NONE));
                      },
                      resultData: (data) {
                        _createMeetingBloc.showChildStream?.notify(
                            ShowChildMenuModel(state: ShowChildMenuState.NONE));
                        _createMeetingBloc.updateUserPicked(data);
                        // _editMeetingBloc.openManagerMember(false);
                      },
                    );
                    break;
                  default:
                    appBloc.backStateBloc.focusWidgetModel =
                        FocusWidgetModel(state: isFocusWidget.NEW_MEETING);
                    return Container();
                    break;
                }
              }),
          StreamBuilder(
            initialData: false,
            stream: _createMeetingBloc.showAddMemberStream.stream,
            builder: (buildContext, AsyncSnapshot<bool> showAddMemberSnap) {
              if (!showAddMemberSnap.data) {
                appBloc.backStateBloc.focusWidgetModel =
                    FocusWidgetModel(state: isFocusWidget.NEW_MEETING);
                return Container();
              } else {
                return AddMemberMeetingScreen(
                  onInit: () {
                    appBloc.backStateBloc.focusWidgetModel = FocusWidgetModel(
                        state: isFocusWidget.NEW_MEETING_MEMBER);
                  },
                  mode: AddMemberScreenMode.CREATE,
                  onBackScreen: (data) {
                    // print(data);
                    _createMeetingBloc.hiddenAddMemberScreen();
                  },
                  onPickedUser: (listUserPicked) {
                    _createMeetingBloc.setListUserPicked(listUserPicked);
                  },
                  listASGUserModel: _createMeetingBloc.listMember,
                );
              }
            },
          ),
        ],
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
                      height: 178.5.h,
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
                    "Tạo lịch họp",
                    style: TextStyle(
                        fontFamily: "Roboto-Bold",
                        fontWeight: FontWeight.bold,
                        color: prefix0.asgBackgroundColorWhite,
                        fontSize: ScreenUtil()
                            .setSp(60.0, allowFontScalingSelf: false)),
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
          titleSpacing: 0.0,
        ),
        preferredSize: Size.fromHeight(ScreenUtil().setHeight(171)));
  }

  _buildMeetingCategory() {
    return TextFormField(
      controller: categoryController,
      cursorColor:  prefix0.color959ca7,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  StreamBuilder(
                    initialData: _createMeetingBloc.sMeetingTime,
                    stream: _createMeetingBloc.meetingTimeStream.stream,
                    builder:
                        (buildContext, AsyncSnapshot<String> timeSnapshot) {
                      return Text(
                        timeSnapshot.data,
                        style: TextStyle(
                            color: prefix0.blackColor333,
                            fontFamily: 'Roboto-Regular',
                            fontSize: 44.sp),
                      );
                    },
                  ),
                  InkWell(
                    onTap: () {
                      _pickTimeMeeting();
                    },
                    child: Image.asset(
                      "asset/images/ic_pick_time_meeting.png",
                      width: 57.0.w,
                    ),
                  ),
                ],
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
                    stream: _createMeetingBloc.meetingTimeLimitStream.stream,
                    builder: (buildContext, AsyncSnapshot<int> snapshotData) {
                      return Text(
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

  _buildComponentPickDateAndPlace() {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  StreamBuilder(
                      initialData: DateTimeFormat.formatMeetingDatePicker(
                          _createMeetingBloc.meetingDate),
                      stream: _createMeetingBloc.meetingDateStream.stream,
                      builder:
                          (buildContext, AsyncSnapshot<String> snapshotData) {
                        return Text(
                          snapshotData.data,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: prefix0.blackColor333,
                              fontFamily: 'Roboto-Regular',
                              fontSize: 44.sp),
                        );
                      }),
                  InkWell(
                    onTap: () {
                      _pickDateMeeting();
                    },
                    child: Image.asset(
                      "asset/images/ic_meeting_pick_date.png",
                      width: 57.0.w,
                    ),
                  )
                ],
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
              Row(
                key: _keyTextPlace,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  StreamBuilder(
                      initialData: null,
                      stream: _createMeetingBloc.roomAvailableStream.stream,
                      builder: (buildContext,
                          AsyncSnapshot<MeetingRoomModel> snapShot) {
                        if (!snapShot.hasData || snapShot.data == null) {
                          return Container(
                            height: 58.0.h,
                          );
                        } else {
                          String roomName =
                              (_createMeetingBloc.listMeetingRoom == null ||
                                      _createMeetingBloc
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
                  InkWell(
                    onTap: () {
                      _pickMeetingRoom();
                    },
                    child: Image.asset(
                      "asset/images/ic_meeitng_pick_place.png",
                      width: 48.0.w,
                    ),
                  )
                ],
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
                    top: 53.5.h, bottom: 72.5.h, left: 47.5.w, right: 47.5.w),
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
  }

  //Danh sách thành viên tham dự
  _buildComponentNoMember() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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

  _buildListMemberPicked() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StreamBuilder(
            initialData: _createMeetingBloc.listMember.length,
            stream: _createMeetingBloc.countMemberStream.stream,
            builder: (buildContext, AsyncSnapshot<int> countMemberSnap) {
              return RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: "THÀNH VIÊN THAM DỰ: ",
                    style: titleTextStyle,
                  ),
                  TextSpan(
                    text: countMemberSnap.data.toString(),
                    style: TextStyle(
                        color: prefix0.blackColor333,
                        fontSize: 50.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto-Bold'),
                  ),
                ]),
              );
            }),
        SizedBox(
          height: 50.0.h,
        ),
        Flexible(
          child: StreamBuilder(
              initialData: _createMeetingBloc.listMember,
              stream: _createMeetingBloc.listMemberStream.stream,
              builder:
                  (buildContext, AsyncSnapshot<List<ASGUserModel>> memberSnap) {
                if (memberSnap.data.length == 0) {
                  return _buildComponentNoMember();
                }
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: _createMeetingBloc.listMember.length,
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
                              ASGUserModel userModel = memberSnap?.data[index];
                              _createMeetingBloc.removeUser(userModel);
                            },
                            memberID: "${memberSnap?.data[index]?.username}",
                            fullName: memberSnap?.data[index].full_name ??
                                "Không xác định",
                            department: memberSnap?.data[index]?.position?.level?.name ??
                                "Không xác định"),
                      );
                    });
              }),
        ),
      ],
    );
  }

  _OnTapSelectmember(){
    FocusScope.of(context).requestFocus(FocusNode());
    if (_createMeetingBloc.listMember != null &&
        _createMeetingBloc.listMember.length > 0) {
      _createMeetingBloc.openManagerMember(true);
    } else {
      _createMeetingBloc.showAddMemberScreen();
    }
  }
  _buildButtonSelectMember() {
    return StreamBuilder(
        initialData: DateTimeFormat.formatMeetingDatePicker(
            _createMeetingBloc.meetingDate),
        stream: _createMeetingBloc.meetingDateStream.stream,
        builder: (buildContext, AsyncSnapshot<String> snapshotData) {
          return  Row(
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
                    child: StreamBuilder(
                        initialData: _createMeetingBloc.listMember,
                        stream: _createMeetingBloc.listMemberStream.stream,
                        builder: (memberContext,
                            AsyncSnapshot<List<ASGUserModel>> dataSnap) {
                          return Text(
                            dataSnap.data != null && dataSnap.data.length > 0
                                ? "Quản lý thành viên"
                                : "Chọn thành viên",
                            style: contentTextStyle,
                          );
                        }),
                  ),
                )
              ],
            );
//          );
        });
  }

  _buildLineRequestAccept() {
    return InkWell(
      splashColor: prefix0.white,
      onTap: () {
        _createMeetingBloc.changeRequestAcceptMeeting();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StreamBuilder(
            initialData: _createMeetingBloc.isRequestAccept,
            stream: _createMeetingBloc.requestAcceptMeetingStream.stream,
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
  _onTapButton() {
    FocusScope.of(context).requestFocus(FocusNode());
    _createMeetingBloc.createMeetingSchedule(
        context,
        categoryController.text.toString().trim(),
        contentController.text.toString().trim());
  }
  _buildButtonCreateSchedule() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
//          onTap: () {
//            FocusScope.of(context).requestFocus(FocusNode());
//            _createMeetingBloc.createMeetingSchedule(
//                appBloc,
//                context,
//                categoryController.text.toString().trim(),
//                contentController.text.toString().trim());
//          },
          child: Container(
            decoration: BoxDecoration(
                color: prefix0.accentColor,
                borderRadius: BorderRadius.circular(10.0.w)),
            padding: EdgeInsets.only(
              top: 38.0.h,
              bottom: 46.0.h,
              right: 303.0.h,
              left: 303.0.h,
            ),
            child: Center(
              child: Text(
                "Tạo lịch",
                style: TextStyle(
                    fontSize: 60.sp,
                    color: prefix0.asgBackgroundColorWhite,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Roboto-Bold"),
              ),
            ),
          ),
        )
      ],
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
      _createMeetingBloc.pickerTime(context, time);
    }, currentTime: DateTime.now(), locale: LocaleType.vi);
  }

  //Chọn thời lượng cuộc họp
  void _pickTimeLimit() {
    FocusScope.of(context).requestFocus(FocusNode());
    Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(
              initValue: _createMeetingBloc.meetingTimeLimit,
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
          _createMeetingBloc.pickLimitTime(
              context, listItemTimeLimit[values[0]]);
        }).showDialog(context);
  }

  void _pickDateMeeting() {
    FocusScope.of(context).requestFocus(FocusNode());
    DatePicker.showDatePicker(
      context,
      onConfirm: (time) {
        _createMeetingBloc.changeMeetingDate(context, time);
      },
      locale: LocaleType.vi,
      currentTime: _createMeetingBloc.meetingDate,
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
    if (_createMeetingBloc?.listMeetingRoom != null) {
      if (_createMeetingBloc.listMeetingRoom.length == 1) {
        DialogUtils.showDialogResult(context, DialogType.SUCCESS,
            "Hiện tại chỉ có 1 phòng họp trống. Không thể chọn phòng họp khác");
      } else if (_createMeetingBloc.listMeetingRoom.length > 1) {
        final RenderBox renderBoxRed =
            _keyTextPlace.currentContext.findRenderObject();
        final Offset position = renderBoxRed.localToGlobal(Offset.zero);

        MeetingRoomModel meetingRoomModel = await showMenu(
            context: context,
            position: RelativeRect.fromLTRB(position.dx, position.dy + 10,
                position.dx + 1, position.dy + 1),
            items: _createMeetingBloc.listMeetingRoom.map((room) {
              return PopupMenuItem<MeetingRoomModel>(
                child: Container(
                  width: ScreenUtil().setWidth(500),
                  child: Row(
                    children: <Widget>[
                      room.id == _createMeetingBloc.meetingRoomPicked.id
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
                            color: room.id ==
                                    _createMeetingBloc.meetingRoomPicked.id
                                ? prefix0.accentColor
                                : prefix0.blackColor333),
                      ))
                    ],
                  ),
                ),
                value: room,
              );
            }).toList());
        if (meetingRoomModel != null) {
          _createMeetingBloc.pickMeetingRoom(meetingRoomModel);
        }
      }
    }
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
