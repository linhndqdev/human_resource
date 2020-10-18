import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/websocket/ws_action.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_typing_model.dart';
import 'package:human_resource/core/api_respository.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/hive/hive_helper.dart';
import 'package:human_resource/core/message/message_services.dart';
import 'package:human_resource/home/home_bloc.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/common/cache_helper.dart';
import 'package:human_resource/utils/common/const.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'chat/chat_bloc.dart';
import 'package:human_resource/chat/screen/main_chat/layout/channel_action/room_info_bloc.dart';

class MainChatBloc {
  CoreStream<MainChatLayoutModel> otherLayoutStream = CoreStream();

  CoreStream<ListGroupModel> listGroupStream = CoreStream();
  CoreStream<ListGroupModel> listDirectStream = CoreStream();
  CoreStream<bool> showLayoutActionStream = CoreStream();

  List<AddressBookModel> listUserOnChatSystem = List();

  CoreStream<WsMessage> lastMessageStream = CoreStream();
  CoreStream<WsRoomModel> updateRoomStream = CoreStream();

  CoreStream<UserStatusModel> userStatusStream = CoreStream();
  CoreStream<int> countUnreadDirectStream = CoreStream();
  CoreStream<int> countUnreadPrivateStream = CoreStream();
  CoreStream<int> countUnreadSumDirectAndPrivateStream = CoreStream();

  CoreStream<AddrebookButtonModel> addressBookButtonStream = CoreStream();
  CoreStream<ListTabModel> listTabStream = CoreStream();
  ChatBloc chatBloc = ChatBloc();
  CoreStream<List<AddressBookModel>> listUserOnlineStream = CoreStream();
  List<AddressBookModel> listUserOnLine = List();
  CoreStream<WsMessage> lastMessageWhenNullStream = CoreStream();
  CoreStream<LoadMoreTextModel> loadMoreTextStream = CoreStream();

  ///Danh sách cái phòng tin nhắn riêng
  List<WsRoomModel> listDirectRoom = List();

  ///Danh sách các phòng tin nhắn nhóm
  List<WsRoomModel> listGroups = List();
  List<WsMessage> listLastMessage = List();
  BuildContext context;

  var homeSearchStream = StreamController<MainChatSearchModel>.broadcast();

  Stream<MainChatSearchModel> get homeSearchTransfer => homeSearchStream.stream;
  bool isReloadDataChat = false;
  String roomIDNeedOpen;
  bool isGettingAllUser = false;

  bool isRunning = false;
  CoreStream<bool> loadingStream = CoreStream();
  List<RestUserModel> listUserGroup = List();
  List<dynamic> dataListmember = List();
  CoreStream<List<RestUserModel>> listUserGroupStream = CoreStream();
  CoreStream<int> countMemberStream = CoreStream();
  CoreStream<NotificationState> notificationStream = CoreStream();
  CoreStream<bool> showAddMemberStream = CoreStream();
  bool isContentLoadMore = true;

  void dispose() {
    lastMessageWhenNullStream?.closeStream();
    listTabStream?.closeStream();
    otherLayoutStream?.closeStream();
    listGroupStream?.closeStream();
    userStatusStream?.closeStream();
    homeSearchStream?.close();
    showLayoutActionStream?.closeStream();
    _timer?.cancel();
    _timer = null;
  }

  void checkUserOnline(BuildContext context) async {
    if (_timer == null || !_timer.isActive) {
      _checkUserOnLine();
    }
  }

  Timer _timer;

  void _checkUserOnLine() async {
    List<AddressBookModel> listUserOnSystem = List();
    _timer?.cancel();
    _timer = null;
    _timer = Timer.periodic(new Duration(minutes: 1), (Timer t) {
      ApiServices apiServices = ApiServices();
      apiServices.getAllUserNotOfLine(
          accountModel: WebSocketHelper.getInstance().wsAccountModel,
          onResultData: (resultData) {
            Iterable i = resultData;
            if (i != null && i.length > 0) {
              listUserOnSystem = i
                  .map((account) =>
                      AddressBookModel.fromGetAllAddressBookInfo(account))
                  .toList();
              listUserOnSystem
                  ?.removeWhere((model) => model.name.contains("Rocket.Cat"));
              listUserOnSystem
                  ?.removeWhere((model) => model.name.contains("ASGL ID"));
              listUserOnSystem?.removeWhere((model) => model.id
                  .contains(WebSocketHelper.getInstance().wsAccountModel.id));
              listUserOnSystem?.sort((o1, o2) => o1.name.compareTo(o2.name));
              updateListUserOnLine(listUserOnSystem);
            }
          },
          onErrorApiCallback: (resultData) {});
    });
  }

