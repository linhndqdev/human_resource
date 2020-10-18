import 'package:flutter/material.dart';
import 'package:human_resource/chat/screen/main_chat/chat/layout_action_bloc.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/meeting/meeting_services.dart';

import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/common/toast.dart';

enum MemeberProfileState { LOADDING, SUCCESS, ERROR }

enum MemberNotificationState { SUCCESS, ERROR, NONE }

class MemberProfileBloc {
  List<dynamic> listRoomIdBlock;
  CoreStream<MemberProfileModel> memberProfileStream = CoreStream();
  CoreStream<MemberNotificationModel> memberNotificationStream = CoreStream();

  void openChatLayout(BuildContext context, String userNameInfo,
      LayoutActionBloc layoutActionBloc) async {
    AppBloc appBloc = BlocProvider.of(context);
    WsRoomModel roomDirect;
    appBloc?.mainChatBloc?.listDirectRoom?.forEach((wsRoomModel) {
      if (wsRoomModel.listUserDirect != null &&
          wsRoomModel.listUserDirect.length > 0) {
        wsRoomModel.listUserDirect?.forEach((userName) {
          if (userName == userNameInfo) {
            roomDirect = wsRoomModel;
          }
        });
      }
    });
    if (roomDirect != null) {
      if (layoutActionBloc == null) {
        appBloc.homeBloc.clickItemBottomBar(1);
      }
      appBloc.mainChatBloc.openRoom(appBloc, roomDirect);
      appBloc.mainChatBloc.chatBloc.resetData(context, roomDirect);
      if (layoutActionBloc != null) {
        Future.delayed(Duration(milliseconds: 100), () {
          layoutActionBloc.changeState(LayoutActionState.NONE);
        });
      }
    } else {
      ApiServices apiServices = ApiServices();
      await apiServices.createDirectRoom(userNameInfo,
          onResultData: (resultData) {
        WsRoomModel roomModel =
            WsRoomModel.fromDirectRoomJson(resultData['room']);
        if (roomModel != null) {
          if (layoutActionBloc == null) {
            appBloc.homeBloc.clickItemBottomBar(1);
          }
          appBloc.mainChatBloc.listDirectRoom.insert(0, roomModel);
          appBloc.mainChatBloc.updateListDirectRoom(ListGroupState.SHOW);
          appBloc.mainChatBloc.openRoom(appBloc, roomModel);
          appBloc.mainChatBloc.chatBloc.resetData(context, roomModel);
          if (layoutActionBloc != null) {
            Future.delayed(Duration(milliseconds: 100), () {
              layoutActionBloc.changeState(LayoutActionState.NONE);
            });
          }
        } else {
          DialogUtils.showDialogResult(context, DialogType.FAILED,
              "Không thể tạo cuộc hội thoại. Vui lòng thử lại");
        }
      }, onErrorApiCallback: (onError) {
        DialogUtils.showDialogResult(context, DialogType.FAILED,
            "Không thể tạo cuộc hội thoại. Vui lòng thử lại");
      });
    }
  }

  Future<void> getUserInfo(dataShow) async {
    MeetingService meetingService = MeetingService();
    await meetingService.getMemberInfo(
        onResultData: (result) {
          ASGUserModel userModel =
              ASGUserModel.fromJson(result['data']["users"][0]);
          memberProfileStream.notify(
              MemberProfileModel(MemeberProfileState.SUCCESS, userModel));
        },
        onErrorApiCallback: (onError) {
          memberProfileStream
              .notify(MemberProfileModel(MemeberProfileState.ERROR, null));
        },
        userName: dataShow.toString());
  }

  void getStatusNotification(String roomId) async {
    ApiServices apiServices = ApiServices();
    await apiServices.getListBlock(
      onResultData: (resultData) {
        listRoomIdBlock = resultData;
        dynamic searchRoomId = listRoomIdBlock
            ?.firstWhere((id) => id?.contains(roomId), orElse: () => null);
        if (searchRoomId != null) {
          MemberNotificationModel model =
              MemberNotificationModel(MemberNotificationState.ERROR, roomId);
          memberNotificationStream.notify(model);
        } else {
          MemberNotificationModel model =
              MemberNotificationModel(MemberNotificationState.SUCCESS, roomId);
          memberNotificationStream.notify(model);
        }
      },
      onErrorApiCallback: (onError) {
        Toast.showShort(onError.toString());
      },
    );
  }

  void turnOffNotification(String roomID) async {
    ApiServices apiServices = ApiServices();
    await apiServices.turnOffNotication(
      roomID,
      onResultData: (resultData) {
        MemberNotificationModel model =
            MemberNotificationModel(MemberNotificationState.ERROR, roomID);
        memberNotificationStream.notify(model);
      },
      onErrorApiCallback: (onError) {
        Toast.showShort("Tắt thông báo thất bại.");
      },
    );
  }

  void turnOnNotification(String roomID) async {
    ApiServices apiServices = ApiServices();
    await apiServices.turnOnNotication(
      roomID,
      onResultData: (resultData) {
        MemberNotificationModel model =
            MemberNotificationModel(MemberNotificationState.SUCCESS, roomID);
        memberNotificationStream.notify(model);
      },
      onErrorApiCallback: (onError) {
        Toast.showShort(onError.toString());
      },
    );
  }

  void getData(BuildContext context, Map<String, dynamic> dataShow,
      {bool isGetUserInfo = false}) async {
    if (isGetUserInfo) {
      memberProfileStream
          ?.notify(MemberProfileModel(MemeberProfileState.LOADDING, null));
      await getUserInfo(
        dataShow['user'].username,
      );
    }
    if (dataShow['roomId'] != null && dataShow['roomId'] != "") {
      getStatusNotification(dataShow['roomId']);
    }
  }
}

class MemberProfileModel {
  MemeberProfileState memberProfileState;
  dynamic data;

  MemberProfileModel(this.memberProfileState, this.data);
}

class MemberNotificationModel {
  MemberNotificationState memberNotificationState;
  dynamic data;

  MemberNotificationModel(this.memberNotificationState, this.data);
}
