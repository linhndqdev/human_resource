import 'package:flutter/material.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/meeting/meeting_services.dart';
import 'package:human_resource/core/meeting/meeting_updated_model.dart';
import 'package:human_resource/core/meeting/model/meeting_model.dart';
import 'package:human_resource/core/meeting/model/meeting_room_model.dart';
import 'package:human_resource/core/meeting/model/participant_model.dart';
import 'package:human_resource/home/home_bloc.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:intl/intl.dart';

//enum isFocusWidget{
//  SHOW_EDIT_LAYOUT,
//  SHOW_MEMBER,
//  ADD_MEMBER
//}
//class FocusWidgetModel{
//  isFocusWidget state;
//  FocusWidgetModel({this.state});
//}

class EditMeetingBloc {
//  FocusWidgetModel focusWidgetModel = FocusWidgetModel(state: isFocusWidget.SHOW_EDIT_LAYOUT);
  MeetingModel meetingModel;
  bool isRequestAccept;
  DateTime meetingDate;
  String sMeetingTime;
  DateTime meetingTime;
  List<ParticipantModel> listMember = List();
  int meetingHour;
  int meetingMinute;
  int meetingTimeLimit = 60;
  MeetingRoomModel meetingRoomPicked;

  List<MeetingRoomModel> listMeetingRoom = List();
  List<MeetingUpdatedModel> listMeetingUpdatedRoom = List();
  MeetingUpdatedModel meetingRoomUpdated;

  EditMeetingBloc(this.isRequestAccept);

  CoreStream<bool> requestAcceptMeetingStream = CoreStream();
  CoreStream<String> meetingTimeStream = CoreStream();
  CoreStream<int> meetingTimeLimitStream = CoreStream();
  CoreStream<DateTime> meetingDateStream = CoreStream();
  CoreStream<bool> loadingStream = CoreStream();
  CoreStream<MeetingRoomModel> roomAvailableStream = CoreStream();

  CoreStream<EditMeetingValidateState> validateTopicStream = CoreStream();
  CoreStream<EditMeetingValidateState> validateContentStream = CoreStream();
  CoreStream<EditMeetingValidateState> validateUpdateMeetingStream =
      CoreStream();
  CoreStream<List<ParticipantModel>> listMemberStream = CoreStream();
  CoreStream<MeetingModel> meetingStream = CoreStream();

  void dispose() {
    meetingStream?.closeStream();
    validateUpdateMeetingStream?.closeStream();
    validateContentStream?.closeStream();
    validateTopicStream?.closeStream();
    requestAcceptMeetingStream?.closeStream();
    meetingTimeStream?.closeStream();
    meetingTimeLimitStream?.closeStream();
    meetingDateStream?.closeStream();
    loadingStream?.closeStream();
    roomAvailableStream?.closeStream();
    showChildStream?.closeStream();
    countMemberStream?.closeStream();
    listMemberStream?.closeStream();
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
    String times = meetingDate.year.toString() +
        '-' +
        meetingDate.month.toString() +
        '-' +
        meetingDate.day.toString() +
        ' ' +
        time.hour.toString() +
        ':' +
        time.minute.toString() +
        ':00.000';
    DateTime currentTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(times);
    Duration difference = currentTime.difference(DateTime.now());
    bool isCheckedTime = false;
    if (difference.inMinutes < 0) {
      isCheckedTime = false;
    } else {
      isCheckedTime = true;
    }
    if (isCheckedTime) {
      _getHourAndMinute(time);
      meetingTime = time;
      String sHour = this.meetingHour < 10 ? "0$meetingHour" : "$meetingHour";
      String sMinute =
          this.meetingMinute < 10 ? "0$meetingMinute" : "$meetingMinute";
      sMeetingTime = "$sHour:$sMinute";
      meetingTimeStream.notify(sMeetingTime);
      getListRoomAvailable(context: context, state: ActionChangeRoomState.EDIT);
    } else {
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Vui lòng chọn thời gian lớn hơn thời gian hiện tại");
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
      getListRoomAvailable(context: context, state: ActionChangeRoomState.EDIT);
    }
  }

