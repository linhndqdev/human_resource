import 'dart:io';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_attachment.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/common/const.dart';

import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:human_resource/utils/common/download_provider.dart';
import 'package:human_resource/utils/common/local_notification.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/utils/widget/loading_circle.dart';
import 'package:human_resource/utils/widget/loading_indicator.dart';
import 'package:human_resource/utils/widget/reaction_widget.dart';
import 'package:image_downloader/image_downloader.dart';

typedef OnClickImage = Function(WsImageFile);
typedef OnLongClickImage = Function();

class MessageItemImage extends StatefulWidget {
  final WsMessage message;
  final bool isShowTime;
  final double marginTop;
  final bool isShowAvatar;
  final OnClickImage onClickImage;
  final bool isOwner; //Tin nhắn của tài khoản này
  final WsRoomModel roomModel;
  final userFullName;
  final OnLongClickImage onLongClickImage;
  final VoidCallback onClickStatus;
  final bool isReadMessge;
  final String title;
  final String shortContent;
  final String sendTo;
  const MessageItemImage(
      {Key key,
      this.message,
      this.isShowTime = true,
      this.marginTop = 0.0,
      this.isShowAvatar = false,
      this.onClickImage,
      this.isOwner = false,
      this.roomModel,
      this.onLongClickImage,
      this.onClickStatus,
      this.userFullName,
      this.isReadMessge = false,
      this.title,
      this.shortContent,
      this.sendTo,

      })
      : super(key: key);

  @override
  _MessageItemImageState createState() => _MessageItemImageState();
}

