import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/home/dashboard/Applicationlist.dart';
import 'package:human_resource/info/orient_bloc.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/animation/animation_vertical.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/widget/line_notification_widget.dart';
import 'package:shimmer/shimmer.dart';

class DashboardLayout extends StatefulWidget {
  final VoidCallback callBackOpenMenu;

  const DashboardLayout({Key key, @required this.callBackOpenMenu})
      : super(key: key);

  @override
  _DashboardLayoutLayoutState createState() => _DashboardLayoutLayoutState();
}

class _DashboardLayoutLayoutState extends State<DashboardLayout> {
  AppBloc appBloc;
  bool sStatus = true;

  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      appBloc.notificationBloc.getUnReadNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    final page = ModalRoute.of(context);
    page.didPush().then((x) {
      SystemChrome.setSystemUIOverlayStyle(prefix0.statusBarAccent);
    });
    appBloc = BlocProvider.of(context);
    return buildWidget();
  }

  Widget buildWidget() {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(),
        ),
        Column(
          children: <Widget>[
            Container(
                child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image:
                                  AssetImage("asset/images/backgroundAsg.jpg"),
                              fit: BoxFit.cover)),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Color(0xFF0005a88).withOpacity(0.71),
                        ),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: ScreenUtil().setWidth(60.0),
                                          top: 48.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          widget.callBackOpenMenu();
                                        },
                                        child: Image.asset(
                                          "asset/images/menuIcon.png",
                                          color: Colors.white,
                                          width: ScreenUtil().setWidth(77.7),
                                          height: ScreenUtil().setHeight(54.4),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        appBloc.homeBloc.scanQrCode(context);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: ScreenUtil().setWidth(20.0),
                                            top: 40),
                                        padding: EdgeInsets.only(
                                          left: 40.w,
                                          right: 40.w,
                                        ),
                                        child: Image.asset(
                                            "asset/images/ic_qrScan.png",
                                            color: Colors.white,
                                            // Color(0xff005a88),
                                            width: 80.w),
                                      ),
                                    ),
                                    _buildNotificationBell()
                                  ],
                                )

                                //Hiển thị chuông thông báo
                              ],
                            ),
//                            sStatus == true?
                            StreamBuilder<String>(
                                initialData: "",
                                stream:
                                    appBloc.homeBloc.notifyContentStream.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.data == null ||
                                      snapshot.data == "") {
                                    return _buildAvatar();
                                  }
                                  return showMeetingNotification(
                                      snapshot.data, "  Xem lịch họp");
                                })
                            //Cuộc họp của bạn vừa có một cập nhật. Xem lịch họp
