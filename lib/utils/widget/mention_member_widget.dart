import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/hive/hive_helper.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/core/style.dart' as prefix0;

typedef OnTagAll = Function();
typedef OnTagMember = Function(dynamic);

class MentionMemberWidget extends StatefulWidget {
  final List<RestUserModel> listMemberShow;
  final OnTagAll onTagAll;
  final OnTagMember onTagMember;

  const MentionMemberWidget(
      {Key key, this.listMemberShow, this.onTagAll, this.onTagMember})
      : super(key: key);

  @override
  _MentionMemberWidgetState createState() => _MentionMemberWidgetState();
}

class _MentionMemberWidgetState extends State<MentionMemberWidget> {
  List<dynamic> listData = List();
  AppBloc appBloc;

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    listData?.clear();
    listData.add("@all");
    if (widget.listMemberShow != null && widget.listMemberShow.length > 0) {
      listData.addAll(widget.listMemberShow);
    }
    return _buildListMemberShow(listData);
  }

  _buildListMemberShow(List<dynamic> listData) {
    return ListView.builder(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      addAutomaticKeepAlives: false,
      itemCount: listData.length,
      itemBuilder: (buildContext, index) {
        if (index == 0) {
          return GestureDetector(
            onTap: () {
              widget.onTagAll();
            },
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    left: 60.0.w,
                    top: 41.0.h,
//                bottom: 34.0.h,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(83.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                              "asset/images/action/ic_tag_all.png",
                            ))),
                            width: ScreenUtil().setWidth(83.0),
                            height: ScreenUtil().setWidth(83.0),
                            child: Container(),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                  left: 35.0.w,
                                ),
                                child: Text(
//                              appBloc.authBloc.asgUserModel.full_name,
                                  "Báo cho cả nhóm",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(36.0),
                                      fontFamily: "Roboto-Regular",
                                      color: Colors.black),
                                  textAlign: TextAlign.left,
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(44.0)),
                                child: Text(
                                  "@all",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(29.0),
                                      fontFamily: "Roboto-Regular",
                                      color: prefix0.color959ca7),
                                  textAlign: TextAlign.left,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return _buildTagMember(
            index, listData[index].username, listData[index].name);
      },
    );
  }

  _buildTagMember(int index, String userName, String name) {
    ASGUserModel userModel = HiveHelper.getOnlyUserFromListContact(userName);
    String depart = "Không xác định";
    if (userModel != null) {
      if (userModel.position != null) {
        if (userModel.position.department != null) {
          if (userModel.position.department.name != null) {
            depart = userModel.position.department.name;
          }
        }
      }
    }
    return InkWell(
      onTap: () {
        widget.onTagMember(listData[index]);
      },
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
              left: 60.0.w,
              top: 41.0.h,
//                bottom: 34.0.h,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(83.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                        "asset/images/baseline-account_circle-24px.png",
                      ))),
                      width: ScreenUtil().setWidth(83.0),
                      height: ScreenUtil().setWidth(83.0),
                      child: CustomCircleAvatar(
                        size: 83.0,
                        userName: userName,
                        position: ImagePosition.GROUP,
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                            left: 35.0.w,
                          ),
                          child: Text(
                            name,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(36.0),
                                fontFamily: "Roboto-Regular",
                                color: Colors.black),
                            textAlign: TextAlign.left,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(44.0)),
                          child: Text(
                            depart,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(29.0),
                                fontFamily: "Roboto-Regular",
                                color: prefix0.color959ca7),
                            textAlign: TextAlign.left,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
