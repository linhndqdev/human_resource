import 'dart:async';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/utils/common/datetime_format.dart';
import 'package:just_audio/just_audio.dart';


class MessageItemAudioBloc {
  AudioPlayer audioPlayer = AudioPlayer();
  CoreStream<AudioPlaybackState> stateStream = CoreStream();
  CoreStream<String> positionStream = CoreStream();
  CoreStream<double> percentStream = CoreStream();

  String url;
  StreamSubscription<AudioPlaybackState> subState;
  StreamSubscription<Duration> subPosition;
  Duration audioDuration;
  Timer timer;

  initAudio(String baseUrl, String url) async {
    this.url = baseUrl + url;
    await audioPlayer.setUrl(this.url).then((duration) {
      String time = DateTimeFormat.convertDurationToDateTime(duration);
      audioDuration = duration;
      positionStream?.notify(time);
    });
    subState = audioPlayer?.playbackStateStream?.listen((state) {
      stateStream?.notify(state);
      if (state == AudioPlaybackState.stopped) {
        subPosition?.cancel();
        percentStream.notify(0.0);
      }
    });
  }

  void close() async {
    subState?.cancel();
    subPosition?.cancel();
    stateStream?.closeStream();
    positionStream?.closeStream();
    percentStream?.closeStream();
    await audioPlayer?.dispose();
  }

  _calculatePercent(Duration position) async {
    int maxMilSecond = audioDuration.inMilliseconds;
    int currentMilSecond = position.inMilliseconds;
    percentStream?.notify(currentMilSecond / maxMilSecond);
  }

  Future _play() async {
    subPosition = audioPlayer?.getPositionStream()?.listen((position) {
      String time = DateTimeFormat.convertDurationToDateTime(position);
      positionStream?.notify(time);
      _calculatePercent(position);
    });
    await audioPlayer.play();
  }

  Future _pause() async {
    await audioPlayer?.pause();
    subPosition?.cancel();
  }

  void changeStateAudio() {
//    if (audioPlayer?.playerState?.state == AudioPlaybackState.playing) {
//      _pause();
//    } else if (audioPlayer?.playerState?.state == AudioPlaybackState.paused) {
//      _play();
//    } else if (audioPlayer?.playerState?.state == AudioPlaybackState.stopped) {
//      _play();
//    }
  }
}
