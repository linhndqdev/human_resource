import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';

import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/fcm/fcm_services.dart';
import 'package:human_resource/utils/common/crypto_hex.dart';
import 'package:human_resource/utils/common/toast.dart';

class KickMemberBloc {
  CoreStream<bool> loadingStream = CoreStream();
  List<RestUserModel> listUserGroup = List();
  CoreStream<List<RestUserModel>> listUserModelStream = CoreStream();
  RestUserModel userPicked;

  void dispose() {
    loadingStream?.closeStream();
    listUserModelStream?.closeStream();
  }

  Future getAllUserOnGroup(WsRoomModel roomModel) async {
    loadingStream?.notify(true);
    ApiServices apiServices = ApiServices();
    await apiServices.getAllUserOnGroup(roomModel, resultData: (resultData) {
      try {
        Iterable iterable = resultData['members'];
        if (iterable != null && iterable.length > 0) {
          listUserGroup = iterable
              .map((user) => RestUserModel.fromGetAllUser(user))
              .toList();
          RestUserModel accountModel = listUserGroup
              ?.where((resUser) => resUser.id == roomModel.skAccountModel.id)
              ?.elementAt(0);
          if (accountModel != null) {
            listUserGroup?.remove(accountModel);
            listUserGroup?.insert(0, accountModel);
          }
          listUserModelStream?.notify(listUserGroup);
        }
      } catch (ex) {
        listUserModelStream?.notify(listUserGroup);
      }
    }, onErrorApiCallback: (onError) {
      listUserModelStream?.notify(listUserGroup);
    });
    loadingStream?.notify(false);
  }

  void kickMember(WsRoomModel roomModel) async {
    loadingStream.notify(true);
    ApiServices apiServices = ApiServices();
    await apiServices.kickMember(roomModel, userPicked,
        resultData: (resultData) {
      loadingStream.notify(false);
      listUserGroup?.removeWhere((user) => user.id == userPicked.id);
      listUserModelStream?.notify(listUserGroup);
      Toast.showShort("Đã xóa thành viên ${userPicked.name}");
      String roomName = CryptoHex.deCodeChannelName(roomModel.name);
      FCMServices fcmServices = FCMServices();
      fcmServices.sendFCMNormalMessageOnlyUser(
          roomModel, "Bạn đã bị xóa khỏi nhóm: $roomName", userPicked.id);
      userPicked = null;
    }, onErrorApiCallback: (onError) {
      loadingStream.notify(false);
      Toast.showShort(onError.toString());
    });
  }

  void searchUser(String dataChange) {
    if (listUserGroup != null &&
        listUserGroup.length > 0 &&
        dataChange != null &&
        dataChange.trim().toString() != "") {
      List<RestUserModel> listSearch = listUserGroup?.where((userModel) {
        if (userModel.name.contains(dataChange) ||
            userModel.name.toLowerCase().contains(dataChange.toLowerCase()) ||
            userModel.name.toUpperCase().contains(dataChange.toUpperCase())) {
          return true;
        } else {
          return false;
        }
//        return userModel.name.contains(dataChange);
      })?.toList();
      if (listSearch == null) listSearch = List();
      listUserModelStream.notify(listSearch);
    } else {
      listUserModelStream.notify(listUserGroup);
    }
  }

  void pickUserToRemove(RestUserModel data) {
    userPicked = data;
    listUserModelStream.notify(listUserGroup);
  }
}
