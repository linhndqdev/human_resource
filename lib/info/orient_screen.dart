import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:human_resource/chat/screen/main_chat/chat/chat_bloc.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/info/FaqPagedetail.dart';
import 'package:human_resource/info/news_and_notification.dart';
import 'package:human_resource/info/news_notify_detail_screen.dart';
import 'package:human_resource/info/orient_bloc.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/info/show_image_item_news_and_notification.dart';
//Muốn mở màn hình này khi nhấn vào 1 trong các item ở dashboard thì làm nhơ sau:

class OrientScreen extends StatefulWidget {
  final OrientState state;

  const OrientScreen({Key key, this.state}) : super(key: key);

  @override
  _OrientScreenState createState() => _OrientScreenState();
}

class _OrientScreenState extends State<OrientScreen> {
  OrientBloc orientBloc = OrientBloc();
  AppBloc appBloc;

  @override
  void dispose() {
    appBloc.homeBloc.typeSystemScreen = OrientState.NONE;
    super.dispose();
  }

  @override
  void didUpdateWidget(OrientScreen oldWidget) {
    if (widget.state == oldWidget.state) {
      super.didUpdateWidget(oldWidget);
    } else {
      super.didUpdateWidget(widget);
      orientBloc.layoutStream.notify(OrientLayoutModel(state: widget.state));
    }
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.ORIENT_SCREEN);
    return WillPopScope(
      onWillPop: () async {
        if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.IMAGE_SHOW) {
          appBloc.mainChatBloc.chatBloc.showOtherLayoutStream
              .notify(OtherLayoutModelStream(OtherLayoutState.NONE, null));
          appBloc.backStateBloc.focusWidgetModel =
              FocusWidgetModel(state: isFocusWidget.ORIENT_SCREEN);
        } else if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.ORIENT_DETAIL_SCREEN) {
          appBloc.mainChatBloc.chatBloc.layoutDetailStream
              .notify(OrientLayoutDetailModel(isShowDetail: false));
          appBloc.backStateBloc.focusWidgetModel =
              FocusWidgetModel(state: isFocusWidget.ORIENT_SCREEN);
        } else {
          appBloc.homeBloc.backLayoutNotBottomBar();
          appBloc.backStateBloc.focusWidgetModel =
              FocusWidgetModel(state: isFocusWidget.HOME);
        }

