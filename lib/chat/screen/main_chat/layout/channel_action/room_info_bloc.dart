import 'package:flutter/material.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/screen/main_chat/chat/layout_action_bloc.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/fcm/fcm_services.dart';
import 'package:human_resource/core/room_chat/room_chat_services.dart';
import 'package:human_resource/home/home_bloc.dart';
import 'package:human_resource/utils/common/crypto_hex.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';

enum NotificationState {
  LOADING,
  ENABLE,
  DISABLE,
}

class RoomInfoLayoutBloc {
  CoreStream<bool> loadingStream = CoreStream();
  List<RestUserModel> listUserGroup = List();
  CoreStream<List<RestUserModel>> listUserGroupStream = CoreStream();
  CoreStream<int> countMemberStream = CoreStream();
  CoreStream<NotificationState> notificationStream = CoreStream();
  CoreStream<bool> showAddMemberStream = CoreStream();
  List<dynamic> listRoomIdBlock;

  void dispose() {
    loadingStream?.closeStream();
    listUserGroupStream?.closeStream();
    countMemberStream?.closeStream();
    notificationStream?.closeStream();
    showAddMemberStream?.closeStream();
  }

  void kickMember( WsRoomModel roomModel,
      RestUserModel restUserModel) async {
    loadingStream.notify(true);
    ApiServices apiServices = ApiServices();
    await apiServices.kickMember(roomModel, restUserModel,
        resultData: (resultData) {
      loadingStream.notify(false);
      listUserGroup?.removeWhere((user) => user.id == restUserModel.id);
      listUserGroupStream?.notify(listUserGroup);
      Toast.showShort("Đã xóa thành viên ${restUserModel.name}");
      String roomName = CryptoHex.deCodeChannelName(roomModel.name);
      FCMServices fcmServices = FCMServices();
      fcmServices.sendFCMNormalMessageOnlyUser(
          roomModel, "Bạn đã bị xóa khỏi nhóm: $roomName", restUserModel.id);
    }, onErrorApiCallback: (onError) {
      loadingStream.notify(false);
      Toast.showShort(onError.toString());
    });
  }

  void getAllUserOnGroup({@required WsRoomModel roomModel}) async {
    loadingStream.notify(true);
    ApiServices apiServices = ApiServices();
    await apiServices.getAllUserOnGroup(roomModel, resultData: (resultData) {
      try {
        Iterable iterable = resultData['members'];
        if (iterable != null && iterable.length > 0) {
          listUserGroup = iterable
              .map((user) => RestUserModel.fromGetAllUser(user))
              .toList();
          RestUserModel userModel = listUserGroup
              ?.where((resUser) => resUser.id == roomModel.skAccountModel.id)
              ?.elementAt(0);
          if (userModel != null) {
            listUserGroup?.removeWhere(
                (resUser) => resUser.id == roomModel.skAccountModel.id);
            listUserGroup.insert(0, userModel);
          }
          countMemberStream?.notify(listUserGroup.length);
          listUserGroupStream?.notify(listUserGroup);
        }
      } catch (ex) {
        listUserGroupStream?.notify(listUserGroup);
      }
    }, onErrorApiCallback: (onError) {
      listUserGroupStream?.notify(listUserGroup);
    });
    loadingStream.notify(false);
  }

  void searchUser(String dataChange) {
    if (listUserGroup != null &&
        listUserGroup.length > 0 &&
        dataChange != null &&
        dataChange.trim().toString() != "") {
      List<RestUserModel> listData = listUserGroup
          ?.where((userModel) => userModel.name.contains(dataChange))
          ?.toList();
      if (listData == null) listData = List();
      listUserGroupStream.notify(listData);
    } else {
      listUserGroupStream.notify(listUserGroup);
    }
  }

  void refreshData() {
    listUserGroupStream.notify(listUserGroup);
  }