  void updateStatusUser(UserStatusModel userStatusModel) {
    bool isChanged = false;
    listUserOnLine?.forEach((user) {
      if (user.username == userStatusModel.userName) {
        isChanged = true;
        if (userStatusModel.state == UserStatusState.OFFLINE) {
          user.status = "offline";
        } else {
          user.status = "online";
        }
      }
    });
    if (!isChanged) {
      AddressBookModel addressBookModel = listUserOnChatSystem?.firstWhere(
          (user) => user.username == userStatusModel.userName,
          orElse: () => null);
      if (addressBookModel != null) {
        isChanged = true;
        addressBookModel.status =
            userStatusModel?.state == UserStatusState.OFFLINE
                ? "offline"
                : "online";
        listUserOnLine?.add(addressBookModel);
      }
    }
    if (isChanged) {
      listUserOnlineStream?.notify(listUserOnLine);
    }
  }

  //Cập nhật thông tin userOnline
  Future<void> updateListUserOnLine(List<AddressBookModel> listModel) async {
    if (listModel != null && listModel.length > 0) {
      listUserOnLine.clear();
      listUserOnLine.addAll(listModel);
      listUserOnLine.removeWhere((r) => r.status == "offline");
    }
    if (listUserOnLine.length == 0) {
      listUserOnlineStream.notify(List());
    } else {
      listUserOnlineStream.notify(listUserOnLine);
    }
  }

  void changeStatusInSearch(String query) {
    if (query == "") {
      updateSearchStatus(MainChatSearchModel(HomeSearchState.SHOW, null));
    } else {
      List<WsRoomModel> listTotal = new List<WsRoomModel>();
      listTotal.addAll(listGroups);
      List<WsRoomModel> test = listTotal.where((roomModel) {
        if (roomModel.name.contains(query) ||
            roomModel.name.toLowerCase().contains(query.toLowerCase()) ||
            roomModel.name.toUpperCase().contains(query.toUpperCase())) {
          return true;
        } else {
          return false;
        }
      }).toList();
      List<AddressBookModel> listUser = listUserOnChatSystem?.where((model) {
        if (model.name.contains(query) ||
            model.name.toLowerCase().contains(query.toLowerCase()) ||
            model.name.toUpperCase().contains(query.toUpperCase())) {
          return true;
        } else {
          return false;
        }
      })?.toList();
      List<dynamic> listSearchResult = List();
      listSearchResult.addAll(test);
      listSearchResult.addAll(listUser);
      updateSearchStatus(
          MainChatSearchModel(HomeSearchState.SEARCH, listSearchResult));
    }
  }

  void updateSearchStatus(MainChatSearchModel homeSearchModel) {
    if (homeSearchStream != null && !homeSearchStream.isClosed) {
      homeSearchStream.sink.add(homeSearchModel);
    }
  }

  void openRoom(AppBloc appBloc, WsRoomModel data) {
    LayoutNotBottomBarModel model = LayoutNotBottomBarModel(
        state: LayoutNotBottomBarState.CHAT_LAYOUT_STATE, data: data);
    appBloc.homeBloc.layoutNotBottomBarStream?.notify(model);
  }

  void backLayout(AppBloc appBloc, WsRoomModel roomModel) {
    chatBloc.isOpenned = false;
    appBloc.homeBloc.changeIndexStackHome(1, null,
        listTabState: roomModel.roomType == RoomType.d
            ? ListTabState.NHAN_TIN
            : ListTabState.NHOM);
    appBloc.mainChatBloc.listTabStream.notify(ListTabModel(
        tab: roomModel.roomType == RoomType.d
            ? ListTabState.NHAN_TIN
            : ListTabState.NHOM));
    appBloc.homeBloc.layoutNotBottomBarStream
        .notify(LayoutNotBottomBarModel(state: LayoutNotBottomBarState.NONE));
  }

