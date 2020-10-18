import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:human_resource/core/meeting/model/meeting_model.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/size_extension.dart';

class ImageMeetingWidget extends StatelessWidget {
  final MeetingStatus meetingStatus;
  final bool hasRecord;

  const ImageMeetingWidget(
      {Key key, this.meetingStatus, this.hasRecord = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (meetingStatus.id == 1 || meetingStatus.id == 2)
      return Container(
          width: 80.0.w,
          height: 80.0.w,
          padding: EdgeInsets.all(21.7.h),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: prefix0.whiteColor,
          ),
          child: Image.asset("asset/images/ic_camera.png", width: 36.6.w));
    else if (meetingStatus.id == 3)
      return Container(
          width: 80.0.w,
          height: 80.0.w,
          padding: EdgeInsets.all(21.7.h),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: prefix0.whiteColor,
          ),
          child: Image.asset("asset/images/ic_camera.png",
              width: 36.6.w, color: prefix0.color959ca7));
    else if (meetingStatus.id == 4)
      return hasRecord
          ? Container(
              width: 80.0.w,
              height: 80.0.w,
              padding: EdgeInsets.only(left: 8.0.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xffe10606),
              ),
              child: Center(
                child: Image.asset(
                  "asset/images/ic_calendar_youtube.png",
                  width: 24.1.w,
                ),
              ),
            )
          : Container(
              alignment: Alignment.center,
              width: 80.0.w,
              height: 80.0.w,
              padding: EdgeInsets.all(21.7.h),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: prefix0.whiteColor,
              ),
              child: Image.asset("asset/images/ic_camera.png",
                  color: prefix0.orangeColor,
                  width: 36.6.w,
                  fit: BoxFit.contain));
    else
      return Container(
          width: 80.0.w,
          height: 80.0.w,
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(17)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFffffff),
          ));
  }
}