  void leaveRoom(BuildContext context, WsRoomModel roomModel,
      LayoutActionBloc actionBloc) {
    loadingStream.notify(true);
    AppBloc appBloc = BlocProvider.of(context);
    RoomChatServices roomChatServices = RoomChatServices();
    roomChatServices.leaveGroup(
        groupID: roomModel.id,
        onResultData: (result) {
          appBloc.mainChatBloc.removeGroup(roomModel);
          loadingStream.notify(false);
          appBloc.homeBloc.clickItemBottomBar(1);
          appBloc.homeBloc.layoutNotBottomBarStream.notify(
              LayoutNotBottomBarModel(state: LayoutNotBottomBarState.NONE));
          actionBloc.changeState(LayoutActionState.NONE);
        },
        onErrorApiCallback: (onError) {
          loadingStream.notify(false);
          DialogUtils.showDialogResult(context, DialogType.FAILED,
              "Không thể rời bỏ nhóm. Vui lòng thử lại sau.");
        });
  }

  //Tắt notification
  void turnOffNotification(String roomID) async {
    ApiServices apiServices = ApiServices();
    await apiServices.turnOffNotication(
      roomID,
      onResultData: (resultData) {
        notificationStream?.notify(NotificationState.DISABLE);
      },
      onErrorApiCallback: (onError) {
        Toast.showShort("Tắt thông báo thất bại.");
        notificationStream?.notify(NotificationState.ENABLE);
      },
    );
  }

  //Bật notification
  void turnOnNotification(String roomID) async {
    ApiServices apiServices = ApiServices();
    await apiServices.turnOnNotication(
      roomID,
      onResultData: (resultData) {
        notificationStream?.notify(NotificationState.ENABLE);
      },
      onErrorApiCallback: (onError) {
        Toast.showShort("Bật thông báo thất bại.");
        notificationStream?.notify(NotificationState.DISABLE);
      },
    );
  }

  void changeRoomNotification(
      WsRoomModel roomModel, bool isEnableNotification) async {
    notificationStream?.notify(NotificationState.LOADING);

    if (!isEnableNotification) {
      turnOffNotification(roomModel.id);
    } else {
      turnOnNotification(roomModel.id);
    }
  }

  void getStatusNotification(String roomId) async {
    ApiServices apiServices = ApiServices();
    await apiServices.getListBlock(
      onResultData: (resultData) {
        listRoomIdBlock = resultData;
        dynamic searchRoomId = listRoomIdBlock
            ?.firstWhere((id) => id?.contains(roomId), orElse: () => null);
        if (searchRoomId != null && searchRoomId != "") {
          notificationStream.notify(NotificationState.DISABLE);
        } else {
          notificationStream.notify(NotificationState.ENABLE);
        }
      },
      onErrorApiCallback: (onError) {
        notificationStream.notify(NotificationState.ENABLE);
      },
    );
  }

  void deleteGroup(BuildContext context, WsRoomModel roomModel,
      LayoutActionBloc layoutActionBloc) async {
    loadingStream.notify(true);
    AppBloc appBloc = BlocProvider.of(context);
    RoomChatServices roomChatServices = RoomChatServices();

    await roomChatServices.deleteGroup(
        groupID: roomModel.id,
        accountModel: WebSocketHelper.getInstance().wsAccountModel,
        onResultData: (result) {
          appBloc.mainChatBloc.removeGroup(roomModel);
          loadingStream.notify(false);
          appBloc.homeBloc.clickItemBottomBar(1);
          appBloc.homeBloc.layoutNotBottomBarStream.notify(
              LayoutNotBottomBarModel(state: LayoutNotBottomBarState.NONE));
          layoutActionBloc.changeState(LayoutActionState.NONE);
          Toast.showShort("Xóa nhóm thành công");
        },
        onErrorApiCallback: (error) {
          loadingStream.notify(false);
          DialogUtils.showDialogResult(context, DialogType.FAILED,
              "Không thể rời nhóm vào lúc này. Vui lòng thử lại sau");
        });
  }

