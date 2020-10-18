import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/utils/animation/ZoomInAnimation.dart';
import 'package:human_resource/utils/common/audio_record_helper.dart';
import 'package:flutter/material.dart';

//import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:just_audio/just_audio.dart';
import 'package:human_resource/core/style.dart' as prefix0;

typedef OnDestroy = Function();
typedef OnErrorPermission = Function();
typedef OnCancelBottomSheet = Function();

class RecordWidget extends StatefulWidget {
  final String roomID;
  final OnDestroy onDestroy;
  final OnCancelBottomSheet onCancelBottomSheet;

  const RecordWidget(
      {Key key,
      @required this.roomID,
      @required this.onDestroy,
      this.onCancelBottomSheet})
      : super(key: key);

  @override
  _RecordWidgetState createState() => _RecordWidgetState();
}

class _RecordWidgetState extends State<RecordWidget> {
  AudioRecordHelper recordHelper = AudioRecordHelper();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      recordHelper.prepare(errorCallBack: (error) {
        _showDialogError(error);
      });
    });
  }

  @override
  void dispose() {
    recordHelper?.close();
    widget?.onDestroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(466.0),
      child: StreamBuilder(
        stream: recordHelper.replayAudioStream.stream,
        initialData: false,
        builder: (replayContext, AsyncSnapshot<bool> statusSnapshot) {
          if (statusSnapshot.data) {
            return _buildLayoutReplay();
          } else {
            return _buildLayoutRecord();
          }
        },
      ),
    );
  }

  _buildLayoutRecord() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil().setHeight(466.0),
      color: Color(0xFFf2f1f1),
      child: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: ScreenUtil().setHeight(68.0),
          ),
          buildTimeRecord(),
          SizedBox(
            height: ScreenUtil().setHeight(23.2),
          ),
          /*ClipOval(
            child: Material(
              color: Colors.white, // button color
              child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: StreamBuilder(
                  stream: recordHelper.recordingStatusStream.stream,
                  builder: (statusContext,
                      AsyncSnapshot<RecordingStatus> statusSnapshot) {
                    if (!statusSnapshot.hasData ||
                        statusSnapshot.data == null) {
                      return Image.asset(
                        "asset/images/ic_record.png",
                        width: ScreenUtil().setWidth( 160.0),
                      );
                    } else {
                      switch (statusSnapshot.data) {
                        case RecordingStatus.Recording:
                          return Image.asset(
                            "asset/images/ic_stop_record.png",
                            width: ScreenUtil().setWidth( 160.0),
                          );
                          break;
                        default:
                          return Image.asset(
                            "asset/images/ic_record.png",
                            width: ScreenUtil().setWidth( 160.0),
                          );
                          break;
                      }
                    }
                  },
                ),
                onTap: () async {
                  recordHelper.notify();
                },
              ),
            ),
          ),*/
          /*Padding(
            padding: EdgeInsets.only(
                top: ScreenUtil().setHeight( 24.0)),
            child: StreamBuilder(
              stream: recordHelper.recordingStatusStream.stream,
              builder: (statusContext,
                  AsyncSnapshot<RecordingStatus> statusSnapshot) {
                if (!statusSnapshot.hasData || statusSnapshot.data == null) {
                  return Text(
                    "Tối đa 30 giây",
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontFamily: "Roboto-Regular",
                      fontSize: ScreenUtil().setSp( 44.0),
                    ),
                  );
                } else {
                  switch (statusSnapshot.data) {
                    case RecordingStatus.Recording:
                      return Text(
                        "Ấn để dừng ghi âm",
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontFamily: "Roboto-Regular",
                          fontSize: ScreenUtil().setSp( 44.0),
                        ),
                      );
                      break;
                    default:
                      return Text(
                        "Tối đa 30 giây",
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontFamily: "Roboto-Regular",
                          fontSize: ScreenUtil().setSp( 44.0),
                        ),
                      );
                      break;
                  }
                }
              },
            ),
          ),*/
        ],
      )),
    );
  }

  _buildLayoutReplay() {
    return Container(
      color: prefix0.white,
      width: MediaQuery.of(context).size.width,
      height: ScreenUtil().setHeight(466.0),
      padding: EdgeInsets.only(
        left: ScreenUtil().setWidth(76.0),
        right: ScreenUtil().setWidth(76.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: () {
              recordHelper.tryRecording();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  "asset/images/ic_re_record.png",
                  width: ScreenUtil().setWidth(75.0),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(12.4),
                ),
                Text(
                  "Ghi lại",
                  style: TextStyle(
                      fontFamily: 'Roboto-Regular',
                      color: prefix0.blackColor333,
                      fontSize: ScreenUtil().setSp(44.0)),
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder(
                initialData: recordHelper.audioMaxTime,
                stream: recordHelper?.audioPlayer?.getPositionStream(),
                builder:
                    (percentContext, AsyncSnapshot<Duration> percentSnapshot) {
                  double _percent = 0.0;
                  if (recordHelper.audioMaxTime == null) {
                    _percent = 0.0;
                  } else {
                    _percent = (percentSnapshot.data.inMicroseconds /
                        recordHelper.audioMaxTime.inMicroseconds);
                    if (_percent > 1.0) _percent = 1.0;
                  }
                  return Container();
                  //_buildAudioTime(
                  // recordHelper?.audioPlayer?.playerState?.state ==
                  //         AudioPlaybackState.playing
                  //   ? percentSnapshot.data
                  //   : recordHelper.audioMaxTime);
                },
              ),
              SizedBox(
                height: ScreenUtil().setHeight(23.2),
              ),
              StreamBuilder(
                stream: recordHelper?.audioPlayer?.playbackStateStream,
                initialData: AudioPlaybackState.none,
                builder: (audioStateContext,
                    AsyncSnapshot<AudioPlaybackState> stateSnapshot) {
                  if (stateSnapshot.data == AudioPlaybackState.playing ||
                      stateSnapshot.data == AudioPlaybackState.buffering) {
                    return InkWell(
                      onTap: () {
                        recordHelper?.changeStateAudioPlayer();
                      },
                      child: Image.asset(
                        "asset/images/ic_pause_audio.png",
                        color: prefix0.accentColor,
                        width: ScreenUtil().setWidth(154.8),
                      ),
                    );
                  } else {
                    return InkWell(
                      onTap: () {
                        recordHelper?.changeStateAudioPlayer();
                      },
                      child: Image.asset(
                        "asset/images/ic_play_audio.png",
                        width: ScreenUtil().setWidth(154.8),
                      ),
                    );
                  }
                },
              ),
              SizedBox(
                height: ScreenUtil().setHeight(21.0),
              ),
              StreamBuilder(
                stream: recordHelper?.audioPlayer?.playbackStateStream,
                initialData: AudioPlaybackState.none,
                builder: (audioStateContext,
                    AsyncSnapshot<AudioPlaybackState> stateSnapshot) {
                  if (stateSnapshot.data == AudioPlaybackState.playing ||
                      stateSnapshot.data == AudioPlaybackState.buffering) {
                    return Text(
                      "Ấn để tắt",
                      style: TextStyle(
                        fontFamily: 'Roboto-Regular',
                        color: prefix0.blackColor333,
                        fontSize: ScreenUtil().setSp(44.0),
                      ),
                    );
                  } else {
                    return Text(
                      "Ấn để nghe lại",
                      style: TextStyle(
                        fontFamily: 'Roboto-Regular',
                        color: prefix0.blackColor333,
                        fontSize: ScreenUtil().setSp(44.0),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          InkWell(
            onTap: () {
              recordHelper.sendAudioToRoom(context, widget.roomID);
              widget.onCancelBottomSheet();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  "asset/images/ic_send_audio.png",
                  width: ScreenUtil().setWidth(75.0),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(12.4),
                ),
                Text(
                  "Gửi ngay",
                  style: TextStyle(
                      fontFamily: 'Roboto-Regular',
                      color: prefix0.blackColor333,
                      fontSize: ScreenUtil().setSp(44.0)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildAudioTime(Duration duration) {
    return Text(
      DateTimeFormat.convertDurationToDateTime(duration),
      style: TextStyle(color: prefix0.blackColor333),
    );
  }

  _showDialogError(AudioHelperError error) async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (buildContext) {
          return ZoomInAnimation(
            Dialog(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      error == AudioHelperError.PERMISSION_ERROR
                          ? "Chúng tôi cần bạn cho phép quyền đọc/ghi dữ liệu từ bộ nhớ và quyền truy cập Micro trên thiết bị để hoàn thành hành động này."
                          : "Đã có lỗi xảy ra vui lòng thử lại.",
                      style: prefix0.text11ColorBDRoboto,
                    ),
                    Row(
                      children: <Widget>[
                        FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Xác nhận",
                              style: TextStyle(
                                  color: prefix0.accentColor, fontSize: 16.0),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  buildTimeRecord() {
    return StreamBuilder(
        initialData: "Nhấn để ghi âm",
        stream: recordHelper.recordingCountDownTimeStream.stream,
        builder: (timeContext, AsyncSnapshot<String> timeSnapshot) {
          return Text(
            timeSnapshot.data,
            style: TextStyle(
                color: Color(0xFF333333),
                fontFamily: "Roboto-Regular",
                fontSize: ScreenUtil().setSp(44.0)),
          );
        });
  }
}
