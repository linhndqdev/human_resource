import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/common/cache_helper.dart';

import 'dialog_utils.dart';

class FingerPrintButton extends StatefulWidget {
  final FingerPrintButtonState state;

  const FingerPrintButton({Key key, this.state}) : super(key: key);

  @override
  _FingerPrintButtonState createState() => _FingerPrintButtonState();
}

class _FingerPrintButtonState extends State<FingerPrintButton> {
  AppBloc appBloc;

  void onClickButton() async {
    if (widget.state == FingerPrintButtonState.ENABLE) {
      if (Platform.isAndroid) {
        bool statusFingerPrintKey = await CacheHelper.getStatusFingerPrint();
        DialogUtils.showDialogAuthenticateFingerprint(
            context, appBloc, statusFingerPrintKey);
      } else if (Platform.isIOS) {
        appBloc.authBloc.authenticateFingerPrintIOS(context);
      }
    } else {
      DialogUtils.showDialogAuthenticateFinger(context,
          title: "Thất bại",
          message:
              "Bạn xác thực vân tay không thành công. Vui lòng đăng nhập bằng tài khoản và mật khẩu.",
          styleTitle: TextStyle(
            color: Color(0xffee8800),
            fontFamily: 'Roboto-Bold',
            fontSize: 50.sp,
          ),
          haveButton: false,
          fingerPrintDisable: false);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return InkWell(
      onTap: () {
        onClickButton();
      },
      child: Container(
        height: 163.h,
        width: 163.w,
        padding: EdgeInsets.only(
            left: 25.9.w, right: 26.8.w, top: 26.7.h, bottom: 26.h),
        decoration: BoxDecoration(
          color: widget.state == FingerPrintButtonState.ENABLE
              ? prefix0.accentColor
              : Color(0xff959ca7),
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10.w),
              topRight: Radius.circular(10.w)),
        ),
        child: Center(
          child: Image.asset(
            "asset/images/ic_finger_disable.png",
            width: 110.3.w,
            height: 110.3.h,
          ),
        ),
      ),
    );
  }
}

enum FingerPrintButtonState { HIDE, ENABLE, DISABLE }