  //Cập nhật danh sách private room
  void updateListDirectRoom(ListGroupState state) {
    listDirectRoom?.sort((o1, o2) {
      if (o1.lastMessage == null || o2.lastMessage == null) {
        DateTime time1 = DateTime.fromMillisecondsSinceEpoch(o1.updatedAt);
        DateTime time2 = DateTime.fromMillisecondsSinceEpoch(o2.updatedAt);
        return time2.compareTo(time1);
      } else {
        int ts1;
        int ts2;
        if (o1.lastMessage.ts == null) {
          ts1 = o1.updatedAt;
        } else {
          ts1 = o1.lastMessage.ts;
        }
        if (o2.lastMessage.ts == null) {
          ts2 = o2.updatedAt;
        } else {
          ts2 = o2.lastMessage.ts;
        }
        DateTime time1 = DateTime.fromMillisecondsSinceEpoch(ts1);
        DateTime time2 = DateTime.fromMillisecondsSinceEpoch(ts2);
        return time2.compareTo(time1);
      }
    });
    HiveHelper.saveAllDirectRoom(listDirectRoom);
    ListGroupModel listGroupModel =
        ListGroupModel(state: state, listGroupModel: listDirectRoom);
    listDirectStream.notify(listGroupModel);
    getAllUnReadMessage();
  }

  // todo: làm lấy danh sách các tim nhắn trực tiếp
  Future<void> getAllDirectMessage(BuildContext context,
      {bool isGetCache = false}) async {
    BuildContext mContext;
    if (context == null) {
      mContext = this.context;
    } else {
      mContext = context;
      this.context = context;
    }
    AppBloc appBloc = BlocProvider.of(mContext);
    if (isGetCache) {
      _getCacheDirectGroup(appBloc);
    }
    ApiRepository apiRepository = ApiRepository();
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _authHeader = {
      "X-Auth-Token": accountModel.token,
      "X-User-Id": accountModel.id,
    };
    Map<String, String> params = {
      "count": "9999",
      "offset": "0",
      "sort": "\{\"name\"\:1\}"
    };
    await apiRepository.createGetWithAuthHeader(
        baseUrl: Constant.SERVER_CHAT_NO_HTTP,
        endpoint: "api/v1/im.list",
        header: _authHeader,
        params: params,
        onResultData: (resultData) {
          if (resultData != null && resultData != "") {
            Iterable i = resultData['ims'];
            if (i != null && i.length > 0) {
              listDirectRoom = i
                  .map((roomData) => WsRoomModel.fromDirectRoomJson(roomData))
                  .toList();
              updateListDirectRoom(ListGroupState.SHOW);
              _checkOpenDirectRoom(appBloc);
            } else {
              List<WsRoomModel> listData = HiveHelper.getListDirectRoom();
              if (listData.length > 0) {
                listDirectRoom.clear();
                listDirectRoom?.addAll(listData);
                updateListDirectRoom(ListGroupState.SHOW);
                _checkOpenDirectRoom(appBloc);
              } else {
                ListGroupModel model = ListGroupModel(
                    state: ListGroupState.NO_DATA,
                    listGroupModel: listDirectRoom);
                listDirectStream.notify(model);
              }
            }
          }
        },
        onErrorApiCallback: (onErrorCallBack) {
          List<WsRoomModel> listData = HiveHelper.getListDirectRoom();
          if (listData.length > 0) {
            listDirectRoom.clear();
            listDirectRoom?.addAll(listData);
            updateListDirectRoom(ListGroupState.SHOW);
            _checkOpenDirectRoom(appBloc);
          } else {
            ListGroupModel model = ListGroupModel(
                state: ListGroupState.NO_DATA, listGroupModel: listDirectRoom);
            listDirectStream.notify(model);
          }
        });
    if (roomIDNeedOpen != null && roomIDNeedOpen != "") {
      WsRoomModel roomModel = listDirectRoom
          ?.firstWhere((room) => room.id == roomIDNeedOpen, orElse: () => null);
      if (roomModel != null) {
        AppBloc appBloc = BlocProvider.of(context);
        openRoom(appBloc, roomModel);
        roomIDNeedOpen = null;
      }
    }
  }

