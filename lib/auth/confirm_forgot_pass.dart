import 'package:human_resource/core/style.dart' as ASGLStyle;
import 'package:flutter/material.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConfirmForgotPass extends StatefulWidget {
  final String messageString;

  ConfirmForgotPass(this.messageString);

  @override
  _ConfirmForgotPassState createState() => _ConfirmForgotPassState();
}

class _ConfirmForgotPassState extends State<ConfirmForgotPass> {
  AppBloc appBloc;

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return Scaffold(
        appBar: AppBar(
            elevation: 0.0,
            centerTitle: true,
            title: Text(
              'Đổi mật khẩu',
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(60),
                  color: ASGLStyle.blackColor),
            ),
            backgroundColor: Color(0xFF0FAFAFA),
            leading: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  color: ASGLStyle.blackColor,
                ),
                onPressed: () {
                  appBloc.authBloc.moveToForgotPassScreen();
                })),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    left: ScreenUtil().setWidth(176.0),
                    right: ScreenUtil().setWidth(176.4),
                    top: ScreenUtil().setHeight(98.3),
                  ),
                  child: Text(
                    widget.messageString,
//                    'Đường dẫn thay đổi mật khẩu đã được gửi tới email tr***89@gmail.com thuộc mã nhân viên ASGL-0078. Nếu bạn không sử dụng email này vui lòng liên hệ trực tiếp với bộ phận hỗ trợ',
                    style: TextStyle(fontSize: ScreenUtil().setSp(48)),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: ScreenUtil().setWidth(96),
                      right: ScreenUtil().setWidth(95.0),
                      top: ScreenUtil().setHeight(139.0),
                      bottom: ScreenUtil().setHeight(56.0)),
                  child: SizedBox(
                      width: double.infinity,
                      height: ScreenUtil().setHeight(176.0),
                      // specific value
                      child: FlatButton.icon(
                          shape: new RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: ASGLStyle.accentColor,
//                          color: Colors.red,
                          icon: Image.asset(
                            "asset/images/iconfinder_phone.png",
                            color: Colors.orange[800],
                            height: ScreenUtil().setWidth(74),
                            width: ScreenUtil().setWidth(74),
                          ),
//                          icon: Icon(Icons.call, color: Colors.orange[800]),
                          //`Icon` to display
                          label: Text(
                            'Liên hệ trực tiếp',
                            style: TextStyle(
                                color: ASGLStyle.white,
                                fontSize: ScreenUtil().setSp(60),
                                fontWeight: FontWeight.bold),
                          ),
                          //`Text` to display
                          onPressed: () {})),
                ),
                InkWell(
                  onTap: () {
                    appBloc.authBloc.moveToLoginScreen();
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      left: ScreenUtil().setWidth(380),
                    ),
                    child: ListTile(
                      leading: Image.asset(
                        "asset/images/back.png",
                        color: Colors.orange[800],
                        height: ScreenUtil().setHeight(40),
                        width: ScreenUtil().setWidth(63),
                      ),
                      title: Text(
                        'Quay lại đăng nhập',
                        style: TextStyle(
                            color: ASGLStyle.blackColor,
                            fontSize: ScreenUtil().setSp(40),
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Future<bool> loginAction() async {
    await new Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
