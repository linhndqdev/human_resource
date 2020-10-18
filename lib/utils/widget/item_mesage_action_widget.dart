import 'package:flutter/material.dart';
import 'package:human_resource/utils/animation/ZoomInAnimation.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/utils/animation/bottomBarAnimation.dart';
import 'package:human_resource/utils/animation/message_action_animation.dart';

class ItemMessageActionWidget extends StatelessWidget {
  final VoidCallback onClickItem;
  final double sizeWidth;
  final String summary;
  final String assetImage;


  ItemMessageActionWidget(this.onClickItem, this.sizeWidth,
      this.summary, this.assetImage);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: MessageActionAnimation(
          OutlineButton(
            highlightedBorderColor: Colors.transparent,
            borderSide: BorderSide(
              color: Colors.transparent
            ),
            padding: EdgeInsets.all(0.0),
              onPressed: () {
                onClickItem();
              },
              child: Container(
                padding: EdgeInsets.only(top: 37.h, bottom: 25.6.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 90.0.h,
                      child: assetImage != ""
                          ? Image.asset(
                        assetImage,
                        width: sizeWidth.w,
                      )
                          : Icon(
                        Icons.flip,
                        color: prefix0.accentColor,
                      ),
                    ),
                    SizedBox(
                      height: 17.3.h,
                    ),
                    Text(
                      summary,
                      style: TextStyle(
                          fontFamily: "Roboto-Regular",
                          fontSize: 42.0.sp,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFFb1afaf)),
                    ),
                  ],
                ),
              ))
      ),
    );
  }
}
