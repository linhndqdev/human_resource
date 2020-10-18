import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/meeting/model/meeting_model.dart';
import 'package:human_resource/core/message/iMessageServices.dart';
import 'package:human_resource/home/HomeIndexStackModel.dart';
import 'package:human_resource/home/notifications/notification_services.dart';
import 'package:human_resource/info/orient_bloc.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/model/home_model.dart';

import 'dart:convert';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:human_resource/model/notification_model.dart';
import 'package:human_resource/model/qr_code_model.dart';
import 'package:human_resource/model/socket_notification.dart';
import 'package:human_resource/utils/common/local_notification.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';

import 'meeting/calendar_meeting_bloc.dart';

enum LayoutNotBottomBarState {
  NONE,
  CREATE_MEETING,
  ADD_MEMBER,
  MANAGER_MEMBER,
  MANAGER_MEMBER_MEETING,
  MEETING_DETAIL,
  EDIT_MEETING,
  ORIENT,
  CHAT_LAYOUT_STATE,
  CREATE_PRIVATE_GROUP,
  OPEN_PROFILE_MEMBER,
  VIDEO_PLAYER,
  NOTIFICATIONS
}

class LayoutNotBottomBarModel {
  LayoutNotBottomBarState state;
  dynamic data;

  LayoutNotBottomBarModel({@required this.state, this.data});
}

enum StateChangeScreenInHome { LEFTTORIGHT, RIGHTTOLEFT, NONE }

class HomeBloc {
  OrientState typeSystemScreen = OrientState.NONE;

  //Khi onLauncher và click vào thông báo
  OrientState systemScreenNeedOpen = OrientState.NONE;
  CoreStream<HomeIndexStackModel> homeIndexStackStream = CoreStream();
  CoreStream<String> notifyContentStream = CoreStream();

  //Sử dụng để hiển thị các màn hình không có bottombar
  CoreStream<LayoutNotBottomBarModel> layoutNotBottomBarStream = CoreStream();

  var _showBadgeNotification = StreamController<bool>.broadcast();

  int bottomBarCurrentIndex = 0;
  int indexStackHome = 0;
  int oldStackHome = 0;
  String lastNotifyMsg = "";
  MeetingNotifyModel meetingNotifyModel;

  Stream<bool> get showBadgeNotificationStream => _showBadgeNotification.stream;

  CoreStream<int> bottomBarStream = CoreStream();
  HomeModel _homeModel;

  CoreStream<bool> loadingStream = CoreStream();

  bool isLeftToRight(int index) {
    if (index > oldStackHome) {
      return true;
    } else {
      return false;
    }
  }

  void handleNotificationClickActiveMeeting() {
    if (meetingNotifyModel == null || meetingNotifyModel?.status == null)
      return;
    if (meetingNotifyModel?.status == "creat") {
      String msg = "Có 1 cuộc họp sắp diễn ra cần bạn xác nhận.";
      lastNotifyMsg = msg;
      notifyContentStream?.notify(msg);
    } else if (meetingNotifyModel?.status == "edit") {
      String msg = "Cuộc họp của bạn vừa có một cập nhật.";
      lastNotifyMsg = msg;
      notifyContentStream?.notify(msg);
    }
    meetingNotifyModel = MeetingNotifyModel();
  }

  void clickItemBottomBar(int index, {ListTabState listTabState}) async {
    if (bottomBarCurrentIndex == index) {
      return;
    }
    oldStackHome = bottomBarCurrentIndex;
    bottomBarCurrentIndex = index;
    bottomBarStream.notify(index);
    if (index == 0) {
      changeIndexStackHome(0, null);
    } else if (index == 1) {
      changeIndexStackHome(1, null, listTabState: listTabState);
    } else if (index == 2) {
      changeIndexStackHome(2, null);
    } else if (index == 3) {
      changeIndexStackHome(3, null);
    } else if (index == 4) {
      changeIndexStackHome(4, null);
    }
  }

//Chuen man danh ba
  void moveToAddressBook() {
    clickItemBottomBar(4);
    HomeChildModel _homeChildModel =
        HomeChildModel(HomeChildState.ADDRESS_BOOK, null, null);
    changeIndexStackHome(4, _homeChildModel);
  }

//Chuyển màn Search
  void moveToAddressBookSearch() {
    HomeChildModel _homeChildModel =
        HomeChildModel(HomeChildState.ADDRESS_BOOK_SEARCH, null, null);
    changeIndexStackHome(5, _homeChildModel);
  }

  dispose() {
    notifyContentStream?.closeStream();
    bottomBarStream?.closeStream();
    homeIndexStackStream?.closeStream();
    _showBadgeNotification?.close();
    loadingStream?.closeStream();
  }

