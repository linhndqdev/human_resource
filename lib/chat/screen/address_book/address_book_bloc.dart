import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/hive/hive_helper.dart';
import 'package:human_resource/core/meeting/meeting_services.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/common/sort_by.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/home/home_bloc.dart';

enum AddressState {
  NONE,
  SHOW,
  ADDRESS,
  NO_DATA,
  NO_DATA_SEARCH,
  SHOW_DATA_SEARCH
}


class AddressBookBloc {
  CoreStream<AddressModel> addressBookStream = CoreStream();
  CoreStream<bool> loadingStream = CoreStream();
  Map<String, List<ASGUserModel>> mapUserASG = Map();
  CoreStream<List<ASGUserModel>> listASGUserStream = CoreStream();
  CoreStream<List<ASGUserModel>> memberProfileStream = CoreStream();
  List<ASGUserModel> listASGLUserModel = List();

  //Đóng Bloc
  close() {
    addressBookStream?.closeStream();
    listASGUserStream?.closeStream();
    loadingStream?.closeStream();
    memberProfileStream.closeStream();
  }


  void filterSearchResults(String query) {
    if (query?.trim() != "") {
      List<ASGUserModel> listAccountResult = listASGLUserModel.where((account) {
        if (account.full_name.contains(query) ||
            account.full_name.toLowerCase().contains(query.toLowerCase()) ||
            account.full_name.toUpperCase().contains(query.toUpperCase())) {
          return true;
        } else {
          return false;
        }
//        return account.name.contains(query);
      }).toList();
      if (listAccountResult != null && listAccountResult.length > 0) {
        AddressModel model = AddressModel(AddressState.SHOW_DATA_SEARCH, null,
            listSearchResult: listAccountResult);
        addressBookStream.notify(model);
      } else {
        AddressModel model = AddressModel(AddressState.NO_DATA_SEARCH, null);
        addressBookStream.notify(model);
      }
    } else {
      backToDefaultAddressBook();
    }
  }

  void backToDefaultAddressBook(){
    AddressModel model = AddressModel(AddressState.SHOW, mapUserASG.keys.toList());
    addressBookStream.notify(model);
  }

  List<ASGUserModel> getDataASGUSerModel(String key) {
    return mapUserASG[key];
  }

  static Map<String, List<ASGUserModel>> _convertUsersData(
      Map<int, dynamic> params) {
    List<ASGUserModel> _list = params[1];

    Map<String, List<ASGUserModel>> map = Map();
    Map<String, List<ASGUserModel>> mapUserASG = Map();
    Sort sort = Sort();
    for (ASGUserModel model in _list) {
      String name = model?.full_name?.trim();
      List<String> arrName = name.split(" ");
      String endOfName =
          arrName[arrName.length - 1].substring(0, 1).toUpperCase();
      // print(endOfName.codeUnitAt(0));
      //Sort sort = Sort();
      endOfName = sort.getEndOfName(endOfName.toLowerCase()).toUpperCase();
      // print(endOfName.codeUnitAt(0));
      if (65 <= endOfName.codeUnitAt(0) && endOfName.codeUnitAt(0) <= 90) {
        if (mapUserASG.containsKey(endOfName)) {
          mapUserASG[endOfName].add(model);
        } else {
          List<ASGUserModel> listAddress = List();
          listAddress.add(model);
          mapUserASG[endOfName] = listAddress;
        }
      } else {
        if (mapUserASG.containsKey("#")) {
          mapUserASG['#'].add(model);
        } else {
          List<ASGUserModel> listData = List();
          listData.add(model);
          mapUserASG['#'] = listData;
        }
      }
    }
    List<String> listKey = mapUserASG?.keys?.toList();
    if (listKey != null && listKey.length > 0) {
      listKey?.sort((key1, key2) => key1.compareTo(key2));
      listKey?.forEach((key) {
        //Sort sort = Sort();
        List<ASGUserModel> listData =
            sort.sortASGUserModelByNameUTF8(mapUserASG[key]);
        mapUserASG[key] = listData;
      });
    }

//    String key = listKey?.firstWhere((key) => key == "#", orElse: () => null);
//    if (key != null) {
//      listKey.remove("#");
//      listKey.insert(0, "#");

    listKey?.forEach((key) {
      map[key] = mapUserASG[key];
    });
//    }
    return map;
  }

  ///Trả về danh sách toàn bộ user trong hệ thống
  Future getAllUserASGL(BuildContext context) async {
    listASGLUserModel = HiveHelper.getListContact();
    AppBloc appBloc = BlocProvider.of(context);
    ASGUserModel currentUser = appBloc.authBloc.asgUserModel;
    if (listASGLUserModel != null && listASGLUserModel.length > 0) {
      listASGLUserModel
          ?.removeWhere((model) => model.username == currentUser.username);
      Map<int, dynamic> params = {0: currentUser, 1: listASGLUserModel};

      mapUserASG = await compute(_convertUsersData, params);
      if (mapUserASG.keys != null && mapUserASG.keys.length > 0) {
        addressBookStream
            .notify(AddressModel(AddressState.SHOW, mapUserASG.keys.toList()));
      } else {
        addressBookStream.notify(
            AddressModel(AddressState.NO_DATA, mapUserASG.keys.toList()));
      }
    }
    reloadData(context);
  }

