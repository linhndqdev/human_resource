import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/hive/hive_helper.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/auth/auth_bloc.dart';
import 'package:human_resource/utils/common/cache_helper.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/fingerprint_button_login.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  AppBloc appBloc;
  TextEditingController _inputPassController = TextEditingController();
  TextEditingController _inputUserController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    Future.delayed(Duration.zero, () async {
      await CacheHelper.removeCachedWhenLogOut();
      await HiveHelper.removeCacheWhenLogOut();
      appBloc?.authBloc?.checkUserNamePassWord(context: context)?.then((_) {
        autoRequestFingerPrint();
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      appBloc?.authBloc?.checkUserNamePassWord(context: context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.LOGIN);
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: Container(
                  color: prefix0.whiteColor,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top: ScreenUtil().setHeight(255)),
                  margin: EdgeInsets.only(
                    left: ScreenUtil().setWidth(128.9),
                    right: ScreenUtil().setWidth(127.9),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset(
                        "asset/images/logo.png",
                        width: ScreenUtil().setWidth(515),
                        height: ScreenUtil().setHeight(266.3),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(152.3),
                      ),
                      _buildTextFieldUser(),
                      StreamBuilder(
                          initialData: RegisterOldValidateState.NONE,
                          stream: appBloc.authBloc.validateUserStream.stream,
                          builder: (iconContext,
                              AsyncSnapshot<RegisterOldValidateState>
                                  validateNameSnap) {
                            switch (validateNameSnap.data) {
                              case RegisterOldValidateState.NONE:
                                return Container(
                                    height: ScreenUtil().setHeight(51.8));
                                break;
                              case RegisterOldValidateState.ERROR:
                                return Container(
                                  margin: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(10),
                                      bottom: ScreenUtil().setHeight(7.8)),
                                  child: Text(
                                    "Vui lòng nhập mã nhân viên đúng định dạng",
                                    style: TextStyle(
                                        color: prefix0.redColor,
                                        fontSize: ScreenUtil().setSp(34)),
                                  ),
                                );
                                break;
                              case RegisterOldValidateState.MATCHED:
                                return Container(
                                    height: ScreenUtil().setHeight(51.8));
                                break;
                              default:
                                return Container(
                                    height: ScreenUtil().setHeight(51.8));
                                break;
                            }
                          }),
                      _buildTextFieldPass(),
                      StreamBuilder(
                          initialData: RegisterOldValidateState.NONE,
                          stream: appBloc.authBloc.validatePassStream.stream,
                          builder: (iconContext,
                              AsyncSnapshot<RegisterOldValidateState>
                                  validateNameSnap) {
                            switch (validateNameSnap.data) {
                              case RegisterOldValidateState.NONE:
                                return Container();
                                break;
                              case RegisterOldValidateState.ERROR:
                                return Container(
                                  margin: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(10),
                                      bottom: ScreenUtil().setHeight(12)),
                                  child: Text(
                                    "Vui lòng nhập đúng định dạng mật khẩu .",
                                    style: TextStyle(
                                        color: prefix0.redColor,
                                        fontSize: ScreenUtil().setSp(34)),
                                  ),
                                );
                                break;
                              case RegisterOldValidateState.MATCHED:
                                return Container();
                                break;
                              default:
                                return Container();
                                break;
                            }
                          }),
                      Container(
                        width: ScreenUtil().setWidth(823),
                        margin:
                            EdgeInsets.only(top: ScreenUtil().setHeight(68.3)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(child: _buildRememberPass()),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(64.0),
                      ),
                      StreamBuilder(
                          initialData: appBloc.authBloc.fingerPrintStatusState,
                          stream:
                              appBloc.authBloc.enableAndDisableButton.stream,
                          builder: (buildContext,
                              AsyncSnapshot<FingerPrintButtonState>
                                  snapshotData) {
                            return Row(
                              children: <Widget>[
                                ButtonTheme(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                          right: BorderSide(
                                        color: Color(0xffffffff),
                                      )),
                                    ),
                                    width: ScreenUtil().setWidth(
                                        snapshotData.data !=
                                                FingerPrintButtonState.HIDE
                                            ? 658
                                            : 823),
                                    height: ScreenUtil().setHeight(163),
                                    child: new ButtonTheme(
                                      height: ScreenUtil().setHeight(163),
                                      minWidth: ScreenUtil().setWidth(
                                          snapshotData.data !=
                                                  FingerPrintButtonState.HIDE
                                              ? 658
                                              : 823),
                                      child: RaisedButton.icon(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10.w),
                                              topLeft: Radius.circular(10.w)),
                                        ),
                                        elevation: 0.0,
                                        icon: Text(''),
                                        color: prefix0.accentColor,
                                        highlightColor: prefix0.accentColor,
                                        label: Text('Đăng nhập',
                                            style: TextStyle(
                                              fontFamily: 'Roboto-Bold',
                                              fontSize:
                                                  ScreenUtil().setSp(50.0),
                                              color: prefix0.whiteColor,
                                            )),
                                        onPressed: () {
                                          FocusScope.of(context)
                                              .requestFocus(FocusNode());
                                          appBloc.authBloc.loginWith(
                                              context,
                                              _inputUserController.text,
                                              _inputPassController.text);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                if (snapshotData.data !=
                                    FingerPrintButtonState.HIDE)
                                  FingerPrintButton(
                                    state: snapshotData.data,
                                  )
                              ],
                            );
                          }),
                      SizedBox(
                        height: ScreenUtil().setHeight(46.0),
                      ),
                      InkWell(
                        onTap: () {
                          appBloc.authBloc.moveToForgotPassScreen();
                        },
                        child: Text("Quên mật khẩu?",
                            style: TextStyle(
                                color: Color(0xffe18c12),
                                fontSize: ScreenUtil().setSp(50.0),
                                fontFamily: 'Roboto-Regular')),
                      ),
                    ],
                  ))),
        ),
        StreamBuilder(
          initialData: false,
          stream: appBloc.authBloc.loadingStream.stream,
          builder: (loadingContext, AsyncSnapshot<bool> loadingSnap) {
            return Visibility(
              child: const Loading(),
              visible: loadingSnap.data,
            );
          },
        )
      ],
    );
  }

  _buildTextFieldUser() {
    _inputUserController.text = appBloc.authBloc?.email ?? "";
    return Stack(
      children: <Widget>[
        TextField(
          keyboardType: TextInputType.emailAddress,
          cursorColor: prefix0.greyColor,
          textInputAction: TextInputAction.done,
          textAlign: TextAlign.start,
          controller: _inputUserController,
          maxLines: 1,
          obscureText: false,
          enabled: true,
          onChanged: (value) {
            appBloc.authBloc.updateUser(value);
          },
          style: TextStyle(
              fontFamily: "Roboto-Regular",
              fontSize: ScreenUtil().setSp(44.0),
              color: prefix0.greyColor,
              fontWeight: FontWeight.normal),
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xffb1afaf),
                ),
                borderRadius: BorderRadius.all(Radius.circular(
                    SizeRender.renderBorderSize(context, 10.0)))),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xffb1afaf),
                ),
                borderRadius: BorderRadius.all(Radius.circular(
                    SizeRender.renderBorderSize(context, 10.0)))),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xffb1afaf),
                ),
                borderRadius: BorderRadius.all(Radius.circular(
                    SizeRender.renderBorderSize(context, 10.0)))),
            disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xffb1afaf),
                ),
                borderRadius: BorderRadius.all(Radius.circular(
                    SizeRender.renderBorderSize(context, 10.0)))),
            hintText: "Mã nhân viên",
            hintStyle: TextStyle(
                fontSize: ScreenUtil().setSp(50.0),
                fontFamily: "Roboto-Regular",
                color: prefix0.greyColor),
            contentPadding: EdgeInsets.only(
              bottom: ScreenUtil().setHeight(57),
              top: ScreenUtil().setHeight(57),
              left: ScreenUtil().setWidth(157),
              right: ScreenUtil().setWidth(63),
            ),
          ),
        ),
        Positioned(
          bottom: ScreenUtil().setHeight(58.0),
          left: ScreenUtil().setWidth(58.1),
          child: Image.asset(
            "asset/images/userIcon.png",
            width: ScreenUtil().setWidth(56.0),
          ),
        ),
      ],
    );
  }

  _buildTextFieldPass() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        StreamBuilder(
            initialData: false,
            stream: appBloc.authBloc.showPassStream.stream,
            builder: (buildContext, AsyncSnapshot<bool> showPassSnap) {
              return InkWell(
                onTap: () {
                  appBloc.authBloc.updateStateShowPass();
                },
                child: showPassSnap.data
                    ? TextField(
                        cursorColor: prefix0.greyColor,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.start,
                        obscureText: false,
                        controller: _inputPassController,
                        maxLines: 1,
                        enabled: true,
                        style: TextStyle(
                            fontFamily: "Roboto-Regular",
                            fontSize: ScreenUtil().setSp(44.0),
                            color: prefix0.greyColor,
                            fontWeight: FontWeight.normal),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffb1afaf),
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  SizeRender.renderBorderSize(context, 10.0)))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffb1afaf),
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  SizeRender.renderBorderSize(context, 10.0)))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffb1afaf),
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  SizeRender.renderBorderSize(context, 10.0)))),
                          disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffb1afaf),
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  SizeRender.renderBorderSize(context, 10.0)))),
                          hintText: "Mật Khẩu",
                          hintStyle: TextStyle(
                              fontSize: ScreenUtil().setSp(50.0),
                              fontFamily: "Roboto-Regular",
                              color: prefix0.greyColor),
                          contentPadding: EdgeInsets.only(
                            bottom: ScreenUtil().setHeight(57),
                            top: ScreenUtil().setHeight(57),
                            left: ScreenUtil().setWidth(157),
                            right: ScreenUtil().setWidth(63),
                          ),
                        ),
                      )
                    : TextField(
                        cursorColor:  prefix0.greyColor,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.start,
                        obscureText: true,
                        controller: _inputPassController,
                        maxLines: 1,
                        enabled: true,
                        style: TextStyle(
                            fontFamily: "Roboto-Regular",
                            fontSize: ScreenUtil().setSp(44.0),
                            color: prefix0.greyColor,
                            fontWeight: FontWeight.normal),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffb1afaf),
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  SizeRender.renderBorderSize(context, 10.0)))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffb1afaf),
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  SizeRender.renderBorderSize(context, 10.0)))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffb1afaf),
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  SizeRender.renderBorderSize(context, 10.0)))),
                          disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffb1afaf),
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  SizeRender.renderBorderSize(context, 10.0)))),
                          hintText: "Mật Khẩu",
                          hintStyle: TextStyle(
                              fontSize: ScreenUtil().setSp(50.0),
                              fontFamily: "Roboto-Regular",
                              color: prefix0.greyColor),
                          contentPadding: EdgeInsets.only(
                            bottom: ScreenUtil().setHeight(57),
                            top: ScreenUtil().setHeight(57),
                            left: ScreenUtil().setWidth(157),
                            right: ScreenUtil().setWidth(63),
                          ),
                        ),
                      ),
              );
            }),
        Positioned(
          bottom: ScreenUtil().setHeight(58.0),
          left: ScreenUtil().setWidth(58.1),
          child: Image.asset(
            "asset/images/ic_lock.png",
            width: ScreenUtil().setWidth(56.0),
          ),
        ),
        Positioned(
            bottom: ScreenUtil().setHeight(58.0),
            right: ScreenUtil().setWidth(31.8),
            child: StreamBuilder(
                initialData: false,
                stream: appBloc.authBloc.showPassStream.stream,
                builder: (buildContext, AsyncSnapshot<bool> showPassSnap) {
                  return InkWell(
                    onTap: () {
                      appBloc.authBloc.updateStateShowPass();
                    },
                    child: showPassSnap.data
                        ? Icon(
                            Icons.remove_red_eye,
                            color: prefix0.accentColor,
                            size: ScreenUtil().setWidth(56.0),
                          )
                        : Image.asset(
                            "asset/images/outline-visibility_off-24px.png",
                            width: ScreenUtil().setWidth(56.0),
                          ),
                  );
                })),
      ],
    );
  }

  _buildRememberPass() {
    return StreamBuilder(
        initialData: false,
        stream: appBloc.authBloc.rememberPassStream.stream,
        builder: (buildContext, AsyncSnapshot<bool> rememberPassSnap) {
          return InkWell(
            onTap: () {
              appBloc.authBloc.updateStateRememberPass();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                rememberPassSnap.data
                    ? Image.asset(
                        "asset/images/outline-check_box-24px.png",
                        width: ScreenUtil().setWidth(58.0),
                      )
                    : Image.asset(
                        "asset/images/outline-no_check_box.png",
                        width: ScreenUtil().setWidth(58.0),
                      ),
                SizedBox(
                  width: ScreenUtil().setWidth(29.0),
                ),
                Text("Nhớ mật khẩu",
                    style: TextStyle(
                        color: prefix0.blackColor,
                        fontSize: ScreenUtil().setSp(50.0),
                        fontFamily: 'Roboto-Regular'))
              ],
            ),
          );
        });
  }

  void autoRequestFingerPrint() async {
    if (appBloc.authBloc.fingerPrintStatusState ==
            FingerPrintButtonState.ENABLE &&
        appBloc.authBloc.isNotLogOut) {
      if (context != null) {
        AppBloc appBloc = BlocProvider.of(context);
        if (Platform.isAndroid) {
          bool statusFingerPrintKey = await CacheHelper.getStatusFingerPrint();
          DialogUtils.showDialogAuthenticateFingerprint(
              context, appBloc, statusFingerPrintKey);
        } else if (Platform.isIOS) {
          appBloc.authBloc.authenticateFingerPrintIOS(context);
        }
      }
    }
  }
}
