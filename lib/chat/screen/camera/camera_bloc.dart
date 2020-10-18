import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:human_resource/chat/screen/main_chat/chat/chat_bloc.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/message/message_services.dart';
import 'package:human_resource/utils/common/toast.dart';

enum PreviewImageState { NONE, LOADING, SUCCESS, ERROR }

class CameraBloc {
  CoreStream<PreviewImageModel> previewImageStream = CoreStream();

  close() {
    previewImageStream?.closeStream();
  }

  void changeStateToLoading(String loadingProcess) {
    PreviewImageModel _previewImageModel =
        PreviewImageModel(PreviewImageState.LOADING, loadingProcess);
    previewImageStream?.notify(_previewImageModel);
  }

  void changeStateToSuccess() {
    PreviewImageModel _previewImageModel =
        PreviewImageModel(PreviewImageState.SUCCESS, null);
    previewImageStream?.notify(_previewImageModel);
  }

  void changeStateToError() {
    PreviewImageModel _previewImageModel =
        PreviewImageModel(PreviewImageState.ERROR, null);
    previewImageStream?.notify(_previewImageModel);
  }

  void changeStateToNone() {
    PreviewImageModel _previewImageModel =
        PreviewImageModel(PreviewImageState.NONE, null);
    previewImageStream?.notify(_previewImageModel);
  }

  void sendImage(
      BuildContext context, WsRoomModel roomModel, String path) async {
    if (path != null && path.trim().toString() != "") {
      previewImageStream
          .notify(PreviewImageModel(PreviewImageState.LOADING, null));
      AppBloc appBloc = BlocProvider.of(context);
      MessageServices messageServices = MessageServices()
        ..setRoomModel(roomModel: roomModel);
      await messageServices.sendImageMessage(
          imagePath: path,
          senderUserName: appBloc.authBloc.asgUserModel.full_name,
          resultData: (result) {
            SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
            appBloc.mainChatBloc.chatBloc
                .updateOtherLayout(OtherLayoutState.NONE);
          },
          onErrorApiCallback: (onError) {},
          fullName: appBloc.authBloc.asgUserModel.full_name);
      previewImageStream
          .notify(PreviewImageModel(PreviewImageState.NONE, null));
    } else {
      Toast.showShort("Không tìm thấy ảnh. Vui lòng chụp lại ảnh và thử lại.");
    }
  }
}

class PreviewImageModel {
  PreviewImageState state;
  dynamic loadingProcess;

  PreviewImageModel(this.state, this.loadingProcess);
}
