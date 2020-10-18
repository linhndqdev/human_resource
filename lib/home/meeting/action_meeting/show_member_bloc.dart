import 'package:flutter/cupertino.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/meeting/meeting_services.dart';
import 'package:human_resource/core/meeting/model/meeting_model.dart';
import 'package:human_resource/core/meeting/model/participant_model.dart';
import 'package:human_resource/home/meeting/action_meeting/show_member_meeting.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';

class ShowMemberBloc {

  CoreStream<bool> showMemberStream = CoreStream();
  CoreStream<bool> loadingStream = CoreStream();
  CoreStream<MeetingModel> meetingModelStream = CoreStream();
  MeetingModel meetingModel;

  void dispose() {
    showMemberStream?.closeStream();
    loadingStream?.closeStream();
    meetingModelStream?.closeStream();
  }

  int stateAccepted;

  void checkAcceptedMeeting(BuildContext context) {
    AppBloc appBloc = BlocProvider.of(context);
    ASGUserModel currentUser = appBloc.authBloc.asgUserModel;
    ParticipantModel model = meetingModel?.participants
        ?.firstWhere((user) => user?.id == currentUser?.id, orElse: () => null);
    if (model != null) {
      stateAccepted = model.accepted;
    }
  }

  void renderWidgetWithData() {
    meetingModelStream.notify(meetingModel);
  }

  void updateAccepted(
      BuildContext context, MeetingModel meetingModel, bool isAccept) {
    AppBloc appBloc = BlocProvider.of(context);
    ASGUserModel userModel = appBloc.authBloc.asgUserModel;
    meetingModel.participants?.forEach((model) {
      stateAccepted = isAccept ? 1 : 2;
      if (userModel.id == model.id) {
        model.accepted = isAccept ? 1 : 2;
      }
    });
    this.meetingModel = meetingModel;
    renderWidgetWithData();
  }

  void acceptOrRefuseMeeting(BuildContext context, OnReloadData onReloadData,
      MeetingModel meetingModel, bool isAccept) async {
    loadingStream.notify(true);
    AppBloc appBloc = BlocProvider.of(context);
    MeetingService meetingService = MeetingService();
    await meetingService.acceptOrRefuseMeeting(
        isAccept: isAccept,
        meetingID: meetingModel.id.toString(),
        onResultData: (resultData) {
          onReloadData(isAccept);
          updateAccepted(context, meetingModel, isAccept);
          loadingStream.notify(false);
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

  bool checkAfterMeetingTime() {
    DateTime dateTime = DateTime.parse(meetingModel.start_at.date);
    DateTime currentTime = DateTime.now();
    //Kiểm tra thời gian hiện tại có lớn hơn thời gian của lịch hay không
    //Nếu lớn hơn thì không cho thao tác Từ chối/ Xác nhận
    //Nếu nhỏ hơn thì cho phép thao tác Từ chối/ Xác nhận
    int isAfterMeetingStatAt = currentTime.compareTo(dateTime);
    return isAfterMeetingStatAt == 1;
  }
}
