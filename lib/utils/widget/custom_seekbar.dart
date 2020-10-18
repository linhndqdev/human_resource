import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/utils/common/custom_size_render.dart';

class CustomSeekBar extends StatefulWidget {
  final Color dotColor;
  final Color lineColor;
  final double percent;

  const CustomSeekBar(
      {Key key, this.dotColor, this.lineColor, this.percent = 0})
      : super(key: key);

  @override
  _CustomSeekBarState createState() => _CustomSeekBarState();
}

class _CustomSeekBarState extends State<CustomSeekBar> {
  double maxWidth = 240.7;
  double dotSize = 32.1;

  @override
  Widget build(BuildContext context) {
    double maximumLineHeight = maxWidth - dotSize-1;
    return Container(
      width: ScreenUtil().setWidth( maxWidth),
      height: ScreenUtil().setHeight( 32.1),
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth( maxWidth),
            height: ScreenUtil().setHeight( 4.0),
            color: widget.lineColor.withOpacity(0.2),
          ),
          Container(
            width: ScreenUtil().setWidth( widget.percent * maximumLineHeight),
            height: ScreenUtil().setHeight( 4.0),
            color: widget.lineColor,
          ),
          Positioned(
            left: ScreenUtil().setWidth( widget.percent * maximumLineHeight),
            child: Container(
              width: ScreenUtil().setWidth( dotSize),
              height: ScreenUtil().setWidth( dotSize),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    SizeRender.renderBorderSize(context, dotSize),
                  ),
                  color: widget.dotColor),
            ),
          )
        ],
      ),
    );
  }
}
