import 'package:flutter/material.dart';

enum ActionState {
  NONE,
  WS_LOGIN,
  LOAD_HISTORY,
}

abstract class WebSocketAction {
  @protected
  void connectWithAction(ActionState actionState, {dynamic requestData});

  @protected
  void reconnect();

  @protected
  void onPong();

  @protected
  void handlerError(String error);

  @protected
  void handlerData(Map<String, dynamic> data);

  @protected
  void authWithUserNameAndPass();

  @protected
  void loadChannelHistory();

  @protected
  void enableTyping(String roomID);

  @protected
  void disableTyping(String roomID);

  @protected
  void subRoomEvent(String roomID);
}
