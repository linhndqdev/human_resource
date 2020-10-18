import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
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
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/utils/widget/item_pdf_default_group.dart';

typedef OnLongClickFile = Function();

class MessageItemOtherFile extends StatefulWidget {
  final WsMessage message;
  final bool isShowTime;
  final double marginTop;
  final bool isShowAvatar;
  final bool isOwner; //Tin nhắn của tài khoản này
  final WsRoomModel roomModel;
  final String userFullName;
  final OnLongClickFile onLongClickFile;
  final bool isReadMessage;
  final String title;
  final String shortContent;
  final String sendTo;
  final String linkPDF;
  final String titlePDf;

  const MessageItemOtherFile(
      {Key key,
      this.message,
      this.isShowTime = true,
      this.marginTop = 0.0,
      this.isShowAvatar = false,
      this.isOwner = false,
      this.roomModel,
      this.userFullName,
      this.onLongClickFile,
      this.isReadMessage = false,
      this.title,
      this.shortContent,
      this.sendTo = "",
      this.linkPDF,
      this.titlePDf})
      : super(key: key);

  @override
  _MessageItemOtherFileState createState() => _MessageItemOtherFileState();
}

class _MessageItemOtherFileState extends State<MessageItemOtherFile> {
  MessageDeleteModel messageDeleteModel = MessageDeleteModel();
  AppBloc appBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return SafeArea(
      child: Container(
        alignment: AlignmentDirectional.center,
        margin: EdgeInsets.only(top: widget.marginTop),
        child: Column(
          crossAxisAlignment: widget.isOwner
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            widget.isOwner ? buildRTL() : buildLTR(),
            widget.isShowTime
                ? Padding(
                    padding: EdgeInsets.only(
                        left: widget.isOwner ? 0.0 : 178.9.w,
                        right: widget.isOwner ? 74.4.w : 0.0),
                    child: Text(
                      DateTimeFormat.convertTimeMessageItem(widget.message.ts),
                      style: TextStyle(
                        fontFamily: "Roboto-Regular",
                        color: prefix0.blackColor.withOpacity(0.4),
                        fontSize: 30.0.sp,
                      ),
                    ),
                  )
                : Container(),
            SizedBox(
              height: 21.8.h,
            )
          ],
        ),
      ),
    );
  }

  Widget buildRTL() {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: buildContentMessage(Alignment.bottomRight, prefix0.white),
        ),
      ],
    );
  }

  Widget buildLTR() {
    return Stack(
      alignment: widget.roomModel.name.contains(Const.THONG_BAO) ||
              widget.roomModel.name.contains(Const.BAN_TIN)
          ? AlignmentDirectional.bottomStart
          : AlignmentDirectional.topStart,
      children: <Widget>[
        buildAvatar(),
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
                              fontSize: ScreenUtil().setSp(42),
                              color: prefix0.accentColor),
                        ),
                      )
                    : Container(),
                if (widget.roomModel.name.contains(Const.THONG_BAO) ||
                    widget.roomModel.name.contains(Const.BAN_TIN)) ...{
                  buildContentMessageBanTinAndThongBao(
                    Alignment.bottomLeft,
                    Colors.black,
                  ),
                } else ...{
                  buildContentMessage(
                    Alignment.bottomLeft,
                    Colors.black,
                  ),
                }
              ],
            ))
      ],
    );
  }

  Widget buildAvatar() {
    if (widget.roomModel.roomType == RoomType.p) {
      if (widget.roomModel.name == Const.BAN_TIN) {
        return Container(
            margin: EdgeInsets.only(
              left: 63.1.w,
              top: 16.6.w,
            ),
            child: Image.asset("asset/images/group_10128.png",
                width: 80.0.w, height: 80.0.h));
      } else if (widget.roomModel.name.contains(Const.THONG_BAO)) {
        return Container(
            margin: EdgeInsets.only(left: 63.1.w, top: 16.6.h),
            child: Image.asset("asset/images/group-10353@3x.png",
                width: 80.0.w, height: 80.0.h));
      } else if (widget.roomModel.name == Const.FAQ) {
        return Container(
            margin: EdgeInsets.only(left: 63.1.w, top: 16.6.h),
            child: Image.asset("asset/images/group-10353@3x.png",
                width: 80.0.w, height: 80.0.h));
      } else {
        return widget.isShowAvatar
            ? Container(
                margin: EdgeInsets.only(left: 79.0.w),
                child: CustomCircleAvatar(
                  userName: widget?.message?.skAccountModel?.userName,
                  position: ImagePosition.GROUP,
                ),
              )
            : Container();
      }
    } else {
      return widget.isShowAvatar
          ? Container(
              margin: EdgeInsets.only(left: 79.0.w),
              child: CustomCircleAvatar(
                  position: ImagePosition.GROUP,
                  userName: widget?.message?.skAccountModel?.userName),
            )
          : Container();
    }
  }

  Widget buildContentMessage(Alignment timeAlign, Color textColor) {
    WsAttachment wsOtherFile = widget.message.wsAttachments[0];
    return Container(
      margin: EdgeInsets.only(left: 176.6.w, right: 74.5.w),
      padding: widget.message.file != null
          ? EdgeInsets.zero
          : EdgeInsets.only(
              top: 23.7.h, bottom: 23.7.h, left: 29.0.w, right: 21.0.w),
      child: Container(
        constraints: BoxConstraints(
          minWidth: 100.0.w,
          minHeight: 56.0.h,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment:
              widget.isOwner ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: <Widget>[
            widget.isOwner
                ? Platform.isAndroid
                    ? InkWell(
                        child: Image.asset(
                          "asset/images/ic_dowload_image.png",
                          width: 50.0.w,
                        ),
                        onTap: () {
//                      _launchURL(wsOtherFile.title_link);
                          _onDownloadFile();
                        })
                    : Container()
                : Container(),
            widget.isOwner
                ? SizedBox(
                    width: 50.0.w,
                  )
                : Container(),
            GestureDetector(
              onLongPress: widget.onLongClickFile,
              child: Container(
                margin: EdgeInsets.only(right: 20.9.w),
                child: Image.asset(
                  "asset/images/ic_bubble_attachment.png",
                  width: 16.5.w,
                ),
              ),
            ),
            Flexible(
                child: GestureDetector(
              onLongPress: widget.onLongClickFile,
              child: Text(
                wsOtherFile.title ?? "Không xác định",
                style: TextStyle(
                    color: prefix0.accentColor,
                    fontSize: 45.0.sp,
                    fontFamily: "Roboto-Regular"),
              ),
            )),
            widget.isOwner
                ? Container()
                : SizedBox(
                    width: 50.0.w,
                  ),
            widget.isOwner
                ? Container()
                : Platform.isAndroid
                    ? InkWell(
                        child: Image.asset(
                          "asset/images/ic_dowload_image.png",
                          width: 50.0.w,
                        ),
                        onTap: () {
                          _onDownloadFile();
                        })
                    : Container()
          ],
        ),
      ),
    );
  }

  Widget buildContentMessageBanTinAndThongBao(
      Alignment timeAlign, Color textColor) {
    WsAttachment wsOtherFile = widget.message.wsAttachments[0];
    return Container(
        constraints: BoxConstraints(
          minWidth: ScreenUtil().setWidth(855),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(40.w)),
          color: prefix0.accentColor,
        ),
        margin: EdgeInsets.only(left: 176.6.w, right: 59.0.w),
        padding: widget.message.file != null
            ? EdgeInsets.zero
            : EdgeInsets.only(
                top: 23.7.h, bottom: 23.7.h, left: 29.0.w, right: 21.0.w),
        child: Column(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                minWidth: ScreenUtil().setWidth(855),
              ),
              padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(18.7),
                  bottom: ScreenUtil().setHeight(19.0),
                  left: ScreenUtil().setWidth(31.5),
                  right: ScreenUtil().setWidth(61.6)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40.w),
                  topLeft: Radius.circular(40.w),
                ),
                color: prefix0.accentColor,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    if (widget.sendTo != null &&
                        widget.sendTo != "" &&
                        widget.roomModel.name.contains(Const.THONG_BAO)) ...{
                      Text(
                        "Gửi từ: " + widget.sendTo,
                        style: TextStyle(
                          fontFamily: "Roboto-Regular",
                          color: Colors.white,
                          fontSize: 36.sp,
                        ),
                      )
                    }
                  ]),
            ),
            if (widget.linkPDF != "" &&
                widget.linkPDF != null &&
                widget.titlePDf != "" &&
                widget.titlePDf != null
              )...{
              Container(
                margin: widget.isReadMessage
                    ? EdgeInsets.only(
                        left: 2.0.w,
                        right: 2.0.w,
                        bottom: 2.0.h,
                      )
                    : EdgeInsets.all(0),
                padding: EdgeInsets.only(
                    left: 31.w, bottom: 28.3.h, right: 31.w, top: 7.7.h),
                decoration: BoxDecoration(
                    color: Color(0xfff8f8f8),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40.w),
                        bottomRight: Radius.circular(40.w))),
                constraints: BoxConstraints(
                  minWidth: ScreenUtil().setWidth(855),
                ),
                child: ItemPDFFileDefaultGroup(titlePdf:widget.titlePDf, linkPdf:widget.linkPDF)
              )
            } else ...{
              Container(
                margin: widget.isReadMessage
                    ? EdgeInsets.only(
                        left: 2.0.w,
                        right: 2.0.w,
                        bottom: 2.0.h,
                      )
                    : EdgeInsets.all(0),
                padding: EdgeInsets.only(
                    left: 31.w, bottom: 28.3.h, right: 31.w, top: 7.7.h),
                decoration: BoxDecoration(
                    color: Color(0xfff8f8f8),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40.w),
                        bottomRight: Radius.circular(40.w))),
                constraints: BoxConstraints(
                  minWidth: ScreenUtil().setWidth(855),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: widget.isOwner
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: <Widget>[
                    widget.isOwner
                        ? Platform.isAndroid
                            ? InkWell(
                                child: Image.asset(
                                  "asset/images/ic_dowload_image.png",
                                  width: 50.0.w,
                                ),
                                onTap: () {
//                      _launchURL(wsOtherFile.title_link);
                                  _onDownloadFile();
                                })
                            : Container()
                        : Container(),
                    widget.isOwner
                        ? SizedBox(
                            width: 50.0.w,
                          )
                        : Container(),
                    GestureDetector(
                      onLongPress: widget.onLongClickFile,
                      child: Container(
                        margin: EdgeInsets.only(right: 20.9.w),
                        child: Image.asset(
                          "asset/images/ic_bubble_attachment.png",
                          width: 16.5.w,
                        ),
                      ),
                    ),
                    Flexible(
                        child: GestureDetector(
                      onLongPress: widget.onLongClickFile,
                      child: Text(
                        wsOtherFile.title ?? "Không xác định",
                        style: TextStyle(
                            color: prefix0.accentColor,
                            fontSize: 45.0.sp,
                            fontFamily: "Roboto-Regular"),
                      ),
                    )),
                    widget.isOwner
                        ? Container()
                        : SizedBox(
                            width: 50.0.w,
                          ),
                    widget.isOwner
                        ? Container()
                        : Platform.isAndroid
                            ? InkWell(
                                child: Image.asset(
                                  "asset/images/ic_dowload_image.png",
                                  width: 50.0.w,
                                ),
                                onTap: () {
                                  _onDownloadFile();
                                })
                            : Container()
                  ],
                ),
              )
            }
          ],
        ));
  }

  Widget buildLineTimeAndStatus() {
    String time = DateTimeFormat.getHourAndMinuteFrom(widget.message.ts);
    return Container(
      height: 37.0.h,
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

  bool isDownloading = false;

  void _onDownloadFile() async {
    if (!isDownloading) {
      isDownloading = true;
      String fileDownloadUrl = Constant.SERVER_BASE_CHAT +
          widget.message.wsAttachments[0].title_link;
      TaskInfo task = TaskInfo(fileDownloadUrl, widget.message.id);
      Downloader downloader = await Downloader.init();
      downloader.requestDownload(
          task: task, fileName: widget.message.file.name);
      isDownloading = false;
    }
  }
}
