import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';

import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/widget/line_action_widget.dart';
import 'package:human_resource/utils/widget/line_user_info_widget.dart';

class AccManagementLayout extends StatefulWidget {
  @override
  _AccManagementLayoutState createState() => _AccManagementLayoutState();
}

class _AccManagementLayoutState extends State<AccManagementLayout> {
  AppBloc appBloc;
  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    final asglUser = appBloc.authBloc.asgUserModel;
    SystemChrome.setSystemUIOverlayStyle(prefix0.statusBarDark);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: prefix0.white,
        elevation: 0.0,
        title: Text(
          "Quản lý tài khoản",
          style: TextStyle(
            color: prefix0.blackColor333,
            fontFamily: 'Roboto-Bold',
            fontWeight: FontWeight.bold,
            fontSize: ScreenUtil().setSp( 60.0),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                      top: ScreenUtil().setHeight( 41.0)),
                  width: ScreenUtil().setWidth( 324.0),
                  child: Image.asset(
                      "asset/images/baseline-account_circle-24px.png"),
                  decoration: BoxDecoration(
                      color: prefix0.white, shape: BoxShape.circle),
                ),
              ],
            ),
            SizedBox(
              height: ScreenUtil().setHeight( 54.0),
            ),
            Text(
              asglUser.full_name??"Không xác định",
              style: TextStyle(
                  color: prefix0.blackColor333,
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil().setSp( 60.0)),
            ),
            SizedBox(
              height: ScreenUtil().setHeight( 6.0),
            ),
            LineUserInfo(
              title: "Mã nhân viên",
              content: asglUser.asgl_id??"Không xác định",
            ),
            LineUserInfo(
              title: "Bộ phận",
              content: "Không xác định",
            ),
            SizedBox(
              height: ScreenUtil().setHeight( 168.0),
            ),
            LineActionWidget(
              title: "Tài khoản",
              titleColor: Color(0xFF959ca7),
              isShowIcon: false,
            ),
            LineActionWidget(
              title: "Đổi mật khẩu",
              titleColor: prefix0.blackColor333,
              isShowIcon: true,
              onClickAction: () {
                //Click ĐỔi mật khẩu
              },
            ),
            LineActionWidget(
              title: "Đăng xuất",
              titleColor: prefix0.accentColor,
              isShowIcon: false,
              onClickAction: () {
                //Click Đăng xuất
                appBloc.authBloc.logOut(context);
              },
            ),
            LineActionWidget(
              title: "Chấm công",
              titleColor: Color(0xFF959ca7),
              isShowIcon: false,
            ),
            LineActionWidget(
              title: "Lịch sử vào/ra",
              titleColor: prefix0.blackColor333,
              isShowIcon: true,
              onClickAction: () {},
            ),
            LineActionWidget(
              title: "Lịch sử chấm công",
              titleColor: prefix0.blackColor333,
              isShowIcon: true,
              onClickAction: () {},
            ),
          ],
        ),
      ),
    );
  }
}
