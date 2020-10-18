import 'package:flutter/material.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/auth/auth_bloc.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/platform/platform_helper.dart';
import 'package:human_resource/utils/common/custom_size_render.dart';
import 'package:human_resource/core/style.dart' as prefix0;

class DialogFingerPrint extends StatefulWidget {
 final String title;
 final String message;
 final bool haveButton;
 final TextStyle styleTitle;
 final bool fingerPrintDisable;

 DialogFingerPrint(this.title, this.message, this.haveButton, this.styleTitle,
     this.fingerPrintDisable);

 @override
  _DialogFingerPrintState createState() => _DialogFingerPrintState();
}

class _DialogFingerPrintState extends State<DialogFingerPrint> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
            Radius.circular(SizeRender.renderBorderSize(context, 10.0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: ScreenUtil().setHeight(36.8),
          ),
          Image.asset(
            widget.fingerPrintDisable
                ? "asset/images/ic_finger_disable.png"
                : "asset/images/ic_finger_enable.png",
            width: 171.2.w,
            height: 171.2.h,
          ),
          SizedBox(
            height: ScreenUtil().setHeight(14.0),
          ),
          Text(
            widget.title,
            style: widget.styleTitle,
          ),
          widget.message != null
              ? Container(
            margin: EdgeInsets.only(left: 47.w, right: 47.h,top: 18.0.h),
                  child: Text(
                    widget.message,
                    style: TextStyle(
                        fontFamily: 'Roboto-Regular',
                        color: prefix0.blackColor333,
                        fontSize: ScreenUtil().setSp(40.0),
                        fontWeight: FontWeight.normal),
                  ),
                )
              : Container(),
          SizedBox(
            height: ScreenUtil().setHeight(54.6),
          ),
          widget.haveButton
              ? Container(
                  height: ScreenUtil().setHeight(1.0),
                  width: ScreenUtil().setWidth(889.0),
                  color: Color(0xff0959ca7),
                )
              : Container(),
          widget.haveButton
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        child: Container(
                          height: 187.5.h,
                          child: Center(
                            child: Text(
                              "Hủy",
                              style: TextStyle(
                                  fontFamily: 'Roboto-Regular',
                                  color: prefix0.accentColor,
                                  fontSize: ScreenUtil().setSp(50.0),
                                  fontWeight: FontWeight.normal),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    )
                  ],
                )
              : Container(
                  height: 90.h,
                ),
        ],
      ),
    );
  }
}
