import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
class ImageEditedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 12.0.w),
      child: Image.asset(
        "asset/images/action/ic_edit_owner.png",
        width: 27.0.w,
      ),
    );
  }
}