  void changeIndexStackHome(int indexStack, HomeChildModel homeChildModel,
      {WsRoomModel roomModel, ListTabState listTabState}) {
    if (indexStack == 0) {
      indexStackHome = 0;
      HomeIndexStackModel _indexModel = HomeIndexStackModel(
          indexStack: indexStack,
          homeModel: _homeModel,
          homeChildModel: homeChildModel);
      homeIndexStackStream?.notify(_indexModel);
    } else if (indexStack == 1) {
      indexStackHome = 1;
      HomeIndexStackModel _indexModel = HomeIndexStackModel(
          indexStack: indexStack,
          homeModel: _homeModel,
          homeChildModel: homeChildModel);
      homeIndexStackStream?.notify(_indexModel);
    } else if (indexStack == 2) {
      indexStackHome = 2;
      HomeIndexStackModel _indexModel = HomeIndexStackModel(
          indexStack: indexStack,
          homeModel: _homeModel,
          homeChildModel: homeChildModel);
      homeIndexStackStream?.notify(_indexModel);
    } else if (indexStack == 3) {
      indexStackHome = 3;
      HomeIndexStackModel _indexModel = HomeIndexStackModel(
          indexStack: indexStack,
          homeModel: _homeModel,
          homeChildModel: homeChildModel);
      homeIndexStackStream?.notify(_indexModel);
    } else if (indexStack == 4) {
      indexStackHome = 4;
      HomeIndexStackModel _indexModel = HomeIndexStackModel(
          indexStack: indexStack,
          homeModel: _homeModel,
          homeChildModel: homeChildModel);
      homeIndexStackStream?.notify(_indexModel);
    } else {
      clickItemBottomBar(5);
      indexStackHome = 5;
      HomeIndexStackModel _indexModel = HomeIndexStackModel(
          indexStack: indexStack,
          homeModel: _homeModel,
          homeChildModel: homeChildModel);
      homeIndexStackStream?.notify(_indexModel);
    }
  }

  void changeBadgeState(Map<String, dynamic> msg, bool isShowBadge) {
    if (_showBadgeNotification != null && !_showBadgeNotification.isClosed) {
      _showBadgeNotification?.sink?.add(isShowBadge);
    }
  }

  void openOrientScreen(OrientState orientState) {
    backLayoutNotBottomBar();
    if (bottomBarCurrentIndex != 0) {
      clickItemBottomBar(0);
    }
    LayoutNotBottomBarModel model = LayoutNotBottomBarModel(
        state: LayoutNotBottomBarState.ORIENT, data: orientState);
    layoutNotBottomBarStream?.notify(model);
  }

  //Thay đổi giao diện thi thực hiện 1 action với meeting
  void changeActionMeeting({LayoutNotBottomBarState state, dynamic data}) {
    LayoutNotBottomBarModel model = LayoutNotBottomBarModel(
      state: state,
      data: data,
    );
    layoutNotBottomBarStream?.notify(model);
  }

  void changeActionMeetingAddMember(
      {LayoutNotBottomBarState state, dynamic data}) {
    LayoutNotBottomBarModel model =
        LayoutNotBottomBarModel(state: state, data: data);
    layoutNotBottomBarStream?.notify(model);
  }

  void backLayoutNotBottomBar() {
    LayoutNotBottomBarModel model = LayoutNotBottomBarModel(
        state: LayoutNotBottomBarState.NONE, data: null);
    layoutNotBottomBarStream?.notify(model);
  }

  void openLayoutCreatePrivateRoom() {
    LayoutNotBottomBarModel model = LayoutNotBottomBarModel(
        state: LayoutNotBottomBarState.CREATE_PRIVATE_GROUP, data: null);
    layoutNotBottomBarStream?.notify(model);
  }

  void closeLayoutNotBottomBar() {
    LayoutNotBottomBarModel model = LayoutNotBottomBarModel(
        state: LayoutNotBottomBarState.NONE, data: null);
    layoutNotBottomBarStream?.notify(model);
  }