class _MessageItemImageState extends State<MessageItemImage> {
  AppBloc appBloc;
  bool isClickedDownload = false;
  MessageDeleteModel messageDeleteModel = MessageDeleteModel();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return SafeArea(
        child: GestureDetector(
      onLongPress: () {
        appBloc.mainChatBloc.chatBloc.getPositions(_messageKey);
        widget.onLongClickImage();
      },
      child: Container(
        key: _messageKey,
        alignment: AlignmentDirectional.center,
        margin: EdgeInsets.only(top: widget.marginTop),
        child: Column(
          crossAxisAlignment: widget.isOwner
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            widget.isOwner ? buildRTL() : buildLTR(),
            widget.isShowTime &&
                    !widget.roomModel.name.contains(Const.BAN_TIN) &&
                    !widget.roomModel.name.contains(Const.THONG_BAO)
                ? SizedBox(
                    height: ScreenUtil().setHeight(49.1),
                  )
                : Container(),
            widget.message.isSending
                ? Container(
                    width: 20.0,
                    height: 20.0,
                    child: LoadingWidget(),
                  )
                : widget.isShowTime
                    ? Padding(
                        padding: EdgeInsets.only(
                            left: ScreenUtil()
                                .setWidth(widget.isOwner ? 0.0 : 178.9),
                            right: ScreenUtil()
                                .setWidth(widget.isOwner ? 59.0 : 0.0)),
                        child: Text(
                          DateTimeFormat.convertTimeMessageItem(
                              widget.message.ts),
                          style: TextStyle(
                            fontFamily: "Roboto-Regular",
                            color: prefix0.blackColor.withOpacity(0.4),
                            fontSize: ScreenUtil().setSp(30.0),
                          ),
                        ),
                      )
                    : Container(),
            SizedBox(
              height: ScreenUtil().setHeight(39.1),
            )
          ],
        ),
      ),
    ));
  }

  Widget buildRTL() {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: buildContentMessage(
            Alignment.bottomRight,
            prefix0.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  GlobalKey _messageKey = GlobalKey();

  Widget buildLTR() {
    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: <Widget>[
        Positioned(
          bottom: 0.0,
          child: buildAvatar(),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              (widget.userFullName != null && widget.userFullName != "") &&
                      widget.roomModel.roomType == RoomType.p &&
                      widget.roomModel.name != Const.FAQ &&
                      widget.roomModel.name != Const.BAN_TIN &&
                      widget.roomModel.name != Const.THONG_BAO
                  ? Container(
                      constraints: BoxConstraints(
                        maxWidth: ScreenUtil().setWidth(751),
                      ),
                      margin: EdgeInsets.only(
                          top: ScreenUtil().setHeight(23.5),
                          bottom: ScreenUtil().setHeight(23.5),
                          left: ScreenUtil().setWidth(176.6),
                          right: ScreenUtil().setWidth(74.5)),
                      child: Text(
                        widget.userFullName,
                        style: TextStyle(
                            fontFamily: 'Roboto-Bold',
                            fontSize: ScreenUtil().setSp(30),
                            color: prefix0.blackColor),
                      ),
                    )
                  : Container(),
              if (widget.roomModel.name.contains(Const.BAN_TIN) ||
                  widget.roomModel.name.contains(Const.THONG_BAO)) ...{
                buildContentMessageBanTinThongBao(
                  Alignment.bottomLeft,
                  prefix0.whiteColor,
                )
              } else ...{
                buildContentMessage(
                  Alignment.bottomLeft,
                  prefix0.whiteColor,
                ),
              }
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAvatar() {
    if (widget.roomModel.roomType == RoomType.p) {
      if (widget.roomModel.name == Const.BAN_TIN) {
        return Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(63.1),
                top: ScreenUtil().setHeight(16.6)),
            child: Image.asset("asset/images/group_10128.png",
                width: ScreenUtil().setWidth(80.0),
                height: ScreenUtil().setHeight(80.0)));
      } else if (widget.roomModel.name.contains(Const.THONG_BAO)) {
        return Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(63.1),
                top: ScreenUtil().setHeight(16.6)),
            child: Image.asset("asset/images/group-10353@3x.png",
                width: ScreenUtil().setWidth(80.0),
                height: ScreenUtil().setHeight(80.0)));
      } else if (widget.roomModel.name == Const.FAQ) {
        return Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(63.1),
                top: ScreenUtil().setHeight(16.6)),
            child: Image.asset("asset/images/group_9906.png",
                width: ScreenUtil().setWidth(80.0),
                height: ScreenUtil().setHeight(80.0)));
      } else {
        return widget.isShowAvatar &&
                widget?.message?.skAccountModel?.userName != "asglchat"
            ? Container(
                margin: EdgeInsets.only(left: ScreenUtil().setWidth(60.0)),
                child: CustomCircleAvatar(
                  size: 80.0,
                  userName: widget?.message?.skAccountModel?.userName,
                  position: ImagePosition.GROUP,
                ),
              )
            : Container();
      }
    } else {
      return widget.isShowAvatar &&
              widget?.message?.skAccountModel?.userName != "asglchat"
          ? Container(
              margin: EdgeInsets.only(left: ScreenUtil().setWidth(60.0)),
              child: CustomCircleAvatar(
                  size: 80.0,
                  position: ImagePosition.GROUP,
                  userName: widget?.message?.skAccountModel?.userName),
            )
          : Container();
    }
  }

  Widget buildContentMessage(Alignment timeAlign, Color textColor) {
    WsImageFile imageFile = widget.message.wsAttachments[0] as WsImageFile;
    String imageUrl = Constant.SERVER_BASE_CHAT + imageFile.image_url;
    return ColumnSuper(
      innerDistance: -46.0.h,
      alignment: widget.isOwner ? Alignment.centerRight : Alignment.centerLeft,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
              top: ScreenUtil().setHeight(10.0),
              bottom: ScreenUtil().setHeight(5.0),
              left: ScreenUtil().setWidth(176.6),
              right: ScreenUtil().setWidth(59.0)),
          padding: widget.message.file != null
              ? EdgeInsets.zero
              : EdgeInsets.only(
                  top: ScreenUtil().setHeight(23.7),
                  bottom: ScreenUtil().setHeight(23.2),
                  left: ScreenUtil().setWidth(25.0),
                  right: ScreenUtil().setWidth(21.0)),
          child: Container(
            constraints: BoxConstraints(
              minWidth: ScreenUtil().setWidth(100.0),
              minHeight: ScreenUtil().setHeight(56.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: widget.isOwner
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: <Widget>[
                widget.isOwner
                    ? InkWell(
                        onTap: () {
                          _onDownloadImage();
                        },
                        child: Image.asset(
                          "asset/images/ic_dowload_image.png",
                          width: ScreenUtil().setWidth(50.0),
                        ),
                      )
                    : Container(),
                widget.isOwner
                    ? SizedBox(
                        width: ScreenUtil().setWidth(50.0),
                      )
                    : Container(),
                Flexible(
                  child: Container(
                    margin:
                        EdgeInsets.only(bottom: ScreenUtil().setHeight(1.0)),
                    width: ScreenUtil().setWidth(746.0),
                    height: ScreenUtil().setHeight(574),
                    child: Hero(
                      tag: "viewphoto",
                      child: InkWell(
                          onTap: () {
                            widget.onClickImage(imageFile);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30.w),
                            child: CachedNetworkImage(
                              filterQuality: FilterQuality.medium,
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (placeHolderContext, url) {
                                return LoadingIndicator();
                              },
                              errorWidget: (placeHolderContext, url, error) {
                                return Container();
                              },
                            ),
                          )),
                    ),
                  ),
                ),
                widget.isOwner
                    ? Container()
                    : SizedBox(
                        width: ScreenUtil().setWidth(50.0),
                      ),
                widget.isOwner
                    ? Container()
                    : InkWell(
                        onTap: () async {
                          _onDownloadImage();
                        },
                        child: Image.asset(
                          "asset/images/ic_dowload_image.png",
                          width: ScreenUtil().setWidth(50.0),
                        ),
                      )
              ],
            ),
          ),
        ),
        widget.message.reactions.isHasReact
            ? Container(
                margin: EdgeInsets.only(
                    left: !widget.isOwner ? (182.0 + 75.0).w : 0.0,
                    right: widget.isOwner ? (75.0).w : 0.0),
                child: ReactionWidgetShow(
                  message: widget.message,
                  showDetailReact: () {
                    widget.onClickStatus();
                  },
                ))
            : Container(),
      ],
    );
  }

  Widget buildContentMessageBanTinThongBao(
      Alignment timeAlign, Color textColor) {
    WsImageFile imageFile = widget.message.wsAttachments[0] as WsImageFile;
    String imageUrl = Constant.SERVER_BASE_CHAT + imageFile.image_url;
    return ColumnSuper(
      alignment: widget.isOwner ? Alignment.centerRight : Alignment.centerLeft,
      children: <Widget>[
        Container(
          constraints: BoxConstraints(
            maxWidth: ScreenUtil().setWidth(855),
          ),
          margin: EdgeInsets.only(
              left: ScreenUtil().setWidth(176.6),
              right: ScreenUtil().setWidth(59.0)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(40.w)),
            color: prefix0.accentColor,
          ),
          child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                      top: 18.7.h, bottom: 13.0.h, left: 31.5.w, right: 61.5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      if (widget.title != null || widget.title != "") ...{
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: "Roboto-Medium",
                            color: Colors.white,
                            fontSize: 45.sp,
                          ),
                        ),
                      },
                      if (widget.sendTo != null && widget.sendTo != ""&&widget.roomModel.name.contains(Const.THONG_BAO)) ...{
                        Text(
                          "Gửi từ: " + widget.sendTo,
                          style: TextStyle(
                            fontFamily: "Roboto-Regular",
                            color: Colors.white,
                            fontSize: 36.sp,
                          ),
                        )
                      }
                    ],
                  ),
                ),
                Container(
                  margin: widget.isReadMessge
                      ? EdgeInsets.only(
                          left: 2.0.w,
                          right: 2.0.w,
                          bottom: 2.0.h,
                        )
                      : EdgeInsets.all(0),
                  padding: EdgeInsets.only(
                      top: 18.0.h, bottom: 15.0.h, left: 55.0.w, right: 54.0.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(40.w),
                      bottomLeft: Radius.circular(40.w),
                    ),
                    color: Color(0xfff8f8f8),
                  ),
                  constraints: BoxConstraints(
                    minWidth: ScreenUtil().setWidth(855),
                  ),
                  child: Hero(
                    tag: "viewphoto",
                    child: InkWell(
                      onTap: () {
                        widget.onClickImage(imageFile);
                      },
                      child: CachedNetworkImage(
                        filterQuality: FilterQuality.medium,
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (placeHolderContext, url) {
                          return LoadingIndicator();
                        },
                        errorWidget: (placeHolderContext, url, error) {
                          return Container();
                        },
                      ),
                    ),
                  ),
                ),
              ]),
        ),
      ],
    );
  }

  Widget buildLineTimeAndStatus() {
    String time = DateTimeFormat.getHourAndMinuteFrom(widget.message.ts);
    return Container(
      height: ScreenUtil().setHeight(39.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            time,
            style: prefix0.text14BlackBold,
          )
        ],
      ),
    );
  }

  void _onDownloadImage() async {
    if (!isClickedDownload) {
      isClickedDownload = true;
      String linkDownload = Constant.SERVER_BASE_CHAT +
          widget.message.wsAttachments[0].title_link;
      if (Platform.isAndroid) {
        Downloader downloader = await Downloader.init();
        TaskInfo taskInfo = TaskInfo(linkDownload, widget.message.id);
        downloader.requestDownload(
            task: taskInfo, fileName: widget.message.file.name);
        isClickedDownload = false;
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
            // Below is a method of obtaining saved image information.
            /*var fileName = await ImageDownloader.findName(imageId);
            var path = await ImageDownloader.findPath(imageId);
            var size = await ImageDownloader.findByteSize(imageId);
            var mimeType = await ImageDownloader.findMimeType(imageId);*/
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
        isClickedDownload = false;
      }
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
