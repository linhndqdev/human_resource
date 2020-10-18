import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/core/style.dart' as prefix0;

typedef OnClickAction = Function();

class LineActionWidget extends StatelessWidget {
  final String title;
  final Color titleColor;
  final bool isShowIcon;
  final OnClickAction onClickAction;

  const LineActionWidget(
      {Key key,
      @required this.title,
      @required this.titleColor,
      this.isShowIcon = false,
      this.onClickAction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: ScreenUtil().setWidth( 60.0),
          right: ScreenUtil().setWidth( 60.0),
          bottom: ScreenUtil().setHeight( 99.0)),
      child: InkWell(
        onTap: () {
          if (onClickAction != null) {
            onClickAction();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Roboto-Bold',
                  color: titleColor,
                  fontSize: ScreenUtil().setSp( 50.0),
                ),
              ),
            ),
            isShowIcon
                ? Icon(
                    Icons.chevron_right,
                    color: prefix0.blackColor333,
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
