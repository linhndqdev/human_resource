import 'package:flutter/cupertino.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/fcm/fcm_services.dart';
import 'package:human_resource/core/room_chat/room_chat_services.dart';
import 'package:human_resource/utils/common/cache_helper.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';

class MyProfileBloc {
  CoreStream<bool> loadingStream = CoreStream();
  CoreStream<bool> loadingUpdatePassStream = CoreStream();
  CoreStream<bool> uploadAvatarStream = CoreStream();
  bool isUploadAvatar = false;
  CoreStream<bool> showPassStream = CoreStream();

  void uploadAvatar(BuildContext context, String imgUrl) async {
    loadingStream.notify(true);
    AppBloc appBloc = BlocProvider.of(context);
    RoomChatServices roomChatServices = RoomChatServices();
    roomChatServices.uploadAvatar(
        imgUrl: imgUrl,
        currentUserName: appBloc.authBloc.asgUserModel.username,
        resultData: (result) {
          isUploadAvatar = !isUploadAvatar;
          loadingStream.notify(false);
          uploadAvatarStream.notify(false);
        },
        onErrorApiCallback: (onError) {
          loadingStream.notify(false);
        });
  }

  void updatePassword(BuildContext context, String oldPasswordInput,
      String newPassword, String newPassword2,VoidCallback resetInput) async {
    if (oldPasswordInput == "") {
      Toast.showShort("Vui lòng nhập mật khẩu hiện tại!");
      return;
    }
    String currentPass = await CacheHelper.getPassword();
    if (oldPasswordInput != currentPass) {
      Toast.showShort("Mật khẩu cũ không đúng");
      return;
    }
    if (newPassword == "") {
      Toast.showShort("Không được để trống mật khẩu mới");
      return;
    }
    if (newPassword.length < 8) {
      Toast.showShort("Mật khẩu phải có ít nhất 8 ký tự");
      return;
    }
    if (newPassword2 != newPassword) {
      Toast.showShort("Vui lòng điền chính xác lại mật khẩu mới");
      return;
    }
    if (WebSocketHelper.getInstance().isConnected) {
      loadingUpdatePassStream.notify(true);
      String ids = await CacheHelper.getID();
      if(ids == null){
        loadingUpdatePassStream.notify(false);
        return;
      }
      ApiServices apiServices =
          ApiServices();
      await apiServices.updatePassword(
          asglID: ids,
          oldPassword: currentPass,
          newPassword: newPassword,
          onResultData: (resultData) {
            if (resultData != null &&
                resultData['data'] != null &&
                resultData['data'] != "") {
              resetInput();
              CacheHelper.savePassword(password: newPassword);
              FCMServices fcmServices = FCMServices();
              fcmServices.postTokenToServer();
            }
            DialogUtils.showDialogResult(context, DialogType.SUCCESS,
                "Cập nhật mật khẩu thành công");
            loadingUpdatePassStream.notify(false);
          },
          onErrorApiCallback: (onError) {
            loadingUpdatePassStream.notify(false);
            Toast.showShort(onError.toString());
//                requestLogin();
          });
    } else {
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Vui lòng kiểm tra kết nối mạng của bạn và thử lại.");
    }
  }

  void dispose() {
    loadingStream?.closeStream();
    uploadAvatarStream?.closeStream();
    loadingUpdatePassStream?.closeStream();
    showPassStream?.closeStream();
  }
}
