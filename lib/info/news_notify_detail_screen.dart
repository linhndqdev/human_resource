import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/info/meta_notification_model.dart';
import 'package:human_resource/model/notification_model.dart';
import 'package:human_resource/utils/common/datetime_format.dart';

class NewsNotifyDetailScreen extends StatelessWidget {
  final NotificationModel data;

  NewsNotifyDetailScreen({this.data});

  @override
  Widget build(BuildContext context) {
    AppBloc appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.ORIENT_DETAIL_SCREEN);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 29.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(width: 74.w),
                Image.asset(
                  'asset/images/document-2.png',
                  height: 70.h,
                  width: 63.3.w,
                  color: Color(0xff515151),
                ),
                SizedBox(width: 36.7.w),
                Expanded(
                    child: Text(
                  data.title,
                  style: TextStyle(
                      fontFamily: "Roboto-Bold", fontSize: 52.sp, height: 1.42),
                )),
                SizedBox(width: 59.1.w)
              ],
            ),
            data.author.full_name != null && data.author.full_name != ""
                ? buildSendToAndTimeTHONGBAO()
                : buildSendToAndTimeBANTIN(),
            Row(
              children: <Widget>[
                SizedBox(width: 60.w),
                Expanded(
                  child: Text(
                    data.content,
                    style: TextStyle(
                        color: Color(0xff333333),
                        fontSize: 45.sp,
                        fontFamily: "Roboto-Regular",
                        height: 1.42),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(width: 59.w),
              ],
            ),
            SizedBox(height: 114.6.h),
          ],
        ),
      ),
    );
  }

  Widget buildSendToAndTimeBANTIN() {
    return Column(
      children: <Widget>[
        SizedBox(height: 22.4.h),
        buildDateTimeSend(),
        SizedBox(height: 50.h),
      ],
    );
  }

  Widget buildSendToAndTimeTHONGBAO() {
    return Column(
      children: <Widget>[
        SizedBox(height: 8.4.h),
        Row(
          children: <Widget>[
            SizedBox(width: 74.w),
            Text(
              "Gửi từ: ",
              style: TextStyle(
                  fontFamily: "Roboto-Regular",
                  fontSize: 32.sp,
                  color: Color(0xff959ca7),
                  height: 1.38),
            ),
            Expanded(
              child: Text(
                data.author.full_name,
                style: TextStyle(
                    fontFamily: "Roboto-Medium",
                    fontSize: 32.sp,
                    color: Color(0xff707070),
                    height: 1.38),
              ),
            ),
            SizedBox(width: 59.w),
          ],
        ),
        SizedBox(height: 20.h),
        buildDateTimeSend(),
        SizedBox(height: 71.h),
      ],
    );
  }

  Widget buildDateTimeSend() {
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 74.w),
          child: Text(
              DateTimeFormat.convertTimeMessageItemDetail(
                  DateTime.parse(data.datePost).millisecondsSinceEpoch),
              style: TextStyle(
                  fontFamily: "Roboto-Regular",
                  fontSize: 32.sp,
                  color: Color(0xff707070),
                  height: 1.38)),
        ),
      ],
    );
  }
}
