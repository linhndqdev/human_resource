import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/meeting/model/meeting_model.dart';
import 'package:human_resource/home/home_bloc.dart';
import 'package:human_resource/utils/animation/buttom_calendar_meeting.dart';
import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/image_meeting_widget.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';
import 'package:human_resource/utils/widget/status_meeting_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/core/bloc_provider.dart';

import 'calendar_meeting_bloc.dart';
import 'calendar_meeting_model.dart';

class CalendarMeetingScreen extends StatefulWidget {
  @override
  _CalendarMeetingScreenState createState() => _CalendarMeetingScreenState();
}

class _CalendarMeetingScreenState extends State<CalendarMeetingScreen>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  CalendarController _calendarController;
  AppBloc appBloc;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      appBloc.calendarBloc.getAllASGLMember(context);
      appBloc.calendarBloc.getDataScheduleApi(context);
    });
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    appBloc.calendarBloc.selectDays = DateTime.now();
    _animationController.dispose();
    _calendarController.dispose();
    appBloc.calendarBloc?.timer?.cancel();
    super.dispose();
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    appBloc.calendarBloc.getDataScheduleApi(context);
  }

  @override
  Widget build(BuildContext context) {
    final page = ModalRoute.of(context);
    page.didPush().then((x) {
      SystemChrome.setSystemUIOverlayStyle(prefix0.statusBarAccent);
    });
    appBloc = BlocProvider.of(context);
    return buildWidget();
  }

  Widget buildWidget() {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: PreferredSize(
              child: AppBar(
                title: Text(
                  "Lịch họp",
                  style: TextStyle(
                      fontFamily: "Roboto-Bold",
                      fontSize: ScreenUtil().setSp(60),
                      color: prefix0.whiteColor),
                ),
                actions: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 20),
                    child: IconButton(
                      icon: Icon(
                        Icons.sync,
                        size: ScreenUtil().setWidth(60),
                      ),
                      onPressed: () {
                        appBloc.calendarBloc.timer.cancel();
                        appBloc.calendarBloc.getDataScheduleApi(context,
                            isShowNotification: true);
                      },
                    ),
                  ),
                ],
                centerTitle: true,
                backgroundColor: prefix0.accentColor,
              ),
              preferredSize: Size.fromHeight(ScreenUtil().setHeight(171))),
          body: SingleChildScrollView(
            child: Container(
              child: StreamBuilder(
                  initialData: CalendarStreamModel(
                    state: CalendarMeetingState.LOADING,
                  ),
                  stream: appBloc.calendarBloc.calendarStream.stream,
                  builder: (buildContext,
                      AsyncSnapshot<CalendarStreamModel> snapshotData) {
                    switch (snapshotData.data.state) {
                      case CalendarMeetingState.SHOW:
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _buildTableCalendarWithBuilders(),
                            appBloc.calendarBloc.selectDays == null
                                ? Container()
                                : Container(
                                    padding: EdgeInsets.only(
                                      left: ScreenUtil().setWidth(60),
                                      bottom: ScreenUtil().setHeight(45),
                                      top: ScreenUtil().setHeight(42),
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    color: Color(0xff959ca7).withOpacity(0.1),
                                    child: Row(
                                      children: <Widget>[
                                        Image.asset(
                                          "asset/images/ic_caledar_meeting.png",
                                          width: ScreenUtil().setWidth(56),
                                          height: ScreenUtil().setHeight(55.6),
                                        ),
                                        SizedBox(
                                          width: ScreenUtil().setWidth(33),
                                        ),
                                        Text(
                                          "NGÀY " +
                                              DateFormat('dd-MM-yyyy')
                                                  .format(appBloc
                                                      .calendarBloc.selectDays)
                                                  .toString(),
                                          style: TextStyle(
                                            fontSize: ScreenUtil().setSp(50),
                                            color: prefix0.accentColor,
                                            fontFamily: 'Roboto-Bold',
                                          ),
                                        ),
                                      ],
                                    )),
                            Container(child: _buildEventList()),
                            ButtomCalendarAnimation(_BuildButtonCreateMeeting(),
                                onTap: () {
                              _onTapButton();
                            }),
                            //nút tạo lịch họp
                          ],
                        );
                        break;
                      default:
                        return Container(
                            height: MediaQuery.of(context).size.height,
                            child: Loading());
                        break;
                    }
                  }),
            ),
          ),
        ),
        StreamBuilder(
            initialData: false,
            stream: appBloc.calendarBloc.loadingStream.stream,
            builder: (buildContext, AsyncSnapshot<bool> loadingSnap) {
              if (!loadingSnap.data) {
                return Container();
              } else {
                return Loading();
              }
            })
      ],
    );
  }

  _onTapButton() {
    bool isAllowCreate = DateTimeFormat.compareDateWithCurrentTime(
        appBloc.calendarBloc.selectDays);
    if (isAllowCreate) {
      appBloc.homeBloc.changeActionMeeting(
          state: LayoutNotBottomBarState.CREATE_MEETING,
          data: appBloc.calendarBloc.selectDays);
    } else {
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Không thể tạo lịch cho ngày đã qua. Vui lòng chọn ngày khác và thử lại.");
    }
  }

  //Tạo rieng cái button create này thành 1 widget. Thêm animation vào trong button
  //Sau đó gọi button này vào trong AnimatedContainer của layout này
  //Khi đó sẽ có animation hiển thị và animation click riêng biệt
  //2 thằng animation không để dùng chung cho 1 widget trong 1 layout đâu ạ
  // Animation đang để sai chỗ rồi anh nhé.
  _BuildButtonCreateMeeting() {
    return Container(
      height: ScreenUtil().setHeight(163),
      width: ScreenUtil().setWidth(823),
      margin: EdgeInsets.only(
        top: ScreenUtil().setHeight(68),
        bottom: ScreenUtil().setHeight(101),
      ),
      padding: EdgeInsets.only(
        top: ScreenUtil().setHeight(26),
        bottom: ScreenUtil().setHeight(26),
        left: ScreenUtil().setWidth(57),
        right: ScreenUtil().setWidth(57),
      ),
      decoration: BoxDecoration(
          color: prefix0.accentColor,
          borderRadius: BorderRadius.all(
              Radius.circular(SizeRender.renderBorderSize(context, 10.0)))),
      child: Center(
        child: Text("Tạo lịch họp",
            style: TextStyle(
                fontFamily: 'Roboto-Bold',
                fontSize: ScreenUtil().setSp(60),
                color: prefix0.whiteColor)),
      ),
    );
  }

  // More advanced TableCalendar configuration (using Builders & Styles)
  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'vi_VN',
      calendarController: _calendarController,
      events: appBloc.calendarBloc.mapDataSchedule,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.monday,
      availableGestures: AvailableGestures.none,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(
            color: Color(0xff959ca7),
            fontSize: ScreenUtil().setSp(50),
            fontFamily: 'Roboto-Regular'),
        weekdayStyle: TextStyle().copyWith(
            color: prefix0.blackColor333,
            fontSize: ScreenUtil().setSp(50),
            fontFamily: 'Roboto-Regular'),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(
            color: Color(0xff959ca7),
            fontSize: ScreenUtil().setSp(50),
            fontFamily: 'Roboto-Regular'),
        weekdayStyle: TextStyle().copyWith(
            color: prefix0.blackColor333,
            fontSize: ScreenUtil().setSp(40),
            fontFamily: 'Roboto-Regular'),
      ),
      headerStyle: HeaderStyle(
        titleTextBuilder: (dateTime, dynamic) {
          return "THÁNG " +
              dateTime.month.toString() +
              " - " +
              dateTime.year.toString();
        },
        titleTextStyle: TextStyle(
          fontSize: ScreenUtil().setSp(60),
          color: Color(0xff959ca7),
          fontFamily: 'Roboto-Bold',
        ),
        centerHeaderTitle: true,
        formatButtonVisible: false,
        leftChevronIcon: Icon(
          Icons.arrow_back_ios,
          color: prefix0.accentColor,
          size: 25.0,
        ),
        rightChevronIcon: Icon(
          Icons.arrow_forward_ios,
          color: prefix0.accentColor,
          size: 25.0,
        ),
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: prefix0.accentColor,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.16),
                        offset: Offset(0, ScreenUtil().setHeight(13.0)),
                        blurRadius: ScreenUtil().setHeight(25.0),
                      )
                    ]),
                width: ScreenUtil().setWidth(129.6),
                height: ScreenUtil().setWidth(129.6),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontFamily: 'Roboto-Regular',
                      color: prefix0.whiteColor,
                      fontSize: ScreenUtil().setSp(50.0),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Center(
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffe18c12),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.16),
                      offset: Offset(0, ScreenUtil().setHeight(13.0)),
                      blurRadius: ScreenUtil().setHeight(25.0),
                    )
                  ]),
              width: ScreenUtil().setWidth(129.6),
              height: ScreenUtil().setWidth(129.6),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    fontFamily: 'Roboto-Regular',
                    color: prefix0.whiteColor,
                    fontSize: ScreenUtil().setSp(50.0),
                  ),
                ),
              ),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];
          if (events.isNotEmpty) {
            children.add(
              Positioned(
                bottom: ScreenUtil().setHeight(40.0),
                child: _buildEventsMarker(date, events),
              ),
            );
          }
          return children;
        },
      ),
      onDaySelected: (date, events) {
        appBloc.calendarBloc.selectDateAndShowEvent(date);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    DateTime now = DateTime.now();
    String formattedDateNow = DateFormat('yyyy-MM-dd').format(now);
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    String formattedSelectDaysDate =
        DateFormat('yyyy-MM-dd').format(appBloc.calendarBloc.selectDays);
    Color color;
    if (formattedSelectDaysDate.contains(formattedDate)) {
      color = Color(0xffffffff);
      //Không màu
    } else if (formattedDateNow.contains(formattedDate)) {
      color = Color(0xffe18c12);
    } else {
      //Màu trắng
      color = Color(0xffdc3023);
    }

    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Container(
          child: Center(
            child: Icon(
              Icons.brightness_1,
              color: color,
              size: ScreenUtil().setHeight(13.0),
            ),
          ),
        ));
  }

  Widget _buildEventList() {
    if (appBloc.calendarBloc.selectedEvents == null ||
        appBloc.calendarBloc.selectedEvents.length == 0) {
      return Container();
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: appBloc.calendarBloc.selectedEvents.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildItemMeeting(index);
      },
    );
  }

  _buildItemMeeting(int index) {
    MeetingModel meetingModel = appBloc.calendarBloc.selectedEvents[index];
    return Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFFd3d6da),
              width: 1.0,
            ),
          ),
        ),
        child: InkWell(
          onTap: () {
            appBloc.calendarBloc
                .checkCreator(appBloc, meetingModel)
                .then((isCreator) {
              if (isCreator) {
                EditMeettingModel editMeetingModel = EditMeettingModel(
                    selectDate: appBloc.calendarBloc.selectDays,
                    meetingID: meetingModel.id,
                    statusMeeting: meetingModel.status.name,
                    startTimeMeeting: meetingModel.start_at.date);

                appBloc.homeBloc.changeActionMeeting(
                    state: LayoutNotBottomBarState.EDIT_MEETING,
                    data: editMeetingModel);
              } else {
                //Chỉ được xem lịch
                appBloc.homeBloc.changeActionMeeting(
                    state: LayoutNotBottomBarState.MEETING_DETAIL,
                    data: meetingModel);
              }
            });
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(
              top: ScreenUtil().setHeight(52.0),
              bottom: ScreenUtil().setHeight(45.5),
              left: ScreenUtil().setWidth(60.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ImageMeetingWidget(
                  meetingStatus: meetingModel.status,
                  hasRecord: meetingModel.hasRecord,
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(40),
                ),
                Flexible(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          meetingModel.topic,
                          style: TextStyle(
                              color: Color(0xFF333333),
                              fontSize: ScreenUtil().setSp(48),
                              fontFamily: 'Roboto-Bold'),
                        ),
                        _buildLineDetail(
                            "Bắt đầu lúc:", meetingModel.getStartTime()),
                        _buildLineDetail(
                            "Thời lượng:", meetingModel.getTimeLimit()),
                      ],
                    ),
                  ),
                ),
