import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/auth/auth_bloc.dart';
import 'package:human_resource/auth/confirm_forgot_pass.dart';
import 'package:human_resource/auth/forgotpass_screen.dart';
import 'package:human_resource/auth/login_screen.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/home/drawer/my_profile/my_profile.dart';
import 'package:human_resource/home/home_bloc.dart';
import 'package:human_resource/home/home_screen.dart';
import 'package:human_resource/home/meeting/action_meeting/show_meeting_video.dart';
import 'package:human_resource/info/orient_bloc.dart';
import 'package:human_resource/model/auth_model.dart';
import 'package:human_resource/model/image_native_model.dart';
import 'package:human_resource/splash/splash_screen.dart';
import 'package:human_resource/utils/common/cache_helper.dart';
import 'package:human_resource/utils/common/local_notification.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'chat/websocket/ws_helper.dart';
import 'core/constant.dart';
import 'core/hive/hive_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.init();
  DefaultCacheManager manager = new DefaultCacheManager();
  try {
    manager.emptyCache();
  } catch (ex) {} // data in cache.
  await FlutterDownloader.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  LocalNotification.getInstance().initLocalNotification();
  Constant.setEnvironment(Environment.DEV);
  final appBloc = AppBloc();
  WebSocketHelper.getInstance().init(appBloc);
  initializeDateFormatting().then(
    (_) => runApp(
      App(appBloc: appBloc),
    ),
  );
}

class App extends StatelessWidget {
  final AppBloc appBloc;
  final navigatorKey = GlobalKey<NavigatorState>();

  App({Key key, this.appBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      appBloc: appBloc,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'S-Connect',
        theme: ThemeData(
          fontFamily: 'Roboto-Regular.ttf',
          primarySwatch: Colors.blue,
        ),
        routes: {
          "show_meeting_video": (context) => ShowMeetingVideo(),
        },
        home: Scaffold(
          body: AppPage(
            appBloc: appBloc,
          ),
        ),
      ),
    );
  }
}

class AppPage extends StatefulWidget {
  final AppBloc appBloc;

