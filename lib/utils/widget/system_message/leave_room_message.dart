import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/style.dart' as prefix0;
class LeaveRoomWidget extends StatefulWidget {
  final String fullName;

  const LeaveRoomWidget({Key key, this.fullName}) : super(key: key);
  @override
  _LeaveRoomWidgetState createState() => _LeaveRoomWidgetState();
}

class _LeaveRoomWidgetState extends State<LeaveRoomWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
      child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(children: [
            TextSpan(
                text: "Người dùng ",
                style: TextStyle(
                    fontSize:
                        ScreenUtil().setSp(40.0, allowFontScalingSelf: false),
                    fontFamily: "Roboto-Regular.ttf",
                    color: prefix0.blackColor333)),
            TextSpan(
                text: "${widget.fullName}",
                style: TextStyle(
                    fontSize:
                        ScreenUtil().setSp(40.0, allowFontScalingSelf: false),
                    fontFamily: "Roboto-Bold.ttf",
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFe18c12))),
            TextSpan(
                text: " đã rời khỏi nhóm.",
                style: TextStyle(
                    fontSize:
                        ScreenUtil().setSp(40.0, allowFontScalingSelf: false),
                    fontFamily: "Roboto-Regular.ttf",
                    color: prefix0.blackColor333)),
          ])),
    );
  }
}