        return false;
      },
      child: Stack(
        children: <Widget>[
          Scaffold(
            appBar: PreferredSize(
                child: AppBar(
                    elevation: 0.0,
                    centerTitle: true,
                    titleSpacing: 0.0,
                    backgroundColor: Color(0xFF0005a88),
                    title: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 178.5.h,
                      child: Stack(
                        children: <Widget>[
                          Positioned(
                            left: 0,
                            child: InkWell(
                              onTap: () {
                                if (appBloc
                                        .backStateBloc.focusWidgetModel.state ==
                                    isFocusWidget.ORIENT_DETAIL_SCREEN) {
                                  appBloc
                                      .mainChatBloc.chatBloc.layoutDetailStream
                                      .notify(OrientLayoutDetailModel(
                                          isShowDetail: false, data: null));
                                  appBloc.backStateBloc.focusWidgetModel =
                                      FocusWidgetModel(
                                          state: isFocusWidget.ORIENT_SCREEN);
                                } else
                                  appBloc.homeBloc.backLayoutNotBottomBar();
                              },
                              child: Container(
                                height: 178.5.h,
                                margin: EdgeInsets.only(
                                  left: 60.0.w,
                                  right: 60.0.w,
                                ),
                                child: Image.asset(
                                  "asset/images/ic_meeting_back_white.png",
                                  color: prefix0.white,
                                  width: 50.0.w,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: StreamBuilder(
                                initialData:
                                    OrientLayoutModel(state: widget.state),
                                stream: orientBloc.layoutStream.stream,
                                builder: (buildContext,
                                    AsyncSnapshot<OrientLayoutModel>
                                        snapshotData) {
                                  appBloc.homeBloc.typeSystemScreen =
                                      snapshotData.data.state;
                                  switch (snapshotData.data.state) {
                                    case OrientState.BAN_TIN:
                                      return Text(
                                        'Bản tin',
                                        style: TextStyle(
                                            fontSize: 60.sp,
                                            fontFamily: "Roboto",
                                            fontWeight: FontWeight.bold,
                                            color: prefix0.white),
                                      );
                                      break;
                                    case OrientState.THONG_BAO:
                                      return Text(
                                        'Thông báo',
                                        style: TextStyle(
                                            fontSize: 60.sp,
                                            fontFamily: "Roboto",
                                            fontWeight: FontWeight.bold,
                                            color: prefix0.white),
                                      );
                                      break;
                                    case OrientState.FAQ:
                                      return Text(
                                        'Hỏi đáp',
                                        style: TextStyle(
                                            fontSize: 60.sp,
                                            fontFamily: "Roboto",
                                            fontWeight: FontWeight.bold,
                                            color: prefix0.white),
                                      );
                                      break;
                                    default:
                                      return Container();
                                      break;
                                  }
                                }),
                          )
                        ],
                      ),
                    )),
                preferredSize: Size.fromHeight(ScreenUtil().setHeight(171))),
            body: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xfff8f8f8),
                      ),
                      padding: EdgeInsets.only(
                        left: 60.0.w,
                        right: 60.0.w,
                      ),
                      child: StreamBuilder(
                          initialData: OrientLayoutModel(state: widget.state),
                          stream: orientBloc.layoutStream.stream,
                          builder: (buildContext,
                              AsyncSnapshot<OrientLayoutModel> snapshotData) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Flexible(
                                  fit: FlexFit.tight,
                                  child: Center(
                                    child: _buildTitleTap(
                                        "BẢN TIN", OrientState.BAN_TIN,
                                        isMarginLeft: true,
                                        isEnable: snapshotData.data.state ==
                                            OrientState.BAN_TIN),
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  child: Center(
                                    child: _buildTitleTap(
                                        "THÔNG BÁO", OrientState.THONG_BAO,
                                        isEnable: snapshotData.data.state ==
                                            OrientState.THONG_BAO),
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  child: Center(
                                    child: _buildTitleTap(
                                        "FAQ", OrientState.FAQ,
                                        isMarginRight: true,
                                        isEnable: snapshotData.data.state ==
                                            OrientState.FAQ),
                                  ),
                                )
                              ],
                            );
                          }),
                    ),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: StreamBuilder(
                            initialData: OrientLayoutModel(state: widget.state),
                            stream: orientBloc.layoutStream.stream,
                            builder: (buildContext,
                                AsyncSnapshot<OrientLayoutModel> snapshotData) {
                              switch (snapshotData.data.state) {
                                case OrientState.BAN_TIN:
                                  return NewAndNotification(
                                    typeId: "2",
                                  );
                                  break;
                                case OrientState.THONG_BAO:
                                  return NewAndNotification(
                                    typeId: "1",
                                  );
                                  break;
                                case OrientState.FAQ:
                                  return FaqScreen();
                                  break;
                                default:
                                  return Container();
                                  break;
                              }
                            }),
                      ),
                    )
                  ],
                ),
                StreamBuilder<OrientLayoutDetailModel>(
                    initialData: OrientLayoutDetailModel(
                        isShowDetail: false, data: null),
                    stream:
                        appBloc.mainChatBloc.chatBloc.layoutDetailStream.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.data.isShowDetail) return Container();
                      return NewsNotifyDetailScreen(data: snapshot.data.data);
                    })
              ],
            ),
          ),
          StreamBuilder(
            initialData: OtherLayoutModelStream(OtherLayoutState.NONE, null),
            stream: appBloc.mainChatBloc.chatBloc.showOtherLayoutStream.stream,
            builder: (buildContext,
                AsyncSnapshot<OtherLayoutModelStream> showLargeImage) {
              switch (showLargeImage.data.state) {
                case OtherLayoutState.IMAGE_SHOW:
                  if (showLargeImage.data.data != null) {
                    return ShowImageItemNewsAndNotification(
                      urlImage: showLargeImage.data.data,
                    );
//                    WsFile wsFile = (showLargeImage.data.data[0] as WsFile);
//                    return ImageShowLayout(
//                        imageFile: showLargeImage.data.data[1] as WsImageFile,
//                        fileName: wsFile.name,
//                        messageID: wsFile.id);
                  } else {
                    return Container();
                  }
                  break;
                default:
                  return Container();
                  break;
              }
              // return Container();
            },
          ), //show anhr
        ],
      ),
    );
  }

  _buildTitleTap(String title, OrientState state,
      {bool isMarginLeft = false,
      bool isEnable = false,
      isMarginRight = false}) {
    return Container(
      padding: EdgeInsets.only(top: 42.h, bottom: 31.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        width: 8.0.h,
        color: isEnable ? prefix0.accentColor : Color(0xfff8f8f8),
      ))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          InkWell(
            onTap: () {
              appBloc.orientBloc.loadDataNotificationModelStream.notify(
                  LoadDataNotificationModel(
                      loadDataNotificationAndNewsState:
                          LoadDataNotificationAndNewsState.LOADDING,
                      data: null));
              orientBloc.layoutStream.notify(OrientLayoutModel(state: state));
            },
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 48.0.sp,
                  fontFamily: isEnable ? "Roboto-Medium" : "Roboto-Regular",
                  color: isEnable ? prefix0.accentColor : Color(0xff959ca7)),
            ),
          ),
        ],
      ),
    );
  }
}
