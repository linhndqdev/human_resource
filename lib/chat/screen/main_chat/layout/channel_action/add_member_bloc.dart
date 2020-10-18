import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';

import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/fcm/fcm_services.dart';
import 'package:human_resource/utils/common/crypto_hex.dart';
import 'package:human_resource/utils/common/sort_by.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';

import 'create_private_channel_bloc.dart';

class AddMemberBloc {
  CoreStream<bool> showButtonCreateStream = CoreStream();
  CoreStream<bool> updateTagsStream = CoreStream();
  CoreStream<bool> loadingStream = CoreStream();
  CoreStream<bool> enableSearchStream = CoreStream();
  CoreStream<FilterTabStreamModel> clickTabStream = CoreStream();
  bool isHasRefreshData = false;

  void changeTab(FilterMemberTabState state) async {
    FilterTabStreamModel model = FilterTabStreamModel(state: state);
    clickTabStream.notify(model);
  }

  dispose() {
    showButtonCreateStream?.closeStream();
    updateTagsStream?.closeStream();
    loadingStream?.closeStream();
    enableSearchStream?.closeStream();
  }

  void checkInputData(String dataChange) {
    if (dataChange == null || dataChange.length == 0) {
      showButtonCreateStream.notify(false);
    } else {
      showButtonCreateStream.notify(true);
    }
  }

  List<AddressBookModel> listAllUserOnSystem = List();
  List<AddressBookModel> listUserFromDirectRoom = List();

  static Map<int, dynamic> _convertListDataToMap(Map<int, dynamic> params) {
    List<AddressBookModel> listAllUserOnSystem = List();
    List<AddressBookModel> listUserFromDirectRoom = List();
    List<AddressBookModel> listAllUser = params[0];
    List<WsRoomModel> listRoom = params[1];
    List<RestUserModel> listMember = params[2];
    if (listAllUser != null && listAllUser.length > 0) {
      Sort sort = Sort();
      List<AddressBookModel> results =
          sort.sortAddressBookModelByNameUTF8(listAllUser);
      if (results != null && results.length > 0) {
        listAllUserOnSystem?.addAll(results);
      } else {
        listAllUserOnSystem?.addAll(listAllUser);
      }
    }
    listRoom?.forEach((data) {
      data.listUserDirect?.forEach((usName) {
        if (usName != WebSocketHelper.getInstance().userName) {
          AddressBookModel model;
          if (listAllUser != null && listAllUser.length > 0) {
            model = listAllUser?.firstWhere((user) => user.username == usName,
                orElse: () => null);
          }
          if (model != null) {
            listUserFromDirectRoom.add(model);
          }
        }
      });
    });
    listMember?.forEach((data) {
      listAllUserOnSystem?.removeWhere((user) => user.id == data.id);
      listUserFromDirectRoom?.removeWhere((user) => user.id == data.id);
    });
    Map<int, dynamic> data = {
      0: listAllUserOnSystem,
      1: listUserFromDirectRoom,
    };
    return data;
  }

  Future<void> setMapData(
      BuildContext context,
      WsRoomModel roomModel,
      List<AddressBookModel> listAllUser,
      List<WsRoomModel> listRoom,
      List<RestUserModel> listMember) async {
    loadingStream.notify(true);
    Map<int, dynamic> mapParams = {0: listAllUser, 1: listRoom, 2: listMember};
    compute(_convertListDataToMap, mapParams).then((result) {
      listAllUserOnSystem.clear();
      listAllUserOnSystem?.addAll(result[0]);
      listUserFromDirectRoom?.clear();
      listUserFromDirectRoom?.addAll(result[1]);
      updateTagsStream.notify(true);
      loadingStream.notify(false);
    });
  }

  bool isEnableSearch = false;

  void searchUser(String dataChange) {
    if (dataChange != null && dataChange.toString().trim() != "") {
      enableSearchStream?.notify(true);
    } else {
      enableSearchStream.notify(false);
    }
  }

  Map<AddressBookModel, bool> mapUserDirectRoom = Map();
  AddressBookModel userPicked;

  void addUserToGroup(BuildContext context, WsRoomModel roomModel) async {
    if (userPicked == null) {
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Bạn chưa chọn thành viên nào để thêm vào nhóm");
    } else if (!WebSocketHelper.getInstance().isConnected) {
      DialogUtils.showDialogResult(
          context, DialogType.FAILED, ErrorModel.netError);
    } else {
      loadingStream.notify(true);
      WsAccountModel wsAccountModel =
          WebSocketHelper.getInstance().wsAccountModel;
      ApiServices apiServices = ApiServices();
      await apiServices.addMemberToGroup(roomModel, wsAccountModel, userPicked,
          onResultData: (resultData) {
        isHasRefreshData = true;
        listAllUserOnSystem
            .removeWhere((user) => user.username == userPicked.username);
        listUserFromDirectRoom
            .removeWhere((user) => user.username == userPicked.username);
        String roomName = CryptoHex.deCodeChannelName(roomModel.name);
        updateTagsStream?.notify(true);
        FCMServices fcmServices = FCMServices();
        fcmServices.sendFCMNormalMessageOnlyUser(
            roomModel, "Bạn đã được thêm vào nhóm: $roomName", userPicked.id);
        userPicked = null;
        DialogUtils.showDialogResult(
            context, DialogType.SUCCESS, "Thêm thành viên vào nhóm thành công");
      }, onErrorApiCallback: (onError) {
        DialogUtils.showDialogResult(context, DialogType.FAILED,
            "Đã xảy ra lỗi khi thêm một số thành viên. Vui lòng thử lại");
      });
      loadingStream.notify(false);
    }
  }

  void pickUser(AddressBookModel model) {
    if (userPicked == null) {
      userPicked = model;
      updateTagsStream.notify(true);
    } else if (userPicked != null && userPicked.username != model.username) {
      userPicked = model;
      updateTagsStream.notify(true);
    }
  }
}
