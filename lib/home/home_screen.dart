import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:human_resource/chat/screen/address_book/address_book_screen.dart';
import 'package:human_resource/chat/screen/main_chat/chat/chat_layout.dart';
import 'package:human_resource/chat/screen/main_chat/layout/channel_action/create_private_channel_layout.dart';
import 'package:human_resource/chat/screen/main_chat/layout/channel_action/member_profile_layout.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_screen.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/home/HomeIndexStackModel.dart';
import 'package:human_resource/home/drawer/drawer_screen.dart';
import 'package:human_resource/home/dashboard/DashboardScreen.dart';
import 'package:human_resource/home/drawer/my_profile/my_profile.dart';
import 'package:human_resource/home/home_bloc.dart';
import 'package:human_resource/home/meeting/action_meeting/edting_meeting.dart';
import 'package:human_resource/home/meeting/action_meeting/show_meeting_detail.dart';
import 'package:human_resource/home/meeting/action_meeting/show_meeting_video.dart';
import 'package:human_resource/home/meeting/action_meeting/show_member_meeting.dart';
import 'package:human_resource/home/notifications/notification_layout.dart';
import 'package:human_resource/info/orient_bloc.dart';
import 'package:human_resource/info/orient_screen.dart';
import 'package:human_resource/model/home_model.dart';
import 'package:human_resource/utils/widget/bottom_appbar_custom.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';

import 'meeting/action_meeting/add_member_screen.dart';
import 'meeting/action_meeting/create_meeting_screen.dart';
import 'meeting/calendar_metting.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppBloc appBloc;
  var scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.HOME);
    Future.delayed(Duration.zero, () {
      appBloc.homeBloc.handleNotificationClickActiveMeeting();
    });

    return WillPopScope(
      onWillPop: () async {
        if (appBloc.backStateBloc.focusWidgetModel.state !=
            isFocusWidget.HOME) {
          //CHỖ NÀY SẼ HỨNG ĐẦU TIÊN, SAU ĐÓ MỚI ĐẾN CÁC HÀM OnWillPop bên trong, nên cần phải check để tránh đóng app
          return true;
        } else {
          DialogUtils.showDialogRequestExitApp(
            context,
            onClickOK: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
          );
          return null;
        }
      },
      child: Stack(
        children: <Widget>[
          Scaffold(
              extendBodyBehindAppBar: true,
              resizeToAvoidBottomInset: false,
              key: scaffoldKey,
              drawer: DrawerScreen(
                appBloc: appBloc,
                onScanQrCode: () {
                  appBloc.homeBloc.scanQrCode(context);
                },
              ),
              bottomNavigationBar: customBottomAppBar(),
              body: StreamBuilder(
                initialData: HomeIndexStackModel(
                    indexStack: appBloc.homeBloc.indexStackHome),
                stream: appBloc.homeBloc.homeIndexStackStream.stream,
                builder:
                    (context, AsyncSnapshot<HomeIndexStackModel> snapshot) {
                  int indexStack = (!snapshot.hasData || snapshot.data == null)
                      ? 0
                      : snapshot.data.indexStack;

                  return IndexedStack(
                    index: indexStack,
                    children: <Widget>[
                      DashboardLayout(
                        callBackOpenMenu: () {
                          scaffoldKey?.currentState?.openDrawer();
                        },
                      ),
                      MainChatScreen(),
                      Container(),
                      CalendarMeetingScreen(),
                      AddressBookScreen(appBloc),
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data.homeChildModel != null) ...{
                        childBodyLayout(snapshot)
                      }
                    ],
                  );
                },
              )),
          _buildLayoutNotBottomBar(),
          StreamBuilder(
              initialData: false,
              stream: appBloc.homeBloc.loadingStream.stream,
              builder: (buildContext, AsyncSnapshot<bool> snapshotData) {
                return Visibility(
                  child: Loading(),
                  visible: snapshotData.data,
                );
              })
        ],
      ),
    );
  }

  childBodyLayout(AsyncSnapshot<HomeIndexStackModel> snapshot) {
    switch (snapshot.data.homeChildModel.state) {
      case HomeChildState.INIT:
        return Container();
        break;
      case HomeChildState.ADDRESS_BOOK:
        return AddressBookScreen(appBloc);
        break;
      case HomeChildState.MY_PROFILE:
        return MyProfileLayout();
        break;
      default:
        return Container();
        break;
    }
  }

  customBottomAppBar() {
    return const BottomAppbarCustom();
  }

  //Todo: Hiển thị các màn hình không có bottombar
  //Dua chat layout vao day
  _buildLayoutNotBottomBar() {
    return StreamBuilder(
        initialData:
            LayoutNotBottomBarModel(state: LayoutNotBottomBarState.NONE),
        stream: appBloc.homeBloc.layoutNotBottomBarStream.stream,
        builder: (buildContext,
            AsyncSnapshot<LayoutNotBottomBarModel> snapshotData) {
          switch (snapshotData.data.state) {
            case LayoutNotBottomBarState.CREATE_MEETING:
              return CreateMeetingLayout(
                initDate: snapshotData.data.data as DateTime,
              );
              break;
            case LayoutNotBottomBarState.ADD_MEMBER:
              return AddMemberMeetingScreen(datetimes: snapshotData.data.data);
              break;
            case LayoutNotBottomBarState.MANAGER_MEMBER_MEETING:
              return ShowMemberMeetingLayout();
              break;
            case LayoutNotBottomBarState.MEETING_DETAIL:
              return ShowMeetingScreen(
                meetingModel: snapshotData.data.data,
              );
              break;
            case LayoutNotBottomBarState.EDIT_MEETING:
              return EditMeetingScreen(dataMeeting: snapshotData.data.data);
              break;
            case LayoutNotBottomBarState.ORIENT:
              appBloc.homeBloc.typeSystemScreen = snapshotData.data.data;
              return OrientScreen(
                state: snapshotData.data.data as OrientState,
              );
            case LayoutNotBottomBarState.OPEN_PROFILE_MEMBER:
              return MemberProfileLayout(
                layoutActionBloc: null,
                roomModel: null,
                dataShow: snapshotData.data.data,
                isScreenInChatLayout: false,
              );
            case LayoutNotBottomBarState.CREATE_PRIVATE_GROUP:
              return CreatePrivateChannelLayout(
                onOpenRoom: (wsRoomModel) {
                  appBloc.mainChatBloc.openRoom(appBloc, wsRoomModel);
                },
                onClickLeading: () {
                  appBloc.homeBloc.closeLayoutNotBottomBar();
                },
              );
              break;
            case LayoutNotBottomBarState.CHAT_LAYOUT_STATE:
              return ChatLayout(
                  roomModel: snapshotData.data.data as WsRoomModel);
              break;
            case LayoutNotBottomBarState.VIDEO_PLAYER:
              return ShowMeetingVideo(videoUrl: snapshotData.data.data);
              break;
            case LayoutNotBottomBarState.NOTIFICATIONS:
              return NotificationLayout(
                appBloc: appBloc,
              );
              break;
            default:
              return Container();
              break;
          }
        });
  }
}
