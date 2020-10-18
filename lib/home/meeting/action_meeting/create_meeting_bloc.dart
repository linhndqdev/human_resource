import 'package:flutter/cupertino.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/meeting/model/meeting_room_model.dart';
import 'package:human_resource/core/meeting/meeting_services.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:intl/intl.dart';

import '../../home_bloc.dart';
import 'edit_meeting_bloc.dart';

class CreateMeetingBloc {
  bool isRequestAccept;
  DateTime meetingDate;
  String sMeetingTime;
  DateTime meetingTime;

  int meetingHour;
  int meetingMinute;
  int meetingTimeLimit = 60;
  MeetingRoomModel meetingRoomPicked;
  List<MeetingRoomModel> listMeetingRoom = List();
  List<ASGUserModel> listMember = List();

  CreateMeetingBloc(this.isRequestAccept);

  CoreStream<bool> requestAcceptMeetingStream = CoreStream();
  CoreStream<bool> loadingStream = CoreStream();
  CoreStream<bool> showAddMemberStream = CoreStream();

  CoreStream<int> countMemberStream = CoreStream();
  CoreStream<int> meetingTimeLimitStream = CoreStream();

  CoreStream<String> meetingDateStream = CoreStream();
  CoreStream<String> meetingTimeStream = CoreStream();

  CoreStream<MeetingRoomModel> roomAvailableStream = CoreStream();

  CoreStream<List<ASGUserModel>> listMemberStream = CoreStream();

  void dispose() {
    requestAcceptMeetingStream?.closeStream();
    meetingTimeStream?.closeStream();
    meetingTimeLimitStream?.closeStream();
    meetingDateStream?.closeStream();
    loadingStream?.closeStream();
    roomAvailableStream?.closeStream();
    countMemberStream?.closeStream();
    listMemberStream?.closeStream();
    showAddMemberStream?.closeStream();
  }

  //Cập nhật số lượng thành viên
  void countMember() {
    countMemberStream?.notify(listMember.length);
  }

  //Chỉ sử dụng trong lần đầu tiên mở screen
  void setMeetingDate(DateTime dateTime) {
    this.meetingDate = dateTime;
    this.sMeetingTime = DateTimeFormat.getMeetingTime(dateTime);
    List<String> times = this.sMeetingTime.split(":");
    meetingHour = int.parse(times[0]);
    meetingMinute = int.parse(times[1]);
  }

  void changeRequestAcceptMeeting() {
    this.isRequestAccept = !this.isRequestAccept;
    requestAcceptMeetingStream?.notify(isRequestAccept);
  }

  void pickerTime(BuildContext context, DateTime time) async {
    DateTime currentTime = DateTime.now();
    int currentHour = currentTime.hour;
    int currentMinus = currentTime.minute;
    int currentMonth = currentTime.month;
    int currentYear = currentTime.year;
    int currentDay = currentTime.day;
    int selectMoth = meetingDate.month;
    int selectYear = meetingDate.year;
    int selectDay = meetingDate.day;
    int resultCompare;
    if (currentYear > selectYear) {
      resultCompare = -1;
    } else if (currentYear < selectYear) {
      resultCompare = 1;
    } else {
      if (currentMonth > selectMoth) {
        resultCompare = -1;
      } else if (currentMonth < selectMoth) {
        resultCompare = 1;
      } else {
        if (currentDay > selectDay) {
          resultCompare = -1;
        } else if (currentDay < selectDay) {
          resultCompare = 1;
        } else {
          resultCompare = 0;
        }
      }
    }
    if (resultCompare == 0) {
      bool isCheckedTime = false;
      if (time.hour < currentHour) {
        isCheckedTime = false;
      } else if (time.hour == currentHour) {
        if (time.minute <= currentMinus) {
          isCheckedTime = false;
        } else {
          isCheckedTime = true;
        }
      } else {
        isCheckedTime = true;
      }
      if (isCheckedTime) {
        _getHourAndMinute(time);
        String sHour = this.meetingHour < 10 ? "0$meetingHour" : "$meetingHour";
        String sMinute =
            this.meetingMinute < 10 ? "0$meetingMinute" : "$meetingMinute";
        sMeetingTime = "$sHour:$sMinute";
        meetingTimeStream.notify(sMeetingTime);
        getListRoomAvailable(context);
      } else {
        DialogUtils.showDialogResult(context, DialogType.FAILED,
            "Vui lòng chọn thời gian lớn hơn thời gian hiện tại");
      }
    } else if (resultCompare == -1) {
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Vui lòng chọn thời gian lớn hơn thời gian hiện tại");
    } else {
      _getHourAndMinute(time);
      String sHour = this.meetingHour < 10 ? "0$meetingHour" : "$meetingHour";
      String sMinute =
          this.meetingMinute < 10 ? "0$meetingMinute" : "$meetingMinute";
      sMeetingTime = "$sHour:$sMinute";
      meetingTimeStream.notify(sMeetingTime);
      getListRoomAvailable(context);
    }
  }

  _getHourAndMinute(DateTime dateTime) {
    this.meetingHour = dateTime.hour;
    this.meetingMinute = dateTime.minute;
  }

  ///[value] : Thời lượng cuộc họp tính bằng phút
  void pickLimitTime(BuildContext context, int value) {
    if (value != this.meetingTimeLimit) {
      this.meetingTimeLimit = value;
      meetingTimeLimitStream?.notify(value);
      getListRoomAvailable(context);
    }
  }