  _checkOpenDirectRoom(AppBloc appBloc) {
    if (roomIDNeedOpen != null && roomIDNeedOpen != "") {
      WsRoomModel roomModel = listDirectRoom
          ?.firstWhere((room) => room.id == roomIDNeedOpen, orElse: () => null);
      if (roomModel != null) {
        appBloc?.homeBloc
            ?.clickItemBottomBar(1, listTabState: ListTabState.NHAN_TIN);
        appBloc.mainChatBloc.listTabStream
            .notify(ListTabModel(tab: ListTabState.NHAN_TIN));
        openRoom(appBloc, roomModel);
        roomIDNeedOpen = null;
      }
    }
  }

  _getCacheUserOnChatSystem() {
    listUserOnChatSystem = HiveHelper.getAllUserChatSystem();
    listUserOnChatSystem?.removeWhere((model) =>
        model.id.contains(WebSocketHelper.getInstance().wsAccountModel.id));
  }

  Future<void> getAllUserOnSystem(BuildContext context) async {
    if (listUserOnChatSystem == null || listUserOnChatSystem.length < 1) {
      _getCacheUserOnChatSystem();
      ApiServices apiServices = ApiServices();
      await apiServices.getAllUserOnSystem(onResultData: (resultData) {
        Iterable i = resultData;
        if (i != null && i.length > 0) {
          listUserOnChatSystem = i
              .map((account) =>
                  AddressBookModel.fromGetAllAddressBookInfo(account))
              .toList();
          listUserOnChatSystem
              ?.removeWhere((model) => model.name.contains("Rocket.Cat"));
          listUserOnChatSystem
              ?.removeWhere((model) => model.name.contains("ASGL ID"));
          listUserOnChatSystem?.sort((o1, o2) => o1.name.compareTo(o2.name));
          HiveHelper.saveAllUserChatSystem(listUserOnChatSystem);
          listUserOnChatSystem?.removeWhere((model) => model.id
              .contains(WebSocketHelper.getInstance().wsAccountModel.id));
        }
      }, onErrorApiCallback: (resultData) {
        listUserOnChatSystem = List();
      });
    }
  }

  void loginChat(BuildContext context) async {
    this.context = context;
    isReloadDataChat = true;
    String email = await CacheHelper.getUserName();
    String pass = await CacheHelper.getPassword();
    WebSocketHelper.getInstance()
        .connectWithAction(ActionState.WS_LOGIN, requestData: {
      "email": "$email",
      "password": pass,
    });
  }

  void getChatData() async {
    AppBloc appBloc = BlocProvider.of(context);
    await getAllUserOnSystem(context);
    getAllPrivateRoom(context, false, isGetCacheFirst: true);
    getAllDirectMessage(context, isGetCache: true);
    await appBloc.authBloc.getChatUserInfo(appBloc);
  }

  //Lấy cache group private
  _getCachePrivateGroup(AppBloc appBloc) async {
    listGroups = HiveHelper.getListPrivateRoom();
    if (listGroups.length > 0) {
      changeRoomPrivate(appBloc.authBloc.asgUserModel, saveRoomData: false);
    }
    if (roomIDNeedOpen != null && roomIDNeedOpen != "") {
      WsRoomModel roomModel = listGroups
          ?.firstWhere((room) => room.id == roomIDNeedOpen, orElse: () => null);
      if (roomModel != null) {
        appBloc?.homeBloc
            ?.clickItemBottomBar(1, listTabState: ListTabState.NHOM);
        appBloc.mainChatBloc.listTabStream
            .notify(ListTabModel(tab: ListTabState.NHOM));
        openRoom(appBloc, roomModel);
        roomIDNeedOpen = null;
      }
    }
  }

  //Lấy cache group direct
  _getCacheDirectGroup(AppBloc appBloc) async {
    listDirectRoom = HiveHelper.getListDirectRoom();
    if (listGroups.length > 0) {
      updateListDirectRoom(ListGroupState.SHOW);
      _checkOpenDirectRoom(appBloc);
    }
  }