  //Chỗ anh gọi sang thằng quản lý thành viên đâu anh nhỉ
  void changeMeetingDate(BuildContext context, DateTime timePicked) {
    //bool isCheckedDate = DateTimeFormat.compareDateWithCurrentTime(timePicked);
    // meetingDate = timePicked;
    String times = timePicked.year.toString() +
        '-' +
        timePicked.month.toString() +
        '-' +
        timePicked.day.toString() +
        ' ' +
        meetingTime.hour.toString() +
        ':' +
        meetingTime.minute.toString() +
        ':00.000';
    DateTime currentTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(times);
    DateTime Nows = DateTime.now();
    //Duration difference = Nows.difference(currentTime);
    Duration difference = currentTime.difference(Nows);

    bool isCheckedTime = false;
    int secons = difference.inSeconds;
    if (secons < 0) {
      isCheckedTime = false;
    } else {
      isCheckedTime = true;
    }
    //if (isCheckedTime) {

    if (isCheckedTime) {
      // ngoc anh
      meetingDate = timePicked;
      meetingDateStream.notify(timePicked);
      //meetingDateStream.notify(sTimePicked);
      getListRoomAvailable(context: context, state: ActionChangeRoomState.EDIT);
    } else {
      Future.delayed(Duration(milliseconds: 500), () {
        DialogUtils.showDialogResult(context, DialogType.FAILED,
            "Vui lòng chọn ngày giờ lớn hơn hoặc bằng ngày hiện tại.");
      });
    }
  }

