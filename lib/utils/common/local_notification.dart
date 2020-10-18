import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/style.dart' as prefix0;

class LocalNotification {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static LocalNotification _instance;
  BuildContext context;
  String roomIDStatus;
  static LocalNotification getInstance() {
    if (_instance == null) _instance = LocalNotification._create();
    return _instance;
  }

  LocalNotification._create() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  initLocalNotification() {
    var initializationSettingsAndroid = AndroidInitializationSettings('logo');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    if (payload != null && payload != "") {
      _openRoomFromPayload(payload);
    }
  }

//Handle click vào notification để mở room trên IOS
  Future<void> onSelectNotification(String payload) async {
    if (payload != null && payload != "") {
      _openRoomFromPayload(payload);
    }
  }

  _openRoomFromPayload(String payload) {
    AppBloc appBloc = BlocProvider.of(context);

    if(payload!= null && (payload == "THONGBAO" || payload == "FAQ" || payload == "BANTIN")){
      appBloc.homeBloc.openSystemScreen(payload);
    }else {
      WsRoomModel roomModel;
      WsRoomModel currentRoomOpen = appBloc?.mainChatBloc?.chatBloc?.roomModel;

      roomModel = appBloc?.mainChatBloc?.listGroups
          ?.firstWhere((room) => room.id == payload, orElse: () => null) ??
          appBloc?.mainChatBloc?.listDirectRoom
              ?.firstWhere((room) => room.id == payload, orElse: () => null);
      //Nếu có room đang mở -> Kiểm tra room đang mở có trùng với roomID hay không
      if (currentRoomOpen != null) {
        //Phải có room thì mới mở room
        if (roomModel != null) {
          if (currentRoomOpen.id != roomModel.id) {
            appBloc?.homeBloc?.clickItemBottomBar(1,
                listTabState: roomModel.roomType == RoomType.d
                    ? ListTabState.NHAN_TIN
                    : ListTabState.NHOM);
            appBloc.mainChatBloc.listTabStream.notify(ListTabModel(
                tab: roomModel.roomType == RoomType.d
                    ? ListTabState.NHAN_TIN
                    : ListTabState.NHOM));
            if (appBloc?.mainChatBloc?.chatBloc?.isOpenned == true) {
              appBloc?.mainChatBloc?.openRoom(appBloc, roomModel);
              appBloc?.mainChatBloc?.chatBloc?.resetData(context, roomModel);
            } else {
              appBloc?.mainChatBloc?.openRoom(appBloc, roomModel);
            }
          }
        }
      } else {
        //Không có room nào đang mở
        if (roomModel != null) {
          appBloc?.homeBloc?.clickItemBottomBar(1,
              listTabState: roomModel.roomType == RoomType.d
                  ? ListTabState.NHAN_TIN
                  : ListTabState.NHOM);
          appBloc.mainChatBloc.listTabStream.notify(ListTabModel(
              tab: roomModel.roomType == RoomType.d
                  ? ListTabState.NHAN_TIN
                  : ListTabState.NHOM));
          if (appBloc?.mainChatBloc?.chatBloc?.isOpenned == true) {
            appBloc?.mainChatBloc?.openRoom(appBloc, roomModel);
            appBloc?.mainChatBloc?.chatBloc?.resetData(context, roomModel);
          } else {
            appBloc?.mainChatBloc?.openRoom(appBloc, roomModel);
          }
        }
      }
    }
  }

