import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/fcm/fcm_services.dart';
import 'package:human_resource/utils/common/crypto_hex.dart';
import 'package:human_resource/utils/common/sort_by.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';

typedef OnCreateSuccess = Function(WsRoomModel);

enum GetListUserState { LOADING, NO_DATA, SHOW }

class ListUserModel {
  GetListUserState state;
  List<RestUserModel> listRestUserModel;

  ListUserModel(this.state, this.listRestUserModel);
}

class CreatePrivateChannelBloc {
  CoreStream<ListUserModel> listUserStream = CoreStream();
  CoreStream<bool> showButtonCreateStream = CoreStream();
  CoreStream<bool> updateTagsStream = CoreStream();
  CoreStream<bool> loadingStream = CoreStream();
  CoreStream<bool> enableSearchStream = CoreStream();
  CoreStream<bool> loadAllDataStream = CoreStream();

  CoreStream<FilterTabStreamModel> clickTabStream = CoreStream();

  void changeTab(FilterMemberTabState state) async {
    FilterTabStreamModel model = FilterTabStreamModel(state: state);
    clickTabStream.notify(model);
  }

  dispose() {
    listUserStream?.closeStream();
    showButtonCreateStream?.closeStream();
    updateTagsStream?.closeStream();
    loadingStream?.closeStream();
    enableSearchStream?.closeStream();
    loadAllDataStream?.closeStream();
  }

  Future createPrivateChannel(
      BuildContext context, AppBloc appBloc, String channelName,
      {@required OnCreateSuccess onCreateSuccess}) async {
    if (channelName == null || channelName.trim().toString() == "") {
      Toast.showShort("Tên phòng không được để trống");
    } else if (channelName.length <= 5) {
      Toast.showShort("Tên phòng phải có ít nhất 6 ký tự");
    } else {
      loadingStream.notify(true);
      List<String> listUserInvite = List();
      mapUserPicked.keys?.forEach((user) {
        if (mapUserPicked[user]) {
          listUserInvite.add(user.username);
        }
      });
      try {
        String nameEnCode = CryptoHex.enCodeChannelName(channelName);
        ApiServices apiServices = ApiServices();
        await apiServices.createPrivateGroup(
            channelName: nameEnCode,
            listMember: listUserInvite,
            resultData: (resultData) {
              loadingStream.notify(false);
              Toast.showShort("Tạo phòng thành công");
              WsRoomModel roomModel =
                  WsRoomModel.fromGroup(resultData['group']);
              String roomName = CryptoHex.deCodeChannelName(roomModel.name);
              FCMServices fcmServices = FCMServices();
              fcmServices.sendFCMNormalMessage(
                  roomModel, "Bạn đã được thêm vào nhóm: $roomName");
              onCreateSuccess(roomModel);
            },
            onErrorApiCallback: (onError) {
              loadingStream.notify(false);
              DialogUtils.showDialogResult(
                  context, DialogType.FAILED, onError.toString());
            });
      } catch (ex) {
        loadingStream.notify(false);
      }
    }
  }

  void checkInputData(String dataChange) {
    if (dataChange == null || dataChange.length == 0) {
      showButtonCreateStream.notify(false);
    } else {
      showButtonCreateStream.notify(true);
    }
  }

  void addUserPicked(AddressBookModel restUserModel) {
    mapUserPicked[restUserModel] = true;
    listUserPicked?.removeWhere((model) => model.id == restUserModel.id);
    listUserPicked.add(restUserModel);
    updateTagsStream.notify(true);
  }

  List<AddressBookModel> listUserPicked = List();

  void removeUserPicked(AddressBookModel restUserModel) {
    mapUserPicked[restUserModel] = false;
    listUserPicked?.removeWhere((model) => model.id == restUserModel.id);
    updateTagsStream.notify(true);
  }

  List<AddressBookModel> listAllUserOnSystem = List();
  List<AddressBookModel> listUserFromDirectRoom = List();

  Map<AddressBookModel, bool> mapUserPicked = Map();

  static Map<int, dynamic> _convertListDataToMap(Map<int, dynamic> params) {
    List<AddressBookModel> listAllUserOnSystem = List();
    List<AddressBookModel> listUserFromDirectRoom = List();
    List<AddressBookModel> listAllUser = params[0];
    List<WsRoomModel> listRoom = params[1];
    List<AddressBookModel> listUserPicked = params[2];
    Map<AddressBookModel, bool> mapUserPicked = Map();
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
        if (usName != params[3]) {
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
    listAllUser?.forEach((user) {
      mapUserPicked[user] = false;
    });
    if (listAllUser != null && listAllUser.length > 0) {
      if (listUserPicked.length > 0) {
        listUserPicked?.forEach((user) {
          mapUserPicked[user] = true;
        });
      }
    }
    Map<int, dynamic> data = {
      0: listAllUserOnSystem,
      1: listUserFromDirectRoom,
      2: mapUserPicked
    };
    return data;
  }

  Future<void> setMapData(
      List<AddressBookModel> listAllUser, List<WsRoomModel> listRoom) async {
    Map<int, dynamic> mapParams = {
      0: listAllUser,
      1: listRoom,
      2: listUserPicked,
      3: WebSocketHelper.getInstance().userName
    };
    compute(_convertListDataToMap, mapParams).then((result) {
      listAllUserOnSystem.clear();
      listAllUserOnSystem?.addAll(result[0]);
      listUserFromDirectRoom?.clear();
      listUserFromDirectRoom?.addAll(result[1]);
      mapUserPicked = result[2];
      loadAllDataStream.notify(true);
    });
  }

  void pickUser(AddressBookModel model) {
    if (mapUserPicked[model]) {
      removeUserPicked(model);
    } else {
      addUserPicked(model);
    }
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
}

enum FilterMemberTabState { LIEN_LAC_GAN_DAY, THEO_DANH_BA }

class FilterTabStreamModel {
  FilterMemberTabState state;

  FilterTabStreamModel({this.state});
}