  void getListRoomAvailable(
      {BuildContext context, @required ActionChangeRoomState state}) async {
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

            if (state != ActionChangeRoomState.INIT) {
              meetingRoomPicked = listMeetingRoom[0];
            } else {
              if (meetingRoomPicked != null) {
                bool checktrue = false;
                for (int i = 0; i < listMeetingRoom.length; i++) {
                  if (listMeetingRoom[i].id == meetingRoomPicked.id) {
                    checktrue = true;
                  }
                }
                if (!checktrue) listMeetingRoom.add(meetingRoomPicked);
              }

//              listMeetingRoom= listMeetingRoom..sort();
              //var descending = ascending.reversed;
              // listMeetingRoom.sort((a, b) => a.id.compareTo(b.id));
            }
          } else {
            listMeetingRoom.clear();
            if (state != ActionChangeRoomState.INIT)
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
          } else {}
        });
  }

  void pickMeetingRoom(MeetingRoomModel meetingRoomModel) {
    meetingRoomPicked = meetingRoomModel;
    roomAvailableStream?.notify(meetingRoomPicked);
  }

  Future<void> getDetailMeeting(
      {AppBloc appBloc,
      String meetingID,
      DateTime selectDays,
      BuildContext context}) async {
    loadingStream?.notify(true);
    MeetingService meetingService = MeetingService();

    await meetingService.getDetailMeeting(
        meetingID: meetingID,
        onResultData: (result) {
//          meetingModel = result
          loadingStream.notify(false);
          meetingModel = MeetingModel.fromJson(result['meeting']);
          meetingStream?.notify(meetingModel);
          meetingDate = DateTime.parse(meetingModel.start_at.date);
          setMeetingDate(meetingDate);
          meetingDateStream.notify(meetingDate);

          meetingRoomPicked = meetingModel.room;
          //roomAvailableStream.notify(meetingRoomPicked);
          meetingTime = DateTime.parse(meetingModel.start_at.date);
          sMeetingTime = new DateFormat.Hm()
              .format(DateTime.parse(meetingModel.start_at.date))
              .toString();
          meetingTimeStream.notify(sMeetingTime);

          DateTime start_at = DateTime.parse(meetingModel.start_at.date);
          DateTime end_at = DateTime.parse(meetingModel.end_at.date);
          Duration difference = end_at.difference(start_at);
          meetingTimeLimit = difference.inMinutes;
          meetingTimeLimitStream.notify(meetingTimeLimit);

          roomAvailableStream.notify(
              MeetingRoomModel(meetingModel.room.id, meetingModel.room.name));
          listMember.clear();

          listMember = meetingModel.participants.map((model) => model).toList();

          countMember();
          listMemberStream.notify(listMember);

//          EditMeettingModel editMeetingModel =
//              EditMeettingModel(selectDate: selectDays, data: datas);
//          appBloc.homeBloc.changeActionMeeting(
//              state: LayoutNotBottomBarState.EDIT_MEETING,
//              data: editMeetingModel);
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
                  "Lấy dữ liệu lịch họp thất bại. Vui lòng thử lại sau");
            }
          }
        });
  }

  void updateMeetingInfo(
      {AppBloc appBloc,
      String id,
      String chude,
      String noidung,
      BuildContext context,
      List<int> lstParticipant,
      DateTime startAt}) async {
    loadingStream?.notify(true);
    List<int> listMemberID = listMember.map((model) => model.id).toList();
    DateTime dateTime = DateTime(meetingDate.year, meetingDate.month,
        meetingDate.day, meetingHour, meetingMinute);
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
    String startAt = dateFormat.format(dateTime);
    MeetingService meetingService = MeetingService();
    await meetingService.updateMeetingInfomation(
        id: id,
        //chỗ này đang test id=4 đã tạo trước đó
        topic: chude,
        description: noidung,
        start_at: startAt,
        duration: meetingTimeLimit,
        room_id: meetingRoomPicked.id,
        participant_ids: listMemberID,
        onResultData: (result) {
          loadingStream.notify(false);
          Toast.showShort("Chúc mừng! Cập nhật lịch họp thành công.");
          appBloc.calendarBloc.getDataScheduleApi(context);
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
                  "Cập nhật lịch họp thất bại. Vui lòng thử lại sau");
            }
          }
        });
  }

  //----------validate form edit meeting ---------------------
  String topic;
  String content;

  void updateTopic(String topicInput) {
    this.topic = topicInput;
    if (this.topic == null || this.topic.trim() == "") {
      validateTopicStream.notify(EditMeetingValidateState.NONE);
    } else {
      validateTopicStream.notify(topicInput.length >= 4
          ? EditMeetingValidateState.MATCHED
          : EditMeetingValidateState.ERROR);
    }
  }

  void updateContentMeeting(String contentInput) {
    this.content = contentInput;
    if (this.content == null || this.content.trim() == "") {
      validateContentStream.notify(EditMeetingValidateState.NONE);
    } else {
      validateContentStream.notify(contentInput.length >= 20
          ? EditMeetingValidateState.MATCHED
          : EditMeetingValidateState.ERROR);
    }
  }

  void updateMeetingInfo1(
      {String chude,
      String noidung,
      BuildContext context,
      List<int> lstParticipant}) {
    if (chude.length < 4) {
      DialogUtils.showDialogResult(
          context, DialogType.FAILED, "Vui lòng nhập chủ đề lớn hơn 3 ký tự");
      return;
    }
    if (noidung.length < 21) {
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Vui lòng nhập nội dung lớn hơn 20 ký tự");
      return;
    }
    if (lstParticipant.length == 0) {
      DialogUtils.showDialogResult(
          context, DialogType.FAILED, "Vui lòng chọn thêm thành viên tham dự");
      return;
    }
//    validateUpdateMeetingStream.notify(dataStream);
  }

  void openEditPage(bool isOpen) {
    if (isOpen) {
      showChildStream
          ?.notify(ShowChildMenuModel(state: ShowChildMenuState.NONE));
    }
  }

  //Open managermember
  void openManagerMember(bool isOpen) {
//    ShowChildMenuModel showChildMenuModel= ShowChildMenuModel(state: ShowChildMenuState.NONE);
//    isOpen?? showChildMenuModel = ShowChildMenuModel(state: ShowChildMenuState.MANAGE_MEMBER);

    if (isOpen) {
      showChildStream
          ?.notify(ShowChildMenuModel(state: ShowChildMenuState.MANAGE_MEMBER));
    }
  }

  void openAddMember(bool isOpen) {
    if (isOpen) {
      showChildStream
          ?.notify(ShowChildMenuModel(state: ShowChildMenuState.ADD_MEMBER));
    }
//    else {
//      showChildStream
//          ?.notify(ShowChildMenuModel(state: ShowChildMenuState.MANAGE_MEMBER));
//    };

//    ShowChildMenuModel showChildMenuModel= ShowChildMenuModel(state: ShowChildMenuState.NONE);
//    isOpen? showChildMenuModel =ShowChildMenuModel(state: ShowChildMenuState.ADD_MEMBER):ShowChildMenuModel(state: ShowChildMenuState.MANAGE_MEMBER);
//    showChildStream
//        ?.notify(showChildMenuModel);
  }

  CoreStream<ShowChildMenuModel> showChildStream = CoreStream();

  //-------------
  CoreStream<int> countMemberStream = CoreStream();
  bool isRemove = false;

  void countMember() {
    countMemberStream?.notify(listMember.length);
  }

  bool removeUser(
      {ParticipantModel data, BuildContext context, AppBloc appBloc}) {
    bool success = true;
    if (!isRemove) {
      if (listMember.length <= 1) {
        DialogUtils.showDialogResult(context, DialogType.FAILED,
            "Bạn không thể xoá hết thành viên được");
        success = false;
      } else {
        appBloc.calendarBloc
            .checkCreator_Thin(appBloc, data.id)
            .then((isCreator) {
          if (isCreator) {
            DialogUtils.showDialogResult(context, DialogType.FAILED,
                "Bạn không thể xoá chính mình được");
          } else {
            isRemove = true;
            listMember?.removeWhere((member) => member?.id == data?.id);
            countMember();
            listMemberStream.notify(listMember);
            isRemove = false;
          }
        });
      }
    }
    return success;
  }

  void removeUser_bak(ParticipantModel data) {
    if (!isRemove) {
      isRemove = true;
      for (int i = 0; i < listMember.length; i++) {
        if (listMember[i].id == data.id) {
          listMember.remove(listMember[i]);
          countMember();
          listMemberStream.notify(listMember);
        }
      }
      isRemove = false;
    }
  }

  void pickedOrRemoveUser({BuildContext context, int id, AppBloc appBloc}) {
    //ngocanh
    AppBloc appBloc = BlocProvider.of(context);
    ParticipantModel asgUserModel =
        listMember?.firstWhere((user) => user.id == id, orElse: () => null);
    if (asgUserModel != null) {
      //listMember.remove(asgUserModel);
      removeUser(data: asgUserModel, appBloc: appBloc, context: context);
    } else {
      ASGUserModel model = appBloc.calendarBloc.listASGLUserModel
          ?.firstWhere((user) => user.id == id, orElse: () => null);

      ParticipantModel model1 = ParticipantModel(
          id: model.id,
          name: model.full_name,
          email: model.email,
          invited: 1,
          attended: 0,
          accepted: 0,
          positions: [
            Position(department: Department(name: model.position.name))
          ]);
      if (model1 != null) {
        //removeUser(model1);
        listMember.add(model1);
      }
    }
    countMember();

    appBloc.calendarBloc.listASGLUserStream
        .notify(appBloc.calendarBloc.listASGLUserModel);
  }

  List<RestUserModel> listRes = List();

  void pickedMember_inGroup(AppBloc appBloc,
      List<RestUserModel> listGroupMember, BuildContext context) async {
    List<RestUserModel> data = List();
    data.addAll(listGroupMember);
    String userName = appBloc.authBloc.asgUserModel.username;
    data?.removeWhere((user) => user?.username == userName);
    data?.removeWhere((user) => user?.username == "asglchat");

    data?.forEach((user) {
      ASGUserModel model = appBloc.calendarBloc.listASGLUserModel?.firstWhere(
          (userPick) => userPick.username == user.username,
          orElse: () => null);

      if (model != null) {
        ParticipantModel model1 = ParticipantModel(
            id: model.id,
            name: model.full_name,
            email: model.email,
            invited: 1,
            attended: 0,
            accepted: 0,
            positions: [
              Position(department: Department(name: model.position.name))
            ]);
        bool isContain = false;
        if (listMember != null) {
          for (int u = 0; u < listMember.length; u++) {
            if (listMember[u].id == model1.id) {
              isContain = true;
            }
          }
        }
        if (!isContain) {
          listMember.add(model1);
        }
//        removeUser(data: model1, appBloc: appBloc, context: context);
//        listMember.add(model1);
      }
    });
    //updateCountUserPicked();
    countMember();
    appBloc.calendarBloc.listASGLUserStream
        .notify(appBloc.calendarBloc.listASGLUserModel);
  }

  void removeMember_inGroup(AppBloc appBloc,
      List<RestUserModel> listGroupMember, BuildContext context) {
    listRes.clear();
    listRes.addAll(listGroupMember);
    String userName = appBloc.authBloc.asgUserModel.username;
    listRes?.removeWhere((user) => user.username == userName);
    listRes?.removeWhere((user) => user.username == "asglchat");

    if (listGroupMember.length < 1) {
      return;
    } else {
      listRes?.forEach((resUser) {
        ASGUserModel model = appBloc.calendarBloc.listASGLUserModel?.firstWhere(
            (user) => user.username == resUser.username,
            orElse: () => null);
        if (model != null) {
          ParticipantModel model1 = ParticipantModel(
              id: model.id,
              name: model.full_name,
              email: model.email,
              invited: 1,
              attended: 0,
              accepted: 0,
              positions: [
                Position(department: Department(name: model.position.name))
              ]);
          //listMember.remove(model1);
          if (!removeUser(data: model1, appBloc: appBloc, context: context))
            return;
        }
      });
      //updateCountUserPicked();
      countMember();
      appBloc.calendarBloc.listASGLUserStream
          .notify(appBloc.calendarBloc.listASGLUserModel);
    }
    listRes.clear();
  }

  // Hàm gọi api cancel cuộc họp
  void cancelMeeting(BuildContext context, String meetingID, AppBloc appBloc,
      String startTimeMeeting) async {
    loadingStream?.notify(true);
    int now = DateTime.now().millisecondsSinceEpoch;
    int startDateTime = new DateFormat("yyyy-MM-dd hh:mm:ss")
        .parse(startTimeMeeting)
        .millisecondsSinceEpoch;
    if (startDateTime < now) {
      loadingStream.notify(false);
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Cuộc họp đã được diễn ra bạn không thể hủy cuộc họp !");
    } else {
      AppBloc appBloc = BlocProvider.of(context);
      MeetingService meetingService = MeetingService();
      await meetingService.cancelMeeting(
          meetingID: meetingID,
          onResultData: (result) {
            loadingStream.notify(false);
            Toast.showShort("Đã hủy cuộc họp");
            appBloc.calendarBloc.getDataScheduleApi(context);
            appBloc.homeBloc
                .changeActionMeeting(state: LayoutNotBottomBarState.NONE);
            loadingStream.notify(false);
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
                    "Hủy lịch họp thất bại. Vui lòng thử lại sau");
              }
            }
          });
    }
  }
}

enum ShowChildMenuState { NONE, MANAGE_MEMBER, ADD_MEMBER }

class ShowChildMenuModel {
  ShowChildMenuState state;
  dynamic data;

  ShowChildMenuModel({@required this.state, this.data});
}

enum EditMeetingValidateState { NONE, ERROR, MATCHED }

class EditParticipantsModel {
  DateTime selectDate;
  dynamic data;

  EditParticipantsModel({this.selectDate, this.data});
}

enum ActionChangeRoomState { INIT, EDIT }
