import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/core/app_bloc.dart';

import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/utils/animation/ZoomInAnimation.dart';
import 'package:human_resource/utils/animation/vibrate_animation.dart';

import 'fingerprint_widget.dart';

typedef OnClickDelete = Function();
typedef OnClickOK = Function();
typedef OnClickCancel = Function();

TapGestureRecognizer _recognizer;

class DialogUtils {
  //ngoc anh chú thích
  static void showDialogRemoveUser(BuildContext context, String userName,
      {@required OnClickDelete onClickDelete}) {
    showDialog(
        context: context,
        builder: (buildContext) {
          return ZoomInAnimation(
            Dialog(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: ScreenUtil().setHeight(36.0),
                        ),
                        Image.asset(
                          "asset/images/ic_warning_red.png",
                          width: ScreenUtil().setWidth(189.0),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(9.7),
                        ),
                        Flexible(
                          child: Text(
                            "Bạn muốn xóa thành viên",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: prefix0.blackColor333,
                                fontSize: ScreenUtil().setSp(44.0),
                                fontFamily: "Roboto-Regular"),
                          ),
                        ),
                        Flexible(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                text: userName,
                                style: TextStyle(
                                    color: prefix0.blackColor333,
                                    fontSize: ScreenUtil().setSp(44.0),
                                    fontFamily: "Roboto-Bold",
                                    fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: "?",
                                style: TextStyle(
                                    color: prefix0.blackColor333,
                                    fontSize: ScreenUtil().setSp(44.0),
                                    fontFamily: "Roboto-Regular"),
                              ),
                            ]),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(23.0),
                        ),
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(159.0),
                              right: ScreenUtil().setWidth(159.0),
                            ),
                            child: Text(
                              "Lưu ý: Hành động này là không thể hoàn tác",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Color(0xFFe50000),
                                  fontStyle: FontStyle.italic,
                                  fontSize: ScreenUtil().setSp(36.0),
                                  fontFamily: "Roboto-Italic"),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(39.0),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(67.0),
                            right: ScreenUtil().setWidth(67.0),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              onClickDelete();
                            },
                            child: ButtonTheme(
                              child: Container(
                                height: ScreenUtil().setHeight(107.5),
                                color: Color(0xFFe50000),
                                child: Center(
                                  child: Text(
                                    "Xóa thành viên".toUpperCase(),
                                    style: TextStyle(
                                        color: prefix0.white,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: "Roboto-Regular",
                                        fontSize: ScreenUtil().setSp(44.0)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(72.8),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: ScreenUtil().setHeight(16.7),
                    right: ScreenUtil().setWidth(23.7),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Image.asset(
                        "asset/images/ic_dismiss.png",
                        width: ScreenUtil().setWidth(69.0),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        barrierDismissible: false);
  }

  static void showAlertNotificationDialog(BuildContext context,
      {@required String title,
      @required String message,
      @required VoidCallback onClickOK}) {
    _recognizer = TapGestureRecognizer()
      ..onTap = () {
        onClickOK();
//       Toast.showShort("Hiển thị thông tin chi tiết thông báo");
      };
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ZoomInAnimation(
          Dialog(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(
                        left: 60.0.w, right: 59.0.w, top: 199.0.h),
                    width: 961.0.w,
//            height: 264.0.h,
                    decoration: BoxDecoration(
                      color: prefix0.whiteColor,
                      borderRadius: BorderRadius.circular(10.0.w),
                    ),
                    child: Row(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  left: 57.5.w, top: 72.0.h, bottom: 90.7.h),
                              child: Image.asset(
                                "asset/images/ic_notifi.png",
                                color: Colors.grey,
                                width: 100.0.w,
                                height: 102.0.h,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 37.9.w,
                        ),
                        Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  right: 26.0.w, top: 72.0.h, bottom: 90.7.h),
                              width: 737.0.w,
                              child: RichText(
                                text: TextSpan(
                                  text: title,
                                  style: TextStyle(
                                    color: prefix0.color959ca7,
                                    fontFamily: 'Roboto-Regular',
                                    fontSize: ScreenUtil().setSp(50.0),
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: message,
                                      style: TextStyle(
                                        color: prefix0.color3baae2,
                                        fontFamily: 'Roboto-Regular',
                                        fontSize: ScreenUtil().setSp(50.0),
                                      ),
                                      recognizer: _recognizer,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  static void showDialogResult(
      BuildContext context, DialogType type, String title) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (buildContext) {
          return ZoomInAnimation(
            Dialog(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: ScreenUtil().setHeight(67.0),
                        ),
                        Image.asset(
                          type == DialogType.SUCCESS
                              ? "asset/images/ic_dialog_success.png"
                              : "asset/images/ic_warning_red.png",
                          width: ScreenUtil().setWidth(189.0),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(19.7),
                        ),
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: prefix0.blackColor333,
                                  fontSize: ScreenUtil().setSp(44.0),
                                  fontFamily: "Roboto-Regular"),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(72.8),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: ScreenUtil().setHeight(16.7),
                    right: ScreenUtil().setWidth(23.7),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Image.asset(
                        "asset/images/ic_dismiss.png",
                        width: ScreenUtil().setWidth(69.0),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  static void showDialogRequestAcceptOrRefuse(BuildContext context,
      {@required String title,
      @required String message,
      @required VoidCallback onClickOK}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ZoomInAnimation(
            Dialog(
              insetAnimationCurve: Curves.bounceIn,
              backgroundColor: prefix0.white,
//            insetAnimationCurve: Curves.bounceIn,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(
                      SizeRender.renderBorderSize(context, 10.0))),
                ),
                padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(66.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                          fontFamily: 'Roboto-Bold',
                          color: Color(0xFF005a88),
                          fontSize: ScreenUtil().setSp(60.0),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(39.0),
                    ),
                    Container(
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Roboto-Regular',
                            color: prefix0.blackColor333,
                            fontSize: ScreenUtil().setSp(50.0),
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(137.5),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(1.0),
                      width: ScreenUtil().setWidth(889.0),
                      color: Color(0xff0959ca7),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            child: Container(
                              height: 187.5.h,
                              child: Center(
                                child: Text(
                                  "Không",
                                  style: TextStyle(
                                      fontFamily: 'Roboto-Regular',
                                      color: Color(0xFF959ca7),
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
                        ),
                        Container(
                          height: ScreenUtil().setHeight(188.0),
                          width: ScreenUtil().setWidth(1.0),
                          color: Color(0xff0959ca7),
                        ),
                        Expanded(
                          child: InkWell(
                            child: Container(
                              height: 187.5.h,
                              child: Center(
                                child: Text(
                                  "Có",
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
                              onClickOK();
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

// static Future<bool> showDialogRequestExitApp(BuildContext context,
//      {@required String title,
//        @required String message,
//        @required VoidCallback onClickOK, @required VoidCallback onClickCancel}) async{
//    bool exit = false;
//    showDialog(
//        barrierDismissible: false,
//        context: context,
//        builder: (BuildContext context) {
//          return AlertDialog(
////            insetAnimationCurve: Curves.bounceIn,
//            backgroundColor: prefix0.white,
//            actions: <Widget>[
//              Container(
//                padding: EdgeInsets.only(
//                  top: ScreenUtil().setHeight(66.0),
//                ),
//                child: Column(
//                  mainAxisSize: MainAxisSize.min,
//                  children: <Widget>[
//                    Text(
//                      title,
//                      style: TextStyle(
//                          fontFamily: 'Roboto-Bold',
//                          color: Color(0xFF005a88),
//                          fontSize: ScreenUtil().setSp(60.0),
//                          fontWeight: FontWeight.bold),
//                    ),
//                    SizedBox(
//                      height: ScreenUtil().setHeight(39.0),
//                    ),
//                    Container(
//                      child: Text(
//                        message,
//                        textAlign: TextAlign.center,
//                        style: TextStyle(
//                            fontFamily: 'Roboto-Regular',
//                            color: prefix0.blackColor333,
//                            fontSize: ScreenUtil().setSp(50.0),
//                            fontWeight: FontWeight.normal),
//                      ),
//                    ),
//                    SizedBox(
//                      height: ScreenUtil().setHeight(137.5),
//                    ),
//                    Container(
//                      height: ScreenUtil().setHeight(1.0),
//                      width: ScreenUtil().setWidth(889.0),
//                      color: Color(0xff0959ca7),
//                    ),
//                    Row(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: <Widget>[
//                        Container(
////                          margin: EdgeInsets.only(left: ScreenUtil().setWidth(151.5),
////                          right: ScreenUtil().setWidth(149.5)
////                          ),
//                          child: FlatButton(
//                            child: Text(
//                              "Không",
//                              style: TextStyle(
//                                  fontFamily: 'Roboto-Regular',
//                                  color: Color(0xFF959ca7),
//                                  fontSize: ScreenUtil().setSp(50.0),
//                                  fontWeight: FontWeight.normal),
//                              textAlign: TextAlign.center,
//                            ),
//                            onPressed: () {
//                              Navigator.of(context).pop();
//                              onClickCancel();
//                              exit =false;
//                            },
//                          ),
//                        ),
//                        Container(
//                          margin: EdgeInsets.only(
//                            left: ScreenUtil().setWidth(130.5),
//                            right: ScreenUtil().setWidth(140.5),
//                          ),
//                          height: ScreenUtil().setHeight(188.0),
//                          width: ScreenUtil().setWidth(1.0),
//                          color: Color(0xff0959ca7),
//                        ),
//                        Container(
////                          margin: EdgeInsets.only(left: ScreenUtil().setWidth(191.5),
////                              right: ScreenUtil().setWidth(191.0)
////                          ),
//                          child: FlatButton(
//                            child: Text(
//                              "Có",
//                              style: TextStyle(
//                                  fontFamily: 'Roboto-Regular',
//                                  color: prefix0.accentColor,
//                                  fontSize: ScreenUtil().setSp(50.0),
//                                  fontWeight: FontWeight.normal),
//                              textAlign: TextAlign.center,
//                            ),
//                            onPressed: () {
//
//                              Navigator.of(context).pop();
//                              onClickOK();
//                              return true;
//                            },
//                          ),
//                        )
//                      ],
//                    ),
//                  ],
//                ),
//              ),
//            ],
//          );
//        });
//    return exit;
//  }
  static void showDialogRemoveUserNewDesign(BuildContext context,
      {@required String title,
      @required String fullName,
      @required VoidCallback onClickOK}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ZoomInAnimation(
            Dialog(
              insetAnimationCurve: Curves.bounceIn,
              backgroundColor: prefix0.white,
              child: Container(
                padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(66.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                          fontFamily: 'Roboto-Bold',
                          color: prefix0.accentColor,
                          fontSize: 60.0.sp,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 39.0.h,
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                            text: "Bạn muốn xóa thành viên ",
                            style: TextStyle(
                              color: prefix0.blackColor333,
                              fontFamily: "Roboto-Regular",
                              fontSize: 50.0.sp,
                            )),
                        TextSpan(
                            text: fullName,
                            style: TextStyle(
                              color: Color(0xFFe10606),
                              fontFamily: "Roboto-Regular",
                              fontSize: 50.0.sp,
                            )),
                        TextSpan(
                            text: " khỏi nhóm?",
                            style: TextStyle(
                              color: prefix0.blackColor333,
                              fontFamily: "Roboto-Regular",
                              fontSize: 50.0.sp,
                            )),
                      ]),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(137.5),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(1.0),
                      width: ScreenUtil().setWidth(889.0),
                      color: Color(0xff0959ca7),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            child: Container(
                              height: 187.5.h,
                              child: Center(
                                child: Text(
                                  "Không",
                                  style: TextStyle(
                                      fontFamily: 'Roboto-Regular',
                                      color: Color(0xFF959ca7),
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
                        ),
                        Container(
                          height: ScreenUtil().setHeight(187.5),
                          width: ScreenUtil().setWidth(1.0),
                          color: Color(0xff0959ca7),
                        ),
                        Expanded(
                          child: InkWell(
                            child: Container(
                              height: 187.5.h,
                              child: Center(
                                child: Text(
                                  "Có",
                                  style: TextStyle(
                                      fontFamily: 'Roboto-Regular',
                                      color: prefix0.accentColor,
                                      fontSize: ScreenUtil().setSp(50.0),
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                              onClickOK();
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  //Void thì không return được anh ạ

  static void showDialogRequest(BuildContext context,
      {@required String title,
      @required String message,
      @required VoidCallback onClickOK}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (buildContext) {
          return ZoomInAnimation(
            Dialog(
              insetAnimationCurve: Curves.bounceIn,
              backgroundColor: prefix0.white,
              child: Container(
                padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(66.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                          fontFamily: 'Roboto-Bold',
                          color: Color(0xFF005a88),
                          fontSize: ScreenUtil().setSp(60.0),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(23.0),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Roboto-Regular',
                            color: prefix0.blackColor333,
                            fontSize: ScreenUtil().setSp(50.0),
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(98.5),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(1.0),
                      width: ScreenUtil().setWidth(889.0),
                      color: Color(0xff0959ca7),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                height: 187.5.h,
                                child: Center(
                                  child: Text(
                                    "Không",
                                    style: TextStyle(
                                        fontFamily: 'Roboto-Regular',
                                        color: Color(0xFF959ca7),
                                        fontSize: ScreenUtil().setSp(50.0),
                                        fontWeight: FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )),
                        ),
                        Container(
                          height: ScreenUtil().setHeight(188.0),
                          width: ScreenUtil().setWidth(1.0),
                          color: Color(0xff0959ca7),
                        ),
                        Expanded(
                          child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                onClickOK();
                              },
                              child: Container(
                                height: 187.5.h,
                                child: Center(
                                  child: Text(
                                    "Có",
                                    style: TextStyle(
                                        fontFamily: 'Roboto-Regular',
                                        color: prefix0.accentColor,
                                        fontSize: ScreenUtil().setSp(50.0),
                                        fontWeight: FontWeight.normal),
                                  ),
                                ),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  static void showDialogCompulsory(BuildContext context,
      {@required String title,
      @required String message,
      @required VoidCallback onClickOK}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (buildContext) {
          return ZoomInAnimation(Dialog(
            insetAnimationCurve: Curves.bounceIn,
            backgroundColor: prefix0.white,
            child: Container(
              padding: EdgeInsets.only(
                top: ScreenUtil().setHeight(66.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                        fontFamily: 'Roboto-Bold',
                        color: Color(0xFF005a88),
                        fontSize: ScreenUtil().setSp(60.0),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(23.0),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Roboto-Regular',
                          color: prefix0.blackColor333,
                          fontSize: ScreenUtil().setSp(50.0),
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(98.5),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onClickOK();
                    },
                    child: Text(
                      "Đã hiểu",
                      style: TextStyle(
                          fontFamily: 'Roboto-Regular',
                          color: prefix0.accentColor,
                          fontSize: ScreenUtil().setSp(50.0),
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
            ),
          ));
        });
  }

  static void showDialogLogout(BuildContext context,
      {@required String title,
      @required String message,
      @required String childtext1,
      @required String childtext2,
      @required VoidCallback onClickOK}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (buildContext) {
          return ZoomInAnimation(
            Dialog(
              insetAnimationCurve: Curves.bounceIn,
              backgroundColor: prefix0.white,
              child: Container(
                padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(66.0),
                ),
                child: Column(
//                crossAxisAlignment: CrossAxisAlignment.center,
//                mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                          fontFamily: 'Roboto-Bold',
                          color: Color(0xFFe10606),
                          fontSize: ScreenUtil().setSp(60.0),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(23.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Flexible(
                          child: Container(
                            margin:
                                EdgeInsets.only(left: 119.w, right: 119.0.w),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: message,
                                style: TextStyle(
                                  color: prefix0.color959ca7,
                                  fontFamily: 'Roboto-Regular',
                                  fontSize: ScreenUtil().setSp(50.0),
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: childtext1,
                                    style: TextStyle(
                                      color: prefix0.accentColor,
                                      fontFamily: 'Roboto-Bold',
                                      fontSize: ScreenUtil().setSp(50.0),
                                    ),
                                  ),
                                  TextSpan(
                                    text: childtext2,
                                    style: TextStyle(
                                      color: prefix0.color959ca7,
                                      fontFamily: 'Roboto-Regular',
                                      fontSize: ScreenUtil().setSp(50.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(98.5),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(1.0),
                      color: Color(0xff0959ca7),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 187.5.h,
                              child: Center(
                                child: Text(
                                  "Hủy",
                                  style: TextStyle(
                                      fontFamily: 'Roboto-Regular',
                                      color: Color(0xFF959ca7),
                                      fontSize: ScreenUtil().setSp(50.0),
                                      fontWeight: FontWeight.normal),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: ScreenUtil().setHeight(188.0),
                          width: ScreenUtil().setWidth(1.0),
                          color: Color(0xff0959ca7),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              onClickOK();
                            },
                            child: Container(
                              height: 187.5.h,
                              child: Center(
                                child: Text(
                                  "Có",
                                  style: TextStyle(
                                      fontFamily: 'Roboto-Regular',
                                      color: prefix0.accentColor,
                                      fontSize: ScreenUtil().setSp(50.0),
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  static void showDialogAllowAuthQrCode(BuildContext context,
      {@required String title,
      @required String message,
      @required String childtext1,
      @required String childtext2,
      @required VoidCallback onClickOK,
      @required VoidCallback onClickCancel}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (buildContext) {
          return ZoomInAnimation(
            Dialog(
              insetAnimationCurve: Curves.bounceIn,
              backgroundColor: prefix0.white,
              child: Container(
                padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(66.0),
                ),
                child: Column(
//                crossAxisAlignment: CrossAxisAlignment.center,
//                mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                          fontFamily: 'Roboto-Bold',
                          color: Color(0xFFe10606),
                          fontSize: ScreenUtil().setSp(60.0),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(23.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Flexible(
                          child: Container(
                            margin:
                                EdgeInsets.only(left: 119.w, right: 119.0.w),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: message,
                                style: TextStyle(
                                  color: prefix0.color959ca7,
                                  fontFamily: 'Roboto-Regular',
                                  fontSize: ScreenUtil().setSp(50.0),
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: childtext1,
                                    style: TextStyle(
                                      color: prefix0.accentColor,
                                      fontFamily: 'Roboto-Bold',
                                      fontSize: ScreenUtil().setSp(50.0),
                                    ),
                                  ),
                                  TextSpan(
                                    text: childtext2,
                                    style: TextStyle(
                                      color: prefix0.color959ca7,
                                      fontFamily: 'Roboto-Regular',
                                      fontSize: ScreenUtil().setSp(50.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(98.5),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(1.0),
                      color: Color(0xff0959ca7),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              onClickCancel();
                            },
                            child: Container(
                              height: 187.5.h,
                              child: Center(
                                child: Text(
                                  "Từ chối",
                                  style: TextStyle(
                                      fontFamily: 'Roboto-Regular',
                                      color: Color(0xFF959ca7),
                                      fontSize: ScreenUtil().setSp(50.0),
                                      fontWeight: FontWeight.normal),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: ScreenUtil().setHeight(188.0),
                          width: ScreenUtil().setWidth(1.0),
                          color: Color(0xff0959ca7),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              onClickOK();
                            },
                            child: Container(
                              height: 187.5.h,
                              child: Center(
                                child: Text(
                                  "Đồng ý",
                                  style: TextStyle(
                                      fontFamily: 'Roboto-Regular',
                                      color: prefix0.accentColor,
                                      fontSize: ScreenUtil().setSp(50.0),
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  static void showDialogRequestExitApp(BuildContext context,
      {@required VoidCallback onClickOK}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (buildContext) {
          return ZoomInAnimation(
            Dialog(
              insetAnimationCurve: Curves.bounceIn,
              backgroundColor: prefix0.white,
              child: Container(
                padding: EdgeInsets.only(
                  top: ScreenUtil().setHeight(117.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Bạn có chắc muốn thoát",
                      style: TextStyle(
                        fontFamily: 'Roboto-Medium',
                        color: Color(0xFF005a88),
                        fontSize: ScreenUtil().setSp(50.0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Ứng dụng?",
                      style: TextStyle(
                        fontFamily: 'Roboto-Medium',
                        color: Color(0xFF005a88),
                        fontSize: ScreenUtil().setSp(50.0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(136.5),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(1.0),
                      width: ScreenUtil().setWidth(889.0),
                      color: Color(0xff0959ca7),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 187.5.h,
                              child: Center(
                                child: Text(
                                  "Huỷ",
                                  style: TextStyle(
                                      fontFamily: 'Roboto-Regular',
                                      color: Color(0xFF959ca7),
                                      fontSize: ScreenUtil().setSp(50.0),
                                      fontWeight: FontWeight.normal),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ), //huỷ
                        Container(
                          height: ScreenUtil().setHeight(188.0),
                          width: ScreenUtil().setWidth(1.0),
                          color: Color(0xff0959ca7),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              onClickOK();
                            },
                            child: Container(
                              height: 187.5.h,
                              child: Center(
                                child: Text(
                                  "Có",
                                  style: TextStyle(
                                      fontFamily: 'Roboto-Regular',
                                      color: prefix0.accentColor,
                                      fontSize: ScreenUtil().setSp(50.0),
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          ),
                        ), //có
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  static void showDialogRequestAddMember(
      BuildContext context, AddressBookModel userPicked,
      {@required VoidCallback onClickOK}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (buildContext) {
          return ZoomInAnimation(
            Dialog(
              insetAnimationCurve: Curves.bounceIn,
              backgroundColor: prefix0.white,
              child: Container(
                padding: EdgeInsets.only(
                    top: ScreenUtil().setHeight(76.0),
                    left: ScreenUtil().setWidth(103.0),
                    right: ScreenUtil().setWidth(103.0)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "Thêm thành viên",
                      style: TextStyle(
                          fontFamily: 'Roboto-Bold',
                          color: Color(0xFF005a88),
                          fontSize: ScreenUtil().setSp(60.0),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(34.0),
                    ),
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(children: [
                          TextSpan(
                            text: "Bạn có muốn thêm thành viên ",
                            style: TextStyle(
                                color: prefix0.blackColor333,
                                fontFamily: 'Roboto-Regular',
                                fontSize: ScreenUtil().setSp(48.0)),
                          ),
                          TextSpan(
                            text: "${userPicked.name}",
                            style: TextStyle(
                                color: Color(0xFFe18c12),
                                fontFamily: 'Roboto-Regular',
                                fontSize: ScreenUtil().setSp(48.0)),
                          ),
                          TextSpan(
                            text: " vào nhóm?",
                            style: TextStyle(
                                color: prefix0.blackColor333,
                                fontFamily: 'Roboto-Regular',
                                fontSize: ScreenUtil().setSp(48.0)),
                          ),
                        ])),
                    SizedBox(
                      height: ScreenUtil().setHeight(82.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 25.0.w,
                                right: 25.0.w,
                              ),
                              height: 187.5.h,
                              child: Center(
                                child: Text(
                                  "KHÔNG",
                                  style: TextStyle(
                                      fontFamily: 'Roboto-Bold',
                                      color: Color(0xFF005a88),
                                      fontSize: ScreenUtil().setSp(48.0),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            onClickOK();
                          },
                          child: Container(
                            height: 187.5.h,
                            margin: EdgeInsets.only(
                              left: 25.0.w,
                              right: 25.0.w,
                            ),
                            child: Center(
                              child: Text(
                                "CÓ",
                                style: TextStyle(
                                    fontFamily: 'Roboto-Bold',
                                    color: prefix0.blackColor333,
                                    fontSize: ScreenUtil().setSp(48.0),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  static void showDialogLogin(
    BuildContext context,
    bool isSucess,
    String title,
    String description,
  ) {
    showDialog(
        context: context,
        builder: (buildContext) {
          return ZoomInAnimation(
            Dialog(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: ScreenUtil().setHeight(36.0),
                        ),
//                      Image.asset(
//                        "asset/images/ic_warning_red.png",
//                        width: SizeRender.renderSizeWith(context, 189.0),
//                      ),
                        SizedBox(
                          height: ScreenUtil().setHeight(9.7),
                        ),
                        Flexible(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                text: title,
                                style: TextStyle(
                                    color: prefix0.blackColor,
                                    fontSize: SizeRender.renderTextSize(
                                        context, 60.0),
                                    fontFamily: "Roboto-Bold",
                                    fontWeight: FontWeight.bold),
                              ),
                            ]),
                          ),
                        ),
                        SizedBox(height: ScreenUtil().setHeight(23)),
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(159.0),
                              right: ScreenUtil().setWidth(159.0),
                            ),
                            child: Text(
                              description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: prefix0.blackColor,
                                  fontSize: ScreenUtil().setSp(50)),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(39.0),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(67.0),
                            right: ScreenUtil().setWidth(67.0),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: ButtonTheme(
                              child: Container(
                                height: ScreenUtil().setHeight(107.5),
                                color: prefix0.accentColor,
                                child: Center(
                                  child: Text(
                                    "Đóng".toUpperCase(),
                                    style: TextStyle(
                                        color: prefix0.white,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: "Roboto-Regular",
                                        fontSize: ScreenUtil().setSp(44)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtil().setHeight(72.8),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: ScreenUtil().setHeight(16.7),
                    right: ScreenUtil().setWidth(23.7),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.close),
//                    child: Image.asset(
//                      "asset/images/ic_dismiss.png",
//                      width: SizeRender.renderSizeWith(context, 69.0),
//                    ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        barrierDismissible: false);
  }

  static void showDialogForgotSuccess(
    BuildContext context,
    bool isSucess,
    String title,
    String description,
    String email,
    bool haveEmail,
  ) {
    String convertString;
    if (haveEmail && email.length >= 8) {
      convertString = email.replaceRange(2, email.length - 8, "******");
    } else {
      convertString = email;
    }
    showDialog(
        context: context,
        builder: (buildContext) {
          return ZoomInAnimation(
            Dialog(
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: <Widget>[
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: SizeRender.renderSizeHeight(context, 103.0),
                        ),
                        Flexible(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                text: title,
                                style: TextStyle(
                                    color: prefix0.blackColor,
                                    fontSize: SizeRender.renderTextSize(
                                        context, 60.0),
                                    fontFamily: "Roboto-Bold",
                                    fontWeight: FontWeight.bold),
                              ),
                            ]),
                          ),
                        ),
                        SizedBox(
                          height: SizeRender.renderSizeHeight(context, 21.0),
                        ),
                        haveEmail
                            ? Container(
                                padding: EdgeInsets.only(
                                  left:
                                      SizeRender.renderSizeWith(context, 53.0),
                                  right:
                                      SizeRender.renderSizeWith(context, 53.0),
                                ),
                                child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                        style: TextStyle(
                                            color: prefix0.blackColor,
                                            fontSize: SizeRender.renderTextSize(
                                                context, 50.0),
                                            fontFamily: 'Roboto-Regular'),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                "Đường dẫn thay đổi mật khẩu đã gửi tới ",
                                            style: TextStyle(
                                                color: prefix0.blackColor,
                                                fontSize:
                                                    SizeRender.renderTextSize(
                                                        context, 50.0),
                                                fontFamily: 'Roboto-Regular'),
                                          ),
                                          TextSpan(
                                            text: convertString,
                                            style: TextStyle(
                                                color: prefix0.accentColor,
                                                fontSize:
                                                    SizeRender.renderTextSize(
                                                        context, 50.0),
                                                fontFamily: 'Roboto-Bold'),
                                          ),
                                          TextSpan(
                                            text:
                                                " .Nếu bạn không sử dụng e-mail này, vui lòng liên hệ trực tiếp với bộ phận hỗ trợ! ",
                                            style: TextStyle(
                                                color: prefix0.blackColor,
                                                fontSize:
                                                    SizeRender.renderTextSize(
                                                        context, 50.0),
                                                fontFamily: 'Roboto-Regular'),
                                          ),
                                        ])),
                              )
                            : Flexible(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: SizeRender.renderSizeWith(
                                        context, 53.0),
                                    right: SizeRender.renderSizeWith(
                                        context, 53.0),
                                  ),
                                  child: Text(
                                    description,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: prefix0.blackColor,
                                        fontSize: SizeRender.renderTextSize(
                                            context, 50.0),
                                        fontFamily: 'Roboto-Regular'),
                                  ),
                                ),
                              ),
                        SizedBox(
                          height: SizeRender.renderSizeHeight(context, 39.0),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: Color(0xffdde0e6), width: 1.0))),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: ScreenUtil().setWidth(444.5),
                                height: ScreenUtil().setHeight(188.5),
                                decoration: BoxDecoration(
                                    border: Border(
                                        right: BorderSide(
                                            color: Color(0xffdde0e6),
                                            width: 1.0))),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: ButtonTheme(
                                  child: Container(
                                    width: ScreenUtil().setWidth(400.5),
                                    height: ScreenUtil().setHeight(188.5),
                                    child: Center(
                                      child: Text(
                                        "Quay lại",
                                        style: TextStyle(
                                            color: prefix0.accentColor,
                                            fontFamily: "Roboto-Bold",
                                            fontSize: ScreenUtil().setSp(50)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        barrierDismissible: false);
  }

  static void showDialogRequestChangeNotify(BuildContext context, String title,
      String content1, String content2, String content3,
      {@required VoidCallback onClickOK}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (buildContext) {
          return ZoomInAnimation(
            Dialog(
              insetAnimationCurve: Curves.bounceIn,
              backgroundColor: prefix0.white,
              child: Container(
                padding: EdgeInsets.only(top: 60.0.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(
                      SizeRender.renderBorderSize(context, 10.0))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Roboto-Bold',
                        color: prefix0.orangeColor,
                        fontSize: ScreenUtil().setSp(60.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 34.0.h,
                    ),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                          text: content1,
                          style: TextStyle(
                              fontSize: 50.0.sp,
                              fontFamily: "Roboto-Regular",
                              color: prefix0.blackColor333),
                        ),
                        TextSpan(
                          text: content2,
                          style: TextStyle(
                              fontSize: 50.0.sp,
                              fontFamily: "Roboto-Bold",
                              color: prefix0.accentColor),
                        ),
                        TextSpan(
                          text: content3,
                          style: TextStyle(
                              fontSize: 50.0.sp,
                              fontFamily: "Roboto-Regular",
                              color: prefix0.blackColor333),
                        ),
                      ]),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(80.5),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(1.0),
                      width: ScreenUtil().setWidth(889.0),
                      color: Color(0xff0959ca7),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                                height: 187.5.h,
                                child: Center(
                                  child: Text(
                                    "Huỷ",
                                    style: TextStyle(
                                        fontFamily: 'Roboto-Regular',
                                        color: Color(0xFF959ca7),
                                        fontSize: ScreenUtil().setSp(50.0),
                                        fontWeight: FontWeight.normal),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                          ),
                        ), //huỷ
                        Container(
                          height: ScreenUtil().setHeight(188.0),
                          width: ScreenUtil().setWidth(1.0),
                          color: Color(0xff0959ca7),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                              onClickOK();
                            },
                            child: Container(
                              height: 187.5.h,
                              child: Center(
                                child: Text(
                                  "Có",
                                  style: TextStyle(
                                      fontFamily: 'Roboto-Regular',
                                      color: prefix0.accentColor,
                                      fontSize: ScreenUtil().setSp(50.0),
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ),
                          ),
                        ), //có
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  static void showDialogAuthenticateFingerprint(
      BuildContext context, AppBloc appBloc, bool statusFingerPrintKey) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (buildContext) {
          return VibrateAnimation(
            Dialog(
              insetAnimationCurve: Curves.bounceIn,
              backgroundColor: prefix0.white,
              child: FingerprintWidget(appBloc, context, statusFingerPrintKey),
            ),
          );
        });
  }

  static void showDialogAuthenticateFinger(
    BuildContext context, {
    String title,
    String message,
    bool haveButton,
    TextStyle styleTitle,
    bool fingerPrintDisable,
  }) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return VibrateAnimation(
          Dialog(
            child: Container(
              margin: EdgeInsets.only(left: 27.w, right: 27.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(
                    SizeRender.renderBorderSize(context, 10.0))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: ScreenUtil().setHeight(36.8),
                  ),
                  Image.asset(
                    fingerPrintDisable
                        ? "asset/images/ic_finger_disable.png"
                        : "asset/images/ic_finger_enable.png",
                    width: 171.2.w,
                    height: 171.2.h,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(4.0),
                  ),
                  Text(
                    title,
                    style: styleTitle,
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(18.0),
                  ),
                  Container(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Roboto-Regular',
                          color: prefix0.blackColor333,
                          fontSize: ScreenUtil().setSp(40.0),
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(54.6),
                  ),
                  haveButton
                      ? Container(
                          height: ScreenUtil().setHeight(1.0),
                          width: ScreenUtil().setWidth(889.0),
                          color: Color(0xff0959ca7),
                        )
                      : Container(),
                  haveButton
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
                                          color: Color(0xff959ca7),
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
            ),
          ),
        );
      },
    );
  }

  static void showDialogAuthenticateFingerFirst(BuildContext context) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return VibrateAnimation(
          Dialog(
            child: Container(
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
            ),
          ),
        );
      },
    );
  }
}

enum DialogType { SUCCESS, FAILED }
enum ConfirmAction { CANCEL, ACCEPT }
