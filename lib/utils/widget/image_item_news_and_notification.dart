import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/model/notification_model.dart';
import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:human_resource/core/style.dart' as prefix0;

import '../../info/meta_notification_model.dart';

class ImageItemNewsAndNotification extends StatefulWidget {
  final NotificationModel newAndNotificationModel;
  final bool isShowTime;
  final bool isRead;

  const ImageItemNewsAndNotification(
      {Key key,
      this.newAndNotificationModel,
      this.isShowTime = true,
      this.isRead = false})
      : super(key: key);

  @override
  _ImageItemNewsAndNotificationState createState() =>
      _ImageItemNewsAndNotificationState();
}

class _ImageItemNewsAndNotificationState
    extends State<ImageItemNewsAndNotification> {
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
                      padding: EdgeInsets.only(
                          left: 55.w, right: 54.w, top: 18.h, bottom: 15.h),
                      child: Container(
                        width: 746.w,
                        child: Image.network(
                            widget.newAndNotificationModel.files[0].src),
                      )),
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
                  ],
                ))
            : SizedBox(
                height: 64.h,
              )
      ],
    );
  }

  String getTimeShow() {
    return DateTimeFormat.convertTimeMessageItem(
        DateTime.parse(widget.newAndNotificationModel.datePost)
            .millisecondsSinceEpoch);
  }
}
