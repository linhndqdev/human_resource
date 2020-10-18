import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/screen/main_chat/chat/chat_bloc.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_attachment.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/animation/animation_images.dart';
import 'package:human_resource/utils/common/download_provider.dart';
import 'package:human_resource/utils/common/local_notification.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:photo_view/photo_view.dart';



class ImageShowLayout extends StatefulWidget {
  final WsImageFile imageFile;
  final String messageID;
  final String fileName;

  const ImageShowLayout(
      {Key key,
      this.imageFile,
      @required this.fileName,
      @required this.messageID})
      : super(key: key);

  @override
  _ImageShowLayoutState createState() => _ImageShowLayoutState();
}

class _ImageShowLayoutState extends State<ImageShowLayout> {
  AppBloc appBloc;

  PhotoViewScaleStateController scaleStateController;
  bool _enableRotation = false;
  bool isClickedDownload = false;

  @override
  void initState() {
    super.initState();
    scaleStateController = PhotoViewScaleStateController();
  }

  @override
  void dispose() {
    scaleStateController.dispose();
    super.dispose();
  }

  void goBack() {
    scaleStateController.scaleState = PhotoViewScaleState.initial;
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.IMAGE_SHOW);
    SystemChrome.setSystemUIOverlayStyle(prefix0.statusLight);
    return Scaffold(
        backgroundColor: prefix0.blackColor333,
        appBar: AppBar(
          titleSpacing: 0.0,
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: prefix0.accentColor,
          leading: Container(
            margin: EdgeInsets.only(left: ScreenUtil().setWidth(60.0)),
            width: ScreenUtil().setWidth(57.6),
            height: ScreenUtil().setHeight(57.6),
            child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: FlatButton(
                onPressed: () {
                  AppBloc appBloc = BlocProvider.of(context);
                  appBloc.mainChatBloc.chatBloc.showOtherLayoutStream?.notify(
                      OtherLayoutModelStream(OtherLayoutState.NONE, null));
                },
                padding: EdgeInsets.all(0.0),
                child: Image.asset(
                  'asset/images/ic_meeting_back_white.png',
                  width: ScreenUtil().setWidth(49.9),
                  color: prefix0.white,
                ),
              ),
            ),
          ),
          title: Text(
            "Xem ảnh",
            style: TextStyle(
              fontFamily: 'Roboto-Bold',
              fontWeight: FontWeight.bold,
              color: prefix0.white,
              fontSize: ScreenUtil().setSp(60.0),
            ),
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            Center(
              child: ImagesAnimation(_BuildImages()),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    InkWell(
                        child: Icon(
                          Icons.filter_center_focus,
                          color: prefix0.white,
                        ),
                        onTap: () {
                          setState(() {
                            goBack();
                          });
                        }),
                    isClickedDownload
                        ? SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            prefix0.accentColor),
                        strokeWidth: 2.0,
                      ),
                    )
                        : InkWell(
                      onTap: () {
                        _onDownloadImage();
                      },
                      child: Image.asset(
                        "asset/images/ic_dowload_image.png",
                        width: 24.0,
                        color: prefix0.white,
                      ),
                    ),
                    InkWell(
                        child: Icon(
                          Icons.threed_rotation,
                          color: _enableRotation
                              ? prefix0.orangeColor
                              : prefix0.white,
                        ),
                        onTap: () {
                          setState(() {
                            goBack();
                            _enableRotation = !_enableRotation;
                          });
                        }),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _BuildImages() {
    return Hero(
      tag: "viewphoto",
      child: PhotoView(
        imageProvider: CachedNetworkImageProvider(
          Constant.SERVER_BASE_CHAT + widget.imageFile.image_url,
        ),
        initialScale: PhotoViewComputedScale.contained * 1.0,
        maxScale: PhotoViewComputedScale.contained * 3.0,
        minScale: PhotoViewComputedScale.contained * 0.5,
        enableRotation: _enableRotation,
        scaleStateController: scaleStateController,
        loadingBuilder: (buildContext, event) {
          return Center(
            child: Loading(),
          );
        },
        loadFailedChild: Center(
          child: Text(
            "Tải ảnh thất bại.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: prefix0.white,
                fontSize: 60.0.sp,
                fontFamily: "Roboto-Regular"),
          ),
        ),
      ),
//                ),
    );
  }

  void _onDownloadImage() async {
    if (!isClickedDownload) {
      setState(() {
        isClickedDownload = true;
      });
      String linkDownload =
          Constant.SERVER_BASE_CHAT + widget.imageFile.title_link;
      if (Platform.isAndroid) {
        Downloader downloader = await Downloader.init();
        TaskInfo taskInfo = TaskInfo(linkDownload, widget.messageID);
        downloader.requestDownload(task: taskInfo, fileName: widget.fileName);
      } else if (Platform.isIOS) {
        try {
          // Saved with this method.
          LocalNotification.getInstance().showNotificationWithNoBody(
              "S-Connect",
              "Đang tải xuống hình ảnh.",
              DateTime.now().millisecond);
          var imageId = await ImageDownloader.downloadImage(linkDownload)
              .catchError((error) {
            LocalNotification.getInstance().showNotificationWithNoBody(
                "S-Connect",
                "Tải xuống hình ảnh thất bại.",
                DateTime.now().millisecond);
          });
          if (imageId != null) {
            LocalNotification.getInstance().showNotificationWithNoBody(
                "S-Connect",
                "Tải xuống hình ảnh hoàn tất.",
                DateTime.now().millisecond);
          }
        } on Exception catch (ex) {
          LocalNotification.getInstance().showNotificationWithNoBody(
              "S-Connect",
              "Tải xuống hình ảnh thất bại.",
              DateTime.now().millisecond);
        }
      }
      setState(() {
        isClickedDownload = false;
      });
    }
  }
}

class CustomRectTween extends RectTween {
  CustomRectTween({this.a, this.b}) : super(begin: a, end: b);
  final Rect a;
  final Rect b;

  @override
  Rect lerp(double t) {
    Curves.elasticOut.transform(t);
    //any curve can be applied here e.g. Curve.elasticOut.transform(t);
    final verticalDist = Cubic(0.72, 0.15, 0.5, 1.23).transform(t);

    final top = lerpDouble(a.top, b.top, t) * (1 - verticalDist);
    return Rect.fromLTRB(
      lerpDouble(a.left, b.left, t),
      top,
      lerpDouble(a.right, b.right, t),
      lerpDouble(a.bottom, b.bottom, t),
    );
  }

  double lerpDouble(num a, num b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }
}
