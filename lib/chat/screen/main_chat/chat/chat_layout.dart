import 'dart:io';
import 'package:camera/camera.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/buble_chat/MessageRevokeItem.dart';
import 'package:human_resource/chat/buble_chat/item_direct_room.dart';
import 'package:human_resource/chat/buble_chat/message_item.dart';
import 'package:human_resource/chat/buble_chat/message_item_image.dart';
import 'package:human_resource/chat/buble_chat/message_item_other_file.dart';
import 'package:human_resource/chat/chat_model/information_member_model.dart';
import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/chat_model/validate_info_message.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/screen/camera/camera_screen.dart';
import 'package:human_resource/chat/screen/camera/preview_picture_screen.dart';
import 'package:human_resource/chat/screen/main_chat/chat/chat_bloc.dart';
import 'package:human_resource/chat/screen/main_chat/chat/status_action_screen.dart';
import 'package:human_resource/chat/screen/main_chat/layout/channel_action/kick_member_layout.dart';
import 'package:human_resource/chat/screen/main_chat/layout/channel_action/member_profile_layout.dart';
import 'package:human_resource/chat/screen/main_chat/layout/channel_action/pick_member_share_layout.dart';
import 'package:human_resource/chat/screen/main_chat/layout/channel_action/room_info_layout.dart';
import 'package:human_resource/chat/screen/reaction/reaction_widget.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_attachment.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_file.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_typing_model.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/core/message/message_services.dart';
import 'package:human_resource/core/platform/platform_helper.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/model/image_native_model.dart';
import 'package:human_resource/utils/animation/ZoomInAnimation.dart';
import 'package:human_resource/utils/common/audio_record_helper.dart';
import 'package:human_resource/utils/common/cache_helper.dart';
import 'package:human_resource/utils/common/const.dart';
import 'package:human_resource/utils/common/crypto_hex.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/chat_layout_child/button_open_close.dart';
import 'package:human_resource/utils/widget/chat_layout_child/chat_layout_user_name.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/image_show_layout.dart';
import 'package:human_resource/utils/widget/loading_indicator.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';
import 'package:human_resource/utils/widget/mention_member_widget.dart';
import 'package:human_resource/utils/widget/quote_widget.dart';
import 'package:human_resource/utils/widget/record_widget.dart';
import 'package:human_resource/utils/widget/result_detect_widget.dart';
import 'package:human_resource/utils/widget/show_screenshot.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'layout_action_bloc.dart';
import 'message_action_screen.dart';

class ChatLayout extends StatefulWidget {
  final WsRoomModel roomModel;

  const ChatLayout({Key key, this.roomModel}) : super(key: key);

  @override
  _ChatLayoutState createState() => _ChatLayoutState();
}

enum RoomAction { ADD_MEMBER, REMOVE_MEMBER }

