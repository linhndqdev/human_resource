import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/info/orient_bloc.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/utils/widget/item_collsnap.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';

class DrawerScreen extends StatelessWidget {
  final AppBloc appBloc;
  final VoidCallback onScanQrCode;

  DrawerScreen({Key key, this.appBloc, this.onScanQrCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.red,
        width: 895.7.w,
        child: Drawer(
          child: Column(
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: 130.6.h),
                    Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: CustomCircleAvatar(
                              isClearCache: true,
                              userName: appBloc.authBloc.asgUserModel.username,
                              size: 271.6,
                            ),
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              border: new Border.all(
                                color: Color(0xffe18c12),
                                width:
                                    SizeRender.renderBorderSize(context, 7.1),
                              ),
                            ),
                          ),
                          SizedBox(height: 31.5.h),
                          new Text(
                            appBloc?.authBloc?.asgUserModel?.full_name ??
                                "Không xác định",
                            style: new TextStyle(
                              color: Color(0xff263238),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              fontSize: 60.0.sp,
                            ),
                          ),
                          new Text(
                            "ID: ${appBloc.authBloc.asgUserModel.getID}",
                            style: new TextStyle(
                              fontFamily: 'Roboto',
                              color: Color(0xff959ca7),
                              fontSize: 50.0.sp,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 75.0.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          //appBloc.homeBloc.changeIndexStackHome(1, null);
                          Navigator.of(context).pop();
                          appBloc.changeProfileLayoutState(true);
                        },
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 59.7.w),
                            Image.asset(
                              "asset/images/settings_work_tool.png",
                              width: 70.0.w,
                            ),
                            SizedBox(width: ScreenUtil().setWidth(45.8)),
                            Text("Tài khoản",
                                style: new TextStyle(
                                  fontFamily: 'Roboto',
                                  color: Color(0xff263238),
                                  fontSize: 50.0.sp,
                                ))
                          ],
                        ),
                      ),
                      SizedBox(height: 61.0.h),
                      ItemCollSnapWidget(
                        isCollSnap: true,
                        urlImg: "asset/images/ic_chat_selected.png",
                        txt: "Trò chuyện",
                      ),
                      SizedBox(height: ScreenUtil().setHeight(61)),
//                  _buildDrawerItem(context, ,
//    "Trò chuyện",
//                      iconColor: Color(0xff005a88),
//                      textColor: Color(0xff005a88),
//                      fontBold: true,
//                      clickItem: true,
//                      hasChild: true,
//                      onClickItem: () {}),
//                  SizedBox(height: ScreenUtil().setHeight(46.4)),
//                  _buildDrawerItem(
//                      context,
//                      "asset/images/outline-ballot-24-px.png",
//                      "Công việc", onClickItem: () {
//                    Navigator.of(context).pop();
//                    appBloc.homeBloc.clickItemBottomBar(2);
//                  }),
//                  SizedBox(height: ScreenUtil().setHeight(61)),
                      _buildDrawerItem(
                          context,
                          "asset/images/outline-account-balance-wallet-24-px.png",
                          "Cuộc họp", onClickItem: () {
                        Navigator.of(context).pop();
                        appBloc.homeBloc.clickItemBottomBar(3);
                      }),
                      SizedBox(height: ScreenUtil().setHeight(61)),
                      _buildDrawerItem(
                          context, "asset/images/document-2.png", "Bản tin",
                          onClickItem: () {
                        Navigator.of(context).pop();
                        appBloc.homeBloc.openOrientScreen(OrientState.BAN_TIN);
                      }),
                      SizedBox(height: ScreenUtil().setHeight(61)),
                      _buildDrawerItem(
                          context, "asset/images/share.png", "Thông báo",
                          onClickItem: () {
                        Navigator.of(context).pop();
                        appBloc.homeBloc
                            .openOrientScreen(OrientState.THONG_BAO);
                      }),
                      SizedBox(height: ScreenUtil().setHeight(61)),
                      _buildDrawerItem(
                          context,
                          "asset/images/security-questions.png",
                          "Hỏi đáp", onClickItem: () {
                        Navigator.of(context).pop();
                        appBloc.homeBloc.openOrientScreen(OrientState.FAQ);
                      }),
                      SizedBox(height: ScreenUtil().setHeight(61)),
                      _buildDrawerItem(
                          context, "asset/images/ic_qrScan.png", "Quét mã Qr",
                          onClickItem: () {
                        Navigator.of(context).pop();
                        onScanQrCode();
                      }),
                    ],
                  ),
                ),
              ),
//            SizedBox(height: ScreenUtil().setHeight(60)),
              Container(
                padding:
                    EdgeInsets.only(top: 50.2.h, bottom: 78.9.h, left: 59.7.w),
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Color(0xfff7f7f7), width: 1.0))),
                child: InkWell(
                  onTap: () {
                    _showDialogExit(context);
//                  Navigator.pop(context);
//                  appBloc.authBloc.logOut(context);
                  },
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Image.asset("asset/images/icon.png",
                              width: ScreenUtil().setWidth(70),
                              height: ScreenUtil().setHeight(70)),
                          SizedBox(width: ScreenUtil().setWidth(45.8)),
                          Text("Đăng xuất",
                              style: new TextStyle(
                                fontFamily: 'Roboto',
                                color: Color(0xffe10606),
                                fontSize: ScreenUtil().setSp(50.0),
                              ))
                        ],
                      ),
