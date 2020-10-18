import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/screen/main_chat/chat/layout_action_bloc.dart';
import 'package:human_resource/chat/websocket/ws_action.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_attachment.dart';
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
import 'package:human_resource/core/message/iMessageServices.dart';
import 'package:human_resource/core/message/message_services.dart';
import 'package:human_resource/home/home_bloc.dart';
import 'package:human_resource/info/meta_notification_model.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/model/notification_model.dart';
import 'package:human_resource/utils/common/const.dart';
import 'package:human_resource/utils/common/sort_by.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/result_detect_widget.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../main_chat_bloc.dart';
class OrientLayoutDetailModel {
  bool isShowDetail;
  NotificationModel data;

  OrientLayoutDetailModel({@required this.isShowDetail,@required this.data});
}
class OrientLayoutDetailDATAModel{
  WsMessage message;
  bool isHasUrl;
  String sendTo;
  WsRoomModel wsRoomModel;
  OrientLayoutDetailDATAModel({this.message,this.isHasUrl,this.sendTo,this.wsRoomModel});
}
enum OtherLayoutState { NONE, CAMERA, IMAGE_SHOW, PREVIEW_IMAGE }

enum ActionBarMessageState { NONE, DEFAULT, CHOOSEMESSAGE, CHOOSESTATUS }

class OtherLayoutModelStream {
  OtherLayoutState state;
  dynamic data;

  OtherLayoutModelStream(this.state, this.data);
}

class MessageActionStreamModel {
//    bool state = false;
  ActionBarMessageState state;
  WsMessage messageHasAction;

  MessageActionStreamModel(this.state, this.messageHasAction);
}

class ChatBloc {
  LayoutActionBloc layoutActionBloc;
  CoreStream<bool> loadMoreStream = CoreStream();
  CoreStream<bool> loadingStream = CoreStream();
  CoreStream<TypingModel> typingStream = CoreStream();
  CoreStream<bool> recodeLayoutStream = CoreStream();
  CoreStream<bool> pickFileLoading = CoreStream();
  CoreStream<bool> showActionChatStream = CoreStream();
  CoreStream<OtherLayoutModelStream> showOtherLayoutStream = CoreStream();
  CoreStream<MessageActionStreamModel> showMessageActionStream = CoreStream();
  CoreStream<bool> blockSendActionStream = CoreStream();
  CoreStream<bool> chooseMultilMessageStream = CoreStream();
  CoreStream<bool> showSearchStream = CoreStream();
  CoreStream<bool> showIconSearchStream = CoreStream();
  CoreStream<int> countSearchResultStream = CoreStream();

  CoreStream<ResultDetectModel> showResultDetectStream = CoreStream();
  CoreStream<OrientLayoutDetailModel> layoutDetailStream = CoreStream();
  //Hiển thị hoặc ẩn giao diện chọn nhóm - thành viên share tin nhắn
  CoreStream<List<WsMessage>> showLayoutPickMemberShareStream = CoreStream();
  CoreStream<ChatListMessageModel> chatListMessageStream = CoreStream();
  CoreStream<bool> showEMOJIKeyboardStream = CoreStream();
  List<WsMessage> listWsMessage = List();
  CoreStream<int> userCountStream = CoreStream();
  int offsetHistory;
  int totalHistory;
  bool isOpenned = false;
  WsRoomModel roomModel;
  bool isShowEMOJI = false;
  bool isOpenQuote = false;
  bool isLoadMore = false;
  bool isLoadingLatestMsg = false;
  Map<RestUserModel, bool> mapUserPicked = Map();
  List<RestUserModel> listAllUserGroupNotPicked =
      List(); //Chứa toàn bộ các thành viên chưa được chọn
  CoreStream<bool> searchMentionsUserStream = CoreStream();
  CoreStream<List<RestUserModel>> listAllUserGroupStream = CoreStream();
  Offset positionStatusBar;
  Size sizeStatusBar;
  WsRoomModel wsRoomModelCheckStatusNotification;

  //Bặt mentions
  bool isEnableSearch = false;
  MessageDeleteModel messageDeleteModel = MessageDeleteModel();
  Map<WsMessage, bool> mapMessagePicked = Map();

  ItemScrollController chatController;

  //Quote
  CoreStream<MessageActionsModel> showQuoteMessageStream = CoreStream();
  MessageActionsModel messageActionsModel = MessageActionsModel();
  String userIDQuote = "";

  //Search content message
  CoreStream<String> searchDataStream = CoreStream();
  Timer _timer;
  String searchData = "";

  void setRoomModelFromChatLayout(WsRoomModel roomModel) {
    this.roomModel = roomModel;
  }

  void changeEMOJIKeyboardState(bool state) {
    isShowEMOJI = state;
    showEMOJIKeyboardStream?.notify(isShowEMOJI);
  }

  void resetData(BuildContext context, WsRoomModel roomModel) {
    resetVariable();
    this.roomModel = roomModel;
    isOpenned = true;
    chatListMessageStream
        .notify(ChatListMessageModel(state: ChatListMessageState.LOADING));
    AppBloc appBloc = BlocProvider.of(context);
    appBloc.mainChatBloc.readAllMessage(roomModel);

    userCountStream.notify(roomModel.usersCount);
    WebSocketHelper.getInstance().subRoomEvent(roomModel.id);
    WebSocketHelper.getInstance().subRoomByRoomID(roomModel.id);
    getAllUserOnGroup(context, roomModel: roomModel); //Context is null
    if (roomModel.roomType == RoomType.p) {
      getListMessageGroupPrivate(roomModel);
    } else {
      getListMessageDirectChat(roomModel);
    }
  }

  void dispose() {
    layoutDetailStream?.closeStream();
    recodeLayoutStream?.closeStream();
    loadMoreStream?.closeStream();
    loadingStream?.closeStream();
    typingStream?.closeStream();
    userCountStream?.closeStream();
    showActionChatStream?.closeStream();
    showOtherLayoutStream?.closeStream();
    showEMOJIKeyboardStream?.closeStream();
    showMessageActionStream?.closeStream();
    showResultDetectStream?.closeStream();
    showLayoutPickMemberShareStream?.closeStream();
    showSearchStream?.closeStream();
    showIconSearchStream?.closeStream();
    countSearchResultStream?.closeStream();
  }

