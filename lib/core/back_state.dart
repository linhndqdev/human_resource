import 'package:human_resource/core/core_stream.dart';

enum isFocusWidget {
  SPLASH,
  SEARCH_MESSAGE_CONTENT,
  CHOOSE_MULTI_MESSAGE,
  PICK_MEMBER_SHARE,
  STATUS_ACTION_SCREEN,
  MESSAGE_ACTION_SCREEN,
  HOME, //đây là trạng thái trang home, khi ở 4 tab cũng đều là home, tại home ấn back sẽ hiện thông báo.
  MY_PROFILE,
  DETAIL_MEETING,
  DETAIL_MEETING_MEMBER,
  EDIT_MEETING,
  EDIT_MEETING_MEMBER,
  EDIT_MEETING_ADD_MEMBER,
  NEW_MEETING,
  NEW_MEETING_MEMBER,
  CREATE_MEETING,
  MANAGER_MEETING,
  ADD_MEMBER_CREATE_MEETING,
  ADD_MEMBER_FROM_CREATE_MANAGER_MEMBER,
  ADDRESS_BOOK,
  ADDRESS_BOOK_SEARCH,
  CHAT_LAYOUT,
  CHAT_ROOM_INFO,
  CHAT_ROOM_INFO_ADD_MEMBER,
  MEMBER_PROFILE,
  CREATE_PRIVATE_GROUP,
  ORIENT_SCREEN,
  ORIENT_DETAIL_SCREEN,
  LOGIN,
  FORGOT_PASSWORD,
  MAIN,
  IMAGE_SHOW,
  PREVIEW_PICTURE,
  CAMERA,
  SHOW_VIDEO_MEETING
}

class FocusWidgetModel {
  isFocusWidget state;

  FocusWidgetModel({this.state});
}

class BackStateBloc {
  FocusWidgetModel focusWidgetModel =
      FocusWidgetModel(state: isFocusWidget.HOME);
  static BackStateBloc _instance;

  BackStateBloc._internal() {
    focusWidgetModel = FocusWidgetModel(state: isFocusWidget.HOME);
  }

  static BackStateBloc getInstance() {
    if (_instance == null) {
      _instance = BackStateBloc._internal();
    }
    return _instance;
  }

  CoreStream hideLayoutWithStream;
}