  void changeMeetingDate(BuildContext context, DateTime timePicked) {
    bool isCheckedDate = DateTimeFormat.compareDateWithCurrentTime(timePicked);
    if (isCheckedDate) {
      this.meetingDate = timePicked;
      String sTimePicked = DateTimeFormat.formatMeetingDatePicker(timePicked);
      meetingDateStream.notify(sTimePicked);
      getListRoomAvailable(context);
    } else {
      Future.delayed(Duration(milliseconds: 500), () {
        DialogUtils.showDialogResult(context, DialogType.FAILED,
            "Vui lòng chọn ngày lớn hơn hoặc bằng ngày hiện tại.");
      });
    }
  }

  void getListRoomAvailable(BuildContext context) async {
    loadingStream?.notify(true);
    MeetingService meetingService = MeetingService();
    String time = DateTimeFormat.formatDateTimeToGetRoomMeeting(
        meetingDate.year,
        meetingDate.month,
        meetingDate.day,
        meetingHour,
        meetingMinute);
    await meetingService.getRoomAvailableAtTime(
        dateTime: time,
        meetingTimeLimit: meetingTimeLimit,
        resultData: (result) {
          Iterable i = result;
          if (i != null && i.length > 0) {
            listMeetingRoom =
                i.map((model) => MeetingRoomModel.fromJson(model)).toList();
            meetingRoomPicked = listMeetingRoom[0];
          } else {
            meetingRoomPicked = MeetingRoomModel(-1, "");
          }
          roomAvailableStream.notify(meetingRoomPicked);
          loadingStream?.notify(false);
        },
        onErrorApiCallback: (onError) {
          loadingStream?.notify(false);
          if (onError == ErrorType.JWT_FOUND) {
            AppBloc appBloc = BlocProvider.of(context);
            appBloc.authBloc.logOut(context);
          } else {
          }
        });
  }

  void pickMeetingRoom(MeetingRoomModel meetingRoomModel) {
    meetingRoomPicked = meetingRoomModel;
    roomAvailableStream?.notify(meetingRoomPicked);
  }

  void createMeetingSchedule(BuildContext context,
      String category, String content) async {
    if (category == null || category == "") {
      DialogUtils.showDialogResult(
          context, DialogType.FAILED, "Vui lòng nhập chủ để cuộc họp.");
    } else if (content == null || content == "") {
      DialogUtils.showDialogResult(
          context, DialogType.FAILED, "Vui lòng nhập nội dung cuộc họp.");
    } else if (meetingRoomPicked == null) {
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Hiện tại không có phòng họp nào trống. Vui lòng chọn thời gian lịch họp khác.");
    } else if (listMember == null || listMember.length == 0) {
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Vui lòng chọn thành viên tham dự cuộc họp.");
    } else {
      loadingStream.notify(true);
      List<int> listMemberID = listMember.map((model) => model.id).toList();
      AppBloc appBloc = BlocProvider.of(context);
      DateTime dateTime = DateTime(meetingDate.year, meetingDate.month,
          meetingDate.day, meetingHour, meetingMinute);
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
      String startAt = dateFormat.format(dateTime);
      MeetingService meetingService = MeetingService();
      await meetingService.createMeeting(
          topic: category,
          description: content,
          duration: meetingTimeLimit,
          roomId: meetingRoomPicked.id,
          startAt: startAt,
          listParticipantID: listMemberID,
          onResultData: (resultData) {
            loadingStream.notify(false);
            Toast.showShort("Chúc mừng! Tạo lịch họp thành công.");
            appBloc.calendarBloc.getDataScheduleApi(context);
            appBloc.homeBloc
                .changeActionMeeting(state: LayoutNotBottomBarState.NONE);
          },
          onErrorApiCallback: (onError) {
            loadingStream.notify(false);
            if (onError is String) {
              DialogUtils.showDialogResult(
                  context, DialogType.FAILED, onError.toString());
            } else {
              if (onError == ErrorType.JWT_FOUND) {
                appBloc.authBloc.logOut(context);
              } else {
                DialogUtils.showDialogResult(context, DialogType.FAILED,
                    "Tạo lịch họp thất bại. Vui lòng thử lại sau");
              }
            }
          });
    }
  }

  void hiddenAddMemberScreen() {
    showAddMemberStream?.notify(false);
  }

  void showAddMemberScreen() {
    showAddMemberStream?.notify(true);
  }

  void setListUserPicked(List<ASGUserModel> listUserPicked) async {
    listMember.clear();
    if (listUserPicked != null && listUserPicked.length > 0) {
      listMember.addAll(listUserPicked);
    }
    countMember();
    listMemberStream.notify(listMember);
  }

  bool isRemove = false;

  void removeUser(ASGUserModel data) {
    if (!isRemove) {
      isRemove = true;
      listMember.remove(data);
      countMember();
      listMemberStream.notify(listMember);
      isRemove = false;
    }
  }

  CoreStream<ShowChildMenuModel> showChildStream = CoreStream();

  void openManagerMember(bool isOpen) {
    if (isOpen) {
      showChildStream
          ?.notify(ShowChildMenuModel(state: ShowChildMenuState.MANAGE_MEMBER));
    }
  }

  void hiddenManagerMember() {
    showChildStream
        ?.notify(ShowChildMenuModel(state: ShowChildMenuState.MANAGE_MEMBER));
  }

  void updateUserPicked(List<ASGUserModel> data) {
    listMember?.clear();
    if (data != null && data.length > 0) {
      listMember?.addAll(data);
    }
    countMember();
    listMemberStream?.notify(listMember);
  }
}