  void getChatHistory(
    BuildContext context,
    WsRoomModel roomModel, {
    bool isCurrentTime = true,
    ScrollController controller,
  }) async {
    this.roomModel = roomModel;
//    List<dynamic> data = [
//      isCurrentTime
//          ? DateTime.now().millisecondsSinceEpoch
//          : listWsMessage[0].ts,
//      9999,
//      roomModel.id
//    ];
//    wsRoomModelCheckStatusNotification = roomModel;
//    WebSocketHelper.getInstance()
//        .connectWithAction(ActionState.LOAD_HISTORY, requestData: data);
    getListMessageGroupPrivate(roomModel, isGetCache: false);
  }

  void checkAmountMessageRemain(
    BuildContext context,
    String roomID,
    String checkTypeRoom,
  ) {
    if (totalHistory > offsetHistory) {
      if (!isLoadMore && !isLoadingLatestMsg) {
        isLoadMore = true;
        loadMoreStream.notify(isLoadMore);
        offsetHistory = offsetHistory + 50;
        if (checkTypeRoom.contains("d")) {
          getListMessageDirectChatNew(roomID, offsetHistory);
        } else {
          getListMessageGroupPrivateNew(roomID, offsetHistory);
        }
      }
    }
  }

  _getCacheMessage(WsRoomModel roomModel) async {
    List<WsMessage> listData =
        await HiveHelper.getListMessageByRoomID(roomModel.id);
    if (listData != null && listData.length > 0) {
      ChatListMessageModel model = ChatListMessageModel(
          state: ChatListMessageState.SHOW, listMessage: listData);
      changeListMessageData(model);
    }
  }

  /// Lấy ra danh sách 50 tin nhắn gần nhất của Group Private
  void getListMessageGroupPrivate(WsRoomModel roomModel,
      {bool isGetCache = true}) async {
    this.roomModel = roomModel;
    if (!isLoadingLatestMsg) {
      if (isGetCache) {
        _getCacheMessage(roomModel);
      } else {
        ChatListMessageModel model = ChatListMessageModel(
          state: ChatListMessageState.LOADING,
        );
        changeListMessageData(model);
      }
      isLoadingLatestMsg = true;
      ApiRepository apiRepository = ApiRepository();
      WsAccountModel accountModel =
          WebSocketHelper.getInstance().wsAccountModel;
      Map<String, String> _header = {
        "X-Auth-Token": "${accountModel.token}",
        "X-User-Id": "${accountModel.id}",
      };
      Map<String, String> params = {
        "roomId": "${roomModel.id}",
        "count": "50",
        "offset": "0",
        "unreads": "false",
        "query": "{\"t\":{ \"\$ne\": \"r\"}}"
      };
      await apiRepository.createGetWithAuthHeader(
          baseUrl: Constant.SERVER_CHAT_NO_HTTP,
          endpoint: "api/v1/groups.messages",
          params: params,
          header: _header,
          onResultData: (resultData) {
            try {
              if (resultData != null && resultData != "") {
                Iterable i = resultData['messages'];
                List<WsMessage> _listMessage = List();
                if (i != null && i.length > 0) {
                  _listMessage =
                      i.map((msg) => WsMessage.fromDirectMessage(msg)).toList();
                  List<WsMessage> messages = List();
                  if (_listMessage != null && _listMessage.length > 0) {
                    messages.addAll(_listMessage);
                  }
                  ChatListMessageModel model = ChatListMessageModel(
                      state: ChatListMessageState.SHOW, listMessage: messages);
                  changeListMessageData(model);
                  totalHistory = resultData["total"];
                  offsetHistory = resultData["offset"];
                } else {
                  _handleErrorWhenGetListMessage(roomModel);
                }
              } else {
                _handleErrorWhenGetListMessage(roomModel);
              }
            } on Exception catch (ex) {
              _handleErrorWhenGetListMessage(roomModel);
            }
          },
          onErrorApiCallback: (onError) {
            _handleErrorWhenGetListMessage(roomModel);
          });
      isLoadingLatestMsg = false;
    }
  }

