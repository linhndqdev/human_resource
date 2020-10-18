import 'package:flutter/material.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/common/datetime_format.dart';

class UserJoinMessage extends StatelessWidget {
  final WsMessage message;
  final String userName;
  const UserJoinMessage({Key key, this.message, this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 10.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$userName",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: prefix0.blue2,
                      fontSize: 13.0),
                ),
                TextSpan(
                    text: " tham gia phòng ",
                    style: prefix0.text12GreyDarkNormal),
                TextSpan(text: " ngày ", style: prefix0.text12GreyDarkNormal),
                TextSpan(
                  text: " ${DateTimeFormat.getDay(message.ts)} ",
                  style: TextStyle(
                      color: prefix0.greyColor,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold),
                ),
                TextSpan(text: " lúc ", style: prefix0.text12GreyDarkNormal),
                TextSpan(
                  text:
                  "${DateTimeFormat.getHourAndMinuteFrom(message.ts)} ",
                  style: TextStyle(
                      color: prefix0.greyColor,
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
