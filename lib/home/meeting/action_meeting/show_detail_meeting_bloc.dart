import 'package:flutter/material.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/meeting/meeting_services.dart';
import 'package:human_resource/core/meeting/model/meeting_model.dart';
import 'package:human_resource/core/meeting/model/participant_model.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';

class ShowDetailMeetingBloc {
  CoreStream<MeetingModel> meetingModelStream = CoreStream();
  CoreStream<bool> requestAcceptMeetingStream = CoreStream();
  CoreStream<bool> loadingStream = CoreStream();
  CoreStream<bool> showMemberStream = CoreStream();

  MeetingModel meetingModel;

  void dispose() {
    meetingModelStream?.closeStream();
    requestAcceptMeetingStream?.closeStream();
    loadingStream?.closeStream();
    showMemberStream?.closeStream();
  }

  void renderWidgetWithData() {
    meetingModelStream.notify(meetingModel);
  }

  bool checkAfterMeetingTime(MeetingModel meetingModel) {
    DateTime dateTime = DateTime.parse(meetingModel.start_at.date);
    DateTime currentTime = DateTime.now();
    //Kiểm tra thời gian hiện tại có lớn hơn thời gian của lịch hay không
    //Nếu lớn hơn thì không cho thao tác Từ chối/ Xác nhận
    //Nếu nhỏ hơn thì cho phép thao tác Từ chối/ Xác nhận
    int isAfterMeetingStatAt = currentTime.compareTo(dateTime);
    return isAfterMeetingStatAt == 1;
  }

  ///[isAccept] = true -> Xác nhận tham dự
  ///[isAccept] = false -> Từ chối tham dự
  void acceptOrRefuseMeeting(
      BuildContext context, MeetingModel meetingModel, bool isAccept) async {
    loadingStream.notify(true);
    AppBloc appBloc = BlocProvider.of(context);
    MeetingService meetingService = MeetingService();
    await meetingService.acceptOrRefuseMeeting(
        isAccept: isAccept,
        meetingID: meetingModel.id.toString(),
        onResultData: (resultData) {
          loadingStream.notify(false);
          appBloc.calendarBloc.getDataScheduleApi(context);
          getMeetingDetail(context, meetingModel, isAccept);
          Toast.showShort(isAccept
              ? "Xác nhận tham gia cuộc họp thành công."
              : "Bạn đã từ chối tham dự cuộc họp này.");
        },
        onErrorApiCallback: (onError) {
          loadingStream.notify(false);
          if (onError is String) {
            DialogUtils.showDialogResult(
                context, DialogType.FAILED, onError.toString());
          } else if (onError is ErrorType) {
            if (onError == ErrorType.JWT_FOUND) {
              appBloc.authBloc.logOut(context);
            } else if (onError == ErrorType.CONNECTION_ERROR) {
              DialogUtils.showDialogResult(context, DialogType.FAILED,
                  "Vui lòng kiểm tra kết nối mạng của bạn và thử lại");
            } else {
              DialogUtils.showDialogResult(
                  context,
                  DialogType.FAILED,
                  isAccept
                      ? "Xác nhận tham dự cuộc họp thất bại. Vui lòng thử lại."
                      : "Từ chối tham dự cuộc họp thất bại. Vui lòng thử lại.");
            }
          }
        });
  }

  int accepted = -1;

  void getMeetingDetail(
      BuildContext context, MeetingModel meetingModel, bool isAccept) {
    loadingStream.notify(true);
    MeetingService meetingService = MeetingService();
    meetingService.getDetailMeeting(
        meetingID: meetingModel.id.toString(),
        onResultData: (result) {
          MeetingModel model = MeetingModel.fromJson(result['meeting']);
          this.meetingModel = model;
          renderWidgetWithData();
          loadingStream.notify(false);
        },
        onErrorApiCallback: (onError) {
          updateAccepted(context, meetingModel, isAccept);
          loadingStream.notify(false);
        });
  }

  void updateAccepted(
      BuildContext context, MeetingModel meetingModel, bool isAccept) {
    AppBloc appBloc = BlocProvider.of(context);
    ASGUserModel userModel = appBloc.authBloc.asgUserModel;
    meetingModel.participants?.forEach((model) {
      accepted = isAccept ? 1 : 2;
      if (userModel.id == model.id) {
        model.accepted = isAccept ? 1 : 2;
      }
    });
    this.meetingModel = meetingModel;
    renderWidgetWithData();
  }

  bool checkAccepted(BuildContext context, List<ParticipantModel> listMember) {
    AppBloc appBloc = BlocProvider.of(context);
    ASGUserModel userModel = appBloc.authBloc.asgUserModel;
    ParticipantModel participantModel = listMember
        .firstWhere((model) => model.id == userModel.id, orElse: () => null);
    if (participantModel == null) {
      return false;
    } else {
      accepted = participantModel.accepted;
      if (participantModel.accepted == 1) {
        return true;
      } else {
        return false;
      }
    }
  }

  void updateData(
      BuildContext context, MeetingModel meetingModel, bool isAccepted) {
    AppBloc appBloc = BlocProvider.of(context);
    appBloc.calendarBloc.getDataScheduleApi(context);
    getMeetingDetail(context, meetingModel, isAccepted);
  }
}
