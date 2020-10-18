import 'package:fluttertoast/fluttertoast.dart' as prefix0;
import 'package:human_resource/core/style.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart' as prefix1;
import 'package:flutter_screenutil/size_extension.dart';

class Toast {
  static void showShort(String msg, {Color textColor, Color backgroundColor}) {
    prefix0.Fluttertoast.showToast(
      msg: msg,
      fontSize: 16.0,
      toastLength: prefix0.Toast.LENGTH_SHORT,
      gravity: prefix0.ToastGravity.BOTTOM,
      backgroundColor: backgroundColor != null ? backgroundColor : accentColor,
      textColor: textColor != null ? textColor : whiteColor,
      timeInSecForIosWeb: 2,
    );
  }

  static void showLong(String msg) {
    prefix0.Fluttertoast.showToast(
      msg: msg,
      fontSize: 16.0,
      toastLength: prefix0.Toast.LENGTH_SHORT,
      gravity: prefix0.ToastGravity.BOTTOM,
      backgroundColor: accentColor,
      textColor: whiteColor,
      timeInSecForIosWeb: 2,
    );
  }

  static void showToastCustom(BuildContext context, String msg) {
    prefix1.Toast.show(msg, context,
        duration: prefix1.Toast.LENGTH_SHORT,
        textColor: Color(0xFF959ca7),
        backgroundColor: Colors.white,
        gravity: prefix1.Toast.BOTTOM,
        backgroundRadius: 55.0.w);
  }
}