  ///Lấy thêm dữ liệu từ server của Private Group
  void getListMessageGroupPrivateNew(String roomID, int _offsetHistory) async {
    this.roomModel = roomModel;
    ApiRepository apiRepository = ApiRepository();
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
    };
    Map<String, String> params = {
      "roomId": "$roomID",
      "count": "50",
      "offset": "$_offsetHistory",
      "unreads": "false",
      "query": "{\"t\":{ \"\$ne\": \"r\"}}"
    };
    await apiRepository.createGetWithAuthHeader(
        baseUrl: Constant.SERVER_CHAT_NO_HTTP,
        endpoint: "api/v1/groups.messages",
        params: params,
        header: _header,
        onResultData: (resultData) {
          try {
            if (resultData != null && resultData != "") {
              Iterable i = resultData['messages'];
              List<WsMessage> _listMessage = List();
              if (i != null && i.length > 0) {
                _listMessage =
                    i.map((msg) => WsMessage.fromDirectMessage(msg)).toList();
                List<WsMessage> messages = List();
                if (listWsMessage != null && listWsMessage.length > 0) {
                  messages.addAll(listWsMessage);
                }
                if (_listMessage != null && _listMessage.length > 0) {
                  messages.addAll(_listMessage);
                }
                ChatListMessageModel model = ChatListMessageModel(
                    state: ChatListMessageState.SHOW, listMessage: messages);
                changeListMessageData(model);
                totalHistory = resultData["total"];
                offsetHistory = resultData["offset"];
              }
            }
          } on Exception catch (ex) {}
        },
        onErrorApiCallback: (onError) {});
    isLoadMore = false;
    loadMoreStream.notify(false);
  }

  ///Lấy ra danh sách 50 tin nhắn gần nhất của DirectChat
  void getListMessageDirectChat(WsRoomModel roomModel,
      {bool isGetCache = false}) async {
    this.roomModel = roomModel;
    if (!isLoadingLatestMsg) {
      if (isGetCache) {
        _getCacheMessage(roomModel);
      } else {
        ChatListMessageModel model = ChatListMessageModel(
          state: ChatListMessageState.LOADING,
        );
        changeListMessageData(model);
      }
      isLoadingLatestMsg = true;
      ApiRepository apiRepository = ApiRepository();
      WsAccountModel accountModel =
          WebSocketHelper.getInstance().wsAccountModel;
      Map<String, String> _header = {
        "X-Auth-Token": "${accountModel.token}",
        "X-User-Id": "${accountModel.id}",
      };
      Map<String, String> params = {
        "roomId": "${roomModel.id}",
        "count": "50",
        "offset": "0",
        "unreads": "false",
      };
      await apiRepository.createGetWithAuthHeader(
          baseUrl: Constant.SERVER_CHAT_NO_HTTP,
          endpoint: "api/v1/im.messages",
          params: params,
          header: _header,
          onResultData: (resultData) {
            try {
              if (resultData != null && resultData != "") {
                Iterable i = resultData['messages'];
                List<WsMessage> _listMessage = List();
                if (i != null && i.length > 0) {
                  _listMessage =
                      i.map((msg) => WsMessage.fromDirectMessage(msg)).toList();
                  List<WsMessage> messages = List();
                  if (_listMessage != null && _listMessage.length > 0) {
                    messages.addAll(_listMessage);
                  }
                  ChatListMessageModel model = ChatListMessageModel(
                      state: ChatListMessageState.SHOW, listMessage: messages);
                  changeListMessageData(model);
                  totalHistory = resultData["total"];
                  offsetHistory = resultData["offset"];
                } else {
                  _handleErrorWhenGetListMessage(roomModel);
                }
              } else {
                _handleErrorWhenGetListMessage(roomModel);
              }
            } on Exception catch (ex) {
              _handleErrorWhenGetListMessage(roomModel);
            }
          },
          onErrorApiCallback: (onError) {
            _handleErrorWhenGetListMessage(roomModel);
          });
      isLoadingLatestMsg = false;
    }
  }

  ///Lấy thêm dữ liệu từ server cua DirectChat
  void getListMessageDirectChatNew(String roomID, int _offsetHistory) async {
    ApiRepository apiRepository = ApiRepository();
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Map<String, String> _header = {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
    };
    Map<String, String> params = {
      "roomId": "$roomID",
      "count": "50",
      "offset": "$_offsetHistory",
      "unreads": "false",
    };
    await apiRepository.createGetWithAuthHeader(
        baseUrl: Constant.SERVER_CHAT_NO_HTTP,
        endpoint: "api/v1/im.messages",
        params: params,
        header: _header,
        onResultData: (resultData) {
          try {
            if (resultData != null && resultData != "") {
              Iterable i = resultData['messages'];
              List<WsMessage> _listMessage = List();
              if (i != null && i.length > 0) {
                _listMessage =
                    i.map((msg) => WsMessage.fromDirectMessage(msg)).toList();
                List<WsMessage> messages = List();
                if (listWsMessage != null && listWsMessage.length > 0) {
                  messages.addAll(listWsMessage);
                }
                if (_listMessage != null && _listMessage.length > 0) {
                  messages.addAll(_listMessage);
                }
                ChatListMessageModel model = ChatListMessageModel(
                    state: ChatListMessageState.SHOW, listMessage: messages);
                changeListMessageData(model);
                totalHistory = resultData["total"];
                offsetHistory = resultData["offset"];
              }
            }
          } on Exception catch (ex) {}
        },
        onErrorApiCallback: (onError) {});
    isLoadMore = false;
    loadMoreStream.notify(false);
  }

  void readAllMessage(BuildContext context, WsRoomModel roomModel) async {
    AppBloc appBloc = BlocProvider.of(context);
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
      appBloc.mainChatBloc.listDirectRoom.forEach((room) {
        if (room.id == roomModel.id) {
          roomModel.lastMessage.unread = false;
        }
      });
      appBloc.mainChatBloc.updateListDirectRoom(ListGroupState.SHOW);
    });
  }

  changeListMessageData(ChatListMessageModel model) {
    if (roomModel != null) {
      if (roomModel.name == Const.BAN_TIN ||
          roomModel.name == Const.FAQ ||
          roomModel.name.contains(Const.THONG_BAO)) {
        model?.listMessage?.removeWhere((message) {
          return message?.t == "au" ||
              message?.t == "uj" ||
              message?.t == "subscription-role-added" ||
              message?.t == "ru" ||
              message?.t == "le";
        });
      }
    }
    listWsMessage.clear();
    if (model?.listMessage != null && model.listMessage.length > 0) {
      listWsMessage?.addAll(model?.listMessage);
    }
    listWsMessage?.sort((msg1, msg2) => msg1.ts < msg2.ts ? 1 : -1);
    if (listWsMessage.length > 50) {
      if (totalHistory == null && offsetHistory == null) {
        offsetHistory = 50;
        totalHistory = 51;
      }
      String roomID = listWsMessage[0].rid;
      HiveHelper.saveListMessageWithRoomID(
          roomID, listWsMessage.take(50).toList());
    } else if (listWsMessage.length > 0 && listWsMessage.length <= 50) {
      if (totalHistory == null && offsetHistory == null) {
        offsetHistory = 50;
        totalHistory = 51;
      }
      String roomID = listWsMessage[0].rid;
      HiveHelper.saveListMessageWithRoomID(roomID, listWsMessage);
    }
    chatListMessageStream.notify(model);
  }

  Future<void> addItem(WsMessage message) async {
    if (message.rid == this.roomModel?.id) {
      bool isDuplicate = false;
      listWsMessage?.removeWhere((message) => message?.isSending == true);
      listWsMessage?.forEach((data) {
        if (data.id == message.id) {
          isDuplicate = true;
        }
      });
      if (!isDuplicate) {
        if (listWsMessage.length > 0) {
          if (message.file == null) {
            listWsMessage?.removeWhere((data) =>
                data.isSending &&
                data.msg == message.msg &&
                data.rid == message.rid);
          }
          listWsMessage?.insert(0, message);
        } else {
          listWsMessage.add(message);
        }
        listWsMessage.sort((msg1, msg2) => msg1.ts < msg2.ts ? 1 : -1);
        if (!message.isSending) {
          if (listWsMessage.length > 0 && listWsMessage.length > 50) {
            String roomID = listWsMessage[0].rid;
            await HiveHelper.saveListMessageWithRoomID(
                roomID, listWsMessage.take(50).toList());
          } else if (listWsMessage.length > 0 && listWsMessage.length < 50) {
            String roomID = listWsMessage[0].rid;
            await HiveHelper.saveListMessageWithRoomID(roomID, listWsMessage);
          }
        }
        ChatListMessageModel model = ChatListMessageModel(
            state: ChatListMessageState.SHOW, listMessage: listWsMessage);
        chatListMessageStream.notify(model);
      }
    } else {
      await HiveHelper.saveOnlyMessageWithRoomID(message);
    }
  }

  Future<void> sendMessage(
      BuildContext context, String messageText, WsRoomModel roomModel) async {
    showActionChatStream?.notify(true);
    showQuoteMessageStream.notify(null);
    changeStateSend(false);
    showActionChatStream.notify(true);
    disableSearchMentions();
    if (messageText != null && messageText.trim().toString() != "") {
      //Không phải chỉnh sửa tin nhắn
      AppBloc appBloc = BlocProvider.of(context);
      appBloc = BlocProvider.of(context);
      if (!isEditMessage) {
        //Không quote thì gửi như bình thường
        WsMessage newMsg =
            WsMessage.createMessageWithAnimation(messageText, roomModel);
        appBloc.mainChatBloc.listGroups?.forEach((roomData) {
          if (roomData.id == roomModel.id) {
            roomData.lastMessage = newMsg;
          }
        });
        if (!isOpenQuote) {
          if (mentionModel.mentionType == MentionType.ALL) {
            mentionModel.mentions.clear();
            mapUserPicked?.keys?.forEach((data) {
              UserMention userMention = UserMention();
              userMention.userID = data.id;
              userMention.fullName = "@" + data.name;
              userMention.content = data.name;
              mentionModel.mentions.add(userMention);
            });
          }
          if (mentionModel != null && mentionModel.mentions.length > 0) {
            //Gửi tin nhắn tag
            MessageActionsModel acctionModel = MessageActionsModel();
            acctionModel.setType(ActionType.MENTION);
            acctionModel.setMention(mentionModel);
            acctionModel.msg = messageText;
            newMsg.messageActionsModel = acctionModel;
            addItem(newMsg);
            this.messageActionsModel = null;
            IMessageServices iMessageServices = IMessageServices();

            iMessageServices.sendMessageWithAction(
                userQuoteID: "",
                messageActionsModel: acctionModel,
                roomModel: roomModel,
                onResultData: (result) {},
                onErrorApiCallback: (onError) {
                  _handleErrorToRemoveGroup(context, appBloc, onError);
                });
            mentionModel = MentionModel();
            messageActionsModel = MessageActionsModel();
          } else {
            addItem(newMsg);
            MessageServices messageServices = MessageServices()
              ..setRoomModel(roomModel: roomModel);
            await messageServices.sendTextMessage(
                roomModel: roomModel,
                message: messageText,
                onResultData: (result) {},
                onErrorApiCallback: (onError) {
                  listWsMessage
                      ?.removeWhere((message) => message.id == newMsg.id);
                  _updateListMessageOnChatLayout();
                  _handleErrorToRemoveGroup(context, appBloc, onError);
                });
          }
        } else {
          //Nếu quote thì gửi như sau:
          MessageActionsModel messageActionsModel = this.messageActionsModel;
          //Nếu tag thì thêm như sau:
          isOpenQuote = false;
          messageActionsModel.msg = messageText;
          messageActionsModel.setMention(mentionModel);
          newMsg.messageActionsModel = messageActionsModel;
          addItem(newMsg);
          this.messageActionsModel = null;
          IMessageServices iMessageServices = IMessageServices();

          iMessageServices.sendMessageWithAction(
              userQuoteID: userIDQuote,
              messageActionsModel: messageActionsModel,
              roomModel: roomModel,
              onResultData: (result) {},
              onErrorApiCallback: (onError) {
                _handleErrorToRemoveGroup(context, appBloc, onError);
              });
          mentionModel = MentionModel();
          messageActionsModel = MessageActionsModel();
        }
      } else {
        //Chỉnh sửa nội dung tin nhắn
        messageEdit.messageActionsModel.msg = messageText;
        IMessageServices iMessageServices = IMessageServices();
        messageEdit.messageActionsModel.isEdited = true;

        if (messageEdit.messageActionsModel.actionType == ActionType.NONE) {
          if (mentionModel == null ||
              mentionModel.mentions == null ||
              mentionModel.mentions.length == 0) {
            messageEdit.messageActionsModel.mentions = null;
            messageEdit.messageActionsModel.actionType = ActionType.NONE;
          } else {
            messageEdit.messageActionsModel.actionType = ActionType.MENTION;
            messageEdit.messageActionsModel.mentions = mentionModel;
          }
        } else if (messageEdit.messageActionsModel.actionType ==
            ActionType.MENTION) {
          if (mentionModel == null ||
              mentionModel.mentions == null ||
              mentionModel.mentions.length == 0) {
            messageEdit.messageActionsModel.mentions = null;
            messageEdit.messageActionsModel.actionType = ActionType.NONE;
          } else {
            messageEdit.messageActionsModel.actionType = ActionType.MENTION;
            messageEdit.messageActionsModel.mentions = mentionModel;
          }
        }
        iMessageServices.updateMessage(
            message: messageEdit,
            roomModel: roomModel,
            onErrorApiCallback: (onError) {
              _handleErrorToRemoveGroup(context, appBloc, onError);
            });
        disableEditMessage();
        mentionModel = MentionModel();
        messageActionsModel = MessageActionsModel();
      }
      if (listWsMessage != null && listWsMessage.length > 0) {
        chatController.jumpTo(index: 0);
      }
    }
  }

  void updateTypingAction(
      List<AddressBookModel> allUserOnSystem, TypingModel typingModel) {
    if (typingModel.isTyping) {
      Map<int, dynamic> mapParams = {
        0: typingModel.userName,
        1: allUserOnSystem,
      };
      compute(_getFullNameTyping, mapParams).then((data) {
        TypingModel model =
            TypingModel(userName: data, isTyping: typingModel.isTyping);
        typingStream.notify(model);
      });
    } else {
      typingStream.notify(typingModel);
    }
  }

  static String _getFullNameTyping(Map<int, dynamic> params) {
    if (params[1] != null && params[1].length > 0) {
      List<AddressBookModel> listData = List();
      listData.addAll(params[1]);
      AddressBookModel userModel = listData
          .firstWhere((user) => user.username == params[0], orElse: () => null);
      if (userModel != null) {
        return userModel?.name;
      }
      return "Ai đó ";
    }
    return "Ai đó ";
  }

  void _updateListMessageOnChatLayout() {
    if (listWsMessage != null && listWsMessage.length > 0) {
      ChatListMessageModel model = ChatListMessageModel(
          state: ChatListMessageState.SHOW, listMessage: listWsMessage);
      chatListMessageStream.notify(model);
      if (listWsMessage.length > 1) {
        chatController?.jumpTo(index: 0);
      }
    } else {
      ChatListMessageModel model = ChatListMessageModel(
          state: ChatListMessageState.NO_DATA, listMessage: listWsMessage);
      chatListMessageStream.notify(model);
    }
  }

  void updateUserCount(WsRoomModel roomModel) {
    if (this.roomModel != null && roomModel.id == this.roomModel.id) {
      this.roomModel.usersCount = roomModel.usersCount;
      userCountStream.notify(roomModel.usersCount);
    }
  }

  void updateOtherLayout(OtherLayoutState state, {dynamic data}) {
    OtherLayoutModelStream stream = OtherLayoutModelStream(state, data);
    showOtherLayoutStream?.notify(stream);
  }

  void leaveRom(BuildContext context, WsRoomModel roomModel) async {
    loadingStream.notify(true);
    AppBloc appBloc = BlocProvider.of(context);
    ApiServices apiServices = ApiServices();
    await apiServices.leaveRoom(
        roomModel: roomModel,
        onResultData: (resultData) {
          loadingStream.notify(false);
          Toast.showShort("Đã rời nhóm.");
          appBloc.mainChatBloc.removeGroup(roomModel);
          appBloc.mainChatBloc.changeRoomPrivate(appBloc.authBloc.asgUserModel);
          appBloc.mainChatBloc.backLayout(appBloc, roomModel);
        },
        onErrorApiCallback: (onError) {
          loadingStream.notify(false);
          Toast.showShort(onError.toString());
        });
    loadingStream.notify(false);
  }

  void sendFileAttachment(BuildContext context, String path,
      WsRoomModel roomModel, VoidCallback onLimitedFileSize) async {
    if (path != null && path.trim().toString() != "") {
      File file = File(path);
      if (file != null && file.existsSync()) {
        await file.length().then((data) {
          if (data <= 100000000) {
            AppBloc appBloc = BlocProvider.of(context);
            MessageServices messageServices = MessageServices()
              ..setRoomModel(roomModel: roomModel);
            messageServices.sendFileMessage(
                fullName: appBloc.authBloc.asgUserModel.full_name,
                senderUserName: appBloc.authBloc.asgUserModel.full_name,
                filePath: path,
                resultData: (result) {},
                onErrorApiCallback: (onError) {});
          } else {
            onLimitedFileSize();
          }
        });
      }
    }
  }

  //Detect Text from Image
  void onDetectTextFromImage(String imageID, OnResultDetect onResultDetect,
      OnResultDetect onErrorDetect) async {
    updateStateResultDetect("Animated", ResultDetectState.ANIMATED);
    IMessageServices iMessageServices = IMessageServices();
    await iMessageServices.detectImageToText(imageID, (result) {
      if (result != null &&
          result['success'] != null &&
          result['success'] != "") {
        if (result['data'] != null && result['data'] != "") {
          if (result['data']['text'] != null && result['data']['text'] != "") {
            Iterable iTexts = result['data']['text'];
            if (iTexts != null && iTexts.length > 0) {
              String text = "";
              iTexts?.forEach((data) {
                text += "$data \n";
              });
              if (text.contains(
                  "error: (-215:Assertion failed) !_src.empty() in function")) {
                onErrorDetect("Không nhận diện được nội dung");
              } else {
                showActionChatStream.notify(false);
                onResultDetect(text);
              }
            } else {
              onErrorDetect("Không nhận diện được nội dung");
            }
          } else {
            onErrorDetect("Không nhận diện được nội dung");
          }
        } else {
          onErrorDetect("Không nhận diện được nội dung");
        }
      } else {
        onErrorDetect("Không nhận diện được nội dung");
      }
    }, (onError) {
      onErrorDetect("Không nhận diện được nội dung");
    });
  }

  void quoteMessage(BuildContext context, WsMessage messageQuote) async {
    disableEditMessage();
    showMessageActionStream
        ?.notify(MessageActionStreamModel(ActionBarMessageState.NONE, null));
    changeStateSend(true);
//      WsMessage newMsg =
//          WsMessage.createMessageWithAnimation(messageText, roomModel);
    mentionModel = MentionModel();
    AppBloc appBloc = BlocProvider.of(context);
    appBloc = BlocProvider.of(context);
    String fullName;
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    if (accountModel.id != messageQuote.skAccountModel.id) {
      userIDQuote = messageQuote.skAccountModel.id;
    }
    if (messageQuote.skAccountModel.userName ==
        appBloc.authBloc.asgUserModel.username) {
      fullName = appBloc.authBloc.asgUserModel.full_name;
    } else {
      AddressBookModel addressBookModel =
          appBloc.mainChatBloc.listUserOnChatSystem?.firstWhere(
              (user) => user.username == messageQuote.skAccountModel.userName,
              orElse: () => null);
      if (addressBookModel != null && addressBookModel.name != null) {
        fullName = addressBookModel.name;
      }
    }
    String msg = "";
    if (messageQuote != null &&
        messageQuote?.messageActionsModel != null &&
        messageQuote?.messageActionsModel?.msg != null &&
        messageQuote?.messageActionsModel?.msg?.trim().toString() != "") {
      msg = messageQuote?.messageActionsModel?.msg;
    } else {
      msg = messageQuote.msg;
    }
    String quoteType = "TEXT";
    String fileUrl = "";
    if (messageQuote?.file != null &&
        messageQuote?.wsAttachments[0] is WsImageFile) {
      quoteType = "IMAGE";
      fileUrl = Constant.SERVER_BASE_CHAT +
          (messageQuote?.wsAttachments[0] as WsImageFile).image_url;
    } else if (messageQuote?.file != null) {
      quoteType = "OTHER_FILE";
      fileUrl = Constant.SERVER_BASE_CHAT +
          (messageQuote?.wsAttachments[0] as WsImageFile).image_url;
    }

    if (fullName != null) {
      if (messageActionsModel == null) {
        messageActionsModel = MessageActionsModel();
      }
      messageActionsModel.setType(ActionType.QUOTE).setQuote(
          MessageQuoteModel.createWith(
              fullName, msg, messageQuote.ts.toString(), quoteType, fileUrl));
      isOpenQuote = true;
      showQuoteMessageStream?.notify(messageActionsModel);
    }
  }

  //Copy tin nhắn vào ClipBoard hệ thống
  void copyMessage(BuildContext context, WsMessage messageCopy) async {
    showMessageActionStream
        ?.notify(MessageActionStreamModel(ActionBarMessageState.NONE, null));
    if (messageCopy.messageActionsModel != null &&
        messageCopy.messageActionsModel.actionType == ActionType.NONE) {
      if (messageCopy.messageActionsModel.msg == null) {
        await Clipboard.setData(ClipboardData(text: messageCopy.msg));
      } else {
        await Clipboard.setData(
            ClipboardData(text: messageCopy.messageActionsModel.msg));
      }
    } else if (messageCopy.messageActionsModel == null) {
      await Clipboard.setData(ClipboardData(text: messageCopy.msg));
    } else {
      if (messageCopy.messageActionsModel != null &&
          (messageCopy.messageActionsModel.actionType == ActionType.FORWARD ||
              messageCopy.messageActionsModel.actionType ==
                  ActionType.MENTION ||
              messageCopy.messageActionsModel.actionType == ActionType.QUOTE)) {
        String content = messageCopy.messageActionsModel.msg;
        await Clipboard.setData(ClipboardData(text: content));
      }
    }
    Toast.showToastCustom(context, " Đã sao chép vào bộ nhớ tạm ");
  }

