import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/core/meeting/model/meeting_model.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/animation/buttom_calendar_meeting.dart';

class StatusMeetingWidget extends StatelessWidget {
  final MeetingModel meetingModel;

  const StatusMeetingWidget({Key key, this.meetingModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = prefix0.white;
    String content = " ";
    if (meetingModel.status.id == 1) {
      color = prefix0.accentColor;
      content = "Chưa bắt đầu";
    } else if (meetingModel.status.id == 2) {
      color = Color(0xFF108800);
      content = "Tham gia";
    } else if (meetingModel.status.id == 3) {
      color = prefix0.color959ca7;
      content = "Đã hủy";
    } else if (meetingModel.status.id == 4) {
      color = meetingModel.hasRecord ? Color(0xffe10606) : prefix0.orangeColor;
      content = meetingModel.hasRecord ? "Xem lại" : "Kết thúc";
    }
    return Container(
      height: 121.0.h,
      width: 316.0.w,
      margin: EdgeInsets.only(
        right: 59.0.h,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(
          Radius.circular(
            SizeRender.renderBorderSize(context, 50.0),
          ),
        ),
      ),
      child: Center(
        child: Text(
          content,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontFamily: 'Roboto-Regular',
              fontSize: 40.0.sp,
              color: prefix0.whiteColor),
        ),
      ),
    );
  }
}
