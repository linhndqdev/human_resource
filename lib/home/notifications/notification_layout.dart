import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/meeting/model/meeting_model.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/home/notifications/detail/notification_detail_screen.dart';
import 'package:human_resource/home/notifications/notification_bloc.dart';
import 'package:human_resource/model/notification_model.dart';
import 'package:human_resource/model/socket_notification.dart';
import 'package:human_resource/utils/widget/custom_behavior.dart';
import 'package:human_resource/utils/widget/loading_indicator.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class NotificationLayout extends StatefulWidget {
  final AppBloc appBloc;

  const NotificationLayout({Key key, this.appBloc}) : super(key: key);

  @override
  _NotificationLayoutState createState() => _NotificationLayoutState();
}

class _NotificationLayoutState extends State<NotificationLayout> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      widget.appBloc?.notificationBloc?.getAllNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: prefix0.white,
      appBar: AppBar(
        backgroundColor: prefix0.accentColor,
        leading: IconButton(
            icon: Icon(
              Icons.keyboard_backspace,
              color: prefix0.white,
            ),
            onPressed: () {
              widget.appBloc.homeBloc.closeLayoutNotBottomBar();
            }),
        centerTitle: true,
        title: Text(
          "Thông báo",
          style: TextStyle(
              color: prefix0.white,
              fontFamily: "Roboto-Regular",
              fontSize: 50.0.sp),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              widget.appBloc.notificationBloc.loadMoreNotification();
            }
            return false;
          },
          child: LiquidPullToRefresh(
            showChildOpacityTransition: false,
            onRefresh: () => widget.appBloc.notificationBloc.refreshData(),
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: StreamBuilder(
                          initialData:
                              ListDataStreamModel(ListDataState.LOADING, []),
                          stream: widget.appBloc.notificationBloc
                              .updateListNotificationsStream.stream,
                          builder: (streamContext,
                              AsyncSnapshot<ListDataStreamModel> snapshot) {
                            switch (snapshot.data.state) {
                              case ListDataState.SHOW:
                                return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: snapshot.data.data.length,
                                    physics: NeverScrollableScrollPhysics(),
                                    reverse: false,
                                    itemBuilder: (listContext, index) {
                                      return _buildItemView(
                                          snapshot.data.data[index]);
                                    });
                                break;
                              case ListDataState.LOADING:
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height - 72.0,
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        prefix0.accentColor),
                                  ),
                                );
                                break;
                              case ListDataState.NONE:
                                return Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height - 72.0,
                                  child: Text(
                                    "Hiện tại chưa có thông báo nào",
                                    style: TextStyle(
                                        color: prefix0.blackColor333,
                                        fontSize: 40.0.sp,
                                        fontFamily: "Roboto-Regular"),
                                  ),
                                );
                                break;
                              default:
                                return Container();
                                break;
                            }
                          }),
                    ),
                    _buildLoadMoreItemView(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemView(SKNotification data) {
    return GestureDetector(
      onTap: () {
        if (data != null && data.data != null) {
          if (data.data is MeetingModel) {
            widget.appBloc.homeBloc.openMeetingDetail(widget.appBloc, data);
          } else if (data.data is NotificationModel) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationDetail(
                  data: data,
                ),
              ),
            );
          }
        }
      },
      child: Container(
        padding: EdgeInsets.only(top: 5.0.h, bottom: 5.0.h, right: 20.0.w),
        color: prefix0.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(20.0.w),
              width: 220.0.h,
              height: 220.0.h,
              child: Image.asset("asset/images/group-10353@3x.png"),
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 10.0.h,
                ),
                Text(
                  data.title,
                  maxLines: 2,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40.0.sp,
                      color: prefix0.blackColor,
                      fontFamily: "Roboto-Bold"),
                ),
                SizedBox(
                  height: 5.0.h,
                ),
                Text(data.message,
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 40.0.sp,
                        color: prefix0.blackColor,
                        fontFamily: "Roboto-Regular")),
                SizedBox(
                  height: 5.0.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      data.createed,
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 30.0.sp,
                          color: prefix0.blackColor,
                          fontFamily: "Roboto-Regular"),
                    ),
                    if (data.read) ...{
                      SizedBox(
                        width: 8.0.w,
                      ),
                    },
                    if (data.read) ...{
                      Icon(
                        Icons.check_circle_outline,
                        size: 16.0,
                        color: prefix0.accentColor,
                      ),
                    },
                  ],
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  _buildLoadMoreItemView() {
    return StreamBuilder(
        initialData: false,
        stream: widget.appBloc.notificationBloc.loadMoreStream.stream,
        builder: (buildContext, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data) {
            return Container(
              margin: EdgeInsets.only(bottom: 10.0.h),
              color: prefix0.white,
              width: MediaQuery.of(context).size.width,
              height: 120.0.h,
              child: LoadingIndicator(),
            );
          }
          return Container();
        });
  }
}
