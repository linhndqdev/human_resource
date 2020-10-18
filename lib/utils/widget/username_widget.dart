import 'package:flutter/material.dart';
import 'package:human_resource/chat/buble_chat/item_direct_room.dart';
import 'package:human_resource/core/style.dart' as prefix0;
class UserNameWidget extends StatefulWidget {
  final String name;
  final bool statusRead;

  const UserNameWidget({Key key, this.name, this.statusRead}) : super(key: key);

  @override
  _UserNameWidgetState createState() => _UserNameWidgetState();
}

class _UserNameWidgetState extends State<UserNameWidget> {
  ItemRoomBloc itemRoomBloc = ItemRoomBloc();

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
              snapshot.data ?? widget.name,
              style: widget.statusRead
                  ? prefix0.textStyleNewMsg
                  : prefix0.textStyleOldMsg,
            );
          }),
    );
  }
}