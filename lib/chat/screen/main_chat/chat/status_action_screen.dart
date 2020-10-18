import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';

typedef OnCloseAction = Function();

class StatusActionScreen extends StatefulWidget {
  final OnCloseAction onCloseAction;
  final WsMessage message;

  const StatusActionScreen({
    Key key,
    @required this.onCloseAction,
    @required this.message,
  }) : super(key: key);

  @override
  _StatusActionScreenState createState() => _StatusActionScreenState();
}

class _StatusActionScreenState extends State<StatusActionScreen> {
  AppBloc appBloc;

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel.state = isFocusWidget.STATUS_ACTION_SCREEN;
    return GestureDetector(
      onTap: () {
        widget.onCloseAction();
      },
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: prefix0.color959ca7.withOpacity(0.5),
          ),
          Positioned(
              bottom: 0.0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(top: 27.0.h, bottom: 25.6.h),
                    decoration: BoxDecoration(
                        color: prefix0.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.0),
                          topRight: Radius.circular(25.0),
                        )),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(bottom: 24.5.h),
                          child: Text(
                            "${widget.message.reactions.sumUserReactions} người đã bày tỏ cảm xúc",
                            style: TextStyle(
                              fontFamily: "Roboto-Regular",
                              fontSize: 36.sp,
                              letterSpacing: 0.7.w,
                              color: prefix0.accentColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              bottom: 12.5.h, top: 9.5.h, left: 60.0.w),
                          decoration: BoxDecoration(
                              border: Border(
                            top: BorderSide(
                                color: Color(0xff959ca7), width: 1.0.h),
                            bottom: BorderSide(
                                color: Color(0xff959ca7), width: 1.0.h),
                          )),
                          child: Row(
                            children: <Widget>[
                              Text(
                                "Tất cả ${widget.message.reactions.sumUserReactions}",
                                style: TextStyle(
                                  fontFamily: "Roboto-Regular",
                                  fontSize: 32.sp,
                                  letterSpacing: 0.7.w,
                                  color: prefix0.accentColor,
                                ),
                              ),
                              SizedBox(
                                width: 65.3.w,
                              ),
                              _itemIconAndCount(
                                  "asset/images/ic_like.png",
                                  widget.message.reactions.reactSLike.length
                                      .toString()),
                              _itemIconAndCount(
                                  "asset/images/ic_dislike.png",
                                  widget.message.reactions.reactSDislike.length
                                      .toString()),
                              _itemIconAndCount(
                                  "asset/images/ic_heart.png",
                                  widget.message.reactions.reactSHeart.length
                                      .toString()),
                              _itemIconAndCount(
                                  "asset/images/ic_ok.png",
                                  widget.message.reactions.reactSOk.length
                                      .toString()),
                              _itemIconAndCount(
                                  "asset/images/ic_no.png",
                                  widget.message.reactions.reactSNo.length
                                      .toString()),
                            ],
                          ),
                        ),
                        Container(
                          height: 346.1.h,
                          child: ListView.builder(
                              padding: EdgeInsets.only(top: 24.5.w),
                              shrinkWrap: true,
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: widget
                                  .message.reactions.mapUserReacted.keys.length,
                              itemBuilder: (buildContext, index) {
                                return Container(
                                  margin: EdgeInsets.only(
                                      left: 60.w, right: 60.w, bottom: 33.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      CustomCircleAvatar(
                                        userName: widget.message.reactions
                                            .mapUserReacted.keys
                                            .elementAt(index),
                                        position: ImagePosition.GROUP,
                                        size: 77.7,
                                      ),
                                      SizedBox(
                                        width: 39.w,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              getFullNameByUserName(widget
                                                  .message
                                                  .reactions
                                                  .mapUserReacted
                                                  .keys
                                                  .elementAt(index)),
                                              style: TextStyle(
                                                fontFamily: "Roboto-Regular",
                                                fontSize: 32.sp,
                                                color: prefix0.blackColor333,
                                              ),
                                            ),
                                            Text(
                                              "Đã xem",
                                              style: TextStyle(
                                                fontFamily: "Roboto-Regular",
                                                fontSize: 26.sp,
                                                letterSpacing: 0.7.w,
                                                color: Color(0xff959ca7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Image.asset(
                                        getIconFromReactName(widget.message
                                                .reactions.mapUserReacted[
                                            widget.message.reactions
                                                .mapUserReacted.keys
                                                .elementAt(index)]),
                                        width: 50.w,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        )
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _itemIconAndCount(String imageUrl, String count) {
    return Container(
      margin: EdgeInsets.only(right: 74.w),
      child: Row(
        children: <Widget>[
          Image.asset(
            imageUrl,
            width: 50.w,
          ),
          SizedBox(
            width: 4.7.w,
          ),
          Text(
            "$count",
            style: TextStyle(
              fontFamily: "Roboto-Regular",
              fontSize: 28.sp,
              letterSpacing: 0.7.w,
              color: Color(0xff959ca7),
            ),
          ),
        ],
      ),
    );
  }

  String getFullNameByUserName(String userName) {
    if (userName == appBloc.authBloc.asgUserModel.username) {
      return appBloc.authBloc.asgUserModel.full_name;
    }
    AddressBookModel user = appBloc.mainChatBloc.listUserOnChatSystem
        ?.firstWhere((user) => user.username == userName, orElse: () => null);
    if (user != null) {
      return user.name;
    }
    return userName;
  }

  String getIconFromReactName(String reactIconName) {
    if (reactIconName == ":s_like:") {
      return "asset/images/ic_like.png";
    } else if (reactIconName == ":s_dislike:") {
      return "asset/images/ic_dislike.png";
    } else if (reactIconName == ":s_heart:") {
      return "asset/images/ic_heart.png";
    } else if (reactIconName == ":s_ok:") {
      return "asset/images/ic_ok.png";
    } else if (reactIconName == ":s_no:") {
      return "asset/images/ic_no.png";
    } else {
      return "asset/images/ic_like.png";
    }
  }
}
