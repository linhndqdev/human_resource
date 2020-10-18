import 'package:flutter/src/widgets/framework.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/home/meeting/action_meeting/add_member_bloc.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/utils/common/crypto_hex.dart';

class PickMemberShareBloc {
  List<ASGUserModel> listUserPicked = List();
  List<WsRoomModel> listGroupPicked = List();
  CoreStream<String> countPickedStream = CoreStream();
  CoreStream<List<WsRoomModel>> listRoomStream = CoreStream();
  CoreStream<List<ASGUserModel>> listUserPickedStream = CoreStream();
  CoreStream<FilterTabStreamModel> clickTabStream = CoreStream();
  CoreStream<bool> showInputStream = CoreStream();
  Map<ASGUserModel, bool> mapUser = Map();
  FilterMemberTabState filterTabState = FilterMemberTabState.THEO_DANH_BA;

  void changeTab(FilterMemberTabState state) async {
    filterTabState = state;
    FilterTabStreamModel model = FilterTabStreamModel(state: state);
    clickTabStream.notify(model);
  }

  void updateCountUserPicked() {
    int sizeListUser = listUserPicked.length;
    int sizeGroupPicked = listGroupPicked.length;
    String content = "";
    if (sizeGroupPicked > 0 && sizeListUser > 0) {
      content = "$sizeListUser thành viên và $sizeGroupPicked nhóm";
    } else if (sizeListUser > 0) {
      content = "$sizeListUser thành viên";
    } else if (sizeGroupPicked > 0) {
      content = "$sizeGroupPicked thành viên";
    } else {
      content = "";
    }
    countPickedStream?.notify(content);
  }

  void dispose() {
    clickTabStream?.closeStream();
    countPickedStream?.closeStream();
    listUserPickedStream?.closeStream();
    listRoomStream?.closeStream();
    showInputStream?.closeStream();
  }

  void pickedOrRemoveUser(BuildContext context, String userName) {
    AppBloc appBloc = BlocProvider.of(context);
    ASGUserModel asgUserModel = listUserPicked
        ?.firstWhere((user) => user.username == userName, orElse: () => null);
    if (asgUserModel != null) {
      listUserPicked.remove(asgUserModel);
    } else {
      ASGUserModel model = appBloc.calendarBloc.listASGLUserModel
          ?.firstWhere((user) => user.username == userName, orElse: () => null);
      if (model != null) {
        listUserPicked.add(model);
      }
    }
    updateCountUserPicked();

    appBloc.calendarBloc.listASGLUserStream
        .notify(appBloc.calendarBloc.listASGLUserModel);
    checkShowInput();
  }

  void checkShowInput() {
    if (listUserPicked.length == 0 && listGroupPicked.length == 0) {
      showInputStream.notify(false);
    } else {
      showInputStream.notify(true);
    }
  }

  void searchUser(AppBloc appBloc, String fullNameSearch) async {
    Iterable<ASGUserModel> i = appBloc.calendarBloc.listASGLUserModel?.where(
        (user) => user.full_name
            .toLowerCase()
            .contains(fullNameSearch.toLowerCase()));
    appBloc.calendarBloc.listASGLUserStream.notify(i.toList());
  }

  void searchGroup(AppBloc appBloc, String fullNameSearch) async {
    if (fullNameSearch == "" || fullNameSearch == null) {
      appBloc.mainChatBloc.listGroupStream.notify(ListGroupModel(
          state: ListGroupState.SHOW,
          listGroupModel: appBloc.mainChatBloc.listGroups));
    } else {
      Iterable<WsRoomModel> i = appBloc.mainChatBloc.listGroups?.where((user) =>
          CryptoHex.deCodeChannelName(user.name)
              .toLowerCase()
              .contains(fullNameSearch.toLowerCase()));
      appBloc.mainChatBloc.listGroupStream.notify(ListGroupModel(
          state: ListGroupState.SHOW, listGroupModel: i.toList()));
    }
  }

  List<WsRoomModel> listRoom = List();

  void setListGroup(List<WsRoomModel> listGroupModel) {
    if (listGroupModel != null && listGroupModel.length > 0) {
      listRoom?.clear();
      listRoom.addAll(listGroupModel);
    }
    listRoomStream?.notify(listRoom);
  }

  void updateListRoom() {
    listRoomStream?.notify(listRoom);
  }

  void addGroup(WsRoomModel wsRoomModel) {
    listGroupPicked?.add(wsRoomModel);
    updateListRoom();
    updateCountUserPicked();
    checkShowInput();
  }

  void removeGroup(WsRoomModel wsRoomModel) {
    listGroupPicked?.remove(wsRoomModel);
    updateListRoom();
    updateCountUserPicked();
    checkShowInput();
  }

  ///Gửi tin nhắn foward
  ///Có 2 luồng gửi tin nhắn như sau:
  /// *** 1 luồng gửi tin nhắn đến chat 1 - 1 ***
  /// *** 1 luồng gửi tin nhắn đến chat 1 - nhiều ***
  ///  2 luồng này sẽ chạy trong 2 isolate riêng biệt
  ///  2 isolate này sẽ được đưa vào home bloc để giải quyết khi màn hình chọn thành viên được tắt đi.
  void shareMessageWith(BuildContext context, String messageSend, List listMessagePicked) {
    AppBloc appBloc = BlocProvider.of(context);
    List<WsRoomModel> roomDirect = appBloc.mainChatBloc.listDirectRoom;
    appBloc.homeBloc.sendMessageForward(
        messageSend,
        listMessagePicked,
        listUserPicked,
        listGroupPicked,
        roomDirect);
  }
}