  Future<void> getAllPrivateRoom(
      BuildContext context, bool isRemoveDefaultGroup,
      {bool isGetCacheFirst = false}) async {
    AppBloc appBloc = BlocProvider.of(context);
    ApiServices apiServices = ApiServices();

    if (isGetCacheFirst) {
      _getCachePrivateGroup(appBloc);
    }
    await apiServices.getAllGroup(onResultData: (resultData) {
      Iterable i = resultData['groups'];
      if (i != null && i.length > 0) {
        listGroups.clear();
        listGroups = i.map((data) => WsRoomModel.fromGroup(data)).toList();
        changeRoomPrivate(appBloc.authBloc.asgUserModel);
        _checkOpenPrivateRoom(appBloc);
      } else {
        List<WsRoomModel> listData = HiveHelper.getListPrivateRoom();
        if (listData != null && listData.length > 0) {
          listGroups.clear();
          listGroups.addAll(listData);
          changeRoomPrivate(appBloc.authBloc.asgUserModel);
          _checkOpenPrivateRoom(appBloc);
        } else {
          if (listData != null && listData.length > 0) {
            listGroups.clear();
            listGroups.addAll(listData);
            changeRoomPrivate(appBloc.authBloc.asgUserModel);
            _checkOpenPrivateRoom(appBloc);
          } else {
            listGroups = List();
            ListGroupModel model =
                ListGroupModel(state: ListGroupState.NO_DATA);
            listGroupStream?.notify(model);
          }
        }
      }
    }, onErrorApiCallback: (onError) async {
      List<WsRoomModel> listData = HiveHelper.getListPrivateRoom();
      if (listData != null && listData.length > 0) {
        listGroups.clear();
        listGroups.addAll(listData);
        changeRoomPrivate(appBloc.authBloc.asgUserModel);
        _checkOpenPrivateRoom(appBloc);
      } else {
        listGroups = List();
        ListGroupModel model = ListGroupModel(state: ListGroupState.NO_DATA);
        listGroupStream?.notify(model);
      }
    });
  }

  _checkOpenPrivateRoom(AppBloc appBloc) {
    if (roomIDNeedOpen != null && roomIDNeedOpen != "") {
      WsRoomModel roomModel = listGroups
          ?.firstWhere((room) => room.id == roomIDNeedOpen, orElse: () => null);
      if (roomModel != null) {
        appBloc?.homeBloc
            ?.clickItemBottomBar(1, listTabState: ListTabState.NHOM);
        appBloc.mainChatBloc.listTabStream
            .notify(ListTabModel(tab: ListTabState.NHOM));
        openRoom(appBloc, roomModel);
        roomIDNeedOpen = null;
      }
    }
  }

  void changeRoomPrivate(ASGUserModel asgUserModel,
      {bool saveRoomData = true}) {
    List<WsRoomModel> temps = List();
    listGroups
        ?.removeWhere((wsRoomModel) => wsRoomModel.roomType == RoomType.c);
    Iterable iterableBanTin =
        listGroups?.where((wsRoomModel) => wsRoomModel.name == Const.BAN_TIN);
    if (iterableBanTin != null && iterableBanTin.length > 0) {
      WsRoomModel roomModel = iterableBanTin?.elementAt(0);
      temps?.add(roomModel);
      listGroups?.removeWhere((wsRoom) => wsRoom.id == roomModel.id);
    }
    String roomQuery = Const.THONG_BAO + asgUserModel.id.toString();
    WsRoomModel roomTB = listGroups?.firstWhere(
        (wsRoomModel) => wsRoomModel.name == roomQuery,
        orElse: () => null);
    if (roomTB != null) {
      listGroups?.removeWhere((wsRoom) => wsRoom.id == roomTB.id);
      listGroups?.removeWhere((wsRoom) => wsRoom.name == roomQuery);
      temps?.add(roomTB);
    }
    Iterable iterableFAQ =
        listGroups?.where((wsRoomModel) => wsRoomModel.name == Const.FAQ);
    if (iterableFAQ != null && iterableFAQ.length > 0) {
      WsRoomModel roomModel = listGroups
          ?.where((wsRoomModel) => wsRoomModel.name == Const.FAQ)
          ?.elementAt(0);
      listGroups?.removeWhere((wsRoom) => wsRoom.id == roomModel.id);
      temps?.add(roomModel);
    }
    temps.addAll(listGroups);
    listGroups.clear();
    listGroups.addAll(temps);
    temps.clear();

    listGroups?.sort((o2, o1) {
      int ts1;
      int ts2;
      if (o1.lastMessage == null || o2.lastMessage == null) {
        if (o1.lastMessage == null && o2.lastMessage != null) {
          DateTime time1 = DateTime.fromMillisecondsSinceEpoch(o1.updatedAt);
          if (o2.lastMessage.ts == null) {
            ts2 = o2.updatedAt;
          } else {
            ts2 = o2.lastMessage.ts;
          }
          DateTime time2 = DateTime.fromMillisecondsSinceEpoch(ts2);
          return time1.compareTo(time2);
        } else if (o2.lastMessage == null && o1.lastMessage != null) {
          DateTime time2 = DateTime.fromMillisecondsSinceEpoch(o2.updatedAt);
          if (o1.lastMessage.ts == null) {
            ts1 = o1.updatedAt;
          } else {
            ts1 = o1.lastMessage.ts;
          }
          DateTime time1 = DateTime.fromMillisecondsSinceEpoch(ts1);
          return time1.compareTo(time2);
        } else {
          DateTime time2 = DateTime.fromMillisecondsSinceEpoch(o2.updatedAt);
          DateTime time1 = DateTime.fromMillisecondsSinceEpoch(o1.updatedAt);
          return time1.compareTo(time2);
        }
      } else {
        if (o1.lastMessage.ts == null) {
          ts1 = o1.updatedAt;
        } else {
          ts1 = o1.lastMessage.ts;
        }
        if (o2.lastMessage.ts == null) {
          ts2 = o2.updatedAt;
        } else {
          ts2 = o2.lastMessage.ts;
        }
        DateTime time1 = DateTime.fromMillisecondsSinceEpoch(ts1);
        DateTime time2 = DateTime.fromMillisecondsSinceEpoch(ts2);
        return time1.compareTo(time2);
      }
    });
    getAllUnReadMessage();
    if (saveRoomData) HiveHelper.saveAllPrivateRoom(listGroups);
    ListGroupModel model =
        ListGroupModel(state: ListGroupState.SHOW, listGroupModel: listGroups);
    listGroupStream.notify(model);
  }

