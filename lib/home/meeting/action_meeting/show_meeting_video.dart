import 'dart:async';

import 'package:awsome_video_player/awsome_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';

class ShowMeetingVideo extends StatefulWidget {
  final String videoUrl;

  const ShowMeetingVideo({Key key, this.videoUrl}) : super(key: key);

  @override
  _ShowMeetingVideoState createState() => _ShowMeetingVideoState();
}

class _ShowMeetingVideoState extends State<ShowMeetingVideo> {
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  set isPlaying(bool playing) {
    _isPlaying = playing;
  }

  Timer _timer;
  AppBloc appBloc;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(seconds: 10), () {
      _timer.cancel();
      DialogUtils.showDialogCompulsory(context,
          title: "Cảnh bảo",
          message: "Vui lòng kiểm tra kết nối mạng và thử lại.", onClickOK: () {
        appBloc.backStateBloc.focusWidgetModel =
            FocusWidgetModel(state: isFocusWidget.HOME);
        appBloc.homeBloc.backLayoutNotBottomBar();
      });
    });
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.SHOW_VIDEO_MEETING);
    return WillPopScope(
      onWillPop: () {
        if (appBloc.backStateBloc.focusWidgetModel.state ==
            isFocusWidget.SHOW_VIDEO_MEETING) {
          appBloc.backStateBloc.focusWidgetModel =
              FocusWidgetModel(state: isFocusWidget.HOME);
          appBloc.homeBloc.backLayoutNotBottomBar();
        }
        return null;
      },
      child: RotatedBox(
        quarterTurns: 3,
        child: Scaffold(
          body: widget.videoUrl != ""
              ? AwsomeVideoPlayer(
                  widget.videoUrl,
                  playOptions: VideoPlayOptions(
                      aspectRatio: MediaQuery.of(context).size.height /
                          MediaQuery.of(context).size.width,
                      seekSeconds: 30,
                      brightnessGestureUnit: 0.05,
                      volumeGestureUnit: 0.05,
                      progressGestureUnit: 2000,
                      loop: true,
                      autoplay: true,
                      allowScrubbing: true,
                      startPosition: Duration(seconds: 0)),
                  videoStyle: VideoStyle(
                    replayIcon: Icon(Icons.pause),
                    playIcon: Icon(
                      Icons.play_circle_outline,
                      size: 80,
                      color: Colors.white,
                    ),
                    showPlayIcon: true,
                    videoLoadingStyle: VideoLoadingStyle(
                      loadingText: "Loading...",
                      loadingTextFontColor: Colors.white,
                      loadingTextFontSize: 20,
                    ),
                    videoTopBarStyle: VideoTopBarStyle(
                      customBar: Container(
                        margin:
                            EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
                        child: InkWell(
                          onTap: () {
                            appBloc.backStateBloc.focusWidgetModel =
                                FocusWidgetModel(state: isFocusWidget.HOME);
                            appBloc.homeBloc.backLayoutNotBottomBar();
                          },
                          child: Icon(
                            Icons.arrow_back,
                            size: 40.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      show: true,
                      height: 40,
                      barBackgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
                    ),
                    videoControlBarStyle: VideoControlBarStyle(
                      margin: EdgeInsets.only(right: 24.0, bottom: 5.0),
                      height: 30,
                      playIcon:
                          Icon(Icons.play_arrow, color: Colors.white, size: 16),
                      pauseIcon: Icon(
                        Icons.pause,
                        color: Colors.white,
                        size: 16,
                      ),
                      forwardIcon: Container(),
                      itemList: [
                        "play",
                        "position-time",
                        "progress",
                        "duration-time", //视频总时长
                      ],
                    ),
                  ),
                  oninit: (controller) {
                    if (controller != null) {
                      _timer?.cancel();
                      _timer = null;
                    }
                  },
                  onnetwork: (data) {},
                  onpause: (value) {},
                  onplay: (value) {},
                  onended: (value) {},
                  ontimeupdate: (value) {},
                  onprogressdrag: (position, duration) {},
                  onvolume: (value) {},
                  onbrightness: (value) {},
                  onfullscreen: (fullscreen) {},
                )
              : AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  ),
                ),
        ),
      ),
    );
  }
}
