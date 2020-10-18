import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:human_resource/chat/buble_chat/item_direct_room.dart';
import 'package:human_resource/core/style.dart' as prefix0;

class ChatUserNameAppBar extends StatefulWidget {
  final String name;

  const ChatUserNameAppBar({Key key, this.name}) : super(key: key);

  @override
  _ChatUserNameAppBarState createState() => _ChatUserNameAppBarState();
}

class _ChatUserNameAppBarState extends State<ChatUserNameAppBar> {
  ItemRoomBloc itemRoomBloc = ItemRoomBloc();
  @override
  void didUpdateWidget(ChatUserNameAppBar oldWidget) {
    if(oldWidget.name!= widget.name){
     itemRoomBloc.getUserInfo(context, widget.name);
    }else {
      super.didUpdateWidget(oldWidget);
    }
  }
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      itemRoomBloc.getUserInfo(context, widget.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
          initialData: widget.name,
          stream: itemRoomBloc.showNameStream.stream,
          builder: (buildContext, AsyncSnapshot<String> snapshot) {
            return Text(
              snapshot.data,
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: prefix0.white,
                  fontSize: ScreenUtil().setSp(50.0),
                  fontFamily: "Roboto-Regular"),
            );
          }),
    );
  }
}
