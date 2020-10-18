import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/style.dart';
import 'package:human_resource/home/notifications/notification_services.dart';
import 'package:human_resource/model/notification_model.dart';
import 'package:human_resource/model/socket_notification.dart';
import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:human_resource/utils/widget/loading_indicator.dart';
import 'package:html/dom.dart' as dom;

class NotificationDetail extends StatefulWidget {
  final SKNotification data;

  const NotificationDetail({Key key, this.data}) : super(key: key);

  @override
  _NotificationDetailState createState() => _NotificationDetailState();
}

class _NotificationDetailState extends State<NotificationDetail> {
  final _NotificationDetailBloc _bloc = _NotificationDetailBloc();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc.getDetailAnnouncement(widget.data);
    });
  }

  @override
  void dispose() {
    _bloc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return null;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: white,
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: blackColor333,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: StreamBuilder(
              initialData: _DetailStreamModel(),
              stream: _bloc.detailStream.stream,
              builder:
                  (buildContext, AsyncSnapshot<_DetailStreamModel> snapshot) {
                switch (snapshot.data.state) {
                  case _NotifyDetailState.LOADING:
                    return Center(
                      child: LoadingIndicator(),
                    );
                    break;
                  case _NotifyDetailState.NO_DATA:
                    return Center(
                      child: Container(
                        margin: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Không tìm thấy nội dung.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: blackColor333,
                                fontSize: 50.0.sp,
                                fontFamily: "Roboto",
                              ),
                            ),
                            SizedBox(
                              height: 10.0.h,
                            ),
                            FlatButton(
                              onPressed: () {
                                _bloc.getDetailAnnouncement(widget.data);
                              },
                              padding: EdgeInsets.all(10.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              color: accentColor,
                              child: Text(
                                "Thử lại",
                                style: TextStyle(
                                  color: white,
                                  fontSize: 45.0.sp,
                                  fontFamily: "Roboto",
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                    break;
                  case _NotifyDetailState.SHOW:
                    return _buildBodyLayout(snapshot.data.data);
                    break;
                  default:
                    return Container();
                    break;
                }
              }),
        ),
      ),
    );
  }

  Widget buildSendToAndTimeBANTIN(NotificationModel data) {
    return Column(
      children: <Widget>[
        SizedBox(height: 22.4.h),
        buildDateTimeSend(data),
        SizedBox(height: 50.h),
      ],
    );
  }

  Widget buildSendToAndTimeTHONGBAO(NotificationModel data) {
    return Column(
      children: <Widget>[
        SizedBox(height: 8.4.h),
        Row(
          children: <Widget>[
            SizedBox(width: 74.w),
            Text(
              "Gửi từ: ",
              style: TextStyle(
                  fontFamily: "Roboto-Regular",
                  fontSize: 32.sp,
                  color: Color(0xff959ca7),
                  height: 1.38),
            ),
            Expanded(
              child: Text(
                data?.author?.full_name,
                style: TextStyle(
                    fontFamily: "Roboto-Medium",
                    fontSize: 32.sp,
                    color: Color(0xff707070),
                    height: 1.38),
              ),
            ),
            SizedBox(width: 59.w),
          ],
        ),
        SizedBox(height: 20.h),
        buildDateTimeSend(data),
        SizedBox(height: 71.h),
      ],
    );
  }

  Widget buildDateTimeSend(NotificationModel data) {
    return Row(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 74.w),
          child: Text(
              DateTimeFormat.convertTimeMessageItemDetail(
                  DateTime.parse(data?.datePost).millisecondsSinceEpoch),
              style: TextStyle(
                  fontFamily: "Roboto-Regular",
                  fontSize: 32.sp,
                  color: Color(0xff707070),
                  height: 1.38)),
        ),
      ],
    );
  }

  Widget _buildBodyLayout(SKNotification data) {
    NotificationModel model;
    try {
      model = data.data;
    } catch (ex) {
      debugPrint(ex);
    }
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: 29.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 74.w),
              Image.asset(
                'asset/images/document-2.png',
                height: 70.h,
                width: 63.3.w,
                color: Color(0xff515151),
              ),
              SizedBox(width: 36.7.w),
              Expanded(
                  child: Text(
                data?.data?.title ?? data.title,
                style: TextStyle(
                    fontFamily: "Roboto-Bold", fontSize: 52.sp, height: 1.42),
              )),
              SizedBox(width: 59.1.w)
            ],
          ),
          data?.data?.author?.full_name != null &&
                  data?.data?.author?.full_name != ""
              ? buildSendToAndTimeTHONGBAO(data?.data)
              : buildSendToAndTimeBANTIN(data?.data),
          Row(
            children: <Widget>[
              SizedBox(width: 60.w),
              Expanded(
                child: Html(
                  renderNewlines: true,
                  padding: EdgeInsets.zero,
                  defaultTextStyle: TextStyle(
                      fontSize: 40.0.sp,
                      color: blackColor333,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal),
                  data: '''${data.data.content} ''',
                ),
              ),
              SizedBox(width: 59.w),
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: 60.0.w, right: 59.0.w, top: 20.0.h),
            alignment: Alignment.topLeft,
            child: Text(
              "Tập tin đính kèm",
              style: TextStyle(
                  fontSize: 60.0.sp,
                  color: blackColor333,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal),
            ),
          ),
          if (model != null &&
              model.files != null &&
              model.files.length > 0) ...{
            for (FileAttachment file in model.files) ...{
              Text(
                file.src,
                style: TextStyle(
                    fontSize: 40.0.sp,
                    color: blackColor333,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal),
              ),
            }
          } else ...{
            Container(
              margin: EdgeInsets.only(left: 60.0.w, right: 59.0.w, top: 20.0.h),
              alignment: Alignment.topLeft,
              child: Text(
                "Không có tập tin đính kèm",
                style: TextStyle(
                    fontSize: 40.0.sp,
                    color: blackColor333,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal),
              ),
            ),
          },
          SizedBox(height: 114.6.h),
        ],
      ),
    );
  }
}

enum _NotifyDetailState { LOADING, NO_DATA, SHOW }

class _DetailStreamModel {
  _NotifyDetailState state;
  SKNotification data;

  _DetailStreamModel({this.state = _NotifyDetailState.LOADING, this.data});
}

class _NotificationDetailBloc {
  CoreStream<_DetailStreamModel> detailStream = CoreStream();
  SKNotification notificationModel;

  void dispose() {
    detailStream?.closeStream();
  }

  void getDetailAnnouncement(SKNotification data) async {
    detailLoading;
    try {
      NotificationServices services = NotificationServices();
      await services.getDetailNotification(
          notificationID: data.id,
          resultData: (result) {
            if (result != null && result != "") {
              if (result.containsKey('notification') &&
                  result['notification'] != null &&
                  result['notification'] != "") {
                notificationModel =
                    SKNotification.fromAPI(result['notification']);
              }
            }
            _showDetailData();
          },
          onErrorApiCallback: (error) {
            _showDetailData();
          });
    } catch (ex) {
      _showDetailData();
    }
  }

  void get detailLoading => detailStream
      ?.notify(_DetailStreamModel(state: _NotifyDetailState.LOADING));

  void get detailNoData => detailStream
      ?.notify(_DetailStreamModel(state: _NotifyDetailState.NO_DATA));

  void get detailShowData => detailStream?.notify(_DetailStreamModel(
      state: _NotifyDetailState.SHOW, data: notificationModel));

  void _showDetailData() {
    if (notificationModel != null) {
      detailShowData;
    } else {
      detailNoData;
    }
  }
}