  void openMemberProfileLayout(dynamic data) {
    LayoutNotBottomBarModel model = LayoutNotBottomBarModel(
      state: LayoutNotBottomBarState.OPEN_PROFILE_MEMBER,
      data: data,
    );
    layoutNotBottomBarStream?.notify(model);
  }

//Sử dụng isolate để gửi tin nhắn đi
  void sendMessageForward(
      String messageSend,
      List listMessagePicked,
      List<ASGUserModel> listUserPicked,
      List<WsRoomModel> listGroupPicked,
      List<WsRoomModel> listRoomDirect) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    List<MessageForwardModel> forwards = List();
    listMessagePicked?.forEach((wsMessage) {
      MessageForwardModel model = MessageForwardModel();
      model.time = wsMessage.ts.toString();
      model.ownerMsg = wsMessage.skAccountModel.userName;
      if (wsMessage.messageActionsModel != null) {
        if (wsMessage.messageActionsModel.actionType == ActionType.QUOTE) {
          model.contentMsg = wsMessage.messageActionsModel.msg;
        } else if (wsMessage.messageActionsModel.actionType ==
            ActionType.MENTION) {
          model.contentMsg = wsMessage.messageActionsModel.msg;
        } else if (wsMessage.messageActionsModel.actionType ==
            ActionType.FORWARD) {
          model.contentMsg = wsMessage.messageActionsModel.msg;
        } else if (wsMessage.messageActionsModel.actionType ==
            ActionType.NONE) {
          if (wsMessage.messageActionsModel.msg == null) {
            model.contentMsg = wsMessage.msg;
          } else {
            model.contentMsg = wsMessage.messageActionsModel.msg;
          }
        } else {
          model.contentMsg = wsMessage.msg;
        }
      } else {
        model.contentMsg = wsMessage.msg;
      }
      forwards.add(model);
    });
    IMessageServices iMessageServices = IMessageServices();
    MessageActionsModel messageActionsModel = MessageActionsModel()
      ..setType(ActionType.FORWARD)
      ..setForwards(forwards)
      ..setMessage(messageSend);
    if (listGroupPicked != null && listGroupPicked.length > 0) {
      _sendForwardToGroup(
          listGroupPicked, accountModel, iMessageServices, messageActionsModel);
    }
    if (listUserPicked != null && listUserPicked.length > 0) {
      _sendForwardToChatDirect(listRoomDirect, listUserPicked, accountModel,
          iMessageServices, messageActionsModel);
    }
  }

  ///Send foward đển tất cả các group được chọn
  Future<void> _sendForwardToGroup(
      List<WsRoomModel> listRoomPicked,
      WsAccountModel accountModel,
      IMessageServices iMessageServices,
      MessageActionsModel messageActionsModel) async {
    for (WsRoomModel roomModel in listRoomPicked) {
      iMessageServices.sendMessageForwardToGroup(
          messageActionsModel: messageActionsModel,
          roomModel: roomModel,
          accountModel: accountModel,
          isRequestBodyRoomName: true,
          onResultData: (result) {},
          onErrorApiCallback: (onError) {});
    }
  }

  ///Send foward đển tất cả các thành viên được chọn
  Future<void> _sendForwardToChatDirect(
      List<WsRoomModel> listRoomDirect,
      List<ASGUserModel> lisUserPicked,
      WsAccountModel accountModel,
      IMessageServices iMessageServices,
      MessageActionsModel messageActionsModel) async {
    for (ASGUserModel userModel in lisUserPicked) {
      WsRoomModel roomModel = listRoomDirect?.firstWhere(
          (room) => room.listUserDirect?.contains(userModel.username),
          orElse: () => null);
      if (roomModel != null) {
        iMessageServices.sendMessageForwardToGroup(
            messageActionsModel: messageActionsModel,
            roomModel: roomModel,
            accountModel: accountModel,
            onResultData: (result) {},
            onErrorApiCallback: (onError) {},
            isRequestBodyRoomName: false);
      } else {
        iMessageServices.sendMessageForwardToUser(
            userModel: userModel,
            messageActionsModel: messageActionsModel,
            accountModel: accountModel,
            isRequestBodyRoomName: false);
      }
    }
  }

  //Mở 1 trong 3 màn hình thông báo , bản tin faq
  void openSystemScreen(String payload) {
    if (payload == "THONGBAO") {
      openOrientScreen(OrientState.THONG_BAO);
    } else if (payload == "BANTIN") {
      openOrientScreen(OrientState.BAN_TIN);
    } else if (payload == "FAQ") {
      openOrientScreen(OrientState.FAQ);
    }
  }

//Được gọi khi click vào system notification từ onlauncher
  void setSystemScreenNeedOpen(OrientState state) {
    systemScreenNeedOpen = state;
  }

