import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/utils/widget/text_animated_widget.dart';
import 'package:human_resource/core/style.dart' as prefix0;

enum ResultDetectState { NONE, SUCCESS, FAILED, ANIMATED }

class ResultDetectModel {
  String message;
  ResultDetectState state;

  ResultDetectModel({this.message, this.state});
}

class ResultDetectWidget extends StatefulWidget {
  final ResultDetectModel resultData;
  final VoidCallback onDisableWidget;

  const ResultDetectWidget({Key key, this.resultData, this.onDisableWidget})
      : super(key: key);

  @override
  _ResultDetectWidgetState createState() => _ResultDetectWidgetState();
}

class _ResultDetectWidgetState extends State<ResultDetectWidget> {
  Timer timer;

  @override
  void didUpdateWidget(ResultDetectWidget oldWidget) {
    if (widget.resultData.state != ResultDetectState.ANIMATED) {
      _autoCloseWidget();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
//    _autoCloseWidget();
  }

  _autoCloseWidget() {
    _cleanTimer();
    //Tự động disable sau 3s
    timer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        widget.onDisableWidget();
      }
      _cleanTimer();
    });
  }

  _cleanTimer() {
    if (timer != null && timer.isActive) {
      timer.cancel();
      timer = null;
    }
  }

  @override
  void dispose() {
    _cleanTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 110.0.h,
      color: widget.resultData.state == ResultDetectState.FAILED
          ? Color(0xFFe18c12)
          : Color(0xFF3baae2),
      child: Center(child: buildContent()),
    );
  }

  buildContent() {
    if (widget.resultData.state == ResultDetectState.FAILED) {
      return Text(
        widget.resultData.message,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
            color: Color(0xFFffffff),
            fontStyle: FontStyle.normal,
            fontFamily: "Roboto-Regular",
            fontSize: 45.0.sp,
            fontWeight: FontWeight.normal),
      );
    } else if (widget.resultData.state == ResultDetectState.ANIMATED) {
      return TextAnimatedWidget(
          speed: Duration(milliseconds: 40),
          text: ["Đang trích xuất văn bản..."],
          textStyle: TextStyle(
              color: prefix0.white,
              fontSize: 45.0.sp,
              fontFamily: "Roboto-Regular"),
          textAlign: TextAlign.center,
          alignment: AlignmentDirectional.center // or Alignment.topLeft
          );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            widget.resultData.message,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
                color: Color(0xFFffffff),
                fontStyle: FontStyle.normal,
                fontFamily: "Roboto-Regular",
                fontSize: 45.0.sp,
                fontWeight: FontWeight.normal),
          ),
          SizedBox(
            width: 17.0.w,
          ),
          Icon(
            Icons.check,
            color: prefix0.white,
            size: 16.0,
          ),
        ],
      );
    }
  }
}
