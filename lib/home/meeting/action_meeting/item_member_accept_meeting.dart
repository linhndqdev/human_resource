import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/core/style.dart' as prefix0;

class ItemMemberAccept extends StatelessWidget {
  final String memberID;
  final String fullName;
  final String department;
  final VoidCallback onRemoveUser;

  const ItemMemberAccept(
      {Key key,
      this.memberID,
      this.fullName,
      this.department,
      this.onRemoveUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        CustomCircleAvatar(
          position: ImagePosition.GROUP,
          size: 114.0,
          userName: memberID,
        ),
        SizedBox(
          width: 60.0.w,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                fullName,
                style: TextStyle(
                    color: prefix0.blackColor333,
                    fontFamily: 'Roboto-Regular',
                    fontSize: 50.sp),
              ),
              Text(
                department,
                style: TextStyle(
                    color: prefix0.color959ca7,
                    fontFamily: 'Roboto-Regular',
                    fontSize: 40.sp),
              ),
            ],
          ),
        ),
        InkWell(
            onTap: () {
              onRemoveUser();
            },
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: prefix0.redColor),
              child: Center(
                child: Icon(
                  Icons.clear,
                  color: prefix0.asgBackgroundColorWhite,
                  size: 47.4.w,
                ),
              ),
            ))
      ],
    );
  }
}
