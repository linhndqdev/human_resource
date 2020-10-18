import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart' as prefix0;
import 'package:human_resource/chat/screen/main_chat/chat/chat_bloc.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/chat/websocket/ws_action.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_typing_model.dart';
import 'package:human_resource/chat/websocket/ws_properties.dart';
import 'package:human_resource/chat/websocket/ws_request.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/core/fcm/fcm_services.dart';
import 'package:human_resource/utils/common/cache_helper.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketHelper extends WebSocketAction {
  static WebSocketHelper _instance;
  IOWebSocketChannel skChannel;
  bool isAutoReconnect = false;
  ActionState _actionState = ActionState.NONE;
  WsAccountModel wsAccountModel;
  dynamic dataRequest;
  AppBloc appBloc;
  String email;
  String userName;
  bool isLoginChat = false;
  bool isConnected = false;

  void init(AppBloc appBloc) {
    this.appBloc = appBloc;
  }

  WebSocketHelper._internal() {
    _initWebSocketHelper();
  }

  static WebSocketHelper getInstance() {
    if (_instance == null) {
      _instance = WebSocketHelper._internal();
    }
    return _instance;
  }

  void _initWebSocketHelper() {
    try {
      skChannel = IOWebSocketChannel.connect(Constant.DOMAIN_WEB_SOCKET);
      skChannel.stream.listen(
          (data) {
            prefix0.debugPrint(data);
            handlerData(json.decode(data));
          },
          onError: (error, StackTrace stackTrace) {
            isConnected = false;
            handlerError(error.toString());
          },
          cancelOnError: false,
          onDone: () {
            isConnected = false;
            reconnect();
          });
    } on Exception catch (ex) {
      isConnected = false;
      _initWebSocketHelper();
    }
  }

  @override
  void connectWithAction(ActionState actionState,
      {dynamic requestData, bool isStartCountDownDisConnect = false}) {
    this.dataRequest = requestData;
    _actionState = actionState;
    skChannel?.sink?.add(WebSocketRequest.requestConnect());
  }

  @override
  void reconnect() {
    skChannel?.sink?.close(status.goingAway);
    isAutoReconnect = true;
    _initWebSocketHelper();
  }

  @override
  void handlerError(String onError) {
    if (onError.contains(Error.SOCKET_EXCEPTION) &&
        (onError.contains(Error.FAILED_HOST_LOOKUP) ||
            onError.contains(Error.NETWORK_UNREACHABLE))) {
      //Không được làm gì trong đây
      if (Constant.ENVIRONMENT == Environment.DEV ||
          Constant.ENVIRONMENT == Environment.TEST) {
        Toast.showShort("WebSocket Error: $onError");
      }
    }
  }

  @override
  void handlerData(Map<String, dynamic> data) {
    if (data[Key.SERVER_ID] != null && data[Key.SERVER_ID] != "") {
      connectWithAction(ActionState.NONE, isStartCountDownDisConnect: true);
    } else {
      switch (data[Key.MSG]) {
        case MsgValue.CONNECTED:
          isConnected = true;
          _onHandlerAction();
          break;
        case MsgValue.ERROR:
          if (data[Key.REASON] == Error.ALREADY_CONNECTED) {
            isConnected = true;
            _onHandlerAction();
          }
          break;
        case MsgValue.PING:
          onPong();
          break;
        case MsgValue.RESULT:
          _handlerResult(data);
          break;
        case MsgValue.CHANGED:
          _handlerValueChange(data);
          break;
      }
    }
  }

  _onHandlerAction() {
    if (isAutoReconnect) {
      authWithUserNameAndPass();
      isAutoReconnect = false;
    } else {
      switch (_actionState) {
        case ActionState.NONE:
          if (appBloc.backStateBloc.focusWidgetModel.state ==
              isFocusWidget.SPLASH) {
            appBloc.authBloc.checkAuth(appBloc);
          }
          break;
        case ActionState.WS_LOGIN:
          authWithUserNameAndPass();
          break;
        case ActionState.LOAD_HISTORY:
          loadChannelHistory();
          break;
      }
    }
  }

  @override
  void subRoomEvent(String roomID) {
    skChannel.sink
        ?.add(WebSocketRequest.requestSubRoomEventTyping(roomID: roomID));
  }

  @override
  void loadChannelHistory() {
    dynamic data = {
      "msg": "method",
      "method": "loadHistory",
      "id": "42",
      "params": [
        dataRequest[2],
        null,
        dataRequest[1],
        "\{ \"\$date\"\: ${dataRequest[0]}\}"
      ]
    };
    skChannel?.sink?.add(jsonEncode(data));
  }

  @override
  void onPong() {
    skChannel?.sink?.add(WebSocketRequest.pongMessage());
  }

  bool isAutoLogin = true;

  @override
  void authWithUserNameAndPass() async {
    if (isAutoLogin) {
      String user;
      String pass;
      try {
        this.email = dataRequest['username'];
        user = dataRequest['username'];
        pass = dataRequest['password'];
      } catch (ex) {
        user = await CacheHelper.getUserName();
        this.email = user;
        pass = await CacheHelper.getPassword();
        dataRequest = {'username': user, 'password': pass};
      }
      if (user != null && pass != null) {
        _actionState = ActionState.WS_LOGIN;
        skChannel?.sink?.add(
            WebSocketRequest.loginEmailPassMessage(userName: user, pass: pass));
      }
    }
  }

  _resetActionState() {
    _actionState = ActionState.NONE;
    this.dataRequest = null;
  }

  void _handlerResult(Map<String, dynamic> data) {
    switch (_actionState) {
      case ActionState.NONE:
        break;
      case ActionState.WS_LOGIN:
        if (data[Key.ERROR] != null && data[Key.ERROR] != '') {
          if (data[Key.ERROR].toString().contains(Error.USER_NOT_FOUND)) {
            Toast.showShort("Thông tin đăng nhập không chính xác.");
          } else {
            Toast.showShort("Đã có lỗi xảy ra. Vui lòng thử lại");
          }
          appBloc.authBloc.requestLogin();
        } else {
          wsAccountModel = WsAccountModel.fromJson(data[Key.RESULT]);
          subUserEventAction();
          FCMServices fcmServices = FCMServices();
          fcmServices.postTokenToServer();
          appBloc.authBloc.loginSuccess(appBloc);
          isLoginChat = true;
          if (appBloc.mainChatBloc.isReloadDataChat) {
            appBloc.mainChatBloc.isReloadDataChat = false;
            appBloc.mainChatBloc.getChatData();
          }
        }
        _resetActionState();
        break;
      case ActionState.LOAD_HISTORY:
        _onLoadHistoryMessage(data);
        _resetActionState();
        break;
    }
  }

  //LẮng nghe xem có được invite vào room mới hay không? nếu có thì cập nhật thêm room
  subUserEventAction() {
    dynamic data = {
      "msg": "sub",
      "id": "711",
      "name": "stream-notify-user",
      "params": ["${wsAccountModel.id}/rooms-changed", false]
    };
    skChannel?.sink?.add(jsonEncode(data));
  }

  void _handlerValueChange(Map<String, dynamic> data) {
    if (data[Key.COLLECTION] != null && data[Key.COLLECTION] != '') {
      if (data[Key.COLLECTION] == Event.NOTIFY_USER) {
        if (data[Key.FIELDS][Key.EVENT_NAME]
            .toString()
            .contains(Event.ROOM_CHANGE)) {
          Iterable iData = data[Key.FIELDS][Key.ARGS];
          if (iData != null && iData.length >= 2) {
            WsRoomModel roomModel = WsRoomModel.fromJson(iData.elementAt(1));
            if (roomModel.lastMessage != null) {
              if (roomModel.roomType != RoomType.d) {
                Iterable iRooms = appBloc.mainChatBloc.listGroups
                    .where((room) => room.id == roomModel.id);
                if (iRooms == null || iRooms.length == 0) {
                  appBloc.mainChatBloc.listGroups.add(roomModel);
                } else {
                  appBloc.mainChatBloc.listGroups.forEach((room) {
                    if (room.id == roomModel.id) {
                      if (room?.lastMessage?.id == roomModel.lastMessage.id) {
                        roomModel.lastMessage.unread = false;
                      } else {
                        roomModel.lastMessage.unread = true;
                      }
                      room.lastMessage = roomModel.lastMessage;
                    }
                  });
                }
                appBloc.mainChatBloc
                    .changeRoomPrivate(appBloc.authBloc.asgUserModel);
              } else {
                bool isHasRoom = false;
                appBloc.mainChatBloc.listDirectRoom.forEach((room) {
                  if (room.id == roomModel.id) {
                    if (room?.lastMessage?.id == roomModel.lastMessage.id) {
                      roomModel.lastMessage.unread = false;
                    } else {
                      roomModel.lastMessage.unread = true;
                    }
                    room.lastMessage = roomModel.lastMessage;
                    isHasRoom = true;
                  }
                });
                if (isHasRoom) {
                  appBloc.mainChatBloc
                      .updateListDirectRoom(ListGroupState.SHOW);
                } else {
                  appBloc.mainChatBloc.getAllDirectMessage(null);
                }
              }
              appBloc.mainChatBloc.chatBloc.addItem(roomModel.lastMessage);
            } else {
              if (roomModel.roomType != RoomType.d) {
                appBloc.mainChatBloc.listGroups
                    .removeWhere((room) => room.id == roomModel.id);
                appBloc.mainChatBloc.listGroups.insert(3, roomModel);
                appBloc.mainChatBloc.chatBloc?.updateUserCount(roomModel);
                appBloc.mainChatBloc
                    .changeRoomPrivate(appBloc.authBloc.asgUserModel);
              }
            }
          }
        }
      } else if (data[Key.COLLECTION] == Event.NOTIFY_LOGGED) {
        if (data[Key.FIELDS][Key.EVENT_NAME]
            .toString()
            .contains(Event.USER_STATUS)) {
          Iterable i = data[Key.FIELDS][Key.ARGS];
          if (i != null && i.length > 0) {
            i.forEach((data) {
              UserStatusState state;
              switch (data[2]) {
                case 0:
                  state = UserStatusState.OFFLINE;
                  break;
                case 1:
                  state = UserStatusState.ONLINE;
                  break;
                case 2:
                  state = UserStatusState.AWAY;
                  break;
                case 3:
                  state = UserStatusState.BUSY;
                  break;
              }
              UserStatusModel statusModel = UserStatusModel(state, data[1]);
              appBloc.mainChatBloc.updateStatusUser(statusModel);
            });
          }
        }
      } else if (data[Key.COLLECTION] == Event.NOTIFY_ROOM) {
        if (data[Key.FIELDS][Key.EVENT_NAME]
            .toString()
            .contains(Event.TYPING)) {
          Iterable i = data[Key.FIELDS][Key.ARGS];
          if (i != null && i.length == 2) {
            TypingModel typingModel =
                TypingModel(userName: i.elementAt(0), isTyping: i.elementAt(1));
            appBloc.mainChatBloc.updateTyping(typingModel);
          }
        }
      } else if (data[Key.COLLECTION] == Event.STREAM_ROOM_MESSAGE) {
        if (data
                .toString()
                .contains("actions_message_com.asgl.human_resource") &&
            data.toString().contains("ActionType.DELETE")) {
          appBloc.mainChatBloc.chatBloc
              .updateMessageWhenRevoke(data[Key.FIELDS][Key.ARGS][0][Key.ID]);
        } else if (data
                .toString()
                .contains("actions_message_com.asgl.human_resource") &&
            data.toString().contains("\"isEdited\":true")) {
          WsMessage message =
              WsMessage.fromLastMessage(data[Key.FIELDS][Key.ARGS][0]);
          appBloc.mainChatBloc.chatBloc
              .updateMessageWhenEdited(data[Key.FIELDS][Key.ARGS][0], message);
        } else {
          WsMessage message =
              WsMessage.fromLastMessage(data[Key.FIELDS][Key.ARGS][0]);
          appBloc.mainChatBloc.chatBloc.updateMessageNormal(message);
        }
      }
    }
  }

  void subUserStatusEvent() {
    skChannel?.sink?.add(WebSocketRequest.requestSubUserStatus());
  }

  void _onLoadHistoryMessage(Map<String, dynamic> data) {
    if (data[Key.ERROR] != null && data[Key.ERROR] != '') {
      ChatListMessageModel model = ChatListMessageModel(
          state: ChatListMessageState.ERROR, error: data[Key.ERROR].toString());
      appBloc.mainChatBloc.chatBloc.changeListMessageData(model);
    } else {
      if (data[Key.RESULT][Key.MESSAGES] != null &&
          data[Key.RESULT][Key.MESSAGES] != "") {
        Iterable i = data[Key.RESULT][Key.MESSAGES];
        List<WsMessage> listMessage = List();
        if (i != null && i.length > 0) {
          listMessage = i.map((msg) => WsMessage.fromLastMessage(msg)).toList();
          ChatListMessageModel model = ChatListMessageModel(
              state: ChatListMessageState.SHOW, listMessage: listMessage);
          appBloc.mainChatBloc.chatBloc.changeListMessageData(model);
        } else {
          ChatListMessageModel model =
              ChatListMessageModel(state: ChatListMessageState.NO_DATA);
          appBloc.mainChatBloc.chatBloc.changeListMessageData(model);
        }
      }
    }
  }

  @override
  void enableTyping(String roomID) {
    skChannel?.sink?.add(WebSocketRequest.requestSendTypingAction(
        roomID: roomID, userName: email, isTyping: true));
  }

  @override
  void disableTyping(String roomID) {
    skChannel?.sink?.add(WebSocketRequest.requestSendTypingAction(
        roomID: roomID, userName: email, isTyping: false));
  }

  void unSubRoomEvent() {
    dynamic data = {"msg": "unsub", "id": "42"};
    skChannel?.sink?.add(jsonEncode(data));
  }

  void removeCache() {
    wsAccountModel = null;
    userName = "";
    email = "";
  }

  void clearCacheWhenLogOut() {
    wsAccountModel = null;
    userName = null;
    email = null;
    dataRequest = null;
    isLoginChat = false;
  }

  void deleteRoom(WsRoomModel roomModel) {
    dynamic data = {
      "msg": "method",
      "method": "eraseRoom",
      "id": "92",
      "params": ["${roomModel.id}"]
    };
    skChannel?.sink?.add(jsonEncode(data));
  }

  void reactMessage(String messageID, String emoji, bool stateAddOrRemoved) {
    dynamic data = {
      "msg": "method",
      "method": "setReaction",
      "id": "22",
      "params": [":nerd:", "$messageID", stateAddOrRemoved]
    };
    skChannel?.sink?.add(jsonEncode(data));
  }

  void subRoomByRoomID(String roomID) {
    skChannel.sink.add(WebSocketRequest.subRoomByRoomIDMessage(
        roomID: "$roomID", subID: "2609"));
  }

  void unSubRoomByRoomID() {
    dynamic data = {"msg": "unsub", "id": "2609"};
    skChannel?.sink?.add(jsonEncode(data));
  }
}
