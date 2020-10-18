import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/model/home_model.dart';

class HomeIndexStackModel {
  int indexStack;
  HomeModel homeModel;
  HomeChildModel homeChildModel;

  HomeIndexStackModel(
      {this.indexStack,
      this.homeModel,
      this.homeChildModel,
      this.roomModel,});

  WsRoomModel roomModel;
}
