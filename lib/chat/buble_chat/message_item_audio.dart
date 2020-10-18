import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_attachment.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/utils/common/const.dart';

import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/utils/widget/custom_seekbar.dart';
import 'package:human_resource/utils/widget/loading_circle.dart';
import 'package:human_resource/utils/widget/loading_indicator.dart';
import 'package:just_audio/just_audio.dart';
import 'package:human_resource/core/style.dart' as prefix0;

import 'message_item_audio_bloc.dart';

class MessageItemAudio extends StatefulWidget {
  final WsMessage message;
  final bool isShowTime;
  final double marginTop;
  final bool isShowAvatar;
  final bool isOwner; //Tin nhắn của tài khoản này
  final String baseUrl;
  final WsRoomModel roomModel;
  final String userFullName;

  const MessageItemAudio(
      {Key key,
      @required this.baseUrl,
      this.message,
      this.isShowTime = true,
      this.marginTop = 0.0,
      this.isShowAvatar = false,
      this.isOwner = false,
      this.roomModel,
      this.userFullName})
      : super(key: key);

  @override
  _MessageItemAudioState createState() => _MessageItemAudioState();
}

class _MessageItemAudioState extends State<MessageItemAudio>
    with AutomaticKeepAliveClientMixin {
  MessageItemAudioBloc messageAudioBloc = MessageItemAudioBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    messageAudioBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Container(
        alignment: AlignmentDirectional.center,
        margin: EdgeInsets.only(top: widget.marginTop),
        child: Column(
          crossAxisAlignment: widget.isOwner
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            widget.isOwner ? buildRTL() : buildLTR(),
            widget.isShowTime
                ? SizedBox(
                    height: ScreenUtil().setHeight(16.1),
                  )
                : Container(),
            widget.message.isSending
                ? Container(
                    width: 20.0,
                    height: 20.0,
                    child: LoadingWidget(),
                  )
                : widget.isShowTime
                    ? Padding(
                        padding: EdgeInsets.only(
                            left: ScreenUtil()
                                .setWidth(widget.isOwner ? 0.0 : 178.9),
                            right: ScreenUtil()
                                .setWidth(widget.isOwner ? 74.4 : 0.0)),
                        child: Text(
                          DateTimeFormat.convertTimeMessageItem(
                              widget.message.ts),
                          style: TextStyle(
                            fontFamily: "Roboto-Regular",
                            color: prefix0.blackColor.withOpacity(0.4),
                            fontSize: ScreenUtil().setSp(30.0),
                          ),
                        ),
                      )
                    : Container(),
            SizedBox(
              height: ScreenUtil().setHeight(21.8),
            )
          ],
        ),
      ),
    );
  }

  Widget buildRTL() {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: buildContentMessage(
            Alignment.bottomRight,
            prefix0.accentColor,
            [
              BoxShadow(
                spreadRadius: 0.0,
                blurRadius: SizeRender.renderBorderSize(context, 25.0),
                color: Colors.black.withOpacity(0.12),
                offset: Offset(
                  0.0, // horizontal, move right 10
                  13, // vertical, move down 10
                ),
              )
            ],
            Colors.white,
          ),
        ),
      ],
    );
  }

  Widget buildLTR() {
    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: <Widget>[
        buildAvatar(),
        Align(
          alignment: Alignment.centerLeft,
          child: buildContentMessage(
            Alignment.bottomLeft,
            prefix0.grey1Color,
            null,
            Colors.black,
          ),
        )
      ],
    );
  }

  Widget buildLTRTyping() {
    return Stack(
      children: <Widget>[
        buildAvatar(),
        Container(
          width: 100.0,
          margin: EdgeInsets.only(left: 60.0, right: 60.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.all(1.0),
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.0,
                      blurRadius: 16.7,
                      color: Colors.black.withOpacity(0.12),
                      offset: Offset(
                        0.0, // horizontal, move right 10
                        8.7, // vertical, move down 10
                      ),
                    )
                  ],
                  color: prefix0.whiteColor,
                  borderRadius: BorderRadius.circular(10.4),
                ),
                child: Container(
                  constraints: BoxConstraints(minWidth: 100.0, minHeight: 40.0),
                  child: LoadingIndicator(
                    color: prefix0.accentColor,
                    size: SizeRender.renderBorderSize(context, 30),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildAvatar() {
    if (widget.roomModel.roomType == RoomType.p) {
      if (widget.roomModel.name == Const.BAN_TIN) {
        return Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(63.1),
                top: ScreenUtil().setHeight(16.6)),
            child: Image.asset("asset/images/group_10128.png",
                width: ScreenUtil().setWidth(80.0),
                height: ScreenUtil().setHeight(80.0)));
      } else if (widget.roomModel.name.contains(Const.THONG_BAO)) {
        return Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(63.1),
                top: ScreenUtil().setHeight(16.6)),
            child: Image.asset("asset/images/group-10353@3x.png",
                width: ScreenUtil().setWidth(80.0),
                height: ScreenUtil().setHeight(80.0)));
      } else if (widget.roomModel.name == Const.FAQ) {
        return Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(63.1),
                top: ScreenUtil().setHeight(16.6)),
            child: Image.asset("asset/images/group_9906.png",
                width: ScreenUtil().setWidth(80.0),
                height: ScreenUtil().setHeight(80.0)));
      } else {
        return widget.isShowAvatar
            ? Container(
                margin: EdgeInsets.only(left: ScreenUtil().setWidth(79.0)),
                child: CustomCircleAvatar(
                  position: ImagePosition.GROUP,
                    userName: widget?.message?.skAccountModel?.userName),
              )
            : Container();
      }
    } else {
      return widget.isShowAvatar
          ? Container(
              margin: EdgeInsets.only(left: ScreenUtil().setWidth(79.0)),
              child: CustomCircleAvatar(
                position: ImagePosition.GROUP,
                  userName: widget?.message?.skAccountModel?.userName),
            )
          : Container();
    }
  }

  Widget buildContentMessage(Alignment timeAlign, Color color,
      List<BoxShadow> boxShadow, Color textColor) {
    WsAudioFile audioFile = widget.message.wsAttachments[0] as WsAudioFile;
    messageAudioBloc?.initAudio(widget.baseUrl, audioFile.audio_url);
    return Container(
      margin: EdgeInsets.only(
          left: ScreenUtil().setWidth(176.6),
          right: ScreenUtil().setWidth(74.5)),
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        boxShadow: boxShadow,
        color: color,
      ),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
                SizeRender.renderBorderSize(context, 16.0)),
            color: widget.isOwner ? prefix0.accentColor : prefix0.whiteColor),
        height: ScreenUtil().setHeight(83.0),
        width: 165.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
                initialData: AudioPlaybackState.none,
                stream: messageAudioBloc?.stateStream?.stream,
                builder: (stateContext,
                    AsyncSnapshot<AudioPlaybackState> snapshotData) {
                  return _buildIconChangeState(snapshotData.data);
                }),
            SizedBox(
              width: ScreenUtil().setWidth(20.0),
            ),
            StreamBuilder(
                initialData: 0.0,
                stream: messageAudioBloc?.percentStream?.stream,
                builder: (stateContext, AsyncSnapshot<double> snapshotData) {
                  return Container(
                    width: ScreenUtil().setWidth(240.7),
                    child: CustomSeekBar(
                      percent: snapshotData.data,
                      dotColor: widget.isOwner
                          ? prefix0.whiteColor
                          : prefix0.blackColor,
                      lineColor: widget.isOwner
                          ? prefix0.whiteColor.withOpacity(0.5)
                          : prefix0.blackColor.withOpacity(0.6),
                    ),
                  );
                }),
            SizedBox(
              width: ScreenUtil().setWidth(11.3),
            ),
            StreamBuilder(
                initialData: "--:--",
                stream: messageAudioBloc?.positionStream?.stream,
                builder: (timeContext, AsyncSnapshot<String> timeSnapshot) {
                  return _buildAudioTime(timeSnapshot.data);
                }),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildIconChangeState(AudioPlaybackState data) {
    if (data == AudioPlaybackState.connecting ||
        data == AudioPlaybackState.buffering ||
        data == AudioPlaybackState.none) {
      return Container(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(prefix0.accentColor),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          messageAudioBloc?.changeStateAudio();
        },
        child: Icon(
          data == AudioPlaybackState.playing ? Icons.pause : Icons.play_arrow,
          color: widget.isOwner ? prefix0.whiteColor : prefix0.blackColor,
        ),
      );
    }
  }

  _buildAudioTime(String data) {
    return Text(
      data,
      style: TextStyle(
          fontFamily: "Roboto-Regular",
          fontSize: ScreenUtil().setSp(34.0),
          color: widget.isOwner ? prefix0.whiteColor : prefix0.blackColor),
    );
  }
}
