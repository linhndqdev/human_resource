import 'package:human_resource/auth/auth_bloc.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/message/message_services.dart';
import 'package:human_resource/home/home_bloc.dart';
import 'package:human_resource/home/meeting/calendar_meeting_bloc.dart';
import 'package:human_resource/home/notifications/notification_bloc.dart';
import 'package:human_resource/info/orient_bloc.dart';
import 'package:human_resource/model/image_native_model.dart';
import 'package:human_resource/utils/common/cache_helper.dart';

import 'core_stream.dart';

class AppBloc {
  CoreStream<bool> showMyProfileStream = CoreStream();

  List<ImageNativeModel> _listImageNative = List();

  AuthBloc _authBloc;

  AuthBloc get authBloc => _authBloc;

  MainChatBloc _mainChatBloc;

  MainChatBloc get mainChatBloc => _mainChatBloc;

  HomeBloc _homeBloc;

  HomeBloc get homeBloc => _homeBloc;

  CalendarMeetingBloc _calendarMeetingBloc;

  CalendarMeetingBloc get calendarBloc => _calendarMeetingBloc;

  BackStateBloc _backStateBloc;

  BackStateBloc get backStateBloc => _backStateBloc;

  NotificationBloc _notificationBloc;

  NotificationBloc get notificationBloc => _notificationBloc;

  OrientBloc _orientBloc;

  OrientBloc get orientBloc => _orientBloc;

  AppBloc() {
    _authBloc = AuthBloc();
    _mainChatBloc = MainChatBloc();
    _homeBloc = HomeBloc();
    _calendarMeetingBloc = CalendarMeetingBloc();
    _backStateBloc = BackStateBloc.getInstance();
    _notificationBloc = NotificationBloc();
    _orientBloc = OrientBloc();
  }

  void addNewImageFromNative(ImageNativeModel imageNativeModel) {
    CacheHelper.saveLatestImageId(imageNativeModel.imageId);
    if (_listImageNative.length > 4) {
      _listImageNative.removeAt(0);
    }
    _listImageNative.add(imageNativeModel);
    openLayoutSendImage();
  }

  void clearListImageFromNative() {
    _listImageNative?.clear();
    showNewImageNativeStream?.notify(_listImageNative);
  }

  List<ImageNativeModel> getListImageFromNative() {
    //Xóa tất cả những ảnh mà thời gian nhận được cách thời gian hiện tại quá 5p
    DateTime dateTime = DateTime.now();
    _listImageNative?.removeWhere((image) =>
        image.timeAddImage < dateTime.millisecondsSinceEpoch - (60000 * 5));
    return _listImageNative;
  }

  CoreStream<List<ImageNativeModel>> showNewImageNativeStream = CoreStream();

  void openLayoutSendImage() {
    List<ImageNativeModel> listData = getListImageFromNative();
    if (listData.length >= 0) {
      showNewImageNativeStream?.notify(listData);
    }
  }

  void sendAllImageToRoom(WsRoomModel roomModel) async {
    showNewImageNativeStream?.notify(List<ImageNativeModel>());
    List<ImageNativeModel> _listMessage = List();
    _listMessage.addAll(_listImageNative);
    _listImageNative?.clear();
    for (ImageNativeModel image in _listMessage) {
      MessageServices messageServices = MessageServices()
        ..setRoomModel(roomModel: roomModel);
      await messageServices.sendImageMessage(
          imagePath: image.imagePath,
          fullName: authBloc.asgUserModel.full_name,
          resultData: (result) {},
          onErrorApiCallback: (onError) {});
    }
  }

  ImageNativeModel getLatestImage() {
    return _listImageNative[_listImageNative.length - 1];
  }

  changeProfileLayoutState(bool isShowMyProfile) {
    showMyProfileStream?.notify(isShowMyProfile);
  }

  void addListImageNew(List<ImageNativeModel> listImage) {
    _listImageNative.clear();
    _listImageNative.addAll(listImage);
    openLayoutSendImage();
  }
}
