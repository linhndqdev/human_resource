import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/core/api_respository.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';

import 'package:human_resource/core/core_stream.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';

enum AudioHelperError { PERMISSION_ERROR }

typedef OnCallBack = Function(AudioHelperError);

class AudioRecordHelper {
  String customPath;
//  FlutterAudioRecorder _recorder;
//  Recording _recording;
  final int maximumCountDownTimeRecord = 30;

//  Recording get recording => _recording;

  Timer _t;

//  CoreStream<Recording> recordingStream = CoreStream();
//  CoreStream<RecordingStatus> recordingStatusStream = CoreStream();
  CoreStream<String> recordingCountDownTimeStream = CoreStream();
  CoreStream<bool> replayAudioStream = CoreStream();

  close() {
    _t?.cancel();
    audioPlayer?.stop();
    audioPlayer?.dispose();
    replayAudioStream?.closeStream();
//    recordingStream?.closeStream();
//    recordingStatusStream?.closeStream();
    recordingCountDownTimeStream?.closeStream();
//    if (_recording?.status == RecordingStatus.Recording) stopRecording();
  }

  Future notify() async {
//    if (_recording == null) {
//      prepare();
//    } else {
//      switch (_recording.status) {
//        case RecordingStatus.Initialized:
//          _startRecording();
//          break;
//        case RecordingStatus.Recording:
//          stopRecording();
//          break;
//        case RecordingStatus.Stopped:
//          prepare();
//          break;
//        default:
//          break;
//      }
//    }
  }

  Future prepare(
      {OnCallBack errorCallBack, bool isRecordingAfterInit = false}) async {
//    var hasPermission = await FlutterAudioRecorder.hasPermissions;
//    if (hasPermission) {
//      await _init();
//      _recording = await _recorder.current();
//      replayAudioStream.notify(false);
//      recordingStatusStream.notify(_recording.status);
//      recordingCountDownTimeStream.notify(_covertCountDownTime(null));
//      if (isRecordingAfterInit) {
//        notify();
//      }
//    } else {
//      errorCallBack(AudioHelperError.PERMISSION_ERROR);
//    }
  }

  Future _init() async {
    Directory appDir;
    if (Platform.isIOS) {
      appDir = await getApplicationDocumentsDirectory();
    } else {
      appDir = await getExternalStorageDirectory();
    }
    customPath = appDir.path + DateTime.now().millisecondsSinceEpoch.toString();
//    _recorder = FlutterAudioRecorder(customPath,
//        audioFormat: AudioFormat.AAC, sampleRate: 22050);
//    await _recorder.initialized;
  }

  Future _startRecording() async {
//    await _recorder.start();
//    _recording = await _recorder.current();
//    recordingStatusStream.notify(_recording.status);
//    print(_recording.status.toString());
//    _t = Timer.periodic(Duration(seconds: 1), (Timer t) async {
//      _t = t;
//      String time = _covertCountDownTime(t.tick);
//      recordingCountDownTimeStream.notify(time);
//      print(t.tick.toString());
//      if (_t.tick == 30) {
//        _t.cancel();
//        notify();
//      }
//    });
  }

  _covertCountDownTime(int timerTick) {
    if(timerTick == null){
      return "Nhấn để ghi âm";
    }
    int count = maximumCountDownTimeRecord - timerTick;
    if (count <= 9) {
      return "00:0$count";
    } else {
      return "00:$count";
    }
  }

  Future stopRecording({bool isInitAudio = true}) async {
//    if (_recording.status == RecordingStatus.Recording) {
//      _recording = await _recorder.stop();
//    }
//    recordingStatusStream.notify(_recording.status);
//    if (isInitAudio) {
//      _initAudio();
//    }
//    _t?.cancel();
  }

  ///=============Audio replay ===============////
  AudioPlayer audioPlayer = AudioPlayer();
  Duration audioMaxTime;

  Future<void> _initAudio() async {
//    if (audioPlayer != null &&
//        _recording != null &&
//        _recording.path.isNotEmpty) {
//      audioPlayer?.stop();
//      await audioPlayer.setFilePath(_recording.path);
//      await audioPlayer.durationFuture.then((value) {
//        audioMaxTime = value;
//        replayAudioStream.notify(true);
//      });
//    }
  }

  Future<void> changeStateAudioPlayer() async {
//    if (audioPlayer.playerState.state == AudioPlaybackState.paused ||
//        audioPlayer.playerState.state == AudioPlaybackState.stopped) {
//      await audioPlayer?.play();
//    } else if (audioPlayer.playerState.state != AudioPlaybackState.paused &&
//        audioPlayer.playerState.state != AudioPlaybackState.stopped) {
//      await audioPlayer?.pause();
//    }
  }

  void tryRecording() {
    audioPlayer?.dispose();
    audioPlayer = AudioPlayer();
    prepare();
  }

  void sendAudioToRoom(BuildContext context, String roomID) {
    AppBloc appBloc = BlocProvider.of(context);
    ApiRepository repository = ApiRepository();
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
//    repository.sendAudio(
//        userID: accountModel.id,
//        roomID: roomID,
//        path: _recording.path,
//        userToken: accountModel.token,
//        uriPath: appBloc.apiBaseChat);
  }
}
