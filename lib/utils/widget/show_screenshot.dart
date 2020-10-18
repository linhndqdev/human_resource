import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/size_extension.dart';

class ShowScreenshot extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onSendImage;

  const ShowScreenshot({Key key, this.onClose, this.onSendImage})
      : super(key: key);

  @override
  _ShowScreenshotState createState() => _ShowScreenshotState();
}

class _ShowScreenshotState extends State<ShowScreenshot> {
  AppBloc appBloc;
  Timer _timer;
  int countDownTime = 30;

  @override
  void didUpdateWidget(ShowScreenshot oldWidget) {
    _startTimer();
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  _startTimer() {
    countDownTime = 30;
    cancelTimerClose();
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (countDownTime > 0) {
        setState(() {
          countDownTime -= 1;
        });
      } else {
        cancelTimerClose();
        widget.onClose();
      }
    });
  }

  cancelTimerClose() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    cancelTimerClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return Container(
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                height: ScreenUtil().setHeight(30.0),
              ),
              Container(
                margin: EdgeInsets.only(right: 88.0.w),
                width: 423.0.w,
                height: ScreenUtil().setHeight(526.0),
                child: Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0.w)),
                  child: Image.file(
                    File(appBloc.getLatestImage().imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                height: ScreenUtil().setHeight(27.0),
              ),
              GestureDetector(
                onTap: () {
                  widget.onSendImage();
                },
                child: Container(
                  color: prefix0.orangeColor,
                  width: 423.0.w,
                  height: 98.0.h,
                  margin: EdgeInsets.only(
                      right: ScreenUtil().setWidth(88.0),
                      bottom: ScreenUtil().setHeight(80.5)),
                  child: Center(
                      child: Text(
                        "Gửi ngay ($countDownTime)",
                        style: TextStyle(
                          fontFamily: "Roboto",
                            fontWeight: FontWeight.bold,
                            color: prefix0.white,
                            fontSize: ScreenUtil().setSp(42.0)),
                        textAlign: TextAlign.center,
                      )),
                ),
              ),
            ],
          ),
          Positioned(
            right: 59.0.w,
            top: 0.0,
            child: GestureDetector(
              onTap: () {
                widget.onClose();
              },
              child: Container(
                child: Image.asset(
                  "asset/images/ic_closeimage.png",
                  width: ScreenUtil().setWidth(88.7),
                  height: ScreenUtil().setHeight(88.4),
                ),
              ),
            ),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(27.0),
          ),
        ],
      ),
    );
  }
}

enum LoadingState { HIDE, SHOW }
