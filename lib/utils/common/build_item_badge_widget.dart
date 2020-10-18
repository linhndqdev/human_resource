import 'package:flutter/material.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/message/message_services.dart';
import 'package:flutter_screenutil/size_extension.dart';

class BuildItemBadgeWidget extends StatelessWidget {
  final TextStyle textStyle;
  final String content;
  final AppBloc appBloc;
  final WsRoomModel roomModel;
  final String groupName;
  final bool isListGroup;


  const BuildItemBadgeWidget(
      {Key key,this.textStyle, this.content,@required this.appBloc,this.roomModel,this.groupName,this.isListGroup=true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Container(
            child: Text(
              content,
              textAlign: TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
        ),
        StreamBuilder(
            initialData: isListGroup?getDefaultUnreadCountDataGroup(roomModel):getDefaultUnreadCountDataDirect(roomModel.lastMessage),
            stream: appBloc.mainChatBloc.countUnreadWithRoomIDStream.stream
                .where((model) => model.rid == roomModel.lastMessage.rid),
            builder: (buildContext, countUnReadData) {
              if (countUnReadData?.data?.unreadCount != null) {
                return countUnReadData.data.unreadCount > 0
                    ? Container(
                        alignment: Alignment.centerRight,
                        constraints: BoxConstraints(
                          minWidth: 100.w,
                        ),
                        margin: EdgeInsets.only(right: 20.0),
                        child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.w)),
                            child: Container(
                              constraints: BoxConstraints(minWidth: 50.w),
                              padding: EdgeInsets.all(7.w),
                              color: Colors.red[900],
                              child: Center(
                                child: Text(
                                  countUnReadData.data.unreadCount.toString(),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 30.sp),
                                ),
                              ),
                            )),
                      )
                    : Container(
                        constraints: BoxConstraints(
                          minWidth: 20.0,
                        ),
                      );
              } else {
                return Container(
                  constraints: BoxConstraints(
                    minWidth: 20.0,
                  ),
                );
              }
            }),
      ],
    );
  }

  UnReadCountModel getDefaultUnreadCountDataGroup(WsRoomModel roomModel) {
    UnReadCountModel defaultInitData;
    if (appBloc.mainChatBloc.mapDataCountUnread.containsKey(RoomType.p)) {
      defaultInitData = appBloc.mainChatBloc.mapDataCountUnread[RoomType.p]
          .firstWhere((model) => model.rid == roomModel.id,
          orElse: () =>
              UnReadCountModel(groupName ?? "", roomModel.id, 0, ""));
    } else {
      defaultInitData = UnReadCountModel(groupName ?? "", roomModel.id, 0, "");
    }
    return defaultInitData;
  }

  UnReadCountModel getDefaultUnreadCountDataDirect(WsMessage message) {
    UnReadCountModel defaultInitData;
    if (appBloc.mainChatBloc.mapDataCountUnread.containsKey(RoomType.d)) {
      defaultInitData = appBloc.mainChatBloc.mapDataCountUnread[RoomType.d]
          .firstWhere((model) => model.rid == message.rid,
          orElse: () => UnReadCountModel("", message.rid, 0, ""));
    } else {
      defaultInitData = UnReadCountModel("", message.rid, 0, "");
    }
    return defaultInitData;
  }
}
