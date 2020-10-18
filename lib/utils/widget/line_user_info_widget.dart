import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LineUserInfo extends StatelessWidget {
  final String title;
  final String content;

  const LineUserInfo({Key key, this.title, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: ScreenUtil().setHeight(16.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Text(
              "$title: $content",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Roboto-Regular',
                  color: Color(0xFF959ca7),
                  fontSize: ScreenUtil().setSp(48.0)),
            ),
          )
        ],
      ),
    );
  }
}
