import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/common/datetime_format.dart';

class QuoteActionWidget extends StatefulWidget {
  final MessageActionsModel messageActionsModel;
  final VoidCallback onDisableQuote;

  const QuoteActionWidget(
      {Key key, this.messageActionsModel, this.onDisableQuote})
      : super(key: key);

  @override
  _QuoteActionWidgetState createState() => _QuoteActionWidgetState();
}

class _QuoteActionWidgetState extends State<QuoteActionWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.messageActionsModel.quote.quoteType == "TEXT") {
      return _buildQuoteTextMessage();
    } else if (widget.messageActionsModel.quote.quoteType == "IMAGE") {
      return _buildQuoteImageMessage();
    } else {
      return Container();
    }
  }

  Widget _buildQuoteTextMessage() {
    return Container(
      color: Color(0xFFe8e8e8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 58.0.w, top: 7.0.h),
                  child: Image.asset(
                    "asset/images/action/ic_quote_check.png",
                    width: 48.0.w,
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 5.0.w,
                      top: 19.0.h,
                    ),
                    child: Text(
                      widget.messageActionsModel.quote.contentQuote,
                      style: TextStyle(
                          fontFamily: "Roboto-Italic",
                          fontStyle: FontStyle.italic,
                          fontSize: 45.0.sp,
                          color: prefix0.blackColor333),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(
                  width: 41.9.w,
                ),
                InkWell(
                  onTap: () {
                    widget.onDisableQuote();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 21.5.h, right: 59.0.w),
                    child: Icon(
                      Icons.clear,
                      color: prefix0.accentColor,
                      size: 22.0,
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: 48.0.w, top: 7.6.h, right: 133.0.w, bottom: 22.4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text:
                            "${widget.messageActionsModel.quote.ownerMessage} ",
                        style: TextStyle(
                            fontFamily: "Roboto-BoldItalic",
                            fontStyle: FontStyle.italic,
                            fontSize: 25.0.sp,
                            fontWeight: FontWeight.bold,
                            color: prefix0.color959ca7),
                      ),
                      TextSpan(
                        text: DateTimeFormat.convertTimeMessageItem(int.parse(
                            widget.messageActionsModel.quote.timeOfMessage)),
                        style: TextStyle(
                            fontFamily: "Roboto-Italic",
                            fontStyle: FontStyle.italic,
                            fontSize: 25.0.sp,
                            color: prefix0.color959ca7),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteImageMessage() {
    return Container(
      color: Color(0xFFe8e8e8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 58.0.w, top: 7.0.h),
                  child: Image.asset(
                    "asset/images/action/ic_quote_check.png",
                    width: 48.0.w,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20.0.w, top: 20.0.h),
                  child: CachedNetworkImage(
                    imageUrl: widget.messageActionsModel.quote.quoteImageUrl,
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
                    width: 80.0.w,
                  ),
                ),
                SizedBox(
                  width: 41.9.w,
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 5.0.w,
                      top: 19.0.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          widget.messageActionsModel.quote.ownerMessage,
                          style: TextStyle(
                              fontFamily: "Roboto-Italic",
                              fontStyle: FontStyle.italic,
                              fontSize: 45.0.sp,
                              color: prefix0.blackColor333),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: 50.0.h,
                        ),
                        Text(
                          "[ Hình ảnh ]",
                          style: TextStyle(
                              fontFamily: "Roboto-Italic",
                              fontStyle: FontStyle.italic,
                              fontSize: 45.0.sp,
                              color: prefix0.blackColor333),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 41.9.w,
                ),
                InkWell(
                  onTap: () {
                    widget.onDisableQuote();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 21.5.h, right: 59.0.w),
                    child: Icon(
                      Icons.clear,
                      color: prefix0.accentColor,
                      size: 22.0,
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                left: 48.0.w, top: 7.6.h, right: 133.0.w, bottom: 22.4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text:
                            "${widget.messageActionsModel.quote.ownerMessage} ",
                        style: TextStyle(
                            fontFamily: "Roboto-BoldItalic",
                            fontStyle: FontStyle.italic,
                            fontSize: 25.0.sp,
                            fontWeight: FontWeight.bold,
                            color: prefix0.color959ca7),
                      ),
                      TextSpan(
                        text: DateTimeFormat.convertTimeMessageItem(int.parse(
                            widget.messageActionsModel.quote.timeOfMessage)),
                        style: TextStyle(
                            fontFamily: "Roboto-Italic",
                            fontStyle: FontStyle.italic,
                            fontSize: 25.0.sp,
                            color: prefix0.color959ca7),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