  const AppPage({Key key, this.appBloc}) : super(key: key);

  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> with WidgetsBindingObserver {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final MethodChannel methodChannel = MethodChannel("com.asgl.human_resource");

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      LocalNotification.getInstance().clearAllNotification();
      resetApplicationWithNewJWT();
    }
  }

  //Nếu được open từ ứng dụng khác
  void resetApplicationWithNewJWT() async {
    String oldUserName = await CacheHelper.getUserName();
    if (oldUserName != widget.appBloc.authBloc.newUserName &&
        widget.appBloc.authBloc.newUserName != "") {
      widget.appBloc.authBloc.logOutAndReLogin(context);
    } else {
      widget.appBloc.authBloc.newJwt = "";
      widget.appBloc.authBloc.newPassword = "";
      widget.appBloc.authBloc.newUserName = "";
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    methodChannel.setMethodCallHandler((call) async {
      try {
        if (call != null && call.method == "NEW_PICTURE") {
          if (call.arguments != null && call.arguments.toString() != "") {
            dynamic data = call.arguments;
            ImageNativeModel imageNativeModel =
                ImageNativeModel.fromJson(json.decode(data));
            imageNativeModel.printData();
            widget.appBloc.addNewImageFromNative(imageNativeModel);
          }
        } else if (call != null && call.method == "NEW_ARRAY_IMAGE") {
          if (call.arguments != null && call.arguments.toString() != "") {
            dynamic data = call.arguments;
            Iterable i = json.decode(data);
            if (i != null && i.length > 0) {
              List<ImageNativeModel> listImage =
                  i.map((model) => ImageNativeModel.fromJson(model)).toList();
              widget.appBloc.addListImageNew(listImage);
            }
          }
        } else if (call != null &&
            call.method == "com.asgl.human_resource.new_url_data") {
          widget.appBloc.authBloc.setData(call.arguments);
        } else if (call != null &&
            call.method == "com.asgl.human_resource.new_intent_jwt") {
          if (call.arguments != null && call.arguments.toString() != "") {
            widget.appBloc.authBloc.setData(call.arguments);
          }
        }
      } catch (ex) {}
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _handleNotificationStatusonMessage(message);
        bool isCheckEventMeeting = _checkEventMeeting(message);
        if (isCheckEventMeeting) {
          _handleEventMeetingActive(message);
        } else {
          _handleNotificationClickInUpcomingMeeting(message);
          _handleNotificationClickActive(message);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        bool isEventMeeting = _checkEventMeeting(message);
        if (isEventMeeting) {
          _handleEventMeetingOnLauncher(message);
        } else {
          if (Platform.isAndroid) {
            if (message['data']['notification_type'] != null &&
                message['data']['notification_type'] != "" &&
                message['data']['meeting_action'] != null &&
                message['data']['meeting_action'] != "") {
              if (message['data']['notification_type']
                      .toString()
                      .contains("MEETING") &&
                  message['data']['meeting_action']
                      .toString()
                      .contains("ready")) {
                _handlerOpenMeetingFromOnLauncher();
              } else {
                _handlerNotificationClickOnLauncher(message);
              }
            } else {
              _handlerNotificationClickOnLauncher(message);
            }
          } else if (Platform.isIOS) {
            if (message['notification_type'] != null &&
                message['notification_type'] != "" &&
                message['meeting_action'] != null &&
                message['meeting_action'] != "") {
              if (message['notification_type'].toString().contains("MEETING") &&
                  message['meeting_action'].toString().contains("ready")) {
                _handlerOpenMeetingFromOnLauncher();
              } else {
                _handlerNotificationClickOnLauncher(message);
                //chỗ này chỉ set giá trị cho 1 biến trong homebloc, khi load homebloc lên thì
                //        //sẽ check biến đó
              }
            } else {
              _handlerNotificationClickOnLauncher(message);
              //chỗ này chỉ set giá trị cho 1 biến trong homebloc, khi load homebloc lên thì
              //        //sẽ check biến đó
            }
          }
        }
      },
      onResume: (Map<String, dynamic> message) async {
        //onBackground
        print("onResume: $message");
        bool isCheckMeetingEvent = _checkEventMeeting(message);
        if (isCheckMeetingEvent) {
          _handleEventMeetingResume(message);
        } else {
          if (Platform.isAndroid) {
            if (message['data']['notification_type'] != null &&
                message['data']['notification_type'] != "" &&
                message['data']['meeting_action'] != null &&
                message['data']['meeting_action'] != "") {
              if (message['data']['notification_type']
                      .toString()
                      .contains("MEETING") &&
                  message['data']['meeting_action']
                      .toString()
                      .contains("ready")) {
                _handleOpenMeetingFromOnResume();
              } else {
                _handleNotificationClickInActive(message);
              }
            } else {
              _handleNotificationClickInActive(message);
            }
          } else if (Platform.isIOS) {
            if (message['notification_type'] != null &&
                message['notification_type'] != "" &&
                message['meeting_action'] != null &&
                message['meeting_action'] != "") {
              if (message['notification_type'].toString().contains("MEETING") &&
                  message['meeting_action'].toString().contains("ready")) {
                _handleOpenMeetingFromOnResume();
              } else {
                _handleNotificationClickInActive(message);
              }
            } else {
              _handleNotificationClickInActive(message);
            }
          }
        }
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
    _firebaseMessaging.getToken().then((String token) {
      if (token != null && token != "") {
        print("firebase:" + token);
        CacheHelper.saveFCMToken(token);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        width: 1080, height: 2334.6, allowFontScaling: true);
    LocalNotification.getInstance().context = context;
    final AuthBloc authBloc = widget.appBloc.authBloc;

    return WillPopScope(
      onWillPop: () async {
        if (widget.appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.FORGOT_PASSWORD) {
          widget.appBloc.authBloc.changeStateBackToLogin();
          return false;
        } else if (widget.appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.LOGIN) {
          DialogUtils.showDialogRequestExitApp(
            context,
            onClickOK: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
          );
        } else {
          //cho phép chạy vào check các will pop bên trong homescreen
          return true;
        }
        return null;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: <Widget>[
              StreamBuilder(
                initialData: AuthenticationModel(AuthState.SPLASH, false, null),
                stream: authBloc.authStream.stream,
                builder: (buildContext,
                    AsyncSnapshot<AuthenticationModel> snapshotData) {
                  switch (snapshotData.data.state) {
                    case AuthState.LOGIN_FAILED:
                      return LoginScreen();
                      break;
                    case AuthState.LOGIN_SUCCESS:
                      return HomeScreen();
                      break;
                    case AuthState.SPLASH:
                      return SplashScreen();
                      break;
                    case AuthState.REQUEST_LOGIN:
                      return LoginScreen();
                      break;
                    case AuthState.FORGOTPASS:
                      return ForgotPassScreen();
                      break;
                    case AuthState.CONFIRMFORGOTPASS:
                      return ConfirmForgotPass(snapshotData.data.data);
                      break;
                    default:
                      return SplashScreen();
                      break;
                  }
                },
              ),
              StreamBuilder(
                  initialData: false,
                  stream: widget.appBloc.showMyProfileStream.stream,
                  builder: (buildContext, AsyncSnapshot<bool> myProfileSnap) {
                    if (myProfileSnap.data) {
                      return MyProfileLayout();
                    } else {
                      return Container();
                    }
                  })
            ],
          )),
    );
  }

  void _handleNotificationClickInActive(Map<String, dynamic> message) {
    AppBloc appBloc = BlocProvider.of(context);
    String meetingId;
    if (Platform.isIOS) {
      if (message != null && message['meeting_action'] != null) {
        meetingId = message['meeting_id'];
      }
    } else if (Platform.isAndroid) {
      if (message['data'] != null) {
        if (message['data'].containsKey("meeting_action")) {
          meetingId = message['data']['meeting_id'];
        }
      }
    }
    if (meetingId != null && meetingId != "") {
      _handleNotificationClickActiveMeeting(appBloc: appBloc, message: message);
    } else {
      bool isSystemNotification = _checkSystemNotification(message);
      if (isSystemNotification) {
        _handleSystemNotificationOnResume(message);
      } else {
        String roomID = "";
        if (Platform.isAndroid) {
          if (message['data'] != null &&
              message['data'].containsKey("room_id")) {
            roomID = message['data']['room_id'];
          }
        } else if (Platform.isIOS) {
          if (message != null && message.containsKey("room_id")) {
            roomID = message['room_id'];
          }
        }
        _openChatFromResume(appBloc, roomID);
      }
    }
  }

  void _handleNotificationClickActive(Map<String, dynamic> message) {
    AppBloc appBloc = BlocProvider.of(context);

    String meetingId;
    if (Platform.isIOS) {
      if (message != null && message['meeting_action'] != null) {
        meetingId = message['meeting_id'];
      }
    } else if (Platform.isAndroid) {
      if (message['data'] != null) {
        if (message['data'].containsKey("meeting_action")) {
          meetingId = message['data']['meeting_id'];
        }
      }
    }
    if (meetingId != null && meetingId != "") {
      _handleNotificationClickActiveMeeting(appBloc: appBloc, message: message);
    } else {
      bool isSystemNotification = _checkSystemNotification(message);
      if (isSystemNotification) {
        _handleSystemNotificationActive(message);
      } else {
        WsRoomModel roomModel;
        WsRoomModel currentRoomOpen = appBloc.mainChatBloc.chatBloc?.roomModel;
        String roomID;
        if (Platform.isIOS) {
          if (message != null && message['room_id'] != null) {
            roomID = message['room_id'];
          }
        } else if (Platform.isAndroid) {
          if (message['data'] != null) {
            if (message['data'].containsKey("room_id")) {
              roomID = message['data']['room_id'];
            }
          }
        }
        if (roomID != null && roomID != "") {
          roomModel = appBloc?.mainChatBloc?.listGroups?.firstWhere(
                  (room) => room.id == roomID,
                  orElse: () => null) ??
              appBloc?.mainChatBloc?.listDirectRoom
                  ?.firstWhere((room) => room.id == roomID, orElse: () => null);
        }
        String title = "";
        String body = "";
        if (Platform.isAndroid) {
          title = message['notification']['title'];
          body = message['notification']['body'];
        } else {
          title = message['aps']['alert']['title'];
          body = message['aps']['alert']['body'];
        }
        if (currentRoomOpen != null) {
          //Phải có room thì mới mở room
          if (roomModel != null) {
            if (currentRoomOpen.id != roomModel.id) {
              LocalNotification.getInstance().showNotificationFromMessage(
                  title, body, DateTime.now().millisecond, roomModel.id);
            }
          }
        } else {
          //Không có room nào đang mở
          if (roomModel != null) {
            LocalNotification.getInstance().showNotificationFromMessage(
                title, body, DateTime.now().millisecond, roomModel.id);
          }
        }
      }
    }
  }

  void _handlerNotificationClickOnLauncher(Map<String, dynamic> message) {
    AppBloc appBloc = BlocProvider.of(context);
    String meetingId;
    bool isSystemNotification = _checkSystemNotification(message);
    if (isSystemNotification) {
      _handleSystemNotificationOnLauncher(message);
    } else {
      if (Platform.isIOS) {
        if (message != null && message['meeting_action'] != null) {
          meetingId = message['meeting_id'];
        }
      } else if (Platform.isAndroid) {
        if (message['data'] != null) {
          if (message['data'].containsKey("meeting_action")) {
            meetingId = message['data']['meeting_id'];
          }
        }
      }
      if (meetingId != null && meetingId != "") {
        _handleNotificationClickActiveMeeting(
            appBloc: appBloc, message: message);
      } else {
        appBloc.mainChatBloc.setRoomNeedOpen(message);
      }
    }
  }

  void _handleNotificationClickActiveMeeting(
      {Map<String, dynamic> message, AppBloc appBloc}) {
    String meetingAction;
    if (Platform.isAndroid) {
      meetingAction = message['data']['meeting_action'];
    } else if (Platform.isIOS) {
      meetingAction = message['meeting_action'];
    }
    if (appBloc.homeBloc.bottomBarCurrentIndex != 2) {
      if (meetingAction.toLowerCase() == "creat") {
        appBloc.homeBloc.meetingNotifyModel = MeetingNotifyModel(
            status: "creat",
            msg: "Có 1 cuộc họp sắp diễn ra cần bạn xác nhận.");
        appBloc.homeBloc.lastNotifyMsg =
            "Có 1 cuộc họp sắp diễn ra cần bạn xác nhận.";
        appBloc.homeBloc.notifyContentStream
            ?.notify(appBloc.homeBloc.lastNotifyMsg);
        appBloc?.calendarBloc?.getDataScheduleApi(context);
      } else if (meetingAction.toLowerCase() == "edit") {
        appBloc.homeBloc.meetingNotifyModel = MeetingNotifyModel(
            status: "edit", msg: "Cuộc họp của bạn vừa có một cập nhật.");
        appBloc.homeBloc.lastNotifyMsg =
            "Cuộc họp của bạn vừa có một cập nhật.";
        appBloc.homeBloc.notifyContentStream
            ?.notify(appBloc.homeBloc.lastNotifyMsg);
        appBloc?.calendarBloc?.getDataScheduleApi(context);
      } else if (meetingAction.toLowerCase() == "cancel") {
        appBloc?.calendarBloc?.getDataScheduleApi(context);
        String title = "";
        String body = "";
        if (Platform.isAndroid) {
          title = message['notification']['title'];
          body = message['notification']['body'];
        } else {
          title = message['aps']['alert']['title'];
          body = message['aps']['alert']['body'];
        }
        LocalNotification.getInstance().showNotificationFromMessage(
            title, body, DateTime.now().millisecond, "123456");
      }
    } else if (appBloc.homeBloc.bottomBarCurrentIndex == 2 ||
        appBloc.backStateBloc.focusWidgetModel.state
            .toString()
            .contains("MEETING")) {
      appBloc.homeBloc.clickItemBottomBar(2);
      appBloc.calendarBloc.getDataScheduleApi(context);
    }
  }

//Trạng thái onMessage khi sắp tới cuộc họp (onForceground : app đang mở)
  void _handleNotificationClickInUpcomingMeeting(Map<String, dynamic> message) {
    if (Platform.isAndroid) {
      if (message['data']['notification_type'] != null &&
          message['data']['notification_type'] != "" &&
          message['data']['meeting_action'] != null &&
          message['data']['meeting_action'] != "") {
        if (message['data']['notification_type']
                .toString()
                .contains("MEETING") &&
            message['data']['meeting_action'].toString().contains("ready")) {
          LocalNotification.getInstance().showNotificationFromMeeting(
            message['notification']['title'],
            message['notification']['body'],
            DateTime.now().millisecond,
          );
        }
      }
    } else if (Platform.isIOS) {
      if (message['notification_type'] != null &&
          message['notification_type'] != "" &&
          message['meeting_action'] != null &&
          message['meeting_action'] != "") {
        if (message['notification_type'].toString().contains("MEETING") &&
            message['meeting_action'].toString().contains("ready")) {
          LocalNotification.getInstance().showNotificationFromMeeting(
            message['aps']['alert']['title'],
            message['aps']['alert']['body'],
            DateTime.now().millisecond,
          );
        }
      }
    }
  }

  void _handlerOpenMeetingFromOnLauncher() {
    AppBloc appBloc = BlocProvider.of(context);
    appBloc.homeBloc.indexStackHome = 3;
    appBloc.homeBloc.clickItemBottomBar(3);
  }

  void _handleOpenMeetingFromOnResume() {
    AppBloc appBloc = BlocProvider.of(context);
    if (appBloc.homeBloc.bottomBarCurrentIndex != 3) {
      appBloc.calendarBloc.getDataScheduleApi(context);
      appBloc.homeBloc.openMeetingScreen();
    }
    appBloc.calendarBloc.getDataScheduleApi(context);
  }

//CHỉ dùng cho 3 phòng: THông báo, FAQ ,Bản tin
  void _handleSystemNotificationActive(Map<String, dynamic> message) {
    AppBloc appBloc = BlocProvider.of(context);

    String type = "";
    String title = "";
    String body = "";
    if (Platform.isAndroid) {
      type = message['data']['notification_type'] ?? "";
      title = message['notification']['title'];
      body = message['notification']['body'];
    } else if (Platform.isIOS) {
      type = message['notification_type'] ?? "";
      title = message['aps']['alert']['title'];
      body = message['aps']['alert']['body'];
    }
    if (type == "THONGBAO" &&
        appBloc.homeBloc.typeSystemScreen != OrientState.THONG_BAO) {
      LocalNotification.getInstance().showNotificationFromSystemMessage(
          title, body, DateTime.now().millisecond, type);
    } else if (type == "BANTIN" &&
        appBloc.homeBloc.typeSystemScreen != OrientState.BAN_TIN) {
      LocalNotification.getInstance().showNotificationFromSystemMessage(
          title, body, DateTime.now().millisecond, type);
    } else if (type == "FAQ" &&
        appBloc.homeBloc.typeSystemScreen != OrientState.FAQ) {
      LocalNotification.getInstance().showNotificationFromSystemMessage(
          title, body, DateTime.now().millisecond, type);
    }
  }

//CHỉ dùng cho 3 phòng: THông báo, FAQ ,Bản tin
  void _handleSystemNotificationOnLauncher(Map<String, dynamic> message) {
    AppBloc appBloc = BlocProvider.of(context);
    String type = "";
    if (Platform.isAndroid) {
      type = message['data']['notification_type'] ?? "";
    } else if (Platform.isIOS) {
      type = message['notification_type'] ?? "";
    }
    if (type == "THONGBAO") {
      appBloc.homeBloc.setSystemScreenNeedOpen(OrientState.THONG_BAO);
    } else if (type == "BANTIN") {
      appBloc.homeBloc.setSystemScreenNeedOpen(OrientState.BAN_TIN);
    } else if (type == "FAQ") {
      appBloc.homeBloc.setSystemScreenNeedOpen(OrientState.FAQ);
    }
  }

  bool _checkSystemNotification(Map<String, dynamic> message) {
    bool isSystemNotification = false;
    if (Platform.isIOS) {
      if (message != null &&
          message['notification_type'] != null &&
          (message['notification_type'] == "THONGBAO" ||
              message['notification_type'] == "BANTIN" ||
              message['notification_type'] == "FAQ")) {
        isSystemNotification = true;
      }
    } else if (Platform.isAndroid) {
      if (message != null &&
          message['data']['notification_type'] != null &&
          (message['data']['notification_type'] == "THONGBAO" ||
              message['data']['notification_type'] == "BANTIN" ||
              message['data']['notification_type'] == "FAQ")) {
        isSystemNotification = true;
      }
    }
    return isSystemNotification;
  }

  //Được gọi nếu click system notification khi app onBackground to fỏceground
  void _handleSystemNotificationOnResume(Map<String, dynamic> message) {
    AppBloc appBloc = BlocProvider.of(context);
    String type = "";
    if (Platform.isAndroid) {
      type = message['data']['notification_type'] ?? "";
    } else if (Platform.isIOS) {
      type = message['notification_type'] ?? "";
    }
    if (type == "THONGBAO") {
      appBloc.homeBloc.openOrientScreen(OrientState.THONG_BAO);
    } else if (type == "BANTIN") {
      appBloc.homeBloc.openOrientScreen(OrientState.BAN_TIN);
    } else if (type == "FAQ") {
      appBloc.homeBloc.openOrientScreen(OrientState.FAQ);
    }
  }

  //OnResume mở chat_layout
  void _openChatFromResume(AppBloc appBloc, String roomID) {
    if (roomID != null && roomID != "") {
      WsRoomModel roomModel;

      roomModel = appBloc?.mainChatBloc?.listGroups
              ?.firstWhere((room) => room.id == roomID, orElse: () => null) ??
          appBloc?.mainChatBloc?.listDirectRoom
              ?.firstWhere((room) => room.id == roomID, orElse: () => null);
      if (roomModel != null) {
        appBloc?.homeBloc?.clickItemBottomBar(1,
            listTabState: roomModel.roomType == RoomType.d
                ? ListTabState.NHAN_TIN
                : ListTabState.NHOM);
        appBloc.mainChatBloc.listTabStream.notify(ListTabModel(
            tab: roomModel.roomType == RoomType.d
                ? ListTabState.NHAN_TIN
                : ListTabState.NHOM));
        if (appBloc.mainChatBloc.chatBloc.isOpenned) {
          if (roomModel.id == appBloc.mainChatBloc.chatBloc.roomModel.id) {
            appBloc.mainChatBloc.openRoom(appBloc, roomModel);
          } else {
            appBloc.mainChatBloc.openRoom(appBloc, roomModel);
            appBloc.mainChatBloc.chatBloc.resetData(context, roomModel);
          }
        } else {
          appBloc.mainChatBloc.openRoom(appBloc, roomModel);
        }
      }
    }
  }

  bool _checkEventMeeting(Map<String, dynamic> message) {
    bool isEventMeeting = false;
    if (Platform.isAndroid) {
      if (message != null &&
          message['data'] != null &&
          message['data']['event'] != null &&
          message['data']['event'] != "") {
        if (message['data']['event'] == "meeting.updated" ||
            message['data']['event'] == "meeting.deleted" ||
            message['data']['event'] == "meeting.ended" ||
            message['data']['event'] == "meeting.started" ||
            message['data']['event'] == "meeting.invited") {
          isEventMeeting = true;
        }
      }
    } else if (Platform.isIOS) {
      if (message != null &&
          message['event'] != null &&
          message['event'] != "") {
        if (message['event'] == "meeting.updated" ||
            message['event'] == "meeting.deleted" ||
            message['event'] == "meeting.ended" ||
            message['data'] == "meeting.invited") {
          isEventMeeting = true;
        }
      }
    }
    return isEventMeeting;
  }

  //Được gọi nếu như là thông báo có event từ lịch họp
  void _handleEventMeetingActive(Map<String, dynamic> message) {
    String event = "";
    if (Platform.isAndroid) {
      event = message['data']['event'];
    } else if (Platform.isIOS) {
      event = message['event'];
    }
    if (event != "") {
      AppBloc appBloc = BlocProvider.of(context);
      if (event == "meeting.updated") {
        appBloc.homeBloc.meetingNotifyModel = MeetingNotifyModel(
            status: "edit", msg: "Cuộc họp của bạn vừa có một cập nhật.");
        appBloc.homeBloc.lastNotifyMsg =
            "Cuộc họp của bạn vừa có một cập nhật.";
        appBloc.homeBloc.notifyContentStream
            ?.notify(appBloc.homeBloc.lastNotifyMsg);
        appBloc?.calendarBloc?.getDataScheduleApi(context);
      } else if (event == "meeting.deleted") {
        appBloc.homeBloc.meetingNotifyModel = MeetingNotifyModel(
            status: "edit", msg: "Cuộc họp của bạn vừa bị hủy.");
        appBloc.homeBloc.lastNotifyMsg = "Cuộc họp của bạn vừa bị hủy.";
        appBloc.homeBloc.notifyContentStream
            ?.notify(appBloc.homeBloc.lastNotifyMsg);
        appBloc?.calendarBloc?.getDataScheduleApi(context);
      } else if (event == "meeting.ended") {
        appBloc.homeBloc.meetingNotifyModel = MeetingNotifyModel(
            status: "edit", msg: "Cuộc họp của bạn đã kết thúc.");
        appBloc.homeBloc.lastNotifyMsg = "Cuộc họp của bạn đã kết thúc.";
        appBloc.homeBloc.notifyContentStream
            ?.notify(appBloc.homeBloc.lastNotifyMsg);
        appBloc?.calendarBloc?.getDataScheduleApi(context);
      } else if (event == "meeting.started") {
        appBloc.homeBloc.meetingNotifyModel = MeetingNotifyModel(
            status: "edit", msg: "Cuộc họp của bạn đã bắt đầu.");
        appBloc.homeBloc.lastNotifyMsg = "Cuộc họp của bạn đã bắt đầu.";
        appBloc.homeBloc.notifyContentStream
            ?.notify(appBloc.homeBloc.lastNotifyMsg);
        appBloc?.calendarBloc?.getDataScheduleApi(context);
      } else if (event == "meeting.invited") {
        appBloc.homeBloc.meetingNotifyModel = MeetingNotifyModel(
            status: "edit", msg: "Bạn có một lời mời tham dự cuộc họp.");
        appBloc.homeBloc.lastNotifyMsg = "Bạn có một lời mời tham dự cuộc họp.";
        appBloc.homeBloc.notifyContentStream
            ?.notify(appBloc.homeBloc.lastNotifyMsg);
        appBloc?.calendarBloc?.getDataScheduleApi(context);
      }
    }
  }

  //Được gọi trong onResumr
  //Nếu như notification là event của lịch họp được gửi từ server
  void _handleEventMeetingResume(Map<String, dynamic> message) {
    String event = "";
    if (Platform.isAndroid) {
      event = message['data']['event'];
    } else if (Platform.isIOS) {
      event = message['event'];
    }
    if (event != "") {
      if (event == "meeting.updated" ||
          event == "meeting.deleted" ||
          event == "meeting.ended" ||
          event == "meeting.started" ||
          event == "meeting.invited") {
        _handleOpenMeetingFromOnResume();
      }
    }
  }

  void _handleEventMeetingOnLauncher(Map<String, dynamic> message) {
    String event = "";
    if (Platform.isAndroid) {
      event = message['data']['event'];
    } else if (Platform.isIOS) {
      event = message['event'];
    }
    if (event != "") {
      if (event == "meeting.updated" ||
          event == "meeting.deleted" ||
          event == "meeting.ended" ||
          event == "meeting.started" ||
          event == "meeting.invited") {
        _handlerOpenMeetingFromOnLauncher();
      }
    }
  }

  //Được gọi khi nhận được notifi thông báo cảm xúc
  void _handleNotificationStatusonMessage(Map<String, dynamic> message) {
    AppBloc appBloc = BlocProvider.of(context);
    if (Platform.isAndroid) {
      if (message['data']['click_action'] != null &&
          message['data']['click_action'] != "" &&
          message['data']['event'] != "" &&
          message['data']['event'] != null &&
          message['data']['room_id'] != "" &&
          message['data']['room_id'] != null) {
        if (message['data']['click_action']
                .toString()
                .contains("FLUTTER_NOTIFICATION_CLICK") &&
            message['data']['event'].toString().contains("chat.emoji")) {
          if (appBloc
                  .mainChatBloc.chatBloc.wsRoomModelCheckStatusNotification !=
              null) {
            if (!appBloc
                .mainChatBloc.chatBloc.wsRoomModelCheckStatusNotification.id
                .contains(message['roomID'])) {
              LocalNotification.getInstance().showNotificationFromStatus(
                  message['notification']['title'],
                  message['notification']['body'],
                  DateTime.now().millisecond,
                  message['data']['room_id']);
            }
          } else {
            LocalNotification.getInstance().showNotificationFromStatus(
                message['notification']['title'],
                message['notification']['body'],
                DateTime.now().millisecond,
                message['data']['room_id']);
          }
        }
      }
    } else if (Platform.isIOS) {
      if (message['room_id'] != null &&
          message['room_id'] != "" &&
          message['event'] != null &&
          message['event'] != "" &&
          message['click_action'] != null &&
          message['click_action'] != "") {
        if (message['click_action']
                .toString()
                .contains("FLUTTER_NOTIFICATION_CLICK") &&
            message['event'].toString().contains("chat.emoji")) {
          if (appBloc
                  .mainChatBloc.chatBloc.wsRoomModelCheckStatusNotification !=
              null) {
            if (!appBloc
                .mainChatBloc.chatBloc.wsRoomModelCheckStatusNotification.id
                .contains(message['room_id'])) {
              LocalNotification.getInstance().showNotificationFromStatus(
                  message['aps']['alert']['title'],
                  message['aps']['alert']['body'],
                  DateTime.now().millisecond,
                  message['room_id']);
            }
          } else {
            LocalNotification.getInstance().showNotificationFromStatus(
                message['aps']['alert']['title'],
                message['aps']['alert']['body'],
                DateTime.now().millisecond,
                message['room_id']);
          }
        }
      }
    }
  }
}
