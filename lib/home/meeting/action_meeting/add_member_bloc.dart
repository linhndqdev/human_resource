import 'package:flutter/src/widgets/framework.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/utils/common/crypto_hex.dart';

class AddMemberMeetingBloc {
  List<ASGUserModel> listUserPicked = List();
  CoreStream<int> countPickedStream = CoreStream();
  CoreStream<List<ASGUserModel>> listUserPickedStream = CoreStream();
  CoreStream<FilterTabStreamModel> clickTabStream = CoreStream();
  Map<ASGUserModel, bool> mapUser = Map();

  void changeTab(FilterMemberTabState state) async {
    FilterTabStreamModel model = FilterTabStreamModel(state: state);
    clickTabStream.notify(model);
  }

  void updateCountUserPicked() {
    countPickedStream?.notify(listUserPicked.length);
  }

  void dispose() {
    clickTabStream?.closeStream();
    countPickedStream?.closeStream();
    listUserPickedStream?.closeStream();
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
        listChuaKiemTraTrung.add(model);
      }
    }
    updateCountUserPicked();

    appBloc.calendarBloc.listASGLUserStream
        .notify(appBloc.calendarBloc.listASGLUserModel);
  }

  List<RestUserModel> listRes = List();
  List<ASGUserModel> listChuaKiemTraTrung = List();

  void pickedMember(
      AppBloc appBloc, List<RestUserModel> listGroupMember) async {
    List<RestUserModel> data = List();
    data.addAll(listGroupMember);
    String userName = appBloc.authBloc.asgUserModel.username;
    data?.removeWhere((user) => user?.username == userName);
    data?.removeWhere((user) => user?.username == "asglchat");

    data?.forEach((user) {
      ASGUserModel restUserModel = appBloc.calendarBloc.listASGLUserModel
          ?.firstWhere((userPick) => userPick.username == user.username,
              orElse: () => null);
      if (restUserModel != null) {
        listUserPicked?.remove(restUserModel);
        listUserPicked.add(restUserModel);
        listChuaKiemTraTrung.add(restUserModel);
      }
    });
    updateCountUserPicked();
    appBloc.calendarBloc.listASGLUserStream
        .notify(appBloc.calendarBloc.listASGLUserModel);
  }

  void removeMember(AppBloc appBloc, List<RestUserModel> listGroupMember) {
    listRes.clear();
    listRes.addAll(listGroupMember);
    String userName = appBloc.authBloc.asgUserModel.username;
    listRes?.removeWhere((user) => user.username == userName);
    listRes?.removeWhere((user) => user.username == "asglchat");
    if (listGroupMember.length < 1) {
      return;
    } else {
      listRes?.forEach((resUser) {
        ASGUserModel asgUserModel = appBloc.calendarBloc.listASGLUserModel
            ?.firstWhere((user) => user.username == resUser.username,
            orElse: () => null);
        if (asgUserModel != null) {
          listUserPicked.remove(asgUserModel);
          listChuaKiemTraTrung.remove(asgUserModel);
          if(listChuaKiemTraTrung.contains(asgUserModel)){
            listUserPicked.add(asgUserModel);
          }
        }
      });
      updateCountUserPicked();
      appBloc.calendarBloc.listASGLUserStream
          .notify(appBloc.calendarBloc.listASGLUserModel);
    }
    listRes.clear();
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
          CryptoHex.deCodeChannelName(user.name).toLowerCase().contains(fullNameSearch.toLowerCase()));
      appBloc.mainChatBloc.listGroupStream.notify(
          ListGroupModel(state: ListGroupState.SHOW, listGroupModel: i.toList()));
    }
  }


}

enum FilterMemberTabState { THEO_DANH_BA, THEO_NHOM }

class FilterTabStreamModel {
  FilterMemberTabState state;

  FilterTabStreamModel({this.state});
}
