import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/info/orient_bloc.dart';
import 'package:human_resource/model/notification_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:html/dom.dart' as dom;

class LineNotificationWidget extends StatefulWidget {
  final OrientState orientState;

  const LineNotificationWidget({Key key, this.orientState}) : super(key: key);

  @override
  _LineNotificationWidgetState createState() => _LineNotificationWidgetState();
}

class _LineNotificationWidgetState extends State<LineNotificationWidget> {
  AppBloc appBloc;
  final _LineNotificationBloc _bloc = _LineNotificationBloc();

  @override
  void didUpdateWidget(LineNotificationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _bloc.getNotificationData(widget.orientState);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc.getNotificationData(widget.orientState);
    });
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return GestureDetector(
      onTap: () {
        print(widget.orientState);
        appBloc?.homeBloc?.openOrientScreen(widget.orientState);
      },
      child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(
            left: 60.w,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  bottom: 35.9.h,
                ),
                height: 203.1.h,
                width: 203.1.w,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0.w),
                    color: Color(0xFF0005a88),
                    shape: BoxShape.rectangle),
                child: Center(
                  child: Image.asset(
                    widget.orientState == OrientState.BAN_TIN
                        ? "asset/images/document.png"
                        : widget.orientState == OrientState.THONG_BAO
                            ? "asset/images/ic_thongbao.png"
                            : "asset/images/ic_faq.png",
                    height: 79.4.h,
                    width: 71.8.w,
                  ),
                ),
              ),
              SizedBox(
                width: 52.5.w,
              ),
              StreamBuilder(
                  initialData: _LineDataModel(_LineDataState.LOADING, null),
                  stream: _bloc.lineDataStream.stream,
                  builder:
                      (buildContext, AsyncSnapshot<_LineDataModel> snapshot) {
                    switch (snapshot.data.state) {
                      case _LineDataState.LOADING:
                        return Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
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
                        );
                        break;
                      case _LineDataState.NO_DATA:
                        return Container(
                          alignment: Alignment.centerLeft,
                          height: 203.1.h,
                          child: Text(
                            widget.orientState == OrientState.BAN_TIN
                                ? "Chưa có bản tin mới"
                                : "Chưa có thông báo mới",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 50.0.sp,
                              fontFamily: "Roboto-Regular",
                              fontWeight: FontWeight.normal,
                              fontStyle: FontStyle.normal,
                              color: Color(0xff0959ca7),
                            ),
                          ),
                        );
                        break;
                      case _LineDataState.SHOW:
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 704.9.w,
                              child: _buildTextTile(snapshot.data.model),
                            ),
                            SizedBox(height: 10.0.h),
                            Container(
                              width: 704.9.w,
                              child: _buildTextContent(snapshot.data.model),
                            ),
                          ],
                        );
                        break;
                      default:
                        return Container();
                        break;
                    }
                  })
            ],
          )),
    );
  }

  _buildTextTile(NotificationModel model) {
    String msg = "";
    if (model.title == null || model.title.trim() == "") {
      msg = widget.orientState == OrientState.BAN_TIN
          ? "Không có bản tin mới"
          : "Không có thông báo mới";
    } else {
      msg = model.title;
    }
    return Text(
      msg,
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 50.0.sp,
        fontFamily: "Roboto-Regular",
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.normal,
        color: const Color(0xff0333333),
      ),
    );
  }

  _buildTextContent(NotificationModel model) {
    String msg = "";
    if (model.content == null || model.title.trim() == "") {
      return Container();
    } else {
      msg = model.content;
    }
    return Html(
      renderNewlines: true,
      padding: EdgeInsets.zero,
      // ignore: missing_return
      customRender: (node, child) {
        if (node is dom.Element) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  node.text,
                  textAlign: TextAlign.start,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 45.0.sp,
                    fontFamily: "Roboto-Regular",
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal,
                    color: const Color(0xff0333333),
                  ),
                )
              ]);
        } else {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: child);
        }
      },
      data: '''$msg''',
    );
  }
}

enum _LineDataState { LOADING, NO_DATA, SHOW }

class _LineDataModel {
  _LineDataState state;
  NotificationModel model;

  _LineDataModel(this.state, this.model);
}

class _LineNotificationBloc {
  CoreStream<_LineDataModel> lineDataStream = CoreStream();
  NotificationModel notificationModel;

  void dispose() {
    lineDataStream?.closeStream();
  }

  void getNotificationData(OrientState orientState) async {
    if (orientState == OrientState.FAQ) {
      lineDataStream?.notify(_LineDataModel(_LineDataState.NO_DATA, null));
      return;
    }
    ApiServices apiServices = ApiServices();
    await apiServices.getOnlyNotificationData(
      size: 1,
      typeId: orientState == OrientState.BAN_TIN ? "2" : "1",
      onResultData: (result) {
        if (result.containsKey('announcements')) {
          Iterable i = result['announcements'];
          if (i != null && i.length > 0) {
            notificationModel = NotificationModel.fromJson(i.elementAt(0));
            lineDataStream?.notify(
                _LineDataModel(_LineDataState.SHOW, notificationModel));
          } else {
            if (notificationModel != null) {
              lineDataStream?.notify(
                  _LineDataModel(_LineDataState.SHOW, notificationModel));
            } else {
              lineDataStream
                  ?.notify(_LineDataModel(_LineDataState.NO_DATA, null));
            }
          }
        } else {
          if (notificationModel != null) {
            lineDataStream?.notify(
                _LineDataModel(_LineDataState.SHOW, notificationModel));
          } else {
            lineDataStream
                ?.notify(_LineDataModel(_LineDataState.NO_DATA, null));
          }
        }
      },
      onErrorApiCallback: (onError) {
        if (notificationModel != null) {
          lineDataStream
              ?.notify(_LineDataModel(_LineDataState.SHOW, notificationModel));
        } else {
          lineDataStream?.notify(_LineDataModel(_LineDataState.NO_DATA, null));
        }
      },
    );
  }
}
