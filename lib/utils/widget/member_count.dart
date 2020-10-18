import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MemberCount extends StatelessWidget {
  const MemberCount({
    Key key,
    @required this.userCount,
  }) : super(key: key);

  final int userCount;

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Text(
        "$userCount thành viên",
        style: TextStyle(
            fontSize: ScreenUtil().setSp(40.0),
            fontFamily: "Roboto-Regular",
            fontWeight: FontWeight.normal,
            color: Color(0xff959ca7)),
      ),
    );
  }
}
