import 'package:flutter/foundation.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/meeting/meeting_services.dart';
import 'package:human_resource/core/meeting/model/creator_model.dart';
import 'package:human_resource/core/meeting/model/meeting_model.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:isolate';

enum CalendarMeetingState { LOADING, SHOW }

class CalendarStreamModel {
  CalendarMeetingState state;
  Map<DateTime, List> mapDataSchedule;

  CalendarStreamModel({this.state, this.mapDataSchedule});
}

class EditMeettingModel {
  DateTime selectDate;
  int meetingID;
  String statusMeeting;
  String startTimeMeeting;

//  MeetingModel data;

  EditMeettingModel(
      {@required this.selectDate,
      @required this.meetingID,
      @required this.statusMeeting,
      @required this.startTimeMeeting});
}

class CalendarMeetingBloc {
  Map<DateTime, List<MeetingModel>> mapDataSchedule = Map();
  Map<DateTime, List<MeetingModel>> mapDataScheduleStatusCancel = Map();

  CoreStream<CalendarStreamModel> calendarStream = CoreStream();
  String error;
  List<ASGUserModel> listASGLUserModel = List();
  CoreStream<List<ASGUserModel>> listASGLUserStream = CoreStream();
  DateTime selectDays = DateTime.now();
  List<MeetingModel> selectedEvents = List();

  Isolate _isolate;
  String notification = "";
  ReceivePort _receivePort;
  bool isListeningIsolate = false;
  Timer timer;

  //Lấy danh sách toàn bộ user ASGL
  void getAllASGLMember(BuildContext context) {
    AppBloc appBloc = BlocProvider.of(context);
    MeetingService service = MeetingService();
    service.getAllMember(onResultData: (resultData) async {
      listASGLUserModel = await compute(_convertUsersData, resultData);
      ASGUserModel userModel = appBloc.authBloc.asgUserModel;
      listASGLUserModel
          ?.removeWhere((user) => user.username == userModel.username);
      listASGLUserStream?.notify(listASGLUserModel);
    }, onErrorApiCallback: (onError) {
      if (onError == ErrorType.JWT_FOUND) {
        appBloc.authBloc.logOut(context);
      }
    });
  }

  static List<ASGUserModel> _convertUsersData(dynamic jsonData) {
    List<ASGUserModel> _list = List();
    if (jsonData['users'] != null && jsonData['users'] != "") {
      Iterable i = jsonData['users'];
      if (i != null && i.length > 0) {
        _list = i.map((model) => ASGUserModel.fromJson(model)).toList();
        if (_list != null && _list.length > 1) {
          _list.sort((o1, o2) {
            List<String> _listFirst = o1.full_name.split(" ");
            List<String> _listLast = o2.full_name.split(" ");
            return _listFirst[_listFirst.length - 1]
                .compareTo(_listLast[_listLast.length - 1]);
          });
        }
      }
    }
    return _list;
  }

  void getDataScheduleApi(BuildContext context,
      {bool isShowNotification = false}) async {
    if (isShowNotification) {
      Toast.showShort("Đang cập nhật thông tin lịch...");
    }
    AppBloc appBloc = BlocProvider.of(context);
    MeetingService meetingService = MeetingService();
    await meetingService.getAllMeeting(onResultData: (result) async {
      if (result != null && result != "") {
        Iterable i = result['meetings'];
        if (i != null && i.length > 0) {
          isoLateCheckTimeCalendarMeeting();
          compute(_convertResultDataToMap, i).then((data) {
            try {
              mapDataSchedule = data;
              getEvent();
              CalendarStreamModel model = CalendarStreamModel(
                  state: CalendarMeetingState.SHOW,
                  mapDataSchedule: mapDataSchedule);
              calendarStream.notify(model);
            } catch (ex) {
              _showCalendarNoData();
            }
          });
        } else {
          _showCalendarNoData();
        }
      } else {
        _showCalendarNoData();
      }
    }, onErrorApiCallback: (onError) {
      _showCalendarNoData();
      if (onError == ErrorType.JWT_FOUND) {
        appBloc.authBloc.logOut(context);
      }
    });
    if (isShowNotification) {
      Toast.showShort("Toàn bộ thông tin lịch đã được cập nhật.");
    }
  }

  static Map<DateTime, List<MeetingModel>> _convertResultDataToMap(Iterable i) {
    List<MeetingModel> listData =
        i.map((model) => MeetingModel.fromJson(model)).toList();
    Map<DateTime, List<MeetingModel>> mapData = Map();
    listData?.forEach((meetingModel) {
      DateTime dateTime = DateTime.parse(meetingModel.start_at.date);
      DateFormat dateFormat = DateFormat("yyyy-MM-dd");
      String timeFormat = dateFormat.format(dateTime);
      DateTime keyTime = DateTime.parse(timeFormat);
      if (mapData.containsKey(keyTime)) {
        mapData[keyTime].add(meetingModel);
      } else {
        mapData[keyTime] = List();
        mapData[keyTime].add(meetingModel);
      }
    });
    return mapData;
  }

