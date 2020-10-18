import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/utils/common/custom_size_render.dart';
import 'package:human_resource/core/style.dart' as prefix0;

class DialogFingerPrintHavenPassUsername extends StatefulWidget {

  @override
  _DialogFingerPrintHavenPassUsernameState createState() => _DialogFingerPrintHavenPassUsernameState();
}

class _DialogFingerPrintHavenPassUsernameState extends State<DialogFingerPrintHavenPassUsername> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 27.w, right: 27.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(
            SizeRender.renderBorderSize(context, 10.0))),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: ScreenUtil().setHeight(51.1),
          ),
          Image.asset(
            "asset/images/ic_finger_disable.png",
            width: 171.2.w,
            height: 171.2.h,
            color: Color(0xffeaeaea),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(23.0),
          ),
          Text(
            "Vui lòng đăng nhập lần đầu tiên trước khi sử dụng vân tay",
            style: TextStyle(
              color: prefix0.accentColor,
              fontFamily: 'Roboto-Bold',
              fontSize: 40.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: ScreenUtil().setHeight(106),
          ),
        ],
      ),
    );
  }
}
