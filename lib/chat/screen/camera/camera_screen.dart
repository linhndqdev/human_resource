import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/screen/main_chat/chat/chat_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/common/toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:human_resource/core/app_bloc.dart';

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final String roomID;

  TakePictureScreen(this.camera, this.roomID);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  List<CameraDescription> cameras;
  AppBloc appBloc;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.CAMERA);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If the Future is complete, display the preview.
                return CameraPreview(_controller);
              } else {
                // Otherwise, display a loading indicator.
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(60.0),
                top: ScreenUtil().setHeight(40.0)),
            child: InkWell(
              onTap: () {
                SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
                appBloc.mainChatBloc.chatBloc
                    .updateOtherLayout(OtherLayoutState.NONE);
              },
              child: Image.asset(
                "asset/images/ic_dismiss.png",
                color: prefix0.whiteColor,
                width: ScreenUtil().setWidth(60.6),
              ),
            ),
          ),
          /*Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(
                  bottom: ScreenUtil().setHeight( 65.6),
                  left: ScreenUtil().setWidth( 53.0),
                  right: ScreenUtil().setWidth( 53.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  InkWell(
                      child: Icon(
                        Icons.image,
                        color: prefix0.white,
                      ),
                      onTap: () {}),
                  InkWell(
                      child: Image.asset(
                        "asset/images/ic_re_take_photo.png",
                        color: prefix0.white,
                        width: ScreenUtil().setWidth( 66.2),
                      ),
                      onTap: () {}),
                ],
              ),
            ),
          )*/
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: InkWell(
        onTap: () async {
          try {
            await _initializeControllerFuture;
            final path = join(
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );
            await _controller.takePicture(path);
            File file = File(path);
            if (file != null) {
              appBloc.mainChatBloc.chatBloc.updateOtherLayout(
                  OtherLayoutState.PREVIEW_IMAGE,
                  data: path);
            } else {
              Toast.showShort("Chụp ảnh thất bại. Vui lòng thử lại.");
            }
          } catch (e) {
            Toast.showShort("Không thể khởi động camera.");
          }
        },
        child: Container(
            margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(65.6)),
            height: ScreenUtil().setWidth(219.0),
            width: ScreenUtil().setWidth(219.0),
            decoration:
                BoxDecoration(color: prefix0.white, shape: BoxShape.circle),
            child: Center(
              child: Container(
                height: ScreenUtil().setWidth(172.0),
                width: ScreenUtil().setWidth(172.0),
                decoration: BoxDecoration(
                    color: Color(0xFF959ca7), shape: BoxShape.circle),
              ),
            )),
      ),
    );
  }
}