//Được gọi khi lấy được hết danh sách group về
  void checkSystemScreenNeedOpen() {
    if (systemScreenNeedOpen != OrientState.NONE) {
      openOrientScreen(systemScreenNeedOpen);
    }
    systemScreenNeedOpen = OrientState.NONE;
  }

  //Gọi để mở màn meeting nếu được click từ event meeting notification
  void openMeetingScreen() {
    backLayoutNotBottomBar();
    clickItemBottomBar(3);
  }

  void openVideoPayer(String record) {
    layoutNotBottomBarStream.notify(LayoutNotBottomBarModel(
        state: LayoutNotBottomBarState.VIDEO_PLAYER, data: record));
  }

  void scanQrCode(BuildContext context) async {
    String _barcodeScanRes =
        await FlutterBarcodeScanner.scanBarcode("", "Hủy", false, ScanMode.QR);
    if (_barcodeScanRes != null && _barcodeScanRes.trim() != "") {
      try {
        dynamic _data = jsonDecode(_barcodeScanRes);
        QrCodeModel _qrCodeModel = QrCodeModel.fromJsonAuth(_data);
        if (_qrCodeModel.qr != null && _qrCodeModel.qr.trim() != "") {
          DialogUtils.showDialogAllowAuthQrCode(context,
              title: "Xác nhận phiên đăng nhập",
              message: "Bạn vừa yêu cầu đăng nhập vào: ",
              childtext1: "S-Connect Lite Web",
              childtext2:
                  " Nếu không phải là bạn hãy bấm từ chối để tránh mất tài khoản",
              onClickOK: () {
            ApiServices apiServices = ApiServices();
            apiServices.allowLoginWithQrData(context, _qrCodeModel.qr,
                resultData: (data) {
              if (data['success']) {
                LocalNotification.getInstance().showNotificationWithNoBody(
                    "S-Connect",
                    "Bạn đã cho phép phiên đăng nhập trên S-Connect Lite",
                    DateTime.now().millisecond);
              } else {
                LocalNotification.getInstance().showNotificationWithNoBody(
                    "S-Connect",
                    "Xác nhận phiên đăng nhập thất bại.",
                    DateTime.now().millisecond);
              }
            }, onErrorApiCallback: (error) {
              LocalNotification.getInstance().showNotificationWithNoBody(
                  "S-Connect",
                  "Xác nhận phiên đăng nhập thất bại.",
                  DateTime.now().millisecond);
            });
          }, onClickCancel: () {
            LocalNotification.getInstance().showNotificationWithNoBody(
                "S-Connect",
                "Đã từ chối phiên đăng nhập trên S-Connect Lite Web.",
                DateTime.now().millisecond);
          });
        }
      } catch (ex) {
        try {
          DialogUtils.showDialogResult(context, DialogType.FAILED,
              "Dữ liệu QrCode không chính xác. Vui lòng thử lại");
        } catch (e, s) {
          print(s);
        }
      }
    }
  }

  //Mở notification layout
  void openNotificationLayout() {
    if (bottomBarCurrentIndex != 0) {
      clickItemBottomBar(0);
    }
    LayoutNotBottomBarModel model = LayoutNotBottomBarModel(
        state: LayoutNotBottomBarState.NOTIFICATIONS, data: null);
    layoutNotBottomBarStream?.notify(model);
  }

  void openMeetingDetail(AppBloc appBloc, SKNotification notification) {
    if (notification.data is MeetingModel) {
      NotificationServices services = NotificationServices();
      services.readNotification(notification, resultData: (result) {
        appBloc.notificationBloc.updateUnRead(false);
        appBloc.notificationBloc.updateListNotificationElement(notification);
      });
      if (bottomBarCurrentIndex != 3) {
        clickItemBottomBar(3);
      }
      LayoutNotBottomBarModel model = LayoutNotBottomBarModel(
          state: LayoutNotBottomBarState.NONE, data: null);
      layoutNotBottomBarStream?.notify(model);
      appBloc.calendarBloc
          .checkCreator(appBloc, notification.data)
          .then((isCreator) {
        if (isCreator) {
          EditMeettingModel editMeetingModel = EditMeettingModel(
              selectDate: appBloc.calendarBloc.selectDays,
              meetingID: notification.data.id,
              statusMeeting: notification.data.status.name,
              startTimeMeeting: notification.data.start_at.date);

          appBloc.homeBloc.changeActionMeeting(
              state: LayoutNotBottomBarState.EDIT_MEETING,
              data: editMeetingModel);
        } else {
          //Chỉ được xem lịch
          appBloc.homeBloc.changeActionMeeting(
              state: LayoutNotBottomBarState.MEETING_DETAIL,
              data: notification.data);
        }
      });
    } else if (notification.data is NotificationModel) {
      debugPrint(notification.data);
    }
  }
}

class BottomBarModel {
  int bottomBarIndex;
  bool isShowBottomBar;

  BottomBarModel(this.bottomBarIndex, this.isShowBottomBar);
}

class MeetingNotifyModel {
  String status;
  String msg;

  MeetingNotifyModel({this.status, this.msg});
}
