import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:human_resource/chat/screen/main_chat/chat/chat_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/size_extension.dart';

typedef OnClick = Function(bool);

class ButtonOpenOrClose extends StatefulWidget {
  final OnClick onClick;

  const ButtonOpenOrClose({Key key, this.onClick}) : super(key: key);

  @override
  _ButtonOpenOrCloseState createState() => _ButtonOpenOrCloseState();
}

class _ButtonOpenOrCloseState extends State<ButtonOpenOrClose> {
  ChatBloc chatBloc;

  @override
  Widget build(BuildContext context) {
    chatBloc = BlocProvider.of(context).mainChatBloc.chatBloc;
    return StreamBuilder(
        initialData: true,
        stream: chatBloc.showActionChatStream.stream,
        builder: (buildContext, AsyncSnapshot<bool> showActionSnap) {
          return Container(
            height: 129.0.h,
            margin: EdgeInsets.only(
              left: ScreenUtil().setWidth(60.0),
              right: ScreenUtil().setWidth(29),
            ),
            child: InkWell(
                onTap: () async {
                  widget.onClick(showActionSnap.data);
                },
                child: Container(
                  width: ScreenUtil().setWidth(73.0),
                  height: ScreenUtil().setHeight(73.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: !showActionSnap.data
                          ? prefix0.grey1Color
                          : prefix0.orangeColor),
                  child: !showActionSnap.data
                      ? Icon(Icons.add, color: prefix0.accentColor)
                      : Icon(
                          Icons.chevron_left,
                          color: prefix0.whiteColor,
                        ),
                )),
          );
        });
  }
}