  //Check quyền user
  //B1: Kiểm tra quyền user roles
  //B2: Nếu là owner thì swapowner
  //B3: Nếu không phải owner leave
  void getUserRoles(BuildContext context, WsRoomModel roomModel,
      LayoutActionBloc layoutActionBloc) async {
    loadingStream.notify(true);
    AppBloc appBloc = BlocProvider.of(context);
    RoomChatServices roomChatServices = RoomChatServices();
    await roomChatServices.getUserRoles(
        WebSocketHelper.getInstance().wsAccountModel, roomModel.id, (result) {
      if (result != null && result != "") {
        if (result['roles'] != null && result['roles'] != "") {
          Iterable i = result['roles'];
          if (i != null && i.length > 0) {
            List<UserRoles> listRoles =
                i.map((role) => UserRoles.fromJson(role)).toList();
            UserRoles userRoles = listRoles?.firstWhere(
                (role) => role.roles.elementAt(0) == "owner",
                orElse: () => null);
            if (userRoles == null) {
              leaveRoom(context, roomModel, layoutActionBloc);
            } else {
              if (listUserGroup.length > 1) {
                if (userRoles.accountModel.userName !=
                    appBloc.authBloc.asgUserModel.username) {
                  leaveRoom(context, roomModel, layoutActionBloc);
                } else {
                  swapOwner(context, roomModel, layoutActionBloc);
                }
              } else {
                deleteGroup(context, roomModel, layoutActionBloc);
              }
            }
          }
        }
      }
    }, (onError) {
      loadingStream.notify(false);
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Không thể rời nhóm vào lúc này. Vui lòng thử lại sau");
    });
  }

  //B2: SwapOwner:
  ///Nếu swap thành công thì leave room
  ///Nếu không thành công thì kiểm tra lỗi
  ///Nếu lỗi là người được swap có quyền owner thì leave room
  ///Nếu lỗi khác thì thông báo lỗi
  void swapOwner(BuildContext context, WsRoomModel roomModel,
      LayoutActionBloc layoutActionBloc) async {
    loadingStream.notify(true);
    AppBloc appBloc = BlocProvider.of(context);
    RoomChatServices roomChatServices = RoomChatServices();
    RestUserModel restUserModel = listUserGroup?.firstWhere(
        (user) =>
            user.username != appBloc.authBloc.asgUserModel.username &&
            user.username != roomModel.skAccountModel.userName,
        orElse: () => null);
    if (restUserModel != null) {
      await roomChatServices.swapOwnerGroup(
          groupID: roomModel.id,
          receivedOwnerUserID: restUserModel.id,
          accountModel: WebSocketHelper.getInstance().wsAccountModel,
          onResultData: (result) {
            leaveRoom(context, roomModel, layoutActionBloc);
          },
          onErrorApiCallback: (error) {
            loadingStream.notify(false);
            if (error is ErrorType) {
              DialogUtils.showDialogResult(context, DialogType.FAILED,
                  "Không thể rời nhóm vào lúc này. Vui lòng thử lại sau");
            } else {
              if (error.toString().contains("error-user-already-owner")) {
                leaveRoom(context, roomModel, layoutActionBloc);
              } else if (error.toString().contains("error-user-not-in-room")) {
                listUserGroup?.removeWhere(
                    (user) => user.username == restUserModel.username);
                swapOwner(context, roomModel, layoutActionBloc);
              } else {
                DialogUtils.showDialogResult(context, DialogType.FAILED,
                    "Không thể rời nhóm vào lúc này. Vui lòng thử lại sau");
              }
            }
          });
    } else {
      deleteGroup(context, roomModel, layoutActionBloc);
    }
  }
}

class UserRoles {
  String id;
  String rid;
  WsAccountModel accountModel;
  List<String> roles;

  UserRoles(this.id, this.rid, this.accountModel, this.roles);

  factory UserRoles.fromJson(Map<String, dynamic> json) {
    WsAccountModel accountModel;
    if (json['u'] != null && json['u'] != "") {
      accountModel = WsAccountModel.fromJsonRoom(json['u']);
    }
    List<String> roles = List();
    if (json['roles'] != null && json['roles'] != "") {
      Iterable i = json['roles'];
      if (i != null && i.length > 0) {
        roles = i.map((role) => role.toString()).toList();
      }
    }
    return UserRoles(json['_id'], json['rid'], accountModel, roles);
  }
}
