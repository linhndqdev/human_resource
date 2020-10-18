import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/common/const.dart';
import 'package:substring_highlight/substring_highlight.dart';

class TextContentMessage extends StatefulWidget {
  final Color textColor;
  final WsMessage message;
  final bool isOwner;
  final WsRoomModel wsRoomModel;
  final String shortContent;

  const TextContentMessage(
      {Key key, this.textColor, this.message, this.isOwner, this.wsRoomModel,this.shortContent})
      : super(key: key);

  @override
  _TextContentMessageState createState() => _TextContentMessageState();
}

class _TextContentMessageState extends State<TextContentMessage> {
  final TextStyle textStyleOrange = TextStyle(
      color: prefix0.orangeColor,
      fontFamily: 'Roboto-Regular',
      fontSize: 45.0.sp);
  AppBloc appBloc;

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return _buildTextContent(widget.textColor);
  }

  _buildTextContent(Color textColor) {
    if (widget.message.messageActionsModel != null &&
        widget.message.messageActionsModel.actionType == ActionType.MENTION) {
      List<TextSpan> listTextTagShow = List();
      List<TextSpan> listNormal = List();
      String msg = widget.message.messageActionsModel.msg;
      widget.message.messageActionsModel?.mentions?.mentions
          ?.forEach((userMention) {
        if (msg.contains(userMention.fullName)) {
          int index = msg.indexOf(userMention.fullName);
          TextSpan textSpan = TextSpan(
              text: userMention.fullName + " ",
              style: TextStyle(
                  color: prefix0.orangeColor,
                  fontFamily: 'Roboto-Regular',
                  fontSize: 45.0.sp));
          listTextTagShow.add(textSpan);
          if (index != 0) {
            msg =
                msg.replaceFirst(userMention.fullName, ";com.asgl.pasrer.tag;");
          } else {
            msg = msg.replaceFirst(
                userMention.fullName, ";;com.asgl.pasrer.tag;");
          }
        }
      });
      List<String> contents = msg.split(";com.asgl.pasrer.tag;");
      if (contents != null && contents.length > 0) {
        contents?.forEach((content) {
          if (content.trim().toString() != "") {
            if (content.trim().toString().contains("@all") &&
                widget.message.messageActionsModel.mentions.mentionType ==
                    MentionType.ALL) {
              if (content.trim().toString() == "@all") {
                TextSpan textSpan2 = TextSpan(
                    text: "@all ",
                    style: TextStyle(
                        color: prefix0.orangeColor,
                        fontFamily: 'Roboto-Regular',
                        fontSize: 45.0.sp));
                listNormal.add(textSpan2);
              } else {
                content = content
                    .trim()
                    .replaceFirst("@all", ";com.asgl.pasrer.tag;");
                List<String> split =
                    content.trim().split(";com.asgl.pasrer.tag;");
                List<TextSpan> childSpan = List();
                if (split.length == 0) {
                  TextSpan textSpan2 = TextSpan(
                      text: "@all ",
                      style: TextStyle(
                          color: prefix0.orangeColor,
                          fontFamily: 'Roboto-Regular',
                          fontSize: 45.0.sp));
                  childSpan.add(textSpan2);
                } else if (split.length == 1) {
                  if (split[0].trim().toString() != "") {
                    TextSpan textSpan = TextSpan(
                        text: split[0] + " ",
                        style: TextStyle(
                            color: widget.isOwner
                                ? prefix0.white
                                : prefix0.blackColor333,
                            fontFamily: 'Roboto-Regular',
                            fontSize: 45.0.sp));
                    childSpan.add(textSpan);
                  }
                  TextSpan textSpan2 = TextSpan(
                      text: "@all",
                      style: TextStyle(
                          color: prefix0.orangeColor,
                          fontFamily: 'Roboto-Regular',
                          fontSize: 45.0.sp));
                  childSpan.add(textSpan2);
                } else if (split.length == 2) {
                  if (split[0].trim().toString() != "") {
                    TextSpan textSpan = TextSpan(
                        text: split[0],
                        style: TextStyle(
                            color: widget.isOwner
                                ? prefix0.white
                                : prefix0.blackColor333,
                            fontFamily: 'Roboto-Regular',
                            fontSize: 45.0.sp));
                    childSpan.add(textSpan);
                  }
                  TextSpan textSpan2 = TextSpan(
                      text: "@all",
                      style: TextStyle(
                          color: prefix0.orangeColor,
                          fontFamily: 'Roboto-Regular',
                          fontSize: 45.0.sp));
                  childSpan.add(textSpan2);
                  if (split[1].trim().toString() != "") {
                    TextSpan textSpan3 = TextSpan(
                        text: split[1],
                        style: TextStyle(
                            color: widget.isOwner
                                ? prefix0.white
                                : prefix0.blackColor333,
                            fontFamily: 'Roboto-Regular',
                            fontSize: 45.0.sp));
                    childSpan.add(textSpan3);
                  }
                } else {
                  TextSpan textSpan3 = TextSpan(
                      text: "@all",
                      style: TextStyle(
                          color: widget.isOwner
                              ? prefix0.white
                              : prefix0.blackColor333,
                          fontFamily: 'Roboto-Regular',
                          fontSize: 45.0.sp));
                  childSpan.add(textSpan3);
                }
                TextSpan addSpan = TextSpan(children: childSpan);
                listNormal.add(addSpan);
              }
            } else {
              TextSpan textSpan = TextSpan(
                  text: content,
                  style: TextStyle(
                      color: widget.isOwner
                          ? prefix0.white
                          : prefix0.blackColor333,
                      fontFamily: 'Roboto-Regular',
                      fontSize: 45.0.sp));
              listNormal.add(textSpan);
            }
          }
        });
      }

      List<TextSpan> mergeList = List();
      if (listNormal == null || listNormal.length == 0) {
        mergeList.addAll(listNormal);
      } else {
        int size = listTextTagShow.length > listNormal.length
            ? listTextTagShow.length
            : listNormal.length;
        for (int i = 0; i < size; i++) {
          if (i < listNormal.length) {
            if (i == 0) {
              if (contents[0] != ";") {
                mergeList.add(listNormal[i]);
              }
            } else {
              mergeList.add(listNormal[i]);
            }
          }

          if (i < listTextTagShow.length) {
            mergeList.add(listTextTagShow[i]);
          }
        }
      }
      return RichText(text: TextSpan(children: mergeList));
    }
    if (widget.wsRoomModel.name == Const.BAN_TIN ||
        widget.wsRoomModel.name.contains(Const.THONG_BAO)) {
      return StreamBuilder(
          initialData: appBloc.mainChatBloc.chatBloc.searchData,
          stream: appBloc.mainChatBloc.chatBloc.searchDataStream.stream,
          builder:
              (BuildContext searchContext, AsyncSnapshot<String> snapshot) {
            return StreamBuilder(
                initialData:LoadMoreTextModel(widget.message, appBloc.mainChatBloc.checkLongContent(widget.message.msg)),
                stream: appBloc.mainChatBloc.loadMoreTextStream
                    .stream.where((f) =>
                    f.wsMessage.id.contains(widget.message.id)
                ),
                builder: (context, snapshot) {

                  switch (snapshot.data.loadMoreTextState) {
                    case LoadMoreTextState.HAVEDATA:
                      return Text(
                        appBloc.mainChatBloc
                            .covertTextSoLong(widget.shortContent),
                        style: TextStyle(
                          fontFamily: "Roboto-Regular",
                          color: prefix0.blackColor333,
                          fontSize: 45.sp,
                        ),
                      );
                      break;
                    default:
                      return Text(
                        widget.shortContent,
                        style: TextStyle(
                          fontFamily: "Roboto-Regular",
                          color: prefix0.blackColor333,
                          fontSize: 45.sp,
                        ),
                      );
                      break;
                  }
                });
          });
    } else {
      return StreamBuilder(
          initialData: appBloc.mainChatBloc.chatBloc.searchData,
          stream: appBloc.mainChatBloc.chatBloc.searchDataStream.stream,
          builder:
              (BuildContext searchContext, AsyncSnapshot<String> snapshot) {
            return SubstringHighlight(
              text: _getContent(),
              term: snapshot?.data?.trim() ?? "",
              textStyleHighlight: TextStyle(
                  fontFamily: 'Roboto-Regular',
                  color: Colors.red,
                  fontSize: 45.0.sp),
              textStyle: TextStyle(
                  fontFamily: 'Roboto-Regular',
                  color: textColor,
                  fontSize: 45.0.sp),
            );
          });
    }
  }

  String _getContent() {
    if (widget.message.messageActionsModel != null &&
        widget.message.messageActionsModel.actionType == ActionType.NONE) {
      if (widget.message.messageActionsModel.isEdited) {
        return widget.message.messageActionsModel.msg;
      } else {
        return widget.message.msg;
      }
    } else {
      return widget.message.msg;
    }
  }
}