  String convertTime(String date) {
    DateTime dateTime = DateTime.parse(date);
    return dateTime.hour.toString() + ":" + dateTime.minute.toString();
  }

  void getEvent() {
    String month = selectDays.month > 9
        ? selectDays.month.toString()
        : "0" + selectDays?.month.toString();
    String day = selectDays.day > 9
        ? selectDays.day.toString()
        : "0" + selectDays?.day.toString();
    String time = selectDays.year.toString() + "-" + month + "-" + day;
    dynamic dateTime;
    if (mapDataSchedule != null &&
        mapDataSchedule.keys != null &&
        mapDataSchedule.keys.length > 0) {
      mapDataSchedule?.keys?.forEach((key) {
        if (key.toString().contains(time)) {
          dateTime = key;
        }
      });
      if (dateTime != null) {
        selectedEvents = mapDataSchedule[dateTime];
      } else {
        selectedEvents = List();
      }
    } else {
      selectedEvents = List();
    }
  }

  Future<bool> checkCreator(AppBloc appBloc, MeetingModel meetingModel) async {
    ASGUserModel currentUser = appBloc.authBloc.asgUserModel;
    CreatorModel creatorModel = meetingModel.creator;
    if (creatorModel == null) {
      return false;
    } else {
      return currentUser.id == creatorModel.id;
    }
  }

  Future<bool> checkCreator_Thin(AppBloc appBloc, int id) async {
    ASGUserModel currentUser = appBloc.authBloc.asgUserModel;
//    CreatorModel creatorModel = meetingModel.creator.;
    if (id == null && id > 0) {
      return false;
    } else {
      return currentUser.id == id;
    }
  }

  void selectDateAndShowEvent(DateTime date) {
    selectDays = date;
    getEvent();
    calendarStream.notify(CalendarStreamModel(
        state: CalendarMeetingState.SHOW, mapDataSchedule: mapDataSchedule));
  }

  void checkAndOpenMeeting(BuildContext context, MeetingModel meetingModel) {
    if (meetingModel.status.id == 3) {
      DialogUtils.showDialogResult(context, DialogType.SUCCESS,
          "Lịch họp đã bị hủy không thể tham gia.");
    } else if (meetingModel.status.id == 4) {
      //Lịch họp đã kết thúc
      if (meetingModel.record != null && meetingModel.record != "") {
        AppBloc appBloc = BlocProvider.of(context);
        _openVideoPlayer(appBloc, meetingModel.record);
      } else {
        DialogUtils.showDialogResult(context, DialogType.SUCCESS,
            "Không thể xem video cuộc họp vào lúc này.");
      }
    } else if (meetingModel.status.id == 2) {
      if (meetingModel.zoom_join_url != null &&
          meetingModel.zoom_join_url.trim().toString() != "") {
//        //Open zoom
//        _openZoom(meetingModel.zoom_join_url);
        _attendMeeting(context, meetingModel);
      } else {
        DialogUtils.showDialogResult(context, DialogType.SUCCESS,
            "Không tìm thấy đường dẫn tham gia cuộc họp lúc này.");
      }
    } else if (meetingModel.status.id == 1) {
      try {
        DateTime endMeeting = DateTime.parse(meetingModel.end_at.date);
        int endTimeStamp = endMeeting.millisecondsSinceEpoch;
        int currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
        if (currentTimeStamp >= endTimeStamp) {
          getDataScheduleApi(context);
          DialogUtils.showDialogResult(context, DialogType.SUCCESS,
              "Lịch họp đã kết thúc không thể tham gia.");
        } else {
          DateTime startTime = DateTime.parse(meetingModel.start_at.date);
          int count = startTime.millisecondsSinceEpoch - currentTimeStamp;
          if (count <= 300000) {
            //Openzoom
            _attendMeeting(context, meetingModel);
          } else {
            //Cách lịch họp >5 phút
            DialogUtils.showDialogResult(context, DialogType.SUCCESS,
                "Vui lòng tham dự trước 5 phút khi cuộc họp bắt đầu.");
          }
        }
      } catch (ex) {
        DialogUtils.showDialogResult(context, DialogType.SUCCESS,
            "Không thể tham gia cuộc họp vào lúc này.");
      }
    }
  }

