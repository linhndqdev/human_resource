import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/splash/splash_bloc.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/widget/dialog_utils.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  AppBloc appBloc;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      if (!WebSocketHelper.getInstance().isConnected) {
        DialogUtils.showDialogCompulsory(context,
            title: "Cảnh báo",
            message:
                "Vui lòng kiểm tra kết nối mạng của bạn và khởi động lại ứng dụng.",
            onClickOK: () {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.HOME);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.SPLASH);
    return AnimatedContainer(
      duration: Duration(milliseconds: 1000),
      color: prefix0.accentColor,
      curve: Curves.fastOutSlowIn,
      child: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            child: Image.asset(
              "asset/images/bg_splash_full.png",
              fit: BoxFit.cover,

              height: MediaQuery.of(context).size.height,
//              width: MediaQuery.of(context).size.width,
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            color: prefix0.accentColor.withOpacity(0.9),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
//              crossAxisAlignment: CrossAxisAlignment.center,
//              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: ScreenUtil().setHeight(558),
                ),
                Image.asset(
                  "asset/images/logo-w.png",
                  height: ScreenUtil().setHeight(310.5),
                  width: ScreenUtil().setWidth(596.5),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(80.6),
                ),
                Image.asset(
                  "asset/images/ic_splash.png",
                  height: ScreenUtil().setHeight(398.7),
                  width: ScreenUtil().setWidth(397.9),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(30),
                ),
                Image.asset(
                  "asset/images/ic_splash_text.png",
                  height: ScreenUtil().setHeight(35.6),
                  width: ScreenUtil().setWidth(530.3),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
