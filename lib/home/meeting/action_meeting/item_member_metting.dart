import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/hive/hive_helper.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/common/cache_helper.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/core/style.dart' as prefix0;

class ItemMember extends StatelessWidget {
  final String memberID;
  final String fullName;
  final String department;
  final int accepted;

  const ItemMember(
      {Key key,
      this.memberID,
      this.fullName,
      this.department,
      this.accepted = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppBloc appBloc = BlocProvider.of(context);
    Color acceptedColor = prefix0.color959ca7;
    if (accepted == 0) {
      //Chưa xác nhận
      acceptedColor = prefix0.color959ca7;
    } else if (accepted == 1) {
      //Đồng ý tham gia
      acceptedColor = Color(0xFF3baae2);
    } else if (accepted == 2) {
      //Từ chối tham gia
      acceptedColor = Color(0xFFe10606);
    }
    ASGUserModel userModel;
    try {
      if(int.parse(memberID) == appBloc.authBloc.asgUserModel.id){
        userModel = appBloc.authBloc.asgUserModel;
      }else {
        userModel = HiveHelper.getListContact().firstWhere(
                (user) => user.id == int.parse(memberID),
            orElse: () => null);
      }
    } on Exception catch (ex){
      userModel = null;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        //avata
        CustomCircleAvatar(
          position: ImagePosition.GROUP,
          size: 114.0,
          userName: userModel != null ? userModel.username : memberID,
        ),
        SizedBox(
          width: 60.0.w,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                fullName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: prefix0.blackColor333,
                    fontFamily: 'Roboto-Regular',
                    fontSize: 50.sp),
              ),
              Text(
                department,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: prefix0.color959ca7,
                    fontFamily: 'Roboto-Regular',
                    fontSize: 40.sp),
              ),
            ],
          ),
        ),
        Container(
          width: 34.w,
          height: 34.w,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: acceptedColor),
        )
      ],
    );
  }
}
