import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/utils/animation/animation_vertical.dart';
import 'package:human_resource/utils/widget/item_application.dart';

class ApplicationList extends StatefulWidget {
  @override
  _ApplicationListState createState() => _ApplicationListState();
}

class _ApplicationListState extends State<ApplicationList> {
  final ApplicationBloc bloc = ApplicationBloc();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color(0xff0ffffff)),
      child: Column(
        children: <Widget>[
          //ĐƯờng kẻ
          Container(
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(60.0),
              right: ScreenUtil().setWidth(59.0),
            ),
            height: ScreenUtil().setHeight(1.0),
            width: ScreenUtil().setWidth(945.0),
            color: Color(0xff0959ca7),
          ),
          SizedBox(
            height: 48.5.h,
          ),
          TranslateVertical(
              isResetWhenUpdateWidget: true,
              curveAnimated: Curves.ease,
              duration: 500,
              translateType: VerticalType.DOWN_TO_UP,
              startPosition: MediaQuery.of(context).size.width / 2,
              /// các icon ứng dụng
              child: Container(
                decoration: BoxDecoration(color: Color(0xff0ffffff)),
                margin: EdgeInsets.only(
                  left: ScreenUtil().setWidth(93.0),
                  right: ScreenUtil().setWidth(117.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      fit: FlexFit.loose,
                      child: ItemApplicationList(
                        pkNameAndroid: "com.asgl.s_timesheet_mobile",
                        pkNameIOS: "stimesheetmobile",
                        imageAsset: "asset/images/ic_s_time_sheet.png",
                        applicationBloc: bloc,
                        title: "S-Timesheet",
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(
            height: 49.0.h,
          ),
          TranslateVertical(
              curveAnimated: Curves.ease,
              duration: 600,
              translateType: VerticalType.DOWN_TO_UP,
              startPosition: MediaQuery.of(context).size.width / 2,
              child: Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                        left: ScreenUtil().setWidth(60.0),
                      ),
                      child: Text(
                        "BẢN TIN",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(60.0),
                            fontFamily: "Roboto-regular",
                            color: Color(0xff0959ca7),
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(
            height: 22.5.h,
          ),
          Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(60.0),
                right: ScreenUtil().setWidth(59.0)),
            height: ScreenUtil().setHeight(1.0),
            width: ScreenUtil().setWidth(945.0),
            color: Color(0xff0959ca7),
          ),
        ],
      ),
    );
  }

  //Yêu cầu logic check time để hiển thị màu của ngày hiên tại
  bool getTitleColor() {
    return false;
  }
}

class ApplicationBloc {
  bool isLoading = false;
}
