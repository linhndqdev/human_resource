import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/style.dart' as prefix0;

class AddUserMessage extends StatelessWidget {
  final String fullName;
  final String adminGroupFullname;

  const AddUserMessage({Key key, this.fullName, this.adminGroupFullname}) : super(key: key);

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
                text: "$fullName",
                style: TextStyle(
                    fontSize:
                    ScreenUtil().setSp(40.0, allowFontScalingSelf: false),
                    fontFamily: "Roboto-Bold.ttf",
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFe18c12))),
            TextSpan(
                text: " đã được thêm bởi ",
                style: TextStyle(
                    fontSize:
                    ScreenUtil().setSp(40.0, allowFontScalingSelf: false),
                    fontFamily: "Roboto-Regular.ttf",
                    color: prefix0.blackColor333)),
            TextSpan(
                text: "$adminGroupFullname",
                style: TextStyle(
                    fontSize:
                    ScreenUtil().setSp(40.0, allowFontScalingSelf: false),
                    fontFamily: "Roboto-Bold.ttf",
                    fontWeight: FontWeight.bold,
                    color: prefix0.accentColor))
          ])),
    );
  }
}