  Future<void> reloadData(BuildContext context) async {
    AppBloc appBloc = BlocProvider.of(context);
    ASGUserModel currentUser = appBloc.authBloc.asgUserModel;
    MeetingService meetingService = MeetingService();
    meetingService.getAllMember(onResultData: (resultData) async {
      if (resultData['users'] != null && resultData['users'] != "") {
        Iterable i = resultData['users'];
        if (i != null && i.length > 0) {
          listASGLUserModel =
              i.map((model) => ASGUserModel.fromJson(model)).toList();
          if (listASGLUserModel != null && listASGLUserModel.length > 0) {
            HiveHelper.saveListContact(listASGLUserModel);
          }
          listASGLUserModel
              ?.removeWhere((model) => model.username == currentUser.username);
        }
      }
      Map<int, dynamic> params = {0: currentUser, 1: listASGLUserModel};
      mapUserASG = await compute(_convertUsersData, params);
      if (mapUserASG.keys != null && mapUserASG.keys.length > 0) {
        addressBookStream
            .notify(AddressModel(AddressState.SHOW, mapUserASG.keys.toList()));
      } else {
        addressBookStream.notify(
            AddressModel(AddressState.NO_DATA, mapUserASG.keys.toList()));
      }
    }, onErrorApiCallback: (onError) async {
      if (onError == ErrorType.JWT_FOUND) {
        appBloc.authBloc.logOut(context);
      } else {
        if (mapUserASG.keys == null || mapUserASG.keys.length == 0) {
          AddressModel addressModel = AddressModel(AddressState.NO_DATA, null);
          addressBookStream.notify(addressModel);
        } else {
          AddressModel addressModel =
              AddressModel(AddressState.SHOW, mapUserASG.keys.toList());
          addressBookStream.notify(addressModel);
        }
      }
    });
  }

  void openChatLayout(BuildContext context, AddressBookBloc addressBookBloc,
      ASGUserModel model) async {
    addressBookBloc.loadingStream.notify(true);
    AppBloc appBloc = BlocProvider.of(context);
    WsRoomModel roomDirect;
    appBloc?.mainChatBloc?.listDirectRoom?.forEach((wsRoomModel) {
      if (wsRoomModel.listUserDirect != null &&
          wsRoomModel.listUserDirect.length > 0) {
        wsRoomModel.listUserDirect?.forEach((userName) {
          if (userName == model.username) {
            roomDirect = wsRoomModel;
          }
        });
      }
    });
    if (roomDirect != null) {
      addressBookBloc.loadingStream.notify(false);
      appBloc.homeBloc.layoutNotBottomBarStream
          .notify(LayoutNotBottomBarModel(state: LayoutNotBottomBarState.NONE));
      appBloc.mainChatBloc.listTabStream
          .notify(ListTabModel(tab: ListTabState.NHAN_TIN));
      appBloc.homeBloc
          .clickItemBottomBar(1, listTabState: ListTabState.NHAN_TIN);
      appBloc.mainChatBloc.openRoom(appBloc, roomDirect);
    } else {
      ApiServices apiServices = ApiServices();
      await apiServices.createDirectRoom(model.username,
          onResultData: (resultData) {
        WsRoomModel roomModel =
            WsRoomModel.fromDirectRoomJson(resultData['room']);
        if (roomModel != null) {
          addressBookBloc.loadingStream.notify(false);

          appBloc.mainChatBloc.listDirectRoom.insert(0, roomModel);
          appBloc.mainChatBloc.updateListDirectRoom(ListGroupState.SHOW);
          appBloc.mainChatBloc.listTabStream
              .notify(ListTabModel(tab: ListTabState.NHAN_TIN));
          appBloc.homeBloc
              .clickItemBottomBar(1, listTabState: ListTabState.NHAN_TIN);
          appBloc.mainChatBloc.openRoom(appBloc, roomModel);
        } else {
          addressBookBloc.loadingStream.notify(false);
          DialogUtils.showDialogResult(context, DialogType.FAILED,
              "Không thể tạo cuộc hội thoại. Vui lòng thử lại");
        }
      }, onErrorApiCallback: (onError) {
        addressBookBloc.loadingStream.notify(false);
        DialogUtils.showDialogResult(context, DialogType.FAILED,
            "Không thể tạo cuộc hội thoại. Vui lòng thử lại");
      });
    }
  }

  void checkAndReloadData() {
    if (mapUserASG != null &&
        mapUserASG.keys != null &&
        mapUserASG.keys.length > 0) {
      addressBookStream
          .notify(AddressModel(AddressState.SHOW, mapUserASG.keys.toList()));
    } else {
      addressBookStream
          .notify(AddressModel(AddressState.NO_DATA, mapUserASG.keys.toList()));
    }
  }
}

class AddressModel {
  AddressState addressState;
  List<String> listKey;
  List<ASGUserModel> listSearchResult;

  AddressModel(this.addressState, this.listKey, {this.listSearchResult});
}

