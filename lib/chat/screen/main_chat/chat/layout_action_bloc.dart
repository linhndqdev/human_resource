import 'package:human_resource/core/core_stream.dart';

enum LayoutActionState { NONE, KICK_USER, ROOM_INFO, MEMBER_PROFILE }

class LayoutActionModel {
  LayoutActionState state;
  dynamic data;

  LayoutActionModel(this.state, {this.data});
}

class LayoutActionBloc {
  CoreStream<LayoutActionModel> actionModelStream = CoreStream();
  CoreStream<int> chosenIconFeelingStream = CoreStream();

  void dispose() {
    actionModelStream?.closeStream();
    chosenIconFeelingStream?.closeStream();
  }

  void changeState(LayoutActionState actionState, {dynamic data}) {
    LayoutActionModel model = LayoutActionModel(actionState, data: data);
    actionModelStream.notify(model);
  }
}