//                    SizedBox(height: ScreenUtil().setHeight(78.9)),
                    ],
                  ),
                ),
//              height: ScreenUtil().setHeight(85 + 68.6),
              )
            ],
          ),
        ));
  }

  void _showDialogExit(BuildContext context) {
    DialogUtils.showDialogLogout(context,
        title: "Đăng xuất",
        message: "Bạn có chắc muốn  ",
        childtext1: "đăng xuất ",
        childtext2: "không?", onClickOK: () {
      Navigator.pop(context);
      appBloc.authBloc.logOut(context);
    });
  }

  _buildDrawerItem(BuildContext context, String urlImg, String txt,
      {double width = 70.0,
      double height = 70.0,
      Color iconColor,
      Color textColor,
      bool fontBold = false,
      bool clickItem = false,
      bool hasChild = false,
      @required VoidCallback onClickItem}) {
    if (iconColor == null) iconColor = Color(0xFF263238);
    if (textColor == null) textColor = Color(0xFF263238);
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (onClickItem != null) {
              onClickItem();
            }
          },
          child: Row(
            children: <Widget>[
              SizedBox(width: 59.7.w),
              Image.asset(urlImg,
                  color: iconColor, // Color(0xff005a88),
                  width: width.w,
                  height: height.h),
              SizedBox(width: 45.8.w),
              Expanded(
                child: Text(txt,
                    style: new TextStyle(
                      fontFamily: 'Roboto',
                      color: textColor,
                      fontWeight:
                          fontBold ? FontWeight.bold : FontWeight.normal,
                      fontSize: 50.0.sp,
                    )),
              ),
              hasChild
                  ? Image.asset(
                      clickItem
                          ? "asset/images/arrow_up_3x.png"
                          : "asset/images/arrow_down.png",
                      color: iconColor,
                      width: 46.0.w,
                      height: 29.0.h,
                    )
                  : Container(),
              SizedBox(width: 53.7.w),
            ],
          ),
        ),
        (hasChild) ? SizedBox(height: 35.3.h) : Container(),

        //Đưa vào 1 list item, đây là ví dụ nên để riêng rẽ thế này
        (hasChild)
            ? _childItem(context, "asset/images/outline-forum-24px.png",
                "Tin nhắn riêng", onClickChildItem: () {
                appBloc.mainChatBloc.listTabStream
                    .notify(ListTabModel(tab: ListTabState.NHAN_TIN));
                appBloc.homeBloc
                    .clickItemBottomBar(1, listTabState: ListTabState.NHAN_TIN);
              })
            : Container(),
        (hasChild)
            ? _childItem(
                context,
                "asset/images/outline-supervised_user_circle-24px.png",
                "Nhóm trò chuyện", onClickChildItem: () {
                appBloc.mainChatBloc.listTabStream
                    .notify(ListTabModel(tab: ListTabState.NHOM));
                appBloc.homeBloc
                    .clickItemBottomBar(1, listTabState: ListTabState.NHOM);
              })
            : Container(),
        /*(hasChild)
            ? _childItem(context, "asset/images/outline-phone_in_talk-24px.png",
                "Gọi điện", onClickChildItem: () {
                appBloc.mainChatBloc.listTabStream
                    .notify(ListTabModel(tab: ListTabState.GOI_DIEN));
                appBloc.homeBloc
                    .clickItemBottomBar(1, listTabState: ListTabState.GOI_DIEN);
              })
            : Container(),*/
      ],
    );
  }

  _childItem(BuildContext context, String urlImg, String title,
      {VoidCallback onClickChildItem}) {
    return Container(
      color: Color(0xffe8e8e8),
      height: ScreenUtil().setHeight(177.2),
      child: GestureDetector(
        onTap: () {
          if (onClickChildItem != null) {
            Navigator.pop(context);
            onClickChildItem();
          }
        },
        child: Column(
          children: <Widget>[
            Container(
              height: 1.0,
              color: Color(0xffffffff),
            ),
            Container(
              padding: EdgeInsets.only(top: ScreenUtil().setHeight(53.5)),
              child: Row(
                children: <Widget>[
                  SizedBox(width: ScreenUtil().setWidth(184.7)),
                  Image.asset(urlImg,
                      width: ScreenUtil().setWidth(61.8),
                      height: ScreenUtil().setHeight(61.8)),
                  SizedBox(width: ScreenUtil().setWidth(54.7)),
                  Text(title,
                      style: new TextStyle(
                        fontFamily: 'Roboto',
                        color: Color(0xff263238),
                        fontSize: ScreenUtil().setSp(50.0),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension AsglUserModelExtendtions on ASGUserModel {
  get getID {
    if (this.asgl_id != null && this.asgl_id != "") {
      String content = this.asgl_id.replaceAll("-", "");
      return content;
    } else
      return "Không xác định";
  }
}