//                                : _BuildAvata(),
                            ,
                            Container(
                              width: MediaQuery.of(context).size.width,
                              color: Colors.transparent,
                              child: Container(
                                  padding: EdgeInsets.only(
                                    top: ScreenUtil().setHeight(84.2),
                                    left: ScreenUtil().setWidth(60.0),
                                    bottom: ScreenUtil().setHeight(22.5),
                                  ),
                                  decoration: new BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                            ScreenUtil().setWidth(50.0)),
                                        topRight: Radius.circular(
                                            ScreenUtil().setWidth(50.0)),
                                      )),
                                  child: TranslateVertical(
                                    curveAnimated: Curves.ease,
                                    duration: 400,
                                    translateType: VerticalType.DOWN_TO_UP,
                                    startPosition:
                                        MediaQuery.of(context).size.width / 2,
                                    child: Text(
                                      "ỨNG DỤNG",
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(60.0),
                                          fontFamily: "Roboto-Regular",
                                          color: Color(0xff0959ca7)),
                                      textAlign: TextAlign.left,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ApplicationList(),
              ],
            )),
            Expanded(
                child: TranslateVertical(
              duration: 700,
              translateType: VerticalType.DOWN_TO_UP,
              startPosition: MediaQuery.of(context).size.width / 2,
              child: Container(
                decoration: BoxDecoration(color: Color(0xff0ffffff)),
                child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    addAutomaticKeepAlives: true,
                    itemCount: 3,
                    itemBuilder: (buildContext, index) {
                      OrientState state = index == 0
                          ? OrientState.BAN_TIN
                          : index == 1
                          ? OrientState.THONG_BAO
                          : OrientState.FAQ;
                      return LineNotificationWidget(
                        orientState: state,
                      );
                    }),
              ),
            )),
          ],
        )
      ],
    );
  }

  Widget _buildAvatar() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                left: 60.0.w,
                top: 39.6.h,
                bottom: 123.2.h,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 201.7.h,
                    height: 201.7.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 6.0.w,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        appBloc.changeProfileLayoutState(true);
                      },
                      child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(191.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                "asset/images/baseline-account_circle-24px.png",
                              ))),
                              width: ScreenUtil().setWidth(191.0),
                              height: ScreenUtil().setWidth(191.0),
                              child: FadeInImage(
                                  placeholder: new AssetImage(
                                      'asset/images/baseline-account_circle-24px.png'),
                                  image: CachedNetworkImageProvider(
                                      "${Constant.SERVER_BASE_CHAT}/avatar/${appBloc.authBloc.asgUserModel.username}" +
                                          "?v=${DateTime.now().millisecondsSinceEpoch}")))),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                appBloc.changeProfileLayoutState(true);
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 35.0.w,
                                ),
                                child: Text(
                                  appBloc.authBloc.asgUserModel.full_name,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(60.0),
                                      fontFamily: "Roboto-Regular",
                                      color: Colors.white),
                                  textAlign: TextAlign.left,
                                ),
                              )),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                appBloc.changeProfileLayoutState(true);
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(42.0)),
                                child: Text(
                                  'ID: ${getID()}',
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(50.0),
                                      fontFamily: "Roboto-Regular",
                                      color: Color(0xff0e8e8e8)),
                                  textAlign: TextAlign.left,
                                ),
                              )),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          InkWell(
                              onTap: () {
                                appBloc.changeProfileLayoutState(true);
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(42.0)),
                                child: Text(
                                  '${getPosition()}',
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(50.0),
                                      fontFamily: "Roboto-Regular",
                                      color: Color(0xff0e8e8e8)),
                                  textAlign: TextAlign.left,
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget showMeetingNotification(String title, String mesage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
              left: 60.0.w, top: 39.6.h, bottom: 61.2.h, right: 59.0.w),
//            margin: EdgeInsets.only(left: 60.0.w  , right: 59.0.w, top: 199.0.h),
//            height: 264.0.h,
          decoration: BoxDecoration(
            color: prefix0.whiteColor,
            borderRadius: BorderRadius.circular(10.0.w),
          ),
          child: Row(
            children: <Widget>[
              Container(
                margin:
                    EdgeInsets.only(left: 57.5.w, top: 72.0.h, bottom: 90.7.h),
                child: Image.asset(
                  "asset/images/ic_notifi.png",
//                        color: Colors.grey,
                  width: 100.0.w,
                  height: 102.0.h,
                ),
              ),
              SizedBox(
                width: 37.9.w,
              ),
              Flexible(
                child: Container(
                  margin: EdgeInsets.only(
                      right: 26.0.w, top: 72.0.h, bottom: 90.7.h),
                  child: RichText(
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      text: title,
                      style: TextStyle(
                        color: prefix0.color959ca7,
                        fontFamily: 'Roboto-Regular',
                        fontSize: ScreenUtil().setSp(50.0),
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: mesage,
                            style: TextStyle(
                              color: prefix0.color3baae2,
                              fontFamily: 'Roboto-Regular',
                              fontSize: ScreenUtil().setSp(50.0),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                appBloc.homeBloc.clickItemBottomBar(3);
                                appBloc.calendarBloc
                                    .getDataScheduleApi(context);
                                appBloc.homeBloc.notifyContentStream
                                    ?.notify(null);
                                //Toast.showShort("Hiển thị thông tin chi tiết thông báo");
                              } // _recognizer,
                            ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  String getID() {
    String content =
        appBloc?.authBloc?.asgUserModel?.asgl_id?.replaceAll("-", "");
    return content ?? "Không xác định";
  }

  String getPosition() {
    String position = "Không xác định";
    ASGUserModel userModel = appBloc.authBloc.asgUserModel;
    if (userModel?.position != null &&
        userModel?.position?.department != null) {
      position = userModel?.position?.department?.name ?? "Không xác định";
    }
    return position;
  }

  Widget _buildAnimationLoading() {
    return ListView.builder(
        itemCount: 3,
        physics: AlwaysScrollableScrollPhysics(),
        itemBuilder: (buildShimmerContext, index) {
          return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(35.9),
                left: ScreenUtil().setHeight(60.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 203.1.h,
                    height: 150.1.h,
                    child: Center(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[200],
                        child: Container(
                          height: 100.w,
                          width: 100.w,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20.5.h,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[200],
                        child: Container(
                          width: 500.9.w,
                          height: 10.0,
                          color: Colors.grey[300],
                        ),
                      ),
                      SizedBox(height: 10.0.h),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[200],
                        child: Container(
                          width: 400.9.w,
                          height: 10.0,
                          color: Colors.grey[300],
                        ),
                      ),
                      SizedBox(height: 10.0.h),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300],
                        highlightColor: Colors.grey[200],
                        child: Container(
                          width: 300.9.w,
                          height: 10.0,
                          color: Colors.grey[300],
                        ),
                      ),
                    ],
                  )
                ],
              ));
        });
  }

  _buildNotificationBell() {
    return StreamBuilder<int>(
        initialData: appBloc.notificationBloc.sumUnReadNotification,
        stream: appBloc.notificationBloc.sumNotificationStream.stream,
        builder: (context, AsyncSnapshot<int> snapshot) {
          return InkWell(
            onTap: () => appBloc.homeBloc.openNotificationLayout(),
            child: Container(
              margin: EdgeInsets.only(
                  right: ScreenUtil().setWidth(59.0), top: 40.0),
              child: Container(
                child: Badge(
                  badgeColor: Colors.red,
                  showBadge: snapshot.data != 0,
                  badgeContent: Text(
                    snapshot.data <= 99 ? snapshot.data.toString() : "99+",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: prefix0.white,
                        fontSize: 30.0.sp,
                        fontFamily: "Roboto-Regular"),
                  ),
                  child: Image.asset(
                    "asset/images/ic_sk_notification.png",
                    color: prefix0.white,
                    width: 80.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        });
  }
}
