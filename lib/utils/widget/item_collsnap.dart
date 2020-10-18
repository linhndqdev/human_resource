import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/style.dart' as prefix0;

class ItemCollSnapWidget extends StatefulWidget {
  final String urlImg;
  final String txt;
  final bool isCollSnap;

  const ItemCollSnapWidget(
      {Key key, this.urlImg, this.txt, this.isCollSnap = false})
      : super(key: key);

  @override
  _ItemCollSnapWidgetState createState() => _ItemCollSnapWidgetState();
}

class _ItemCollSnapWidgetState extends State<ItemCollSnapWidget> {
  double width = 70.0;
  double height = 70.0;
  Color iconColor;
  Color textColor;
  bool fontBold = false;
  bool clickItem = false;
  VoidCallback onClickItem = () {};
  AppBloc appBloc;

  bool isOpenChild = false;

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    iconColor = isOpenChild ? prefix0.accentColor : Color(0xFF263238);
    textColor = isOpenChild ? prefix0.accentColor : Color(0xFF263238);
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            if (onClickItem != null) {
              setState(() {
                isOpenChild = !isOpenChild;
              });
            }
          },
          child: Row(
            children: <Widget>[
              SizedBox(width: 59.7.w),
              Image.asset(widget.urlImg,
                  color: iconColor, // Color(0xff005a88),
                  width: width.w,
                  height: height.h),
              SizedBox(width: 45.8.w),
              Expanded(
                child: Text(widget.txt,
                    style: new TextStyle(
                      fontFamily: 'Roboto',
                      color: textColor,
                      fontWeight:
                          fontBold ? FontWeight.bold : FontWeight.normal,
                      fontSize: 50.0.sp,
                    )),
              ),
              widget.isCollSnap
                  ? Image.asset(
                      isOpenChild
                          ? "asset/images/arrow_up_3x.png"
                          : "asset/images/arrow_down.png",
                      color:
                          isOpenChild ? prefix0.accentColor : Color(0xFF263238),
                      width: 46.0.w,
                      height: 29.0.h,
                    )
                  : Container(),
              SizedBox(width: 53.7.w),
            ],
          ),
        ),
        (widget.isCollSnap && isOpenChild)
            ? SizedBox(height: 53.3.h)
            : Container(),

        //Đưa vào 1 list item, đây là ví dụ nên để riêng rẽ thế này
        (widget.isCollSnap && isOpenChild)
            ? _childItem(context, "asset/images/outline-forum-24px.png",
                "Tin nhắn riêng", onClickChildItem: () {
                appBloc.mainChatBloc.listTabStream
                    .notify(ListTabModel(tab: ListTabState.NHAN_TIN));
                appBloc.homeBloc
                    .clickItemBottomBar(1, listTabState: ListTabState.NHAN_TIN);
              })
            : Container(),
        (widget.isCollSnap && isOpenChild)
            ? _childItem(
                context,
                "asset/images/outline-supervised_user_circle-24px.png",
                "Nhóm trò chuyện", onClickChildItem: () {
                appBloc.mainChatBloc.listTabStream
                    .notify(ListTabModel(tab: ListTabState.NHOM));
                appBloc.homeBloc
                    .clickItemBottomBar(1, listTabState: ListTabState.NHOM);
              })
            : Container(),
        /*(widget.isCollSnap && isOpenChild)
            ? _childItem(context, "asset/images/outline-phone_in_talk-24px.png",
                "Gọi điện", onClickChildItem: () {
                appBloc.mainChatBloc.listTabStream
                    .notify(ListTabModel(tab: ListTabState.GOI_DIEN));
                appBloc.homeBloc
                    .clickItemBottomBar(1, listTabState: ListTabState.GOI_DIEN);
              })
            : Container(),*/
      ],
    );
  }

  _childItem(BuildContext context, String urlImg, String title,
      {VoidCallback onClickChildItem}) {
    return Container(
      color: Color(0xffe8e8e8),
      height: ScreenUtil().setHeight(177.2),
      child: GestureDetector(
        onTap: () {
          if (onClickChildItem != null) {
            Navigator.pop(context);
            onClickChildItem();
          }
        },
        child: Column(
          children: <Widget>[
            Container(
              height: 1.0,
              color: Color(0xffffffff),
            ),
            Container(
              padding: EdgeInsets.only(top: ScreenUtil().setHeight(53.5)),
              child: Row(
                children: <Widget>[
                  SizedBox(width: ScreenUtil().setWidth(184.7)),
                  Image.asset(urlImg,
                      width: ScreenUtil().setWidth(61.8),
                      height: ScreenUtil().setHeight(61.8)),
                  SizedBox(width: ScreenUtil().setWidth(54.7)),
                  Text(title,
                      style: new TextStyle(
                        fontFamily: 'Roboto',
                        color: Color(0xff263238),
                        fontSize: ScreenUtil().setSp(50.0),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
