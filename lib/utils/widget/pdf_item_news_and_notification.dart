import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/info/orient_bloc.dart';
import 'package:human_resource/model/notification_model.dart';
import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/item_pdf_default_group.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:human_resource/core/style.dart' as prefix0;

import '../../info/meta_notification_model.dart';

class PDFItemNewsAndNotification extends StatefulWidget {
  final NotificationModel newAndNotificationModel;
  final bool isShowTime;
  final bool isRead;

  const PDFItemNewsAndNotification(
      {Key key,
      this.newAndNotificationModel,
      this.isShowTime = true,
      this.isRead = false})
      : super(key: key);

  @override
  _PDFItemNewsAndNotificationState createState() =>
      _PDFItemNewsAndNotificationState();
}

class _PDFItemNewsAndNotificationState
    extends State<PDFItemNewsAndNotification> {
  AppBloc appBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 165.w),
              width: 855.w,
              decoration: BoxDecoration(
                  color: Color(0xff005b8c),
                  borderRadius: BorderRadius.all(Radius.circular(40.w))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        left: 31.5.w,
                        top: 18.7.h,
                        right: 61.6.w,
                        bottom: 7.9.h),
                    child: Text(
                      widget?.newAndNotificationModel?.title,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto-Medium',
                          fontSize: 45.sp),
                    ),
                  ),
                  if (widget.newAndNotificationModel.author.full_name != null &&
                      widget.newAndNotificationModel.author.full_name != "" &&
                      widget.newAndNotificationModel.type.id != null &&
                      widget.newAndNotificationModel.type.id==1) ...{
                    Padding(
                      padding: EdgeInsets.only(
                          left: 31.5.w, bottom: 15.5.h, right: 61.6.w),
                      child: Text(
                        "Gửi từ: " + widget.newAndNotificationModel.author.full_name,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 36.sp,
                            fontFamily: 'Roboto-Regular'),
                      ),
                    )
                  },
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40.w),
                          bottomRight: Radius.circular(40.w),
                        ),
                        color: Color(0xfff8f8f8),
                      ),
                      margin: widget.isRead
                          ? EdgeInsets.all(1.0)
                          : EdgeInsets.all(0),
                      padding: EdgeInsets.only(
                          left: 31.6.w,
                          right: 61.5.w,
                          top: 54.7.h,
                          bottom: 27.h),
                      child: ItemPDFFileDefaultGroup(
                          titlePdf: appBloc.orientBloc.getNameFileInURL(
                              widget.newAndNotificationModel.files[0].src),
                          linkPdf: widget.newAndNotificationModel.files[0].src)
                      ),
                ],
              ),
            ),
            Positioned(
                bottom: 0,
                left: 60.w,
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  child: Image.asset("asset/images/Group11263.png"),
                ))
          ],
        ),
        widget.isShowTime
            ? Container(
                margin: EdgeInsets.only(left: 165.w, bottom: 24.6.h),
                child: Row(
                  children: <Widget>[
                    Text(
                      getTimeShow(),
                      style: TextStyle(
                        fontFamily: "Roboto-Regular",
                        color: prefix0.blackColor.withOpacity(0.4),
                        fontSize: ScreenUtil().setSp(30.0),
                      ),
                    ),
                    if (widget.isRead) ...{
                      Container(
                        margin: EdgeInsets.only(left: 17.7.w),
                        width: 50.6.w,
                        height: 21.3.h,
                        child: Image.asset("asset/images/ic_read.png"),
                      )
                    }
                  ],
                ))
            : SizedBox(
                height: 64.h,
              )
      ],
    );
  }

  Widget itemTextInMessage(AppBloc appBloc) {
    return StreamBuilder(
        initialData: LoadMoreTextModel(
            widget.newAndNotificationModel,
            appBloc.orientBloc
                .checkLongContent(widget.newAndNotificationModel.content)),
        stream: appBloc.orientBloc.loadMoreTextStream.stream.where((f) => f
            .newAndNotificationModel.id
            .toString()
            .contains(widget.newAndNotificationModel.id.toString())),
        builder: (context, AsyncSnapshot<LoadMoreTextModel> snapshot) {
          if (snapshot.data.loadMoreTextState == LoadMoreTextState.HAVEDATA) {
            return itemContentLinkInMessage(appBloc.orientBloc
                .covertTextSoLong(widget.newAndNotificationModel.content));
          } else {
            return itemContentLinkInMessage(
                widget.newAndNotificationModel.content);
          }
        });
  }

  Widget itemContentLinkInMessage(String msg) {
    return Linkify(
      onOpen: (link) async {
        if (await canLaunch(link.url)) {
          await launch(link.url);
        } else {
          Toast.showShort("Không thể mở đường dẫn");
        }
      },
      linkStyle: TextStyle(
          decoration: TextDecoration.underline,
          fontFamily: 'Roboto-Regular',
          color: prefix0.accentColor,
          fontSize: ScreenUtil().setSp(45.0)),
      text: msg,
      style: TextStyle(
          fontFamily: 'Roboto-Regular',
          color: prefix0.blackColor333,
          fontSize: ScreenUtil().setSp(45.0)),
    );
  }

  String getTimeShow() {
    return DateTimeFormat.convertTimeMessageItem(
        DateTime.parse(widget.newAndNotificationModel.datePost)
            .millisecondsSinceEpoch);
  }
}