  void clearCache() {
    listUserOnChatSystem?.clear();
    listGroups?.clear();
    listDirectRoom?.clear();
    mapDataCountUnread.clear();
  }

  void setRoomNeedOpen(Map<String, dynamic> message) {
    if (Platform.isIOS) {
      if (message != null && message['room_id'] != null) {
        roomIDNeedOpen = message['room_id'];
      }
    } else if (Platform.isAndroid) {
      if (message['data'] != null) {
        if (message['data'].containsKey("room_id")) {
          roomIDNeedOpen = message['data']['room_id'];
        }
      }
    }
  }

  void openNewChatRoom(BuildContext context, AddressBookModel model) async {
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
      appBloc.mainChatBloc.openRoom(appBloc, roomDirect);
    } else {
      ApiServices apiServices = ApiServices();
      await apiServices.createDirectRoom(model.username,
          onResultData: (resultData) {
        WsRoomModel roomModel =
            WsRoomModel.fromDirectRoomJson(resultData['room']);
        if (roomModel != null) {
          appBloc.mainChatBloc.listDirectRoom.insert(0, roomModel);
          appBloc.mainChatBloc.updateListDirectRoom(ListGroupState.SHOW);
          appBloc.mainChatBloc.openRoom(appBloc, roomModel);
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

  //Sau khi roi nhom thanh cong thi xoa nhom va cap nhat nhom
  void removeGroup(WsRoomModel roomModel) {
    listGroups?.removeWhere((room) => room.id == roomModel.id);
    HiveHelper.removeCacheRoomMessage(roomModel.id);
    if (listGroups != null && listGroups.length == 0) {
      listGroupStream?.notify(ListGroupModel(
          state: ListGroupState.NO_DATA, listGroupModel: listGroups));
    } else {
      listGroupStream?.notify(ListGroupModel(
          state: ListGroupState.SHOW, listGroupModel: listGroups));
    }
  }

  void updateTyping(TypingModel typingModel) {
    chatBloc.updateTypingAction(listUserOnChatSystem, typingModel);
  }

  void readAllMessage(WsRoomModel roomModel) async {
    ApiRepository apiRepository = ApiRepository();
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _authHeader = {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
    };
    Map<String, String> _body = {"rid": "${roomModel.id}"};
    await apiRepository.createPostWithAuthHeader(
        Constant.SERVER_BASE_CHAT, "/api/v1/subscriptions.read", _authHeader,
        body: _body,
        onErrorApiCallback: (onError) {}, onResultData: (resultData) {
      print("READ: " + resultData);
      listDirectRoom.forEach((room) {
        if (room.id == roomModel.id) {
          roomModel.lastMessage.unread = false;
        }
      });
      updateListDirectRoom(ListGroupState.SHOW);
    });
    getAllUnReadMessage();
  }

  int unReadDirect = 0;
  int unReadPrivate = 0;
  int unReadDirectAndPrivate = 0;
  CoreStream<UnReadCountModel> countUnreadWithRoomIDStream = CoreStream();
  Map<RoomType, List<UnReadCountModel>> mapDataCountUnread = Map();

  void getAllUnReadMessage() async {
    mapDataCountUnread[RoomType.d] = List<UnReadCountModel>();
    mapDataCountUnread[RoomType.p] = List<UnReadCountModel>();
    MessageServices messageServices = MessageServices();
    await messageServices
        .getAllUnReadMessage()
        .then((Map<RoomType, List<UnReadCountModel>> mapResult) {
      if (mapResult.keys.length > 0) {
        if (mapResult.keys.contains(RoomType.d) &&
            mapResult[RoomType.d].length > 0) {
          unReadDirect = 0;
          mapResult[RoomType.d]?.forEach((data) {
            mapDataCountUnread[RoomType.d].add(data);
            countUnreadWithRoomIDStream?.notify(data);
            unReadDirect += data.unreadCount;
          });
          countUnreadDirectStream?.notify(unReadDirect);
        }
        if (mapResult.keys.contains(RoomType.p) &&
            mapResult[RoomType.p].length > 0) {
          unReadPrivate = 0;
          mapResult[RoomType.p]?.forEach((data) {
            mapDataCountUnread[RoomType.p].add(data);
            countUnreadWithRoomIDStream?.notify(data);
            unReadPrivate += data.unreadCount;
          });
          countUnreadPrivateStream?.notify(unReadPrivate);
        }
        unReadDirectAndPrivate = unReadDirect + unReadPrivate;
        countUnreadSumDirectAndPrivateStream?.notify(unReadDirectAndPrivate);
      }
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  LoadMoreTextState checkLongContent(String msg) {
    if (msg.length < 200) {
      return LoadMoreTextState.NONE;
    } else {
      return LoadMoreTextState.HAVEDATA;
    }
  }

  String covertTextSoLong(String msg) {
    if (msg.length > 200) {
      String message;
      message = msg.substring(0, 199).trim() + " ...";
      return message;
    } else {
      return msg;
    }
  }

  void changeStateLoadmoreContentStream(WsMessage message,LoadMoreTextState loadMoreTextState) {
    isContentLoadMore = !isContentLoadMore;
    loadMoreTextStream.notify(LoadMoreTextModel(
        message,
        loadMoreTextState));
  }
}

class MainChatLayoutModel {
  MainChatState state;
  dynamic data;

  MainChatLayoutModel({@required this.state, this.data});
}

enum MainChatState {
  INIT,
  CHAT,
  SETTING,
  CREATE_PRIVATE_CHANNEL,
  CREATE_PUBLIC_CHANNEL,
}

enum UserStatusState {
  ONLINE,
  OFFLINE,
  BUSY, //Bận
  AWAY, //Vắng mặt
}

class UserStatusModel {
  UserStatusState state;
  String userName;

  UserStatusModel(this.state, this.userName);
}

enum HomeSearchState { SEARCH, SHOW, NONE }

class MainChatSearchModel {
  HomeSearchState state;
  dynamic data;

  MainChatSearchModel(this.state, this.data);
}

class ListGroupModel {
  ListGroupState state;
  List<WsRoomModel> listGroupModel;

  String error;

  ListGroupModel({this.state, this.listGroupModel, this.error});
}

enum ListGroupState {
  LOADING,
  SHOW,
  NO_DATA,
  ERROR,
}
enum AddrebookButtonState { SHOW, NONE }

class AddrebookButtonModel {
  AddrebookButtonState state;

  AddrebookButtonModel(this.state);
}

enum ListTabState { NHAN_TIN, NHOM, NHOM_NOTIFI, GOI_DIEN }

class ListTabModel {
  ListTabState tab;

  ListTabModel({@required this.tab});
}

class LoadMoreTextModel {
  WsMessage wsMessage;
  LoadMoreTextState loadMoreTextState;

  LoadMoreTextModel(this.wsMessage, this.loadMoreTextState);
}

enum LoadMoreTextState { HAVEDATA, NODATA, NONE }
