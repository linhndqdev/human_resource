import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/common/datetime_format.dart';

class QuoteShowWidget extends StatefulWidget {
  final WsMessage message;
  final bool isOwner;

  const QuoteShowWidget({Key key, this.message, this.isOwner})
      : super(key: key);

  @override
  _QuoteShowWidgetState createState() => _QuoteShowWidgetState();
}

class _QuoteShowWidgetState extends State<QuoteShowWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.message.messageActionsModel.quote.quoteType == "TEXT") {
      return _buildQuoteMsg();
    } else if (widget.message.messageActionsModel.quote.quoteType == "IMAGE") {
      return _buildQuoteImage();
    }
    return Container();
  }

  BorderRadius getBorder() {
    return widget.isOwner
        ? BorderRadius.only(
            topLeft: Radius.circular(35.0.w),
            topRight: Radius.circular(15.0.w),
            bottomLeft: Radius.circular(35.0.w),
            bottomRight: Radius.circular(15.0.w))
        : BorderRadius.only(
            topLeft: Radius.circular(15.0.w),
            topRight: Radius.circular(35.0.w),
            bottomLeft: Radius.circular(15.0.w),
            bottomRight: Radius.circular(35.0.w));
  }

  TextStyle getTextStyle(Color textColor) {
    if (widget.message.messageActionsModel != null &&
        widget.message.messageActionsModel.actionType == ActionType.DELETE) {
      return TextStyle(
          fontFamily: 'Roboto-Italic',
          color: Color(0xff959ca7),
          fontSize: ScreenUtil().setSp(45.0));
    }
    return TextStyle(
        fontFamily: 'Roboto-Regular',
        color: textColor,
        fontSize: ScreenUtil().setSp(45.0));
  }

  _buildQuoteMsg() {
    return Container(
        decoration:
            BoxDecoration(color: Color(0xFFe8e8e8), borderRadius: getBorder()),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: 27.0.w,
                ),
                Image.asset(
                  "asset/images/action/ic_quote_check.png",
                  width: 48.0.w,
                ),
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(top: 19.0.h),
                    child: Text(
                      widget.message.messageActionsModel.quote.contentQuote,
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 45.0.sp,
                          fontWeight: FontWeight.normal,
                          color: prefix0.blackColor333,
                          fontFamily: "Roboto-Regular"),
                    ),
                  ),
                ),
                SizedBox(
                  width: 43.0.w,
                ),
              ],
            ),
            Container(
              margin:
                  EdgeInsets.only(left: 68.9.w, right: 43.1.w, bottom: 54.4.h),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text:
                        "${widget.message.messageActionsModel.quote.ownerMessage} ",
                    style: TextStyle(
                        fontFamily: "Roboto-BoldItalic",
                        fontStyle: FontStyle.italic,
                        fontSize: 25.0.sp,
                        fontWeight: FontWeight.bold,
                        color: prefix0.color959ca7),
                  ),
                  TextSpan(
                    text: DateTimeFormat.convertTimeMessageItem(int.parse(widget
                        .message.messageActionsModel.quote.timeOfMessage)),
                    style: TextStyle(
                        fontFamily: "Roboto-Italic",
                        fontStyle: FontStyle.italic,
                        fontSize: 25.0.sp,
                        color: prefix0.color959ca7),
                  ),
                ]),
              ),
            )
          ],
        ));
  }

  _buildQuoteImage() {
    return Container(
        margin: EdgeInsets.only(top: 10.0.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              margin:
                  EdgeInsets.only(left: 68.9.w, bottom: 2.0.h),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text:
                        "${widget.message.messageActionsModel.quote.ownerMessage} ",
                    style: TextStyle(
                        fontFamily: "Roboto-BoldItalic",
                        fontStyle: FontStyle.italic,
                        fontSize: 25.0.sp,
                        fontWeight: FontWeight.bold,
                        color: prefix0.color959ca7),
                  ),
                  TextSpan(
                    text: DateTimeFormat.convertTimeMessageItem(int.parse(widget
                        .message.messageActionsModel.quote.timeOfMessage)),
                    style: TextStyle(
                        fontFamily: "Roboto-Italic",
                        fontStyle: FontStyle.italic,
                        fontSize: 25.0.sp,
                        color: prefix0.color959ca7),
                  ),
                ]),
              ),
            ),
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0.w)
              ),
              child: Container(
                width: 748.0.w,
                height: 574.0.h,
                child: CachedNetworkImage(
                  imageUrl:
                      widget.message.messageActionsModel.quote.quoteImageUrl,
                  placeholder: (buildContext, url) {
                    return Container(
                      height: 80.0.h,
                      width: 80.0.h,
                    );
                  },
                  errorWidget: (buildContext, url, error) {
                    return Container(
                      height: 80.0.h,
                      width: 80.0.h,
                    );
                  },
                  fit: BoxFit.cover,
                ),
              ),
            )
          ],
        ));
  }
}