  _openZoom(String zoomUrl) async {
    try {
      String url = zoomUrl;
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (ex) {
      Toast.showShort("Không thể tham gia cuộc họp vào lúc này.");
    }
  }

  CoreStream<bool> loadingStream = CoreStream();

  Future<void> _attendMeeting(
      BuildContext context, MeetingModel meetingModel) async {
    loadingStream.notify(true);
    AppBloc appBloc = BlocProvider.of(context);
    MeetingService meetingService = MeetingService();
    await meetingService.attendMeeting(
        meetingID: meetingModel.id.toString(),
        onResultData: (resultData) {
          loadingStream.notify(false);
          _openZoom(meetingModel.zoom_join_url);
        },
        onErrorApiCallback: (onError) {
          loadingStream.notify(false);
          if (onError is String) {
            DialogUtils.showDialogResult(
                context, DialogType.SUCCESS, onError.toString());
          } else if (onError is ErrorType) {
            if (onError == ErrorType.JWT_FOUND) {
              appBloc.authBloc.logOut(context);
            } else {
              DialogUtils.showDialogResult(context, DialogType.SUCCESS,
                  "Không thể tham gia cuộc họp vào lúc này.");
            }
          }
        });
  }

  void refeshAllData() {
    listASGLUserStream?.notify(listASGLUserModel);
  }

  void isoLateCheckTimeCalendarMeeting() async {
    timer = Timer.periodic(new Duration(minutes: 1), (Timer t) async {
      if (_isolate != null) {
        _isolate?.kill(priority: Isolate.immediate);
        _isolate = null;
      }
      _receivePort = ReceivePort();
      Map<int, dynamic> _mapParams = {
        0: mapDataSchedule,
        1: _receivePort.sendPort,
      };
      _isolate = await Isolate.spawn(_checkTimer, _mapParams);
      if (!isListeningIsolate) {
        isListeningIsolate = true;
        _receivePort?.asBroadcastStream()?.listen((onData) {
          if (onData != null && onData.length > 0) {
            mapDataSchedule.clear();
            mapDataSchedule = onData;
            getEvent();
            CalendarStreamModel model = CalendarStreamModel(
                state: CalendarMeetingState.SHOW,
                mapDataSchedule: mapDataSchedule);
            calendarStream.notify(model);
          }
        });
      }
    });
  }

  static void _checkTimer(Map<int, dynamic> _mapParams) async {
    int now = DateFormat('yyyy-MM-dd HH:mm:ss')
        .parse(DateTime.now().toString())
        .millisecondsSinceEpoch;
    if (_mapParams[0] != null) {
      //Kiểm tra từng nhóm
      List<MeetingModel> listReadAllData = List();
      _mapParams[0].forEach((k, v) {
        List<MeetingModel> listReadData = List();
        v.forEach((r) {
          int startAt = DateFormat('yyyy-MM-dd HH:mm:ss')
              .parse(r.start_at.date)
              .millisecondsSinceEpoch;
          int endAt = DateFormat('yyyy-MM-dd HH:mm:ss')
              .parse(r.end_at.date)
              .millisecondsSinceEpoch;
          if (now >= endAt) {
            r.status.id = 4;
            r.status.name = "Đã kết thúc";
          } else {
            if (r.status.id == 1) {
              if (now >= startAt) {
                //chuyển đổi trạng thái về đang họp
                r.status.id = 2;
                r.status.name = "Tham gia";
              }
            } else if (r.status.id == 2) {
              if (now >= endAt) {
                r.status.id = 4;
                r.status.name = "Đã kết thúc";
              }
            }
          }

          listReadData.add(r);
        });
        listReadAllData.addAll(listReadData);
      });
      Map<DateTime, List<MeetingModel>> mapData = Map();
      listReadAllData?.forEach((meetingModel) {
        DateTime dateTime = DateTime.parse(meetingModel.start_at.date);
        DateFormat dateFormat = DateFormat("yyyy-MM-dd");
        String timeFormat = dateFormat.format(dateTime);
        DateTime keyTime = DateTime.parse(timeFormat);
        if (mapData.containsKey(keyTime)) {
          mapData[keyTime].add(meetingModel);
        } else {
          mapData[keyTime] = List();
          mapData[keyTime].add(meetingModel);
        }
      });
      _mapParams[1].send(mapData);
    }
  }

  void _openVideoPlayer(AppBloc appBloc, String record) {
    appBloc.homeBloc.openVideoPayer(record);
  }

  void _showCalendarNoData() {
    mapDataSchedule = Map();
    CalendarStreamModel model = CalendarStreamModel(
        state: CalendarMeetingState.SHOW, mapDataSchedule: mapDataSchedule);
    calendarStream.notify(model);
  }
}
