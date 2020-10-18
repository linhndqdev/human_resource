import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/home/drawer/my_profile/my_profile_bloc.dart';
import 'package:human_resource/utils/common/custom_size_render.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/loading_indicator.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';
import 'package:image_picker/image_picker.dart';

class MyProfileLayout extends StatefulWidget {
  @override
  _MyProfileLayoutState createState() => _MyProfileLayoutState();
}

class _MyProfileLayoutState extends State<MyProfileLayout> {
  TextEditingController _inputOldPassWord = TextEditingController();
  TextEditingController _inputNewPassWord = TextEditingController();
  TextEditingController _inputNewPassWord2 = TextEditingController();
  AppBloc appBloc;
  MyProfileBloc myProfileBloc = MyProfileBloc();

  @override
  void dispose() {
    _inputNewPassWord.dispose();
    _inputOldPassWord.dispose();
    _inputNewPassWord2.dispose();
    myProfileBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = ModalRoute.of(context);
    page.didPush().then((x) {
      SystemChrome.setSystemUIOverlayStyle(prefix0.statusBarAccent);
    });
    appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.MY_PROFILE);
    return WillPopScope(
      onWillPop: () async {
        appBloc.changeProfileLayoutState(false);
        appBloc.backStateBloc.focusWidgetModel =
            FocusWidgetModel(state: isFocusWidget.HOME);

        return false;
      },
      child: Stack(
        children: <Widget>[
          Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              titleSpacing: 0.0,
              centerTitle: true,
              backgroundColor: Color(0xff005a88),
              title: Container(
                width: MediaQuery.of(context).size.width,
                height: 178.5.h,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      left: 0,
                      child: InkWell(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 60.w,
                              right: 59.w,
                              bottom: 66.2.h,
                              top: 60.h),
                          child: Image.asset(
                            "asset/images/ic_meeting_back_white.png",
                            color: prefix0.white,
                            width: ScreenUtil().setWidth(49.9),
                          ),
                        ),
                        onTap: () {
                          appBloc.backStateBloc.focusWidgetModel =
                              FocusWidgetModel(state: isFocusWidget.HOME);
                          appBloc.changeProfileLayoutState(false);
                        },
                      ),
                    ),
                    Center(
                      child: Text(
                        "Tài khoản",
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(60.0),
                          fontFamily: "Roboto-Bold",
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: ScreenUtil().setHeight(74.7)),
                  Center(
                    child: Container(
                        width: ScreenUtil().setHeight(346.7),
                        height: ScreenUtil().setHeight(344.2),
                        child: CircleAvatar(
                          child: Stack(
                            children: <Widget>[
                              StreamBuilder(
                                  initialData: false,
                                  stream:
                                      myProfileBloc.uploadAvatarStream.stream,
                                  builder: (buildContext,
                                      AsyncSnapshot<bool>
                                          uploadAvatarSnapshot) {
                                    return CustomCircleAvatar(
                                      isClearCache: true,
                                      userName: appBloc
                                          .authBloc.asgUserModel.username,
                                      size: 346.7,
                                    );
                                  }),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                height: ScreenUtil().setHeight(96.0),
                                child: Container(
                                  width: ScreenUtil().setWidth(96.0),
                                  height: ScreenUtil().setHeight(96.0),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF0e18c12),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: SizeRender.renderBorderSize(
                                          context, 6.0),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      _pickImageAvatar();
                                    },
                                    child: Icon(
                                      Icons.arrow_upward,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          radius: 50.0,
                          backgroundColor: Colors.transparent,
                        )),
                  ),
                  //avatar
                  SizedBox(height: ScreenUtil().setHeight(36.3)),
                  Text(
                    appBloc.authBloc.asgUserModel.full_name ?? "Không xác định",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(60.0),
                        fontFamily: "Roboto-Bold",
                        fontWeight: FontWeight.bold,
                        color: Color(0xff263238)),
                  ),
                  //Họ tên
                  SizedBox(height: ScreenUtil().setHeight(4.7)),
                  Text(
                    "ID: ${getID()}",
                    style: new TextStyle(
                      fontFamily: 'Roboto',
                      color: Color(0xff959ca7),
                      fontSize: ScreenUtil().setSp(50.0),
                    ),
                  ),
                  //ID: ASGL-0053
                  SizedBox(height: ScreenUtil().setHeight(56.0)),
                  Container(
                    width: MediaQuery.of(context).size.width,
//              height: ScreenUtil().setHeight(148.0),
//              color: Color(0xff959ca7),
                    decoration: BoxDecoration(
                      color: Color(0xff959ca7).withOpacity(0.05),
                    ),
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setHeight(44.0),
                        bottom: ScreenUtil().setHeight(43.0),
                        left: ScreenUtil().setWidth(60)),
                    child: Text(
                      "THÔNG TIN CÁ NHÂN",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Color(0xff959ca7),
                        fontSize: ScreenUtil().setSp(50.0),
                      ),
                    ),
                  ),
                  //tiêu đề: thông tin cá nhân,
                  SizedBox(height: ScreenUtil().setHeight(7.5)),
                  //khoảng cách giữa các dòng là 110.0
                  _buildItemInfor(
                      "Họ tên",
                      appBloc?.authBloc?.asgUserModel?.full_name ??
                          "Không xác định"),
                  _buildItemInfor("Mã nhân viên", getID()),
                  _buildItemInfor(
                      "Bộ phận",
                      appBloc?.authBloc?.asgUserModel?.position?.department
                              ?.name ??
                          "Không xác định"),
                  _buildItemInfor(
                      "Chức danh",
                      appBloc?.authBloc?.asgUserModel?.position?.level?.name ??
                          "Không xác định"),
                  _buildItemInfor("Điện thoại", getPhone()),
                  _buildItemInfor("Email", getEmail(), lastItem: true),
                  SizedBox(height: ScreenUtil().setHeight(102.0 - 7.0)),
                  //chỗ này do thiết kế dị quá, trừ áng chừng
                  Container(
                    width: MediaQuery.of(context).size.width,
//              height: ScreenUtil().setHeight(148.0),
//              color: Color(0xff959ca7),
                    decoration: BoxDecoration(
                      color: Color(0xff959ca7).withOpacity(0.05),
                    ),
                    padding: EdgeInsets.only(
                        top: ScreenUtil().setHeight(44.0),
                        bottom: ScreenUtil().setHeight(43.0),
                        left: ScreenUtil().setWidth(60)),
                    child: Text(
                      "ĐỔI MẬT KHẨU",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Color(0xff959ca7),
                        fontSize: ScreenUtil().setSp(50.0),
                      ),
                    ),
                  ),
                  //Đổi mật khẩu
                  SizedBox(height: ScreenUtil().setHeight(51.0)),
                  //chỗ này do thiết kế dị quá, trừ áng chừng
                  _buildTextCurrentPassWord(),
                  SizedBox(height: ScreenUtil().setHeight(51.0)),
                  _buildTextNewPassWord(),
                  SizedBox(height: ScreenUtil().setHeight(51.0)),
                  _buildTextNewPassWordConfirm(),
                  SizedBox(height: ScreenUtil().setHeight(51.0)),
                  ButtonTheme(
                      child: Container(
//                  width: ScreenUtil().setWidth(823),
//                  height: ScreenUtil().setHeight(163),
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(96.0),
                        right: ScreenUtil().setWidth(95.0)),
                    child: new ButtonTheme(
                      height: ScreenUtil().setHeight(176),
                      minWidth: ScreenUtil().setWidth(889),
                      child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                ScreenUtil().setWidth(10.0))),
                        elevation: 0.0,
                        icon: Text(''),
                        color: prefix0.accentColor,
                        highlightColor: prefix0.accentColor,
                        label: Text('Cập nhật',
                            style: TextStyle(
                              fontFamily: 'Roboto-Bold',
                              fontSize: ScreenUtil().setSp(60.0),
                              color: prefix0.whiteColor,
                            )),
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          myProfileBloc.updatePassword(
                              context,
                              _inputOldPassWord.text.trim(),
                              _inputNewPassWord.text.trim(),
                              _inputNewPassWord2.text.trim(), () {
                            _inputOldPassWord.text = "";
                            _inputNewPassWord.text = "";
                            _inputNewPassWord2.text = "";
                          });
                        },
                      ),
                    ),
                  )),
                  SizedBox(height: ScreenUtil().setHeight(94.0)),
                ],
              ),
            ),
          ),
          StreamBuilder(
              initialData: false,
              stream: myProfileBloc.loadingStream.stream,
              builder: (buildContext, AsyncSnapshot<bool> loadingSnapShot) {
                if (!loadingSnapShot.data) {
                  return Container();
                }
                return Container(
                  color: prefix0.blackColor333.withOpacity(0.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      LoadingIndicator(),
                      Text(
                        "Đang cập nhật ảnh đại diện...",
                        style: TextStyle(
                            color: prefix0.white,
                            fontSize: 40.0.sp,
                            fontFamily: "Roboto-Regular",
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                );
              }),
          StreamBuilder(
              initialData: false,
              stream: myProfileBloc.loadingUpdatePassStream.stream,
              builder: (buildContext, AsyncSnapshot<bool> snapshotData) {
                return Visibility(
                  child: Loading(),
                  visible: snapshotData.data,
                );
              })
        ],
      ),
    );
  }

  _buildItemInfor(String title, String content, {bool lastItem = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(60.0),
              right: ScreenUtil().setWidth(59.0)),
          height: ScreenUtil().setHeight(110.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(title,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Color(0xff959ca7),
                    fontSize: ScreenUtil().setSp(50.0),
                  )),
              Text(content,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    color: Color(0xff333333),
                    fontSize: ScreenUtil().setSp(50.0),
                  ))
            ],
          ),
        ),
        !lastItem
            ? Container(
                margin: EdgeInsets.only(
                    left: ScreenUtil().setWidth(60.0),
                    right: ScreenUtil().setWidth(59.0)),
                height: 1.0,
                color: Color(0xff959ca7).withOpacity(0.15),
              )
            : Container()
      ],
    );
  }

  _buildTextCurrentPassWord() {
//    _inputUserController.text = appBloc.authBloc?.email ?? "";
    return Stack(
      children: <Widget>[
        StreamBuilder(
            initialData: false,
            stream: appBloc.authBloc.showPassStreamCurrent.stream,
            builder: (buildContext, AsyncSnapshot<bool> showPassSnap) {
              return Container(
                decoration: BoxDecoration(),
                height: ScreenUtil().setHeight(176.0),
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(96.0),
                    right: ScreenUtil().setWidth(95.0)),
                child: TextField(
                  keyboardType: TextInputType.text,
                  cursorColor: prefix0.greyColor,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.start,
                  controller: _inputOldPassWord,
                  maxLines: 1,
                  obscureText: !showPassSnap.data,
                  enabled: true,
                  onChanged: (value) {
//              appBloc.authBloc.updateUser(value);
                  },
                  style: TextStyle(
                      fontFamily: "Roboto-Regular",
                      fontSize: ScreenUtil().setSp(50.0),
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
                    hintText: "Mật khẩu cũ",
                    hintStyle: TextStyle(
                        fontSize: ScreenUtil().setSp(50.0),
                        fontFamily: "Roboto-Regular",
                        color: prefix0.greyColor),
                    contentPadding: EdgeInsets.only(
                      bottom: ScreenUtil().setHeight(56),
                      top: ScreenUtil().setHeight(59),
                      left: ScreenUtil().setWidth(172),
//                right: ScreenUtil().setWidth(63),
                    ),
                  ),
                ),
              );
            }),
        Positioned(
          bottom: ScreenUtil().setHeight(58.0),
          left: ScreenUtil().setWidth(159.0),
          child: Image.asset(
            "asset/images/Group10519.png",
            width: ScreenUtil().setWidth(56.0),
            height: ScreenUtil().setHeight(60.0),
          ),
        ),
        Positioned(
            bottom: 0, //ScreenUtil().setHeight(71.5),
            right: ScreenUtil().setWidth(131.7),
            child: StreamBuilder(
                initialData: false,
                stream: appBloc.authBloc.showPassStreamCurrent.stream,
                builder: (buildContext, AsyncSnapshot<bool> showPassSnap) {
                  return InkWell(
                    onTap: () {
                      appBloc.authBloc.updateStateShowPassCurrent();
                    },
                    child: showPassSnap.data
                        ? Center(
                            child: Container(
                              width: ScreenUtil().setWidth(70.3),
                              height: ScreenUtil().setHeight(176.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    "asset/images/Outline@2x.png",
                                    width: ScreenUtil().setWidth(46.3),
                                    height: ScreenUtil().setHeight(31.5),
                                    fit: BoxFit.fitHeight,
                                  )
                                ],
                              ),
                            ),
                          )
                        : Center(
                            child: Container(
                                width: ScreenUtil().setWidth(70.3),
                                height: ScreenUtil().setHeight(176.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      "asset/images/Outline_disable.png",
                                      width: ScreenUtil().setWidth(46.3),
                                      height: ScreenUtil().setHeight(31.5),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ],
                                )),
                          ),
                  );
                }))
      ],
    );
  }

  _buildTextNewPassWord() {
//    _inputUserController.text = appBloc.authBloc?.email ?? "";
    return Stack(
      children: <Widget>[
        StreamBuilder(
            initialData: false,
            stream: appBloc.authBloc.showPassStream.stream,
            builder: (buildContext, AsyncSnapshot<bool> showPassSnap) {
              return Container(
                decoration: BoxDecoration(),
                height: ScreenUtil().setHeight(176.0),
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(96.0),
                    right: ScreenUtil().setWidth(95.0)),
                child: TextField(
                  keyboardType: TextInputType.text,
                  cursorColor: prefix0.greyColor,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.start,
                  controller: _inputNewPassWord,
                  maxLines: 1,
                  obscureText: !showPassSnap.data,
                  enabled: true,
                  onChanged: (value) {
//              appBloc.authBloc.updateUser(value);
                  },
                  style: TextStyle(
                      fontFamily: "Roboto-Regular",
                      fontSize: ScreenUtil().setSp(50.0),
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
                    hintText: "Mật khẩu mới",
                    hintStyle: TextStyle(
                        fontSize: ScreenUtil().setSp(50.0),
                        fontFamily: "Roboto-Regular",
                        color: prefix0.greyColor),
                    contentPadding: EdgeInsets.only(
                      bottom: ScreenUtil().setHeight(56),
                      top: ScreenUtil().setHeight(59),
                      left: ScreenUtil().setWidth(172),
//                right: ScreenUtil().setWidth(63),
                    ),
                  ),
                ),
              );
            }),
        Positioned(
          bottom: ScreenUtil().setHeight(58.0),
          left: ScreenUtil().setWidth(159.0),
          child: Image.asset(
            "asset/images/Group10519.png",
            width: ScreenUtil().setWidth(56.0),
            height: ScreenUtil().setHeight(60.0),
          ),
        ),
        Positioned(
            bottom: 0, //ScreenUtil().setHeight(71.5),
            right: ScreenUtil().setWidth(131.7),
            child: StreamBuilder(
                initialData: false,
                stream: appBloc.authBloc.showPassStream.stream,
                builder: (buildContext, AsyncSnapshot<bool> showPassSnap) {
                  return InkWell(
                    onTap: () {
                      appBloc.authBloc.updateStateShowPass();
                    },
                    child: showPassSnap.data
                        ? Center(
                            child: Container(
                              width: ScreenUtil().setWidth(70.3),
                              height: ScreenUtil().setHeight(176.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    "asset/images/Outline@2x.png",
                                    width: ScreenUtil().setWidth(46.3),
                                    height: ScreenUtil().setHeight(31.5),
                                    fit: BoxFit.fitHeight,
                                  )
                                ],
                              ),
                            ),
                          )
                        : Center(
                            child: Container(
                                width: ScreenUtil().setWidth(70.3),
                                height: ScreenUtil().setHeight(176.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      "asset/images/Outline_disable.png",
                                      width: ScreenUtil().setWidth(46.3),
                                      height: ScreenUtil().setHeight(31.5),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ],
                                )),
                          ),
                  );
                })),
      ],
    );
  }

  _buildTextNewPassWordConfirm() {
//    _inputUserController.text = appBloc.authBloc?.email ?? "";
    return Stack(
      children: <Widget>[
        StreamBuilder(
            initialData: false,
            stream: appBloc.authBloc.showPassStream2.stream,
            builder: (buildContext, AsyncSnapshot<bool> showPassSnap) {
              return Container(
                decoration: BoxDecoration(),
                height: ScreenUtil().setHeight(176.0),
                padding: EdgeInsets.only(
                    left: ScreenUtil().setWidth(96.0),
                    right: ScreenUtil().setWidth(95.0)),
                child: TextField(
                  keyboardType: TextInputType.text,
                  cursorColor: prefix0.greyColor,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.start,
                  controller: _inputNewPassWord2,
                  maxLines: 1,
                  obscureText: !showPassSnap.data,
                  enabled: true,
                  onChanged: (value) {
//              appBloc.authBloc.updateUser(value);
                  },
                  style: TextStyle(
                      fontFamily: "Roboto-Regular",
                      fontSize: ScreenUtil().setSp(50.0),
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
                    hintText: "Xác nhận lại mật khẩu",
                    hintStyle: TextStyle(
                        fontSize: ScreenUtil().setSp(50.0),
                        fontFamily: "Roboto-Regular",
                        color: prefix0.greyColor),
                    contentPadding: EdgeInsets.only(
                      bottom: ScreenUtil().setHeight(56),
                      top: ScreenUtil().setHeight(59),
                      left: ScreenUtil().setWidth(172),
//                right: ScreenUtil().setWidth(63),
                    ),
                  ),
                ),
              );
            }),
        Positioned(
          bottom: ScreenUtil().setHeight(58.0),
          left: ScreenUtil().setWidth(159.0),
          child: Image.asset(
            "asset/images/Group10519.png",
            width: ScreenUtil().setWidth(56.0),
            height: ScreenUtil().setHeight(60.0),
          ),
        ),
        Positioned(
            bottom: 0, //ScreenUtil().setHeight(71.5),
            right: ScreenUtil().setWidth(131.7),
            child: StreamBuilder(
                initialData: false,
                stream: appBloc.authBloc.showPassStream2.stream,
                builder: (buildContext, AsyncSnapshot<bool> showPassSnap) {
                  return InkWell(
                    onTap: () {
                      appBloc.authBloc.updateStateShowPass2();
                    },
                    child: showPassSnap.data
                        ? Center(
                            child: Container(
                              width: ScreenUtil().setWidth(70.3),
                              height: ScreenUtil().setHeight(176.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    "asset/images/Outline@2x.png",
                                    width: ScreenUtil().setWidth(46.3),
                                    height: ScreenUtil().setHeight(31.5),
                                    fit: BoxFit.fitHeight,
                                  )
                                ],
                              ),
                            ),
                          )
                        : Center(
                            child: Container(
                                width: ScreenUtil().setWidth(70.3),
                                height: ScreenUtil().setHeight(176.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      "asset/images/Outline_disable.png",
                                      width: ScreenUtil().setWidth(46.3),
                                      height: ScreenUtil().setHeight(31.5),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ],
                                )),
                          ),
                  );
                })),
      ],
    );
  }

  String getID() {
    String content =
        appBloc?.authBloc?.asgUserModel?.asgl_id?.replaceAll("-", "");
    return content ?? "Không xác định";
  }

  String getPhone() {
    if (appBloc.authBloc.asgUserModel.mobile_phone != null &&
        appBloc.authBloc.asgUserModel.mobile_phone != "") {
      return appBloc.authBloc.asgUserModel.mobile_phone;
    } else if (appBloc.authBloc.asgUserModel.secondary_phone != null &&
        appBloc.authBloc.asgUserModel.secondary_phone != null) {
      return appBloc.authBloc.asgUserModel.secondary_phone;
    } else {
      return "Không xác định";
    }
  }

  String getEmail() {
    if (appBloc.authBloc.asgUserModel.email != null &&
        appBloc.authBloc.asgUserModel.email != "") {
      return appBloc.authBloc.asgUserModel.email;
    } else if (appBloc.authBloc.asgUserModel.secondary_email != null &&
        appBloc.authBloc.asgUserModel.secondary_email != null) {
      return appBloc.authBloc.asgUserModel.secondary_email;
    } else {
      return "Không xác định";
    }
  }

  void _pickImageAvatar() async {
    try {
      File file = await ImagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 100);
      if (file != null) {
        bool exits = await file.exists();
        if (exits) {
          myProfileBloc.uploadAvatar(context, file.path);
        } else {
          Toast.showShort("Hình ảnh không nằm trong bộ nhớ thiết bị.");
        }
      }
    } on Exception catch (e) {
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Không thể đọc hình ảnh. Vui lòng chọn hình ảnh khác.");
    }
  }
}
