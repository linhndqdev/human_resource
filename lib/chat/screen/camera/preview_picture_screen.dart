import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/screen/camera/camera_bloc.dart';
import 'package:human_resource/chat/screen/main_chat/chat/chat_bloc.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'dart:io';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final WsRoomModel roomModel;

  DisplayPictureScreen(this.imagePath, this.roomModel);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  AppBloc appBloc;
  CameraBloc cameraBloc = CameraBloc();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.PREVIEW_PICTURE);
    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: <Widget>[
              Container(
                color: Colors.black,
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  height: ScreenUtil().setHeight(160.0),
                  width: ScreenUtil().setWidth(160.0),
                  margin: EdgeInsets.only(
                      right: ScreenUtil().setWidth(87.0),
                      bottom: ScreenUtil().setHeight(65.6)),
                  decoration: BoxDecoration(
                      color: prefix0.accentColor, shape: BoxShape.circle),
                  child: InkWell(
                    onTap: () async {
                      cameraBloc.sendImage(
                          context, widget.roomModel, widget.imagePath);
                    },
                    child: Center(
                      child: Image.asset(
                        "asset/images/ic_submit_image.png",
                        width: ScreenUtil().setWidth(100.0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: ScreenUtil().setWidth(60.0),
            top: ScreenUtil().setHeight(40.0),
          ),
          child: InkWell(
            onTap: () {
              SystemChrome.setEnabledSystemUIOverlays([]);
              appBloc.mainChatBloc.chatBloc
                  .updateOtherLayout(OtherLayoutState.CAMERA);
            },
            child: Image.asset(
              "asset/images/back_color_white.png",
              width: ScreenUtil().setWidth(65.3),
            ),
          ),
        ),
        StreamBuilder(
            initialData: PreviewImageModel(PreviewImageState.NONE, null),
            stream: cameraBloc.previewImageStream.stream,
            builder: (BuildContext context,
                AsyncSnapshot<PreviewImageModel> snapshot) {
              switch (snapshot.data.state) {
                case PreviewImageState.LOADING:
                  return Loading();
                  break;
                default:
                  return Container();
                  break;
              }
            }),
      ],
    );
  }
}