class _ChatLayoutState extends State<ChatLayout> with WidgetsBindingObserver {
  AppBloc appBloc;
  ScrollController controller;
  bool isShowKeyBoard = false;
  AudioRecordHelper helper;
  bool isShowRecordWidget = false;
  TextEditingController _messageTextController = TextEditingController();
  TextEditingController _searchTextController = TextEditingController();
  FocusNode _focus = new FocusNode();
  FocusNode _focusSearch = new FocusNode();
  int maxLine = 1;
  LayoutActionBloc _layoutActionBloc = LayoutActionBloc();
  CameraDescription cameraDescription;
  Offset positionIMessage;
  bool statusEdit = false;
  bool styleOBJ = false;
  ChatBloc chatBloc;
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ItemScrollController chatController = ItemScrollController();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      appBloc.openLayoutSendImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = ModalRoute.of(context);
    page.didPush().then((x) {
      SystemChrome.setSystemUIOverlayStyle(prefix0.statusBarAccent);
    });
    appBloc = BlocProvider.of(context);
    chatBloc = appBloc.mainChatBloc.chatBloc;
    chatBloc.chatController = chatController;
    chatBloc.isOpenned = true;
    chatBloc.setRoomModelFromChatLayout(widget.roomModel);
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.CHAT_LAYOUT);
    String ids = WebSocketHelper.getInstance().wsAccountModel?.id ?? "";
    String ids2 = widget.roomModel.skAccountModel?.id ?? "";
    bool isOwnerMsg123 = ids2 == ids;
    chatBloc.layoutActionBloc = _layoutActionBloc;

    return WillPopScope(
      onWillPop: () async {
        if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.CHAT_LAYOUT) {
          if (isShowRecordWidget)
            _hideLayoutRecord();
          else {
            _messageTextController.clear();
            if (appBloc.mainChatBloc.chatBloc.isEditMessage) {
              appBloc.mainChatBloc.chatBloc.disableEditMessage();
            } else if (appBloc.mainChatBloc.chatBloc.isOpenQuote) {
              appBloc.mainChatBloc.chatBloc.disableQuote();
            } else {
              appBloc.backStateBloc.focusWidgetModel =
                  FocusWidgetModel(state: isFocusWidget.HOME);
              appBloc.homeBloc.backLayoutNotBottomBar();
            }
          }
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.MESSAGE_ACTION_SCREEN) {
          appBloc.backStateBloc.focusWidgetModel.state =
              isFocusWidget.CHAT_LAYOUT;
          closeActionMessage();
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.SEARCH_MESSAGE_CONTENT) {
          appBloc.backStateBloc.focusWidgetModel.state =
              isFocusWidget.CHAT_LAYOUT;
          _cancelSearch();
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.CHOOSE_MULTI_MESSAGE) {
          appBloc.backStateBloc.focusWidgetModel.state =
              isFocusWidget.CHAT_LAYOUT;
          closeActionMessage();
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.STATUS_ACTION_SCREEN) {
          appBloc.backStateBloc.focusWidgetModel.state =
              isFocusWidget.CHAT_LAYOUT;
          closeActionMessage();
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.PICK_MEMBER_SHARE) {
          appBloc.backStateBloc.focusWidgetModel.state =
              isFocusWidget.CHAT_LAYOUT;
          chatBloc.disableShare();
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.CHAT_ROOM_INFO) {
          if (appBloc.backStateBloc.hideLayoutWithStream != null) {
            appBloc.backStateBloc.hideLayoutWithStream.notify(false);
            appBloc.backStateBloc.hideLayoutWithStream = null;
          } else {
            _layoutActionBloc.changeState(LayoutActionState.NONE);
            appBloc.backStateBloc.focusWidgetModel =
                FocusWidgetModel(state: isFocusWidget.CHAT_LAYOUT);
          }
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.MEMBER_PROFILE) {
          _layoutActionBloc.changeState(LayoutActionState.ROOM_INFO,
              data: isOwnerMsg123);
          appBloc.backStateBloc.focusWidgetModel =
              FocusWidgetModel(state: isFocusWidget.CHAT_LAYOUT);
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
                isFocusWidget.CAMERA ||
            appBloc.backStateBloc.focusWidgetModel.state ==
                isFocusWidget.IMAGE_SHOW) {
          SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
          chatBloc.showOtherLayoutStream
              .notify(OtherLayoutModelStream(OtherLayoutState.NONE, null));
          appBloc.backStateBloc.focusWidgetModel =
              FocusWidgetModel(state: isFocusWidget.CHAT_LAYOUT);
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.PREVIEW_PICTURE) {
          chatBloc.updateOtherLayout(OtherLayoutState.CAMERA);
        }
        return false;
      },
      child: Stack(
        children: <Widget>[
          _buildLayoutChat(),
          _buildLayoutGroupAction(),
          StreamBuilder(
            initialData: OtherLayoutModelStream(OtherLayoutState.NONE, null),
            stream: chatBloc.showOtherLayoutStream.stream,
            builder: (buildContext,
                AsyncSnapshot<OtherLayoutModelStream> showLargeImage) {
              switch (showLargeImage.data.state) {
                case OtherLayoutState.NONE:
                  cameraDescription = null;
                  return Container();
                  break;
                case OtherLayoutState.CAMERA:
                  return TakePictureScreen(
                      cameraDescription, widget.roomModel.id);
                  break;
                case OtherLayoutState.PREVIEW_IMAGE:
                  return DisplayPictureScreen(
                      showLargeImage.data.data, widget.roomModel);
                  break;
                case OtherLayoutState.IMAGE_SHOW:
                  if (showLargeImage.data.data != null) {
                    WsFile wsFile = (showLargeImage.data.data[0] as WsFile);
                    return ImageShowLayout(
                      imageFile: showLargeImage.data.data[1] as WsImageFile,
                      fileName: wsFile.name,
                      messageID: wsFile.id,
                    );
                  } else {
                    return Container();
                  }
                  break;
              }
              return Container();
            },
          ),
          StreamBuilder(
              initialData: false,
              stream: chatBloc.loadingStream.stream,
              builder:
                  (loadingBuildContext, AsyncSnapshot<bool> loadingSnapshot) {
                return Visibility(
                  visible: loadingSnapshot.data,
                  child: Loading(),
                );
              }),
          StreamBuilder(
            initialData:
                MessageActionStreamModel(ActionBarMessageState.NONE, null),
            stream: chatBloc.showMessageActionStream.stream,
            builder: (buildContext,
                AsyncSnapshot<MessageActionStreamModel> showMessageAction) {
              switch (showMessageAction.data.state) {
                case ActionBarMessageState.DEFAULT:
                  return MessageActionScreen(
                    isOwnerOfMessage: showMessageAction
                            .data.messageHasAction.skAccountModel.userName ==
                        appBloc.authBloc.asgUserModel.username,
                    iMessageType:
                        showMessageAction.data.messageHasAction.file != null
                            ? IMessageType.FILE
                            : IMessageType.TEXT,
                    onCloseAction: () {
                      closeActionMessage();
                    },
                    onQuoteAction: () {
                      _messageTextController.clear();
                      _cancelSearch();
                      chatBloc.quoteMessage(
                          context, showMessageAction.data.messageHasAction);
                      chatBloc.showActionChatStream.notify(false);
                    },
                    onCopyAction: () {
                      _cancelSearch();
                      chatBloc.copyMessage(
                          context, showMessageAction.data.messageHasAction);
                    },
                    onEditAction: () {
                      _cancelSearch();
                      _handleEditClicked(
                          showMessageAction.data.messageHasAction);
                    },
                    onRevokeAction: () {
                      _cancelSearch();
                      chatBloc.revokeMessage(
                          widget.roomModel.id,
                          showMessageAction.data.messageHasAction.id,
                          widget.roomModel);
                    },
                    onChooseMultiMessage: () {
                      _cancelSearch();
                      appBloc.backStateBloc.focusWidgetModel.state =
                          isFocusWidget.CHOOSE_MULTI_MESSAGE;
                      chatBloc.mapMessagePicked[
                          showMessageAction.data.messageHasAction] = true;
                      chatBloc.showMessageActionStream?.notify(
                          MessageActionStreamModel(
                              ActionBarMessageState.CHOOSEMESSAGE,
                              showMessageAction.data.messageHasAction));
                    },
                    onDetectImage: () {
                      _cancelSearch();
                      chatBloc.showMessageActionStream?.notify(
                          MessageActionStreamModel(
                              ActionBarMessageState.NONE, null));
                      chatBloc.onDetectTextFromImage(
                          showMessageAction.data.messageHasAction.file.id,
                          (result) {
                        chatBloc.updateStateResultDetect(
                            "Trích xuất văn bản thành công",
                            ResultDetectState.SUCCESS);
                        _messageTextController.text = result;
                        _focus.requestFocus();
                      }, (onError) {
                        chatBloc.updateStateResultDetect(
                            "Trích xuất văn bản thất bại.",
                            ResultDetectState.FAILED);
                      });
                    },
                    chooseStatus: (status) {
                      chatBloc.reaction(
                          widget.roomModel,
                          showMessageAction.data.messageHasAction,
                          status,
                          appBloc.authBloc.asgUserModel.username);
                      Future.delayed(Duration(milliseconds: 1500), () {
                        chatBloc.showMessageActionStream?.notify(
                            MessageActionStreamModel(
                                ActionBarMessageState.NONE, null));
                      });
                    },
                    removeReact: () {
                      chatBloc.showMessageActionStream?.notify(
                          MessageActionStreamModel(
                              ActionBarMessageState.NONE, null));
                      chatBloc.removeReaction(
                          widget.roomModel,
                          showMessageAction.data.messageHasAction,
                          appBloc.authBloc.asgUserModel.username);
                    },
                    offsetStatus: positionIMessage,
                  );
                case ActionBarMessageState.CHOOSEMESSAGE:
                  return MessageActionScreen(
                    onShare: () {
                      chatBloc.openPickMemberShareMessage();
                    },
                    isOwnerOfMessage: showMessageAction
                            .data?.messageHasAction?.skAccountModel?.userName ==
                        appBloc?.authBloc?.asgUserModel?.username,
                    iMessageType:
                        showMessageAction?.data?.messageHasAction?.file != null
                            ? IMessageType.FILE
                            : IMessageType.TEXT,
                    onCloseAction: () {
                      closeActionMessage();
                    },
                    onQuoteAction: () {},
                    isCheckChooseMultilMessage: true,
                    offsetStatus: positionIMessage,
                    onDetectImage: () {},
                    onEditAction: () {},
                    onChooseMultiMessage: () {},
                    onRevokeAction: () {},
                    onCopyAction: () {},
                  );
                  break;
                case ActionBarMessageState.CHOOSESTATUS:
                  return StatusActionScreen(
                    message: showMessageAction.data.messageHasAction,
                    onCloseAction: () {
                      appBloc.mainChatBloc.chatBloc.showMessageActionStream
                          ?.notify(MessageActionStreamModel(
                              ActionBarMessageState.NONE, null));
                    },
                  );
                  break;
                default:
                  return Container();
                  break;
              }
            },
          ),
          StreamBuilder(
              initialData: null,
              stream: appBloc
                  .mainChatBloc.chatBloc.showLayoutPickMemberShareStream.stream,
              builder: (buildContext,
                  AsyncSnapshot<List<WsMessage>> showLayoutPickMemberShare) {
                if (!showLayoutPickMemberShare.hasData ||
                    showLayoutPickMemberShare.data == null ||
                    showLayoutPickMemberShare.data.length == 0) {
                  return Container();
                }
                return PickMemberShareLayout(
                  roomModel: widget.roomModel,
                  showPopupShared: () {
                    DialogUtils.showDialogResult(
                        context, DialogType.SUCCESS, "Đã chia sẻ nội dung.");
                  },
                  onInit: () {
                    //Back layout
                  },
                  onBackLayout: () {
                    chatBloc.disablePickMemberShare();
                  },
                  listMessagePicked: showLayoutPickMemberShare.data,
                );
              }),
        ],
      ),
    );
  }

  bool checkRverseListView() {
    if (widget.roomModel.name.contains(Const.THONG_BAO) ||
        widget.roomModel.name.contains(Const.BAN_TIN)) {
      return false;
    } else {
      return true;
    }
  }

  bool checkShowAvatar(List<WsMessage> listMessage, int index) {
    if (widget.roomModel.name == Const.BAN_TIN ||
        widget.roomModel.name == Const.FAQ ||
        widget.roomModel.name.contains(Const.THONG_BAO)) {
      return true;
    } else {
      if (listMessage.length == 1 || index == listMessage.length - 1) {
        return true;
      } else {
        if (listMessage[index]?.skAccountModel?.id ==
            listMessage[index + 1]?.skAccountModel?.id) {
          return false;
        } else {
          return true;
        }
      }
    }
  }

  customAppbar() {
    String name = "";
    if (widget.roomModel.roomType == RoomType.d) {
      widget.roomModel?.listUserDirect?.forEach((usName) {
        if (usName != WebSocketHelper.getInstance().userName) {
          name = usName;
        }
      });
      return AppBar(
          centerTitle: false,
          titleSpacing: 0.0,
          elevation: 0.0,
          backgroundColor: Color(0xFF005a88),
          title: Container(
            height: ScreenUtil().setHeight(178.5),
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 0,
                  child: InkWell(
                      splashColor: prefix0.transparentColor,
                      onTap: () {
                        if (isShowRecordWidget)
                          _hideLayoutRecord();
                        else {
                          _focus.unfocus();
                          appBloc.mainChatBloc
                              .backLayout(appBloc, widget.roomModel);
                        }
                      },
                      child: Container(
                        height: ScreenUtil().setHeight(178.5),
                        margin: EdgeInsets.only(
                            left: 60.w, right: 59.w, bottom: 66.2.w),
                        child: Image.asset(
                          'asset/images/ic_meeting_back_white.png',
                          width: ScreenUtil().setWidth(49.9),
                          color: prefix0.white,
                        ),
                      )),
                ),
                Positioned(
                    left: 169.0.w,
                    child: Container(
                      height: ScreenUtil().setHeight(178.5),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          ///Lấy ra tên người chat
                          _buildLineName(name),
                          StreamBuilder(
                              initialData: appBloc.mainChatBloc.listUserOnLine,
                              stream: appBloc
                                  .mainChatBloc.listUserOnlineStream.stream,
                              builder: (statusBuilder,
                                  AsyncSnapshot<List<AddressBookModel>>
                                      snapshot) {
                                String status = "Đang offline";
                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  status = "Đang offline";
                                } else {
                                  snapshot.data?.forEach((user) {
                                    if (user.username == name) {
                                      if (user.status == "offline") {
                                        status = "Đang offline";
                                      } else {
                                        status = "Đang online";
                                      }
                                    }
                                  });
                                }
                                return Text(
                                  status,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(40),
                                    fontWeight: FontWeight.normal,
                                    color: prefix0.grey1Color,
                                    fontFamily: 'Roboto-Regular',
                                  ),
                                );
                              })
                        ],
                      ),
                    )),
              ],
            ),
          ),
          actions: <Widget>[
            InkWell(
              onTap: () {
                closeActionMessage();
                _createCallPhone();
              },
              child: Container(
                margin: EdgeInsets.only(right: 62.9.w),
                child: Icon(
                  Icons.call,
                  size: 56.0.w,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                closeActionMessage();
                InformationMemberModel info = InformationMemberModel.createWith(
                  widget.roomModel.name,
                  true,
                  widget.roomModel.id,
                );
                appBloc.homeBloc.openMemberProfileLayout({
                  "owner": true,
                  "user": info,
                  "roomModel": widget.roomModel,
                  "roomId": widget.roomModel.id,
                  "openNotification": true
                });
              },
              child: Container(
                margin: EdgeInsets.only(right: 62.9.w),
                child: Icon(
                  Icons.info,
                  color: prefix0.white,
                  size: ScreenUtil().setWidth(56),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                right: ScreenUtil().setWidth(59.1),
              ),
              child: InkWell(
                onTap: () {
                  closeActionMessage();
                  _loadLatestMessage();
                },
                child: Icon(
                  Icons.sync,
                  size: 56.0.w,
                ),
              ),
            ),
          ]);
    } else {
      bool isShowMenu = false;
      String titleName = "";
      String subtitle = "";
      if (widget.roomModel.name == Const.FAQ) {
        titleName = "FAQ";
      } else if (widget.roomModel.name == Const.BAN_TIN) {
        titleName = "Bản tin";
      } else if (widget.roomModel.name ==
          Const.THONG_BAO + appBloc.authBloc.asgUserModel.id.toString()) {
        titleName = "Thông báo";
      } else {
        titleName = CryptoHex.deCodeChannelName(widget.roomModel.name);
        subtitle = "${widget.roomModel.usersCount} thành viên";
        isShowMenu = true;
      }

      //Appbar cho giao diện chat nhóm
      return AppBar(
        titleSpacing: 0.0,
        backgroundColor: prefix0.accentColor,
        centerTitle: false,
        title: Container(
            width: MediaQuery.of(context).size.width,
            height: 178.5.h,
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 0,
                  child: InkWell(
                    onTap: () {
                      if (isShowRecordWidget)
                        _hideLayoutRecord();
                      else {
                        _focus.unfocus();
                        appBloc.mainChatBloc
                            .backLayout(appBloc, widget.roomModel);
                      }
                    },
                    child: Container(
                      width: 170.w,
                      height: 178.5.h,
                      padding: EdgeInsets.only(
                        left: 60.w,
                        right: 59.w,
                        bottom: 66.2.h,
                        top: 60.h,
                      ),
                      child: Image.asset(
                          'asset/images/ic_meeting_back_white.png',
                          width: ScreenUtil().setWidth(49.9),
                          color: prefix0.white),
                    ),
                  ),
                ),
                Positioned(
                  left: 169.0.w,
                  bottom: 37.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        titleName,
                        style: TextStyle(
                            fontFamily: "Roboto-Bold",
                            fontSize: ScreenUtil().setSp(50.0),
                            color: prefix0.white,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "$subtitle thành viên",
                        style: TextStyle(
                            fontFamily: "Roboto-Regular",
                            fontSize: ScreenUtil().setSp(40.0),
                            color: prefix0.white,
                            fontWeight: FontWeight.normal),
                      )
                    ],
                  ),
                )
              ],
            )),
        elevation: 0,
        actions: <Widget>[
//          IconButton(
//            onPressed: () {},
//            icon: Icon(Icons.videocam),
//          ),
          isShowMenu ? _buildLayoutAction() : Container(),
          Container(
            margin: EdgeInsets.only(
              right: ScreenUtil().setWidth(59.1),
            ),
            child: InkWell(
              onTap: () {
                closeActionMessage();
                _loadLatestMessage();
              },
              child: Icon(
                Icons.sync,
                size: 56.0.w,
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appBloc.mainChatBloc.readAllMessage(widget.roomModel);
    chatBloc.resetVariable();
    _layoutActionBloc?.dispose();
    WebSocketHelper.getInstance().disableTyping(widget.roomModel.id);
    WebSocketHelper.getInstance().unSubRoomEvent();
    WebSocketHelper.getInstance().unSubRoomByRoomID();
    if (isShowRecordWidget) _hideLayoutRecord();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      chatBloc.userCountStream.notify(widget.roomModel.usersCount);

      WebSocketHelper.getInstance().subRoomEvent(widget.roomModel.id);
      WebSocketHelper.getInstance().subRoomByRoomID(widget.roomModel.id);
      if (widget.roomModel.roomType == RoomType.p) {
        chatBloc.getAllUserOnGroup(context, roomModel: widget.roomModel);
      }
      _loadLatestMessage(isLoadCacheFirst: true);
    });
    itemPositionsListener.itemPositions.addListener(() {
      if (itemPositionsListener?.itemPositions?.value != null &&
          itemPositionsListener.itemPositions.value.length > 0) {
        int index =
            itemPositionsListener?.itemPositions?.value?.last?.index ?? -1;
        if (index == chatBloc.listWsMessage.length - 1 && index >= 49) {
          chatBloc.checkAmountMessageRemain(context, widget.roomModel.id,
              widget.roomModel.roomType == RoomType.p ? "p" : "d");
        }
      }
    });
    _focus.addListener(_onFocusChange);
  }

  _buildLayoutAction() {
    if (widget.roomModel.roomType == RoomType.d) {
      return Container();
    } else if (widget.roomModel.roomType == RoomType.c) {
      return Container();
    }

    bool isOwnerMsg = widget.roomModel.skAccountModel.id ==
        WebSocketHelper.getInstance().wsAccountModel.id;
    if (widget.roomModel.roomType == RoomType.p) {
      return InkWell(
          child: Container(
            margin: EdgeInsets.only(right: 62.9.w),
            child: Center(
              child: Icon(
                Icons.info,
                color: prefix0.white,
                size: ScreenUtil().setWidth(56),
              ),
            ),
          ),
          onTap: () {
            closeActionMessage();
            _focus.unfocus();
            _layoutActionBloc.changeState(LayoutActionState.ROOM_INFO,
                data: isOwnerMsg);
          });
      /*return PopupMenuButton(
          offset: Offset(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                SizeRender.renderBorderSize(context, 10.0)),
            side: BorderSide.none,
          ),
          elevation: 10.0,
          onSelected: (titleSelected) {
            if (titleSelected == "Thêm thành viên") {
              Future.delayed(Duration(milliseconds: 500), () {
                _layoutActionBloc.changeState(LayoutActionState.ADD_USER);
              });
            } else if (titleSelected == "Thông tin nhóm") {
              _layoutActionBloc.changeState(LayoutActionState.ROOM_INFO);
            } else if (titleSelected == "Rời bỏ nhóm") {
              WsAccountModel accountModel =
                  WebSocketHelper.getInstance().wsAccountModel;
              if (widget.roomModel.skAccountModel.id != accountModel.id) {
                Future.delayed(Duration(milliseconds: 500), () {
                  _showDialogLeaveRoom();
                });
              } else {
                Toast.showShort("Admin không thể rời khỏi nhóm");
              }
            } else if (titleSelected == "Xóa thành viên") {
              _layoutActionBloc.changeState(LayoutActionState.KICK_USER);
            }
          },
          icon: Icon(
            Icons.info,
            color: prefix0.white,
          ),
          itemBuilder: (buildContext) {
            return listData.map((title) {
              return PopupMenuItem<String>(
                  value: title,
                  child: Text(
                    title,
                    style: TextStyle(
                        fontFamily: 'Roboto-Regular',
                        fontSize: ScreenUtil().setSp(42.0),
                        color: prefix0.blackColor333),
                  ));
            }).toList();
          });*/
    } else {
      return Container();
    }
  }

  Widget _buildLayoutChat() {
    return Scaffold(
      appBar: customAppbar(),
      body: GestureDetector(
        onTap: () {
          chatBloc.disableSearchMentions();
          _focus.unfocus();
          if (chatBloc.isShowEMOJI) {
            chatBloc.changeEMOJIKeyboardState(false);
          }
        },
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              StreamBuilder(
                  initialData: ResultDetectModel(
                      message: "", state: ResultDetectState.NONE),
                  stream: appBloc
                      .mainChatBloc.chatBloc.showResultDetectStream.stream,
                  builder: (buildContext,
                      AsyncSnapshot<ResultDetectModel> snapshotData) {
                    if (!snapshotData.hasData || snapshotData.data == null) {
                      return Container();
                    } else {
                      if (snapshotData.data.state == ResultDetectState.NONE) {
                        return Container();
                      }
                      return ResultDetectWidget(
                        resultData: snapshotData.data,
                        onDisableWidget: () {
                          chatBloc.updateStateResultDetect(
                              null, ResultDetectState.NONE);
                        },
                      );
                    }
                  }),
              StreamBuilder(
                  initialData: false,
                  stream: chatBloc.showSearchStream.stream,
                  builder:
                      (buildSearchContext, AsyncSnapshot<bool> showSearch) {
                    if (showSearch.data) {
                      appBloc.backStateBloc.focusWidgetModel.state =
                          isFocusWidget.SEARCH_MESSAGE_CONTENT;
                      return _buildSearchContentMessage();
                    }
                    return Container();
                  }),
              StreamBuilder(
                  initialData: false,
                  stream: chatBloc.loadMoreStream.stream,
                  builder:
                      (loadMoreContext, AsyncSnapshot<bool> asyncSnapshot) {
                    if (asyncSnapshot.data) {
                      return LoadingIndicator();
                    } else {
                      return Container();
                    }
                  }),
              Expanded(
                  child: Stack(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height,
                    //Lấy danh sach tin nhắn trong nhóm
                    child: _buildListMessage(),
                  ),
                  Positioned(
                    right: 10.0,
                    bottom: 0,
                    child: StreamBuilder(
                        initialData: appBloc.getListImageFromNative(),
                        stream: appBloc.showNewImageNativeStream.stream,
                        builder: (buildContext,
                            AsyncSnapshot<List<ImageNativeModel>> snapshot) {
                          if (snapshot.data.length == 0) {
                            return Container();
                          } else {
                            return ShowScreenshot(
                              onClose: () {
                                appBloc.clearListImageFromNative();
                              },
                              onSendImage: () {
                                appBloc.sendAllImageToRoom(widget.roomModel);
                              },
                            );
                          }
                        }),
                  )
                ],
              )),
              StreamBuilder(
                  initialData: MessageActionStreamModel(
                      ActionBarMessageState.NONE, null),
                  stream: appBloc
                      .mainChatBloc.chatBloc.showMessageActionStream.stream,
                  builder: (buildContext,
                      AsyncSnapshot<MessageActionStreamModel>
                          showMessageAction) {
                    switch (showMessageAction.data.state) {
                      case ActionBarMessageState.CHOOSEMESSAGE:
                        return SizedBox(
                          height: 49.8.h,
                        );
                        break;
                      default:
                        return Container();
                        break;
                    }
                  }),
              StreamBuilder(
                  initialData: -1,
                  stream: appBloc
                      .mainChatBloc.chatBloc.countSearchResultStream.stream,
                  builder:
                      (countSearchContext, AsyncSnapshot<int> showSnapshot) {
                    if (showSnapshot.data == -1) {
                      return _buildLineSendChat();
                    } else {
                      return _buildSearchResult(showSnapshot.data);
                    }
                  }),
              StreamBuilder(
                  initialData: false,
                  stream: chatBloc.recodeLayoutStream.stream,
                  builder:
                      (buildContext, AsyncSnapshot<bool> showRecordSnapshot) {
                    if (!showRecordSnapshot.data) {
                      return Container();
                    } else {
                      return RecordWidget(
                        roomID: widget.roomModel.id,
                        onDestroy: () {
                          if (isShowRecordWidget) {
                            isShowRecordWidget = false;
                          }
                        },
                        onCancelBottomSheet: () {
                          _hideLayoutRecord();
                        },
                      );
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayoutGroupAction() {
    return StreamBuilder(
        stream: _layoutActionBloc.actionModelStream.stream,
        initialData: LayoutActionModel(LayoutActionState.NONE),
        builder: (layoutContext, AsyncSnapshot<LayoutActionModel> layoutSnap) {
          switch (layoutSnap.data.state) {
            case LayoutActionState.NONE:
              return Container();
              break;
            case LayoutActionState.KICK_USER:
              return KickMemberActionLayout(
                roomModel: widget.roomModel,
                layoutActionBloc: _layoutActionBloc,
              );
              break;
            case LayoutActionState.ROOM_INFO:
              return RoomInfoLayout(
                roomModel: widget.roomModel,
                layoutActionBloc: _layoutActionBloc,
                isOwner: layoutSnap.data.data,
                onInit: () {
                  appBloc.backStateBloc.focusWidgetModel.state =
                      isFocusWidget.CHAT_ROOM_INFO;
                },
              );
              break;
            case LayoutActionState.MEMBER_PROFILE:
              return MemberProfileLayout(
                onInit: () {
                  appBloc.backStateBloc.focusWidgetModel.state =
                      isFocusWidget.MEMBER_PROFILE;
                },
                roomModel: widget.roomModel,
                layoutActionBloc: _layoutActionBloc,
                dataShow: layoutSnap.data.data,
                isScreenInChatLayout: true,
              );
              break;
            default:
              return Container();
              break;
          }
        });
  }

  _buildLineName(String name) {
    ItemRoomBloc itemRoomBloc = ItemRoomBloc();
    itemRoomBloc.getUserInfo(context, name);
    return Flexible(
        child: ChatUserNameAppBar(
      name: name,
    ));
  }

  _buildLineNoData() {
    String _content = "";
    if (widget.roomModel.roomType == RoomType.d) {
      _content = "Hãy gửi một tin nhắn.";
    } else {
      _content = "Hiện chưa có thông tin nào.";
    }
    return Center(
      child: Text(_content),
    );
  }

  //Tân sửa screen này
  _buildLineSendChat() {
    if (widget.roomModel.ro != null && widget.roomModel.ro) {
      return Container();
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        StreamBuilder(
            initialData: TypingModel(userName: "", isTyping: false),
            stream: chatBloc.typingStream.stream,
            builder: (buildContext, AsyncSnapshot<TypingModel> typingSnap) {
              if (typingSnap.data.isTyping) {
                return Container(
                  margin: EdgeInsets.only(bottom: 5.0, left: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "${typingSnap.data.userName} đang soạn tin",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: prefix0.accentColor,
                            fontSize: 35.0.sp,
                            fontFamily: "Roboto-Regular"),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 1.0, left: 3.0),
                        child: LoadingIndicator(
                          color: prefix0.accentColor,
                          size: 5.0,
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return Container();
              }
            }),
        _buildContentQuote(),
//        show_screenshot(),
        //Giao diện khi chọn người dùng để tag
        StreamBuilder(
          initialData: false,
          stream: chatBloc.searchMentionsUserStream.stream,
          builder: (BuildContext searchContext, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.data) {
              return Container();
            } else {
              chatBloc.getAllUserOnGroup(context, roomModel: widget.roomModel);
              return StreamBuilder(
                  initialData: chatBloc.listAllUserGroupNotPicked,
                  stream: appBloc
                      .mainChatBloc.chatBloc.listAllUserGroupStream.stream,
                  builder: (listContext,
                      AsyncSnapshot<List<RestUserModel>> snapshotData) {
                    if (!snapshotData.hasData || snapshotData.data == null)
                      return Container();
                    return Container(
                      constraints: BoxConstraints(maxHeight: 515.0.h),
                      child: MentionMemberWidget(
                        listMemberShow: snapshotData.data,
                        onTagAll: () {
                          chatBloc.mentionsAllUser();
                          updateTextControllerMentionAll();
                        },
                        onTagMember: (userTag) {
                          chatBloc.tagMember(userTag);
                          updateTextController(userTag);
                        },
                      ),
                    );
                  });
            }
          },
        ),
        Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
                top: 31.0.h,
                bottom: 31.0.h,
                right: ScreenUtil().setWidth(59.0)),
            decoration: BoxDecoration(
              color: prefix0.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ButtonOpenOrClose(
                  onClick: (isOpen) {
                    chatBloc.showActionChatStream?.notify(!isOpen);
                    if (chatBloc.isShowEMOJI) {
                      chatBloc.changeEMOJIKeyboardState(false);
                    }
                  },
                ),
//                    _buildButtonOpenOrClose(showActionSnap.data),
                ReactionListButton(
                  onClickAttachment: () {
                    if (chatBloc.isShowEMOJI) {
                      chatBloc.changeEMOJIKeyboardState(false);
                    }
                    _focus.unfocus();
                    _pickFileOnDevice();
                  },
                  onClickCamera: () {
                    if (chatBloc.isShowEMOJI) {
                      chatBloc.changeEMOJIKeyboardState(false);
                    }
                    _focus.unfocus();
                    _openCamera();
                  },
                  onClickEmoji: () {
                    if (chatBloc.isShowEMOJI) {
                      _focus.requestFocus();
                      chatBloc.changeEMOJIKeyboardState(false);
                    } else {
                      if (_focus != null && _focus.hasFocus) {
                        _focus.unfocus();
                      }
                      chatBloc.changeEMOJIKeyboardState(true);
                    }
                  },
                  onClickPickImage: () {
                    chatBloc.changeEMOJIKeyboardState(false);
                    _focus.unfocus();
                    _pickerImages();
                  },
                ),
                Expanded(
                  child: Container(
                      constraints: BoxConstraints(
                        minHeight: 129.0.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xffe8e8e8),
                        borderRadius: BorderRadius.circular(
                            SizeRender.renderBorderSize(context, 65.0)),
                      ),
                      child: StreamBuilder(
                          initialData: true,
                          stream: chatBloc.showActionChatStream.stream,
                          builder: (buildContext,
                              AsyncSnapshot<bool> showActionSnap) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(
                                  width: ScreenUtil().setWidth(57.7),
                                ),
                                Flexible(
                                  child: Container(
                                    constraints: BoxConstraints(
                                        minHeight: 129.0.h, maxHeight: 350.0.h),
                                    child: TextField(
                                      focusNode: _focus,
                                      cursorColor: prefix0.blackColor333,
                                      onChanged: (data) {
                                        _handleDataChange(showActionSnap, data);
                                        _handleMention(showActionSnap, data);
                                      },
                                      style: TextStyle(
                                        fontFamily: "Roboto-Regular",
                                        fontSize: ScreenUtil().setSp(50.0),
                                        color: prefix0.blackColor333,
                                      ),
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      controller: _messageTextController,
                                      maxLines: null,
                                      textAlign: TextAlign.start,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        hintText: "Nhập nội dung của bạn",
                                        hintStyle: TextStyle(
                                          fontFamily: "Roboto-Regular",
                                          fontSize: ScreenUtil().setSp(50.0),
                                          color: Color(0xff9a9ca4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                StreamBuilder(
                                    initialData: false,
                                    stream:
                                        chatBloc.blockSendActionStream.stream,
                                    builder: (buildContext,
                                        AsyncSnapshot<bool> blockSendSnapshot) {
                                      if (blockSendSnapshot.data) {
                                        return Container(
                                          margin: EdgeInsets.only(
                                              bottom:
                                                  ScreenUtil().setHeight(18),
                                              top: ScreenUtil().setHeight(20),
                                              right: ScreenUtil().setWidth(24)),
                                          child: InkWell(
                                            onTap: () {
                                              if (chatBloc.isEditMessage) {
                                                _messageTextController.clear();
                                                chatBloc.disableEditMessage();
                                              }
                                            },
                                            child: Image.asset(
                                              "asset/images/action/ic_block_send_quote.png",
                                              width: ScreenUtil().setHeight(91),
                                            ),
                                          ),
                                        );
                                      }
                                      return Container(
                                        margin: EdgeInsets.only(
                                            bottom: ScreenUtil().setHeight(20),
                                            top: ScreenUtil().setHeight(20),
                                            right: ScreenUtil().setWidth(24)),
                                        child: InkWell(
                                          onTap: () {
                                            _sendMsg();
                                          },
                                          child: Image.asset(
                                            "asset/images/ic_senchatmsg.png",
                                            width: ScreenUtil().setHeight(89),
                                          ),
                                        ),
                                      );
                                    })
                              ],
                            );
                          })),
                ),
              ],
            )),
        StreamBuilder(
            initialData: false,
            stream: chatBloc.showEMOJIKeyboardStream.stream,
            builder: (buildContext, AsyncSnapshot<bool> showEMOJIKeyboard) {
              if (showEMOJIKeyboard.data) {
                return EmojiPicker(
                  rows: 3,
                  columns: 6,
                  buttonMode: ButtonMode.MATERIAL,
                  numRecommended: 0,
                  onEmojiSelected: (emoji, category) {
                    _messageTextController.text =
                        _messageTextController.text + " " + emoji.emoji;
                  },
                );
              } else {
                return Container();
              }
            })
      ],
    );
  }

  //Tìm kiếm nội dung tin nhắn
  _buildSearchContentMessage() {
    return Column(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
            minHeight: 126.0.h,
          ),
          decoration: BoxDecoration(
            color: Color(0xff333333),
            borderRadius: BorderRadius.circular(
                SizeRender.renderBorderSize(context, 0.0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              StreamBuilder(
                  initialData: false,
                  stream: chatBloc.showIconSearchStream.stream,
                  builder: (buildContext, AsyncSnapshot<bool> searchDataSnap) {
                    if (searchDataSnap.hasData && searchDataSnap.data) {
                      return Container(
                        margin: EdgeInsets.only(left: 59.3.w),
                      );
                    }
                    return Container(
                      margin: EdgeInsets.only(
                        bottom: ScreenUtil().setHeight(30.0),
                        top: ScreenUtil().setHeight(30.0),
                        left: ScreenUtil().setWidth(85.0),
                      ),
//                child: InkWell(
                      child: Icon(
                        Icons.search,
                        size: ScreenUtil().setWidth(66.0),
                        color: Color(0xff9a9ca4),
                      ),
                    );
                  }),
              SizedBox(
                width: ScreenUtil().setWidth(25.7),
              ),
              Flexible(
                child: Container(
                  margin: EdgeInsets.only(right: 15.0),
                  child: TextField(
                    focusNode: _focusSearch,
                    cursorColor:  Color(0XFFFFFFFF),
                    onChanged: (data) {
                      chatBloc.searchContentMessage(data);
                    },
                    style: TextStyle(
                      fontFamily: "Roboto-Regular",
                      fontSize: ScreenUtil().setSp(50.0),
                      color: Color(0XFFFFFFFF),
                    ),
                    controller: _searchTextController,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: "Tìm kiếm tin nhắn",
                      hintStyle: TextStyle(
                        fontFamily: "Roboto-Regular",
                        fontSize: ScreenUtil().setSp(50.0),
                        color: prefix0.color959ca7,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: ScreenUtil().setWidth(59.0)),
                child: InkWell(
                  onTap: () {
                    _searchTextController.clear();
                    _focusSearch?.unfocus();
                    chatBloc.changeStateSearchMessage(false);
                  },
                  child: Image.asset(
                    "asset/images/ic_Close.png",
                    width: ScreenUtil().setHeight(49.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildSearchResult(int count) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 142.0.h,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              bottom: ScreenUtil().setHeight(44.0),
              top: ScreenUtil().setHeight(50.0),
              left: ScreenUtil().setWidth(60.0),
            ),
            child: Text(
              count == 0
                  ? 'Không tìm thấy kết quả'
                  : "Đã tìm thấy: $count kết quả",
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(36.0),
                  color: Color(0XFF959ca7),
                  fontFamily: "Robot-Regular"),
            ),
          ),
        ],
      ),
    );
  }

  _buildListMessage() {
    return StreamBuilder(
        initialData: ChatListMessageModel(state: ChatListMessageState.LOADING),
        stream: chatBloc.chatListMessageStream.stream,
        builder: (streamListMessage,
            AsyncSnapshot<ChatListMessageModel> listMessageSnap) {
          switch (listMessageSnap.data.state) {
            case ChatListMessageState.LOADING:
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: prefix0.white,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(prefix0.accentColor),
                ),
              );
              break;
            case ChatListMessageState.NO_DATA:
              return _buildLineNoData();
              break;
            case ChatListMessageState.ERROR:
              return Container();
              break;
            case ChatListMessageState.SHOW:
              AppBloc appBloc = BlocProvider.of(context);
              bool isReverse = checkRverseListView();
              return StreamBuilder(
                  initialData: MessageActionStreamModel(
                      ActionBarMessageState.NONE, null),
                  stream: appBloc
                      .mainChatBloc.chatBloc.showMessageActionStream.stream,
                  builder: (buildContent,
                      AsyncSnapshot<MessageActionStreamModel> snapshot) {
                    switch (snapshot.data.state) {
                      case ActionBarMessageState.CHOOSEMESSAGE:
                        return NotificationListener<ScrollNotification>(
                          child: ListView.builder(
                              reverse: isReverse,
                              controller: controller,
                              addAutomaticKeepAlives: false,
                              itemCount:
                                  listMessageSnap.data.listMessage.length,
                              itemBuilder: (buildContext, index) {
                                ValidateInfoMessage validate =
                                    ValidateInfoMessage()
                                      ..setRoomModel(widget.roomModel)
                                      ..setPositionOfItem(index)
                                      ..setMessage(listMessageSnap
                                          .data.listMessage[index]);
                                double marginTop = index ==
                                        listMessageSnap
                                                .data.listMessage.length -
                                            1
                                    ? ScreenUtil().setWidth(0)
                                    : 0.0;

                                bool isShowTimeAndAvatar =
                                    validate.checkShowTime(
                                  listMessageSnap.data.listMessage,
                                );
                                if (validate.isRevokeMessage) {
                                  return MessageRevokeItem(
                                    roomModel: widget.roomModel,
                                    marginTop: marginTop,
                                    message: validate.message,
                                    isShowTime: isShowTimeAndAvatar,
                                    isShowAvatar: isShowTimeAndAvatar,
                                    isShowDate: false,
                                    isOwner: validate.checkMessageOwner(
                                        listMessageSnap.data.listMessage),
                                    userFullName: validate.getNameShow(appBloc,
                                        listMessageSnap.data.listMessage),
                                  );
                                }
                                if (!validate.isFile) {
                                  return GestureDetector(
                                    onTapDown: (detail) {
                                      positionIMessage = detail.globalPosition;
                                    },
                                    child: MessageItem(
                                      roomModel: widget.roomModel,
                                      marginTop: marginTop,
                                      message: validate.message,
                                      isShowTime: isShowTimeAndAvatar,
                                      isShowAvatar: isShowTimeAndAvatar,
                                      isShowDate:
                                          false /*validate.checkShowDateTime(
                                          listMessageSnap.data.listMessage)*/
                                      ,
                                      isOwner: validate.checkMessageOwner(
                                          listMessageSnap.data.listMessage),
                                      userFullName: validate.getNameShow(
                                          appBloc,
                                          listMessageSnap.data.listMessage),
                                      isShowNewMessage: false,
                                      isShowCheckBoxActionBar: true,
                                    ),
                                  );
                                } else {
                                  if (validate.message.wsAttachments == null ||
                                      validate.message.wsAttachments.length ==
                                          0) {
                                    return Container();
                                  } else if (validate.message.wsAttachments[0]
                                      is WsAudioFile) {
                                    //Tin nhắn âm thanh
                                    return Container();
//                                      return MessageItemAudio(
//                                        baseUrl: appBloc.apiBaseChat,
//                                        marginTop: marginTop,
//                                        message: validate.message,
//                                        isShowTime: isShowTimeAndAvatar,
//                                        isShowAvatar: isShowTimeAndAvatar,
//                                        isOwner: validate.checkMessageOwner(
//                                            listMessageSnap.data.listMessage),
//                                        userFullName: validate.getNameShow(
//                                            appBloc,
//                                            listMessageSnap.data.listMessage),
//                                        roomModel: widget.roomModel,
//                                      );
                                  } else if (validate.message.wsAttachments[0]
                                      is WsImageFile) {
                                    //Tin nhắn hình ảnh
                                    return MessageItemImage(
                                      onLongClickImage: () {
                                        //Nếu đang chọn nhiều thì không làm gì
                                      },
                                      roomModel: widget.roomModel,
                                      marginTop: marginTop,
                                      message: validate.message,
                                      isShowTime: isShowTimeAndAvatar,
                                      isShowAvatar: isShowTimeAndAvatar,
                                      isOwner: validate.checkMessageOwner(
                                          listMessageSnap.data.listMessage),
                                      userFullName: validate.getNameShow(
                                          appBloc,
                                          listMessageSnap.data.listMessage),
                                      onClickImage: (imageFile) {
                                        chatBloc.showOtherLayoutStream?.notify(
                                            OtherLayoutModelStream(
                                                OtherLayoutState.IMAGE_SHOW, {
                                          0: validate.message.file,
                                          1: validate.message.wsAttachments[0]
                                        }));
                                      },
                                    );
                                  } else {
                                    //Tin nhắn có tập tin đính kèm không phải hình ảnh
                                    return MessageItemOtherFile(
                                      onLongClickFile: () {
                                        //Nếu đang chọn nhiều thì không làm gì
                                      },
                                      marginTop: marginTop,
                                      message: validate.message,
                                      isShowTime: isShowTimeAndAvatar,
                                      isShowAvatar: isShowTimeAndAvatar,
                                      isOwner: validate.checkMessageOwner(
                                          listMessageSnap.data.listMessage),
                                      roomModel: widget.roomModel,
                                      userFullName: validate.getNameShow(
                                          appBloc,
                                          listMessageSnap.data.listMessage),
                                    );
                                  }
                                }
                              }),
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                              if (widget.roomModel.roomType == RoomType.p) {
                                chatBloc.checkAmountMessageRemain(
                                    context, widget.roomModel.id, "p");
                              } else {
                                chatBloc.checkAmountMessageRemain(
                                    context, widget.roomModel.id, "d");
                              }
                            }
                            return true;
                          },
                        );
                        break;
                      default:
                        return ScrollablePositionedList.builder(
                          itemPositionsListener: itemPositionsListener,
                          reverse: isReverse,
                          addAutomaticKeepAlives: false,
                          itemScrollController: chatController,
                          itemCount: listMessageSnap.data.listMessage.length,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemBuilder: (buildContext, index) {
                            double marginTop = index ==
                                    listMessageSnap.data.listMessage.length - 1
                                ? ScreenUtil().setWidth(0)
                                : 0.0;
                            ValidateInfoMessage validate = ValidateInfoMessage()
                              ..setRoomModel(widget.roomModel)
                              ..setPositionOfItem(index)
                              ..setMessage(
                                  listMessageSnap.data.listMessage[index]);
                            bool isShowTimeAndAvatar = validate.checkShowTime(
                                listMessageSnap.data.listMessage);
                            //Nếu như không phải tin nhắn hình ảnh hoặc tập tin đính kèm
                            if (validate.isRevokeMessage) {
                              return MessageRevokeItem(
                                roomModel: widget.roomModel,
                                marginTop: marginTop,
                                message: validate.message,
                                isShowTime: isShowTimeAndAvatar,
                                isShowAvatar: isShowTimeAndAvatar,
                                isShowDate: false,
                                isOwner: validate.checkMessageOwner(
                                    listMessageSnap.data.listMessage),
                                userFullName: validate.getNameShow(
                                    appBloc, listMessageSnap.data.listMessage),
                              );
                            }
                            if (!validate.isFile) {
                              return GestureDetector(
                                onTapDown: (detail) {
                                  String userName =
                                      appBloc.authBloc.asgUserModel.username;
                                  if (userName.contains(validate
                                      .message.skAccountModel.userName)) {
                                    positionIMessage = null;
                                  } else {
                                    positionIMessage = detail.globalPosition;
                                  }
                                },
                                child: MessageItem(
                                  roomModel: widget.roomModel,
                                  marginTop: marginTop,
                                  message: validate.message,
                                  isShowTime: isShowTimeAndAvatar,
                                  isShowAvatar: isShowTimeAndAvatar,
                                  isShowDate: false,
                                  isOwner: validate.checkMessageOwner(
                                      listMessageSnap.data.listMessage),
                                  userFullName: validate.getNameShow(appBloc,
                                      listMessageSnap.data.listMessage),
                                  isShowNewMessage: false,
                                  onClickStatus: () {
                                    appBloc.mainChatBloc.chatBloc
                                        .showMessageActionStream
                                        ?.notify(MessageActionStreamModel(
                                        ActionBarMessageState.CHOOSESTATUS,
                                        validate.message));
                                  },
                                  onLongPress: () {
                                    if (validate.message.messageActionsModel
                                        ?.actionType !=
                                        ActionType.DELETE) {
                                      _showPopupAction(validate.message);
                                    }
                                  },
                                ),
                              );
                            } else {
                              if (validate.message.wsAttachments == null ||
                                  validate.message.wsAttachments.length == 0) {
                                return Container();
                              } else if (validate.message.wsAttachments[0]
                                  is WsAudioFile) {
                                //Tin nhắn âm thanh
                                return Container();
                              } else if (validate.message.wsAttachments[0]
                                  is WsImageFile) {
                                //Tin nhắn hình ảnh
                                return GestureDetector(
                                  onTapDown: (detail) {
                                    String userName =
                                        appBloc.authBloc.asgUserModel.username;
                                    if (userName.contains(validate
                                        .message.skAccountModel.userName)) {
                                      positionIMessage = null;
                                    } else {
                                      positionIMessage = detail.globalPosition;
                                    }
                                  },
                                  child: MessageItemImage(
                                    onClickStatus: () {
                                      appBloc.mainChatBloc.chatBloc
                                          .showMessageActionStream
                                          ?.notify(MessageActionStreamModel(
                                              ActionBarMessageState
                                                  .CHOOSESTATUS,
                                              validate.message));
                                    },
                                    onLongClickImage: () {
                                      if (validate.message.messageActionsModel
                                              .actionType !=
                                          ActionType.DELETE) {
                                        _focus.unfocus();
                                        _showPopupAction(validate.message);
                                      }
                                    },
                                    roomModel: widget.roomModel,
                                    marginTop: marginTop,
                                    message: validate.message,
                                    isShowTime: isShowTimeAndAvatar,
                                    isShowAvatar: isShowTimeAndAvatar,
                                    isOwner: validate.checkMessageOwner(
                                        listMessageSnap.data.listMessage),
                                    userFullName: validate.getNameShow(appBloc,
                                        listMessageSnap.data.listMessage),
                                    onClickImage: (imageFile) {
                                      chatBloc.showOtherLayoutStream?.notify(
                                          OtherLayoutModelStream(
                                              OtherLayoutState.IMAGE_SHOW, {
                                        0: validate.message.file,
                                        1: validate.message.wsAttachments[0]
                                      }));
                                    },
                                  ),
                                );
                              } else {
                                //Tin nhắn có tập tin đính kèm không phải hình ảnh
                                return GestureDetector(
                                  onTapDown: (detail) {
                                    positionIMessage = null;
                                  },
                                  child: MessageItemOtherFile(
                                    onLongClickFile: () {},
                                    marginTop: marginTop,
                                    message: validate.message,
                                    isShowTime: isShowTimeAndAvatar,
                                    isShowAvatar: isShowTimeAndAvatar,
                                    isOwner: validate.checkMessageOwner(
                                        listMessageSnap.data.listMessage),
                                    roomModel: widget.roomModel,
                                    userFullName: validate.getNameShow(appBloc,
                                        listMessageSnap.data.listMessage),
                                  ),
                                );
                              }
                            }
                          },
                        );
                    }
                  });
              break;
            default:
              return Container();
              break;
          }
        });
  }

  _hideLayoutRecord() {
    appBloc?.mainChatBloc?.chatBloc?.recodeLayoutStream?.notify(false);
  }

  void _onFocusChange() {
    _hideLayoutRecord();
    isShowKeyBoard = !isShowKeyBoard;
    if (isShowKeyBoard) {
      chatBloc.changeEMOJIKeyboardState(false);
      WebSocketHelper.getInstance().enableTyping(widget.roomModel.id);
    } else {
      WebSocketHelper.getInstance().disableTyping(widget.roomModel.id);
    }
  }

  ///Chọn tập tin đính kèm trong thiết bị

  void _pickFileOnDevice() async {
    chatBloc.pickFileLoading.notify(true);
    FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
      allowedFileExtensions: Const.fileExtensions,
      allowedMimeTypes: Const.mimeTypes,
      invalidFileNameSymbols: ['/'],
    );

    await FlutterDocumentPicker.openDocument(params: params).then((path) {
      chatBloc.pickFileLoading.notify(false);
      if (mounted) {
        chatBloc.sendFileAttachment(context, path, widget.roomModel, () {
          _showErrorLimitedFileSize();
        });
      }
    }).catchError((onError) {
      chatBloc.pickFileLoading.notify(false);
      Toast.showShort("Định dạng tập tin không được hỗ trợ.");
    });
  }

  void _sendMsg() {
    chatBloc.sendMessage(context, _messageTextController.text.toString().trim(),
        widget.roomModel);
    _messageTextController.clear();
//    FocusScope.of(context).requestFocus(FocusNode());
  }

  //Chọn ảnh
  void _pickerImages() async {
    try {
      File file = await ImagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 100);
      if (file != null) {
        bool exits = await file.exists();
        if (exits) {
          AppBloc appBloc = BlocProvider.of(context);
          String userName = await CacheHelper.getUserName();
          MessageServices messageServices = MessageServices()
            ..setRoomModel(roomModel: widget.roomModel);
          messageServices.sendImageMessage(
              imagePath: file.path,
              senderUserName: userName,
              resultData: (onResult) {},
              onErrorApiCallback: (onError) {},
              fullName: appBloc.authBloc.asgUserModel.full_name);
        } else {
          Toast.showShort("Hình ảnh không nằm trong bộ nhớ thiết bị.");
        }
      } else {
//        Future.delayed(Duration(milliseconds: 200),(){
//          DialogUtils.showDialogResult(context, DialogType.FAILED, "Không thể đọc hình ảnh. Vui lòng chọn hình ảnh khác.");
//        });
      }
    } catch (ex) {
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Không thể đọc hình ảnh. Vui lòng chọn hình ảnh khác.");
    }
  }

  void _openCamera() async {
    final cameras = await availableCameras();
    if (cameras != null && cameras.length > 0) {
      cameraDescription = cameras.first;
      chatBloc.showOtherLayoutStream
          .notify(OtherLayoutModelStream(OtherLayoutState.CAMERA, null));
    } else {
      Toast.showShort("Thiết bị không hỗ trợ Camera");
    }
  }

  void _showPopupAction(WsMessage message) async {
    _focus.unfocus();
    if (chatBloc.isShowEMOJI) {
      chatBloc.showEMOJIKeyboardStream?.notify(false);
    }
    if (chatBloc.isOpenQuote) {
      chatBloc.disableQuote();
    }
    if (chatBloc.isEditMessage) {
      _messageTextController.clear();
      chatBloc.disableEditMessage();
    }
    MessageActionStreamModel model =
        MessageActionStreamModel(ActionBarMessageState.DEFAULT, message);
    chatBloc.showMessageActionStream?.notify(model);
  }

  //chỗ này hiển thị popup bật lên ví dụ khi nhấn vào tin nhắn, nhấn trả lời thì hiện lên popup ngay phía trên ô text
  _buildContentQuote() {
    return StreamBuilder(
        initialData: null,
        stream: chatBloc.showQuoteMessageStream.stream,
        builder:
            (buildContext, AsyncSnapshot<MessageActionsModel> snapshotData) {
          if (!snapshotData.hasData || snapshotData.data == null) {
            return Container();
          }
          _focus.requestFocus();
          return QuoteActionWidget(
            messageActionsModel: snapshotData.data,
            onDisableQuote: () {
              chatBloc.disableQuote();
            },
          );
        });
  }

  void _handleDataChange(AsyncSnapshot<bool> showActionSnap, String data) {
    if (data != null && data != "" && data.trim().length > 0) {
      chatBloc.showActionChatStream.notify(false);
      if (chatBloc.isOpenQuote ||
          (!chatBloc.isEditMessage && chatBloc.isBlockedSend)) {
        chatBloc.changeStateSend(false);
      }
    } else {
      if (chatBloc.isOpenQuote) {
        chatBloc.showActionChatStream.notify(false);
        chatBloc.changeStateSend(true);
      } else {
        chatBloc.showActionChatStream.notify(true);
        chatBloc.changeStateSend(false);
      }
    }
    if (chatBloc.isEditMessage) {
      chatBloc.checkUserEditContentMessage(data);
    }
  }

  void _showErrorLimitedFileSize() {
    DialogUtils.showDialogResult(context, DialogType.FAILED,
        "Dung lượng tập tin tối đa cho phép gửi là 50MB. Vui lòng chọn tập tin khác có kích thước phù hợp.");
  }

  void _handleMention(AsyncSnapshot<bool> showActionSnap, String data) {
    if (data != null && data.trim().toString() != "" && data.length > 0) {
      if (data.contains("@")) {
        if (!chatBloc.isEnableSearch) {
          chatBloc.openSearch();
        }
        chatBloc.searchUserByName(
            data, _messageTextController.selection.baseOffset);
      } else if (chatBloc.isEnableSearch) {
        chatBloc.disableSearchMentions();
      }
    } else {
      chatBloc.disableSearchMentions();
      chatBloc.showActionChatStream.notify(true);
    }
  }

  void updateTextController(RestUserModel userTag) {
    int positionCursor = _messageTextController.selection.baseOffset;
    String data = _messageTextController.text;
    if (positionCursor < _messageTextController.text.length) {
      String dataChange =
          _messageTextController.text.substring(0, positionCursor);
      int lastIndex = dataChange.lastIndexOf("@");
      String newData = dataChange.replaceRange(
          lastIndex, dataChange.length, "@${userTag.name} ");
      String result = data.replaceRange(lastIndex, positionCursor, newData);
      _messageTextController.text = result;
      _messageTextController.selection =
          TextSelection.fromPosition(TextPosition(offset: result.length));
    } else {
      int lastIndex = data.lastIndexOf("@");
      String newData =
          data.replaceRange(lastIndex, data.length, "@${userTag.name} ");
      _messageTextController.text = newData;
      _messageTextController.selection =
          TextSelection.fromPosition(TextPosition(offset: newData.length));
    }
  }

  void updateTextControllerMentionAll() {
    if (_messageTextController.text != null &&
        _messageTextController.text.length > 0) {
      int positionCursor = _messageTextController.selection.baseOffset;
      String data = _messageTextController.text;
      if (positionCursor < _messageTextController.text.length) {
        String dataChange =
            _messageTextController.text.substring(0, positionCursor);
        int lastIndex = dataChange.lastIndexOf("@");
        String newData =
            dataChange.replaceRange(lastIndex, dataChange.length, "@all ");
        String result = data.replaceRange(lastIndex, positionCursor, newData);
        _messageTextController.text = result;
        _focus.requestFocus();
        _messageTextController.selection =
            TextSelection.fromPosition(TextPosition(offset: result.length));
      } else {
        int lastIndex = data.lastIndexOf("@");
        String newData = data.replaceRange(lastIndex, data.length, "@all ");
        _messageTextController.text = newData;
        _focus.requestFocus();
        _messageTextController.selection =
            TextSelection.fromPosition(TextPosition(offset: newData.length));
      }
    }
  }

  void _handleEditClicked(WsMessage messageHasAction) {
    _messageTextController.clear();
    String rootContentEdit = "";
    if (messageHasAction != null &&
        messageHasAction.messageActionsModel != null) {
      if (messageHasAction.messageActionsModel.actionType == ActionType.NONE) {
        if (messageHasAction.messageActionsModel.isEdited) {
          rootContentEdit = messageHasAction.messageActionsModel.msg;
        } else {
          rootContentEdit = messageHasAction.msg;
        }
      } else {
        rootContentEdit = messageHasAction.messageActionsModel.msg;
      }
    }

    _messageTextController.text = rootContentEdit;
    _searchTextController?.clear();
    chatBloc.editMessage(context, messageHasAction);
    _focus.requestFocus();
    _messageTextController.selection = TextSelection.fromPosition(
        TextPosition(offset: rootContentEdit.length));
    chatBloc.showActionChatStream?.notify(false);
  }

  void _cancelSearch() {
    _searchTextController?.clear();
    chatBloc.changeStateSearchMessage(false);
  }

  void closeActionMessage() {
    chatBloc.disablePickMultiMessage();
    chatBloc.showMessageActionStream
        ?.notify(MessageActionStreamModel(ActionBarMessageState.NONE, null));
  }

  //Khởi tạo cuộc gọi với tin nhắn 1 vs 1
  void _createCallPhone() {
    String mUserName = appBloc.authBloc.asgUserModel.username;
    String otherUserName = widget.roomModel?.listUserDirect
        ?.firstWhere((userName) => mUserName != userName, orElse: () => "");
    if (otherUserName != "") {
      PlatformHelper.createCallPhoneWith(
          context: context, userName: otherUserName);
    } else {
      Toast.showShort("Không thể tạo cuộc gọi với thành viên này.");
    }
  }

  //lấy danh sách 50 tin nhắn mới nhất
  void _loadLatestMessage({bool isLoadCacheFirst = false}) {
    if (!appBloc.mainChatBloc.chatBloc.isLoadingLatestMsg) {
      if (widget.roomModel.roomType == RoomType.p) {
        chatBloc.getListMessageGroupPrivate(widget.roomModel,
            isGetCache: isLoadCacheFirst);
      } else {
        chatBloc.getListMessageDirectChat(widget.roomModel,
            isGetCache: isLoadCacheFirst);
      }
      appBloc?.mainChatBloc?.readAllMessage(widget.roomModel);
    }
  }
}
