import 'package:flutter/material.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/utils/common/const.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/text_content_message.dart';
import 'package:url_launcher/url_launcher.dart';

typedef OnClickItem = Function();

class ItemMessageDefaultGroupNew extends StatefulWidget {
  final WsMessage message;
  final bool isHasUrl;
  final String sendTo;
  final WsRoomModel wsRoomModel;
  final OnClickItem onClickItem;
  final bool isReadMessage;
  final String title;
  final String shortContent;

  ItemMessageDefaultGroupNew(
      {this.message,
      this.isHasUrl,
      this.sendTo,
      this.wsRoomModel,
      this.onClickItem,
      this.isReadMessage = false,
      this.title,
      this.shortContent});

  @override
  _ItemMessageDefaultGroupNewState createState() =>
      _ItemMessageDefaultGroupNewState();
}

class _ItemMessageDefaultGroupNewState
    extends State<ItemMessageDefaultGroupNew> {
  @override
  Widget build(BuildContext context) {
    AppBloc appBloc = BlocProvider.of(context);
    return InkWell(
      onTap: () {
        widget.onClickItem();
      },
      child: Container(
        child: ColumnSuper(
          alignment: Alignment.centerLeft,
          outerDistance: 10.0.h,
          innerDistance: -46.0.h,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 182.0.w,
                ),
                Column(
                  children: <Widget>[
                    Container(
                      width: ScreenUtil().setWidth(855),
                      padding: widget.message.file != null
                          ? EdgeInsets.zero
                          : EdgeInsets.only(
                              top: ScreenUtil().setHeight(18.7),
                              bottom: ScreenUtil().setHeight(19.0),
                              left: ScreenUtil().setWidth(31.5),
                              right: ScreenUtil().setWidth(61.6)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(40.w),
                          topLeft: Radius.circular(40.w),
                        ),
                        color: prefix0.accentColor,
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontFamily: "Roboto-Medium",
                                color: Colors.white,
                                fontSize: 45.sp,
                              ),
                            ),
                            if (widget.sendTo != null &&
                                widget.sendTo != "" &&
                                widget.wsRoomModel.name
                                    .contains(Const.THONG_BAO)) ...{
                              Text(
                                "Gửi từ: " + widget.sendTo,
                                style: TextStyle(
                                  fontFamily: "Roboto-Regular",
                                  color: Colors.white,
                                  fontSize: 36.sp,
                                ),
                              )
                            }
                          ]),
                    ),
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: ScreenUtil().setWidth(855),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40.w),
                          bottomRight: Radius.circular(40.w),
                        ),
                        color: prefix0.accentColor,
                      ),
                      child: Container(
                        margin: widget.isReadMessage
                            ? EdgeInsets.only(
                                left: 2.0.w,
                                right: 2.0.w,
                                bottom: 2.0.h,
                              )
                            : EdgeInsets.all(0),
                        constraints: BoxConstraints(
                          maxWidth: ScreenUtil().setWidth(855),
                        ),
                        padding: widget.message.file != null
                            ? EdgeInsets.zero
                            : EdgeInsets.only(
                                top: ScreenUtil().setHeight(56.7),
                                bottom: ScreenUtil().setHeight(38.9),
                                left: ScreenUtil().setWidth(30.6),
                                right: ScreenUtil().setWidth(62.5)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40.w),
                            bottomRight: Radius.circular(40.w),
                          ),
                          color: Color(0xfff8f8f8),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              itemTextInMessage(appBloc),
                              StreamBuilder(
                                  initialData: LoadMoreTextModel(
                                      widget.message,
                                      appBloc.mainChatBloc.checkLongContent(
                                          widget.shortContent)),
                                  stream: appBloc
                                      .mainChatBloc.loadMoreTextStream.stream
                                      .where((f) => f.wsMessage.id
                                          .contains(widget.message.id)),
                                  builder: (context, snapshot) {
                                    switch (snapshot.data.loadMoreTextState) {
                                      case LoadMoreTextState.HAVEDATA:
                                        return Container(
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              appBloc.mainChatBloc
                                                  .changeStateLoadmoreContentStream(
                                                      widget.message,LoadMoreTextState.NODATA);
                                            },
                                            child: Text(
                                              "Xem Thêm",
                                              style: TextStyle(
                                                fontSize: 36.sp,
                                                fontFamily: "Roboto-Regular",
                                                color: Color(0xff005b8c),
                                              ),
                                            ),
                                          ),
                                        );
                                        break;
                                      case LoadMoreTextState.NODATA:
                                        return Container(
                                          alignment: Alignment.centerRight,
                                          child: InkWell(
                                            onTap: () {
                                              appBloc.mainChatBloc
                                                  .changeStateLoadmoreContentStream(
                                                      widget.message,LoadMoreTextState.HAVEDATA);
                                            },
                                            child: Text(
                                              "Thu Nhỏ",
                                              style: TextStyle(
                                                fontSize: 36.sp,
                                                fontFamily: "Roboto-Regular",
                                                color: Color(0xff005b8c),
                                              ),
                                            ),
                                          ),
                                        );
                                        break;
                                      default:
                                        return Container();
                                        break;
                                    }
                                  }),
                            ]),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget itemTextInMessage(AppBloc appBloc) {
    if (widget.isHasUrl) {
      return StreamBuilder(
          initialData: LoadMoreTextModel(widget.message,
              appBloc.mainChatBloc.checkLongContent(widget.shortContent)),
          stream: appBloc.mainChatBloc.loadMoreTextStream.stream
              .where((f) => f.wsMessage.id.contains(widget.message.id)),
          builder: (context, snapshot) {
            if (snapshot.data.statusLoadMoreTextModel) {
              return itemContentLinkInMessage(
                  appBloc.mainChatBloc.covertTextSoLong(widget.shortContent));
            } else {
              return itemContentLinkInMessage(widget.shortContent);
            }
          });
    } else {
      return TextContentMessage(
        textColor: prefix0.blackColor333,
        message: widget.message,
        isOwner: false,
        wsRoomModel: widget.wsRoomModel,
        shortContent: widget.shortContent,
      );
    }
  }

  Widget itemContentLinkInMessage(String msg) {
    return Linkify(
      onOpen: (link) async {
        if (await canLaunch(link.url)) {
          await launch(link.url);
        } else {
          Toast.showShort("Không thể mở đường dẫn");
        }
      },
      linkStyle: TextStyle(
          decoration: TextDecoration.underline,
          fontFamily: 'Roboto-Regular',
          color: prefix0.accentColor,
          fontSize: ScreenUtil().setSp(45.0)),
      text: msg,
      style: TextStyle(
          fontFamily: 'Roboto-Regular',
          color: prefix0.blackColor333,
          fontSize: ScreenUtil().setSp(45.0)),
    );
  }
}