//                InkWell(
//                  onTap: () {
//                    appBloc.calendarBloc
//                        .checkAndOpenMeeting(context, meetingModel);
//                  },
                ButtomCalendarAnimation(
                    StatusMeetingWidget(meetingModel: meetingModel), onTap: () {
                  _OntapPlayVideos(index);
                }),
//                ),
              ],
            ),
          ),
        ));
  }

  _OntapPlayVideos(int index) {
    MeetingModel meetingModel = appBloc.calendarBloc.selectedEvents[index];
    appBloc.calendarBloc.checkAndOpenMeeting(context, meetingModel);
  }

  Image showProcessIcon(CalendarDataModel event) {
    Image image;
    ProcessType processType = event.checkInsideTime();
    switch (processType) {
      case ProcessType.ENDED:
        image = Image.asset("asset/images/Outline.png",
            width: ScreenUtil().setWidth(83),
            height: ScreenUtil().setWidth(83),
            fit: BoxFit.contain);
        break;
      default:
        image = Image.asset(
          "asset/images/Group 9803.png",
          width: ScreenUtil().setWidth(83),
          height: ScreenUtil().setWidth(83),
          fit: BoxFit.contain,
        );
        break;
    }
    return image;
  }

  Color showProcessColor(CalendarDataModel event) {
    Color color;
    ProcessType processType = event.checkInsideTime();
    switch (processType) {
      case ProcessType.PROCESSING:
        color = prefix0.blue1;
        break;
      case ProcessType.NOT_START:
        color = prefix0.accentColor;
        break;
      case ProcessType.ENDED:
        color = prefix0.redColor;
        break;
      default:
        break;
    }
    return color;
  }

  Widget showProcessSchedule(CalendarDataModel event) {
    String titleShow = "";
    ProcessType processType = event.checkInsideTime();
    switch (processType) {
      case ProcessType.PROCESSING:
        titleShow = 'Tham gia'.toUpperCase();
        break;
      case ProcessType.NOT_START:
        titleShow = 'Chưa bắt đầu'.toUpperCase();
        break;
      case ProcessType.ENDED:
        titleShow = 'Đã kết thúc'.toUpperCase();
        break;
      default:
        titleShow = 'Phòng 1'.toUpperCase();
        break;
    }
    return Text(titleShow,
        style: TextStyle(
            fontFamily: 'Roboto-Regular',
            fontSize: ScreenUtil().setSp(30),
            color: prefix0.whiteColor));
  }

  _buildLineDetail(String title, String content) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: Text(
            title,
            style: TextStyle(
                color: prefix0.color959ca7,
                fontSize: ScreenUtil().setSp(48),
                fontFamily: 'Roboto-Regular'),
          ),
        ),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: Text(
            content,
            style: TextStyle(
                color: Color(0xFF333333),
                fontSize: ScreenUtil().setSp(48),
                fontFamily: 'Roboto-Regular'),
          ),
        ),
      ],
    );
  }
}