//close edit tin nhắn
  bool isEditMessage = false;
  WsMessage messageEdit;

  void editMessage(BuildContext context, WsMessage messageEdit) async {
    mentionModel = MentionModel();
    changeStateSearchMessage(false);
    disableQuote();
    if (messageEdit.messageActionsModel != null &&
        messageEdit.messageActionsModel.actionType == ActionType.MENTION) {
      mentionModel = messageEdit.messageActionsModel.mentions;
    }
    isEditMessage = true;
    this.messageEdit = messageEdit;
    showMessageActionStream
        ?.notify(MessageActionStreamModel(ActionBarMessageState.NONE, null));
    changeStateSend(true);
  }

  void disableQuote() {
    isOpenQuote = false;
    userIDQuote = "";
    showQuoteMessageStream?.notify(null);
    changeStateSend(false);
  }

  //Bắt buộc người dùng rời room chat
  void forceOutChatScreen(BuildContext context, String roomID) {
    //Làm gì đó ở đây
    AppBloc appBloc = BlocProvider.of(context);
    DialogUtils.showDialogRequest(context,
        title: "Cảnh báo",
        message:
            "Nhóm của bạn đã bị xóa bởi người sáng lập. Bạn sẽ không thể thực hiện bất cứ thao tác nào với nhóm này nữa.",
        onClickOK: () {
      appBloc.homeBloc.clickItemBottomBar(1);
      appBloc.homeBloc.layoutNotBottomBarStream
          .notify(LayoutNotBottomBarModel(state: LayoutNotBottomBarState.NONE));
      layoutActionBloc.changeState(LayoutActionState.NONE);
    });
  }

  void revokeMessage(String roomId, String msgId, WsRoomModel wsRoomModel) {
    loadingStream.notify(true);
    showMessageActionStream
        ?.notify(MessageActionStreamModel(ActionBarMessageState.NONE, null));
    MessageActionsModel messageActionsModel = MessageActionsModel.createWith(
        "Tin nhắn đã bị thu hồi",
        ActionType.DELETE,
        null,
        null,
        null,
        MessageDeleteModel.createWith(msgId),
        false);
    IMessageServices iMessageServices = IMessageServices();
    iMessageServices.revokeMessage(
        messageActionsModel: messageActionsModel,
        roomId: roomId,
        msgId: msgId,
        onResultData: (result) {
          //Gọi hàm cập nhật lại giá trị của tin nhắn
          updateMessageWhenRevoke(msgId);
          loadingStream.notify(false);
        },
        onErrorApiCallback: (error) {
          loadingStream.notify(false);
        });
  }

  updateMessageWhenRevoke(String msgID) {
    try {
      WsMessage message =
          listWsMessage?.firstWhere((r) => r.id.contains(msgID), orElse: null);
      if (message != null) {
        message.msg = messageDeleteModel.messageContent;
        message.messageActionsModel.actionType = ActionType.DELETE;
        message.messageActionsModel.forwards = null;
        message.messageActionsModel.mentions = null;
        message.messageActionsModel.quote = null;
        if (!message.isSending) {
          HiveHelper.saveListMessageWithRoomID(message.rid, listWsMessage);
        }
        ChatListMessageModel model = ChatListMessageModel(
            state: ChatListMessageState.SHOW, listMessage: listWsMessage);
        chatListMessageStream.notify(model);
      }
    } catch (ex) {}
  }

  void openSearch() {
    isEnableSearch = true;
    searchMentionsUserStream?.notify(true);
  }

  //Tắt mentions
  void disableSearchMentions() {
    isEnableSearch = false;
    searchMentionsUserStream?.notify(false);
  }

  void checkAndUnCheckMessage() {
    bool isCheckMessage = false;
    if (!isCheckMessage) {
      chooseMultilMessageStream.notify(true);
    }
  }

  void pickMessage(WsMessage model) {
    if (mapMessagePicked.isNotEmpty) {
      if (mapMessagePicked[model] != null) {
        if (mapMessagePicked[model]) {
          removeMessagePicked(model);
        } else {
          addMessagePicked(model);
        }
      } else {
        addMessagePicked(model);
      }
    } else {
      addMessagePicked(model);
    }
  }

  void removeMessagePicked(WsMessage messageModel) {
    mapMessagePicked[messageModel] = false;
    chooseMultilMessageStream.notify(true);
  }

  void addMessagePicked(WsMessage messageModel) {
    mapMessagePicked[messageModel] = true;
    chooseMultilMessageStream.notify(true);
  }

  //Lấy ra danh sách các user có trong phòng
  Future<void> getAllUserOnGroup(BuildContext context,
      {@required WsRoomModel roomModel}) async {
//    loadingStream.notify(true);
    ApiServices apiServices = ApiServices();
    await apiServices.getAllUserOnGroup(roomModel, resultData: (resultData) {
      try {
        Iterable iterable = resultData['members'];
        if (iterable != null && iterable.length > 0) {
          listAllUserGroupNotPicked?.clear();
          listAllUserGroupNotPicked = iterable
              .map((user) => RestUserModel.fromGetAllUser(user))
              .toList();
          AppBloc appBloc = BlocProvider.of(context);
          ASGUserModel curentUser = appBloc.authBloc.asgUserModel;
          listAllUserGroupNotPicked
              ?.removeWhere((user) => user.username == curentUser.username);
          mapUserPicked.clear();
          listAllUserGroupNotPicked?.forEach((data) {
            mapUserPicked[data] = false;
          });
          mentionModel?.mentions?.forEach((user) {
            RestUserModel model = listAllUserGroupNotPicked?.firstWhere(
                (resuser) => resuser.id == user.userID,
                orElse: () => null);
            if (model != null) {
              mapUserPicked[model] = true;
            }
            listAllUserGroupNotPicked?.remove(model);
          });
          listAllUserGroupStream?.notify(listAllUserGroupNotPicked);
          if (isEnableSearch) {
            listAllUserGroupStream?.notify(listAllUserGroupNotPicked);
          }
        }
      } catch (ex) {}
    }, onErrorApiCallback: (onError) {
      mapUserPicked = Map();
    });
  }

  ///Cập nhật trạng thái cho việc hiển thị result detect text from image
  /// Nếu truyền [result] == "" thì sẽ không hiển thị widget result và ngược lại
  void updateStateResultDetect(String result, ResultDetectState state) {
    ResultDetectModel resultDetectModel;
    if (result == null || result == "") {
      resultDetectModel =
          ResultDetectModel(message: "", state: ResultDetectState.NONE);
    } else {
      resultDetectModel = ResultDetectModel(message: result, state: state);
    }
    showResultDetectStream?.notify(resultDetectModel);
  }

  void mentionsAllUser() {
    if (mentionModel == null) {
      mentionModel = MentionModel();
    }
    mentionModel?.mentions?.clear();
    mentionModel.mentionType = MentionType.ALL;
    mapUserPicked.keys?.forEach((data) {
      mapUserPicked[data] = true;
      UserMention userMention = UserMention();
      userMention.userID = data.id;
      userMention.content = data.name;
      userMention.fullName = "@" + data.name;
      mentionModel.mentions.add(userMention);
    });
    listAllUserGroupNotPicked.clear();
    disableSearchMentions();
  }

  void searchUserByName(String data, int positionOfCursor) {
    if (!data.contains("@all")) {
      mentionModel.mentionType = MentionType.OTHER;
    }
    mapUserPicked.keys.forEach((key) {
      if (mapUserPicked[key] && !data.contains("@${key.name}")) {
        mapUserPicked[key] = false;
        if (mentionModel.mentionType != MentionType.ALL) {
          mentionModel?.mentions
              ?.removeWhere((userModel) => userModel.userID == key.id);
        }
        listAllUserGroupNotPicked.add(key);
        listAllUserGroupStream.notify(listAllUserGroupNotPicked);
      }
    });
    String dataChange = data;
    if (positionOfCursor < data.length) {
      dataChange = data.substring(0, positionOfCursor);
    }
    if (dataChange != "@") {
      int indexLast = dataChange.lastIndexOf("@");

      if (indexLast < dataChange.length) {
        String name = dataChange.substring(indexLast + 1, dataChange.length);
        if (name != null && name.trim() != "") {
          List<RestUserModel> res = List();
          listAllUserGroupNotPicked?.forEach((user) {
            Sort sort = Sort();
            if (sort.compareStringUTF8(name, user.name)) {
              res.add(user);
            }
          });
          listAllUserGroupStream?.notify(res);
        }
      } else {
        listAllUserGroupNotPicked.clear();
        mapUserPicked?.keys?.forEach((user) {
          listAllUserGroupNotPicked.add(user);
        });
        listAllUserGroupStream?.notify(listAllUserGroupNotPicked);
      }
    }
  }

  MentionModel mentionModel = MentionModel();

  void tagMember(RestUserModel restUserModel) {
    disableSearchMentions();
    UserMention userMention = UserMention();
    userMention.userID = restUserModel.id;
    userMention.content = restUserModel.name;
    userMention.fullName = "@" + restUserModel.name;
    mentionModel.mentions.add(userMention);
    if (mentionModel.mentionType != MentionType.ALL) {
      mentionModel.mentionType = MentionType.OTHER;
    }
    mapUserPicked[restUserModel] = true;
    listAllUserGroupNotPicked
        ?.removeWhere((user) => user.username == restUserModel.username);
    listAllUserGroupStream?.notify(listAllUserGroupNotPicked);
  }

  //Chỉ được gọi khi chat_layout dispose
  void resetVariable() {
    WebSocketHelper.getInstance().unSubRoomEvent();
    WebSocketHelper.getInstance().unSubRoomByRoomID();
    isLoadingLatestMsg = false;
    listWsMessage.clear();
    listAllUserGroupNotPicked?.clear();
    mapUserPicked?.clear();
    isOpenned = false;
    roomModel = null;
    isLoadMore = false;
    wsRoomModelCheckStatusNotification = null;
    messageActionsModel = MessageActionsModel();
    mentionModel = MentionModel();
    messageDeleteModel = MessageDeleteModel();
    disableQuote();
    disableEditMessage();
    disableSearchMentions();
    disableShare();
    changeStateSearchMessage(false);
    changeEMOJIKeyboardState(false);
  }

  void disablePickMultiMessage() {
    showMessageActionStream
        ?.notify(MessageActionStreamModel(ActionBarMessageState.NONE, null));
    mapMessagePicked.clear();
  }

  void openPickMemberShareMessage() {
    List<WsMessage> listMessagePicked = List();
    if (mapMessagePicked != null && mapMessagePicked.keys != null) {
      mapMessagePicked?.keys?.forEach((key) {
        if (mapMessagePicked[key]) {
          listMessagePicked.add(key);
        }
      });
      if (listMessagePicked.length > 0) {
        showLayoutPickMemberShareStream.notify(listMessagePicked);
      } else {
        Toast.showShort("Vui lòng chọn ít nhất một tin nhắn để chia sẻ");
      }
    } else {
      Toast.showShort("Vui lòng chọn ít nhất một tin nhắn để chia sẻ");
    }
  }

  void disablePickMemberShare() {
    showLayoutPickMemberShareStream?.notify(null);
  }

  //Tắt toàn bộ các tính năng của share
  void disableShare({bool isShowPopupNotification = false}) {
    disablePickMemberShare();
    disablePickMultiMessage();
  }

  void searchContentMessage(String data) {
    showIconSearchStream?.notify(data != "");
    searchData = data;
    if (_timer != null && _timer.isActive) {
      _timer.cancel();
      _timer = null;
    }
    if (data.trim().toString() != "") {
      _timer = Timer.periodic(Duration(milliseconds: 500), (sTimer) {
        Iterable<WsMessage> i = listWsMessage?.where((message) {
          if (message?.messageActionsModel != null) {
            if (message.messageActionsModel.actionType == ActionType.DELETE) {
              return false;
            } else if (message.messageActionsModel.actionType ==
                ActionType.NONE) {
              return message.msg.toLowerCase().contains(data.toLowerCase());
            } else {
              return message.messageActionsModel.msg
                  .toLowerCase()
                  .contains(data.toLowerCase());
            }
          } else {
            return false;
          }
        });
        if (i != null) {
          countSearchResultStream?.notify(i.length);
          if (i.length > 0) {
            chatController.jumpTo(index: listWsMessage.indexOf(i.elementAt(0)));
          }
        } else {
          countSearchResultStream?.notify(0);
        }
        searchDataStream?.notify(data);
        _timer.cancel();
        _timer = null;
      });
    } else {
      searchDataStream?.notify(data);
    }
  }

  void changeStateSearchMessage(bool isShowSearch) {
    showSearchStream?.notify(isShowSearch);
    if (!isShowSearch) {
      searchData = "";
      searchDataStream?.notify("");
      countSearchResultStream.notify(-1);
    } else {
      countSearchResultStream.notify(0);
    }
  }

  bool isBlockedSend = false;

  void changeStateSend(bool isBlocked) {
    isBlockedSend = isBlocked;
    blockSendActionStream.notify(isBlockedSend);
  }

  void checkUserEditContentMessage(String newData) {
    if (newData == null || newData == "") {
      this.messageEdit = null;
      isEditMessage = false;
      changeStateSend(true);
    } else {
      String rootContent = "";
      if (messageEdit != null && messageEdit.messageActionsModel != null) {
        if (messageEdit.messageActionsModel.actionType == ActionType.NONE) {
          rootContent = messageEdit.msg;
        } else {
          rootContent = messageEdit.messageActionsModel.msg;
        }
      }
      changeStateSend(rootContent == newData);
    }
  }

  void updateMessageWhenEdited(data, WsMessage message) {
    String _id = data['_id'];
    if (_id != null && _id != "") {
      MessageActionsModel messageActionsModel =
          MessageActionsModel.fromJson(json.decode(data['msg']));
      listWsMessage?.forEach((wsMessage) {
        if (wsMessage.id == _id) {
          wsMessage.msg = data['msg'];
          wsMessage.messageActionsModel = messageActionsModel;
          wsMessage.reactions = message.reactions;
        }
      });
      if (!message.isSending) {
        HiveHelper.saveListMessageWithRoomID(message.rid, listWsMessage);
      }
      ChatListMessageModel model = ChatListMessageModel(
          state: ChatListMessageState.SHOW, listMessage: listWsMessage);
      chatListMessageStream.notify(model);
    }
  }

  void getPositions(dynamic messageKey) {
    final RenderBox renderBox = messageKey.currentContext.findRenderObject();
    positionStatusBar = renderBox.localToGlobal(Offset.zero);
    sizeStatusBar = renderBox.size;
  }

  void disableEditMessage() {
    messageEdit = null;
    isEditMessage = false;
    changeStateSend(false);
  }

  void reaction(WsRoomModel roomModel, WsMessage message, String rectIconName,
      String userNameReact) async {
    IMessageServices iMessageServices = IMessageServices();
    bool isShouldReact = false;
    String userName = message?.reactions?.mapUserReacted?.keys?.firstWhere(
        (userName) => userNameReact == userName,
        orElse: () => null);
    if (userName == null) {
      isShouldReact = true;
      iMessageServices.reactionMessage(roomModel, message, (result) {},
          (onError) {}, rectIconName, isShouldReact);
    } else {
      if (message.reactions.mapUserReacted[userName] == rectIconName) {
        isShouldReact = false;
      } else {
        await iMessageServices.reactionMessage(roomModel, message, (result) {},
            (onError) {}, message.reactions.mapUserReacted[userName], false);
        isShouldReact = true;
        iMessageServices.reactionMessage(roomModel, message, (result) {},
            (onError) {}, rectIconName, isShouldReact);
      }
    }
  }

  void removeReaction(
      WsRoomModel roomModel, WsMessage message, String userNameReact) async {
    IMessageServices iMessageServices = IMessageServices();
    String userName = message?.reactions?.mapUserReacted?.keys?.firstWhere(
        (userName) => userNameReact == userName,
        orElse: () => null);
    if (userName != null) {
      await iMessageServices.reactionMessage(roomModel, message, (result) {},
          (onError) {}, message.reactions.mapUserReacted[userName], false);
    }
  }

  void updateMessageNormal(WsMessage message) {
    if (listWsMessage.length == 0) {
      listWsMessage.add(message);
      if (!message.isSending) {
        HiveHelper.saveListMessageWithRoomID(message.rid, listWsMessage);
      }
      ChatListMessageModel model = ChatListMessageModel(
          state: ChatListMessageState.SHOW, listMessage: listWsMessage);
      chatListMessageStream.notify(model);
    } else {
      int index = -1;
      for (int i = 0; i < listWsMessage.length; i++) {
        if (message.id == listWsMessage[i].id) {
          index = i;
          break;
        }
      }
      if (index != -1) {
        if (index == listWsMessage.length - 1) {
          listWsMessage.removeAt(listWsMessage.length - 1);
          listWsMessage.add(message);
        } else {
          listWsMessage.removeAt(index);
          listWsMessage.insert(index, message);
        }
        if (!message.isSending) {
          HiveHelper.saveListMessageWithRoomID(message.rid, listWsMessage);
        }
        ChatListMessageModel model = ChatListMessageModel(
            state: ChatListMessageState.SHOW, listMessage: listWsMessage);
        chatListMessageStream.notify(model);
      }
    }
  }

  void _handleErrorToRemoveGroup(
      BuildContext context, AppBloc appBloc, dynamic onError) {
    appBloc.mainChatBloc.removeGroup(roomModel);
    if (onError is String) {
      if (onError == "Cannot read property 'starred' of undefined") {
        HiveHelper.removeCacheRoomMessage(roomModel.id);
        DialogUtils.showDialogCompulsory(context,
            title: "Cảnh báo",
            message:
                "Bạn không còn là thành viên của nhóm. Bạn không thể gửi tin nhắn đến nhóm",
            onClickOK: () {
          appBloc.mainChatBloc.backLayout(appBloc, roomModel);
        });
      }
    }
  }

  void _handleErrorWhenGetListMessage(WsRoomModel roomModel) async {
    List<WsMessage> listData =
        await HiveHelper.getListMessageByRoomID(roomModel?.id);
    if (listData != null && listData.length > 0) {
      ChatListMessageModel model = ChatListMessageModel(
          state: ChatListMessageState.SHOW, listMessage: listData);
      changeListMessageData(model);
    } else {
      ChatListMessageModel model =
          ChatListMessageModel(state: ChatListMessageState.NO_DATA);
      changeListMessageData(model);
    }
  }
}

typedef OnResultDetect = Function(String);
typedef OnErrorDetect = Function(String);
enum ChatListMessageState {
  LOADING,
  NO_DATA,
  SHOW,
  ERROR,
}

class ChatListMessageModel {
  ChatListMessageState state;
  List<WsMessage> listMessage;
  String error;

  ChatListMessageModel({@required this.state, this.listMessage, this.error});
}