  Future<void> showNotificationFromMessage(
      String title, String body, int notificationID, String roomID) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'ASGL ID Channel', 'S-Connect', 'Thông báo từ S-Connect',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
        style: AndroidNotificationStyle.BigText,
        playSound: true,
        channelShowBadge: true,
        largeIcon: 'ic_launcher',
        color: prefix0.accentColor,
        autoCancel: true,
        largeIconBitmapSource: BitmapSource.Drawable);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        notificationID, title, body, platformChannelSpecifics,
        payload: roomID);
  }
  Future<void> showNotificationFromSystemMessage(
      String title, String body, int notificationID, String typeSystem) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'ASGL ID Channel', 'S-Connect', 'Thông báo từ S-Connect',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
        style: AndroidNotificationStyle.BigText,
        playSound: true,
        channelShowBadge: true,
        largeIcon: 'ic_launcher',
        color: prefix0.accentColor,
        autoCancel: true,
        largeIconBitmapSource: BitmapSource.Drawable);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: "notification.mp3",
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        notificationID, title, body, platformChannelSpecifics,
        payload: typeSystem);
  }
  Future<void> showNotificationWithNoBody(
      String title, String body, int notificationID) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '260996', 'S-Connect', 'S-Connect',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
        style: AndroidNotificationStyle.BigText,
        playSound: true,
        channelShowBadge: true,
        largeIcon: 'ic_launcher',
        color: prefix0.accentColor,
        autoCancel: true,
        largeIconBitmapSource: BitmapSource.Drawable);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        notificationID, title, body, platformChannelSpecifics);
  }

  Future<void> showNotificationSilent(
      int notificationID, String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '260997', 'S-Connect', 'S-Connect Tải lên tập tin đính kèm',
        importance: Importance.Default,
        priority: Priority.Default,
        ticker: 'ticker',
        style: AndroidNotificationStyle.BigText,
        playSound: false,
        enableVibration: false,
        channelShowBadge: false,
        largeIcon: 'ic_launcher',
        autoCancel: true,
        color: prefix0.accentColor,
        largeIconBitmapSource: BitmapSource.Drawable);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        notificationID, title, body, platformChannelSpecifics);
  }

  Future showUploadProcess(
      int idPlanOrder, int currentProcess, String fileName) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '260997', 'S-Connect', 'S-Connect Tải lên tập tin đính kèm',
        importance: Importance.Default,
        priority: Priority.Default,
        ticker: 'ticker',
        style: AndroidNotificationStyle.BigText,
        color: prefix0.accentColor,
        progress: currentProcess,
        indeterminate: true,
        maxProgress: 100,
        enableVibration: false,
        playSound: false,
        largeIcon: 'ic_launcher',
        channelShowBadge: false,
        showProgress: true,
        largeIconBitmapSource: BitmapSource.Drawable);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        idPlanOrder,
        "Đang tải lên: $fileName",
        "$currentProcess% Vui lòng không tắt ứng dụng.",
        platformChannelSpecifics);
  }

  void clearNotification(int millisecond) {
    flutterLocalNotificationsPlugin?.cancel(millisecond);
  }
  void clearAllNotification() {
    flutterLocalNotificationsPlugin?.cancelAll();
  }
  Future<void> showNotificationFromMeeting(
      String title, String body, int notificationID) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'ASGL ID Channel', 'S-Connect', 'Thông báo từ S-Connect',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
        style: AndroidNotificationStyle.BigText,
        playSound: true,
        channelShowBadge: true,
        largeIcon: 'ic_launcher',
        color: prefix0.accentColor,
        autoCancel: true,
        largeIconBitmapSource: BitmapSource.Drawable);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: "notification.mp3",
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        notificationID, title, body, platformChannelSpecifics,
        payload: "");
    var initializationSettingsAndroid = AndroidInitializationSettings('logo');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotificationMeetingComing);
  }

  Future<void> onSelectNotificationMeetingComing(String payload) async {
    AppBloc appBloc = BlocProvider.of(context);
    appBloc.homeBloc.clickItemBottomBar(3);
    appBloc.calendarBloc.getDataScheduleApi(context);
  }

  Future<void> showNotificationFromStatus(
      String title, String body, int notificationID,String roomID) async {
    roomIDStatus=roomID;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'ASGL ID Channel', 'S-Connect', 'Thông báo từ S-Connect',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
        style: AndroidNotificationStyle.BigText,
        playSound: true,
        channelShowBadge: true,
        largeIcon: 'ic_launcher',
        color: prefix0.accentColor,
        autoCancel: true,
        largeIconBitmapSource: BitmapSource.Drawable);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: "notification.mp3",
        presentAlert: true,
        presentBadge: true,
        presentSound: true);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        notificationID, title, body, platformChannelSpecifics,
        payload: "");
    var initializationSettingsAndroid = AndroidInitializationSettings('logo');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotificationStatus);
  }

  Future<void> onSelectNotificationStatus(String payload) async {
    _openRoomFromPayload(roomIDStatus);
  }


}
