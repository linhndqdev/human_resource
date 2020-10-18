import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/core/style.dart' as prefix0;

class InformationEmpty extends StatefulWidget {
  final String noData;

  InformationEmpty(this.noData);

  @override
  _InformationEmptyState createState() => _InformationEmptyState();
}

class _InformationEmptyState extends State<InformationEmpty> {
  final ApplicationBloc bloc = ApplicationBloc();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 117.7.h,
          ),
          Container(
            child: Image.asset(
              "asset/images/img_infomationemty.png",
//            color: Colors.white,
              width: 626.8.w,
              height: 425.h,
            ),
          ),
          SizedBox(
            height: 67.8.h,
          ),
          Container(
            child: Text(
              'Hiện không có' + widget.noData + 'nào',
              style: TextStyle(
                  fontSize: 48.0.sp,
                  fontFamily: "Roboto-Regular",
                  color: prefix0.greyColor),
            ),
          )
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
