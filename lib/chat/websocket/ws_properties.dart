const String DOMAIN_PROD = "ws://18.139.16.74:3000/websocket";//Dùng cho production
const String DOMAIN_DEV= "ws://18.141.67.43:3002/websocket";//Chỉ dùng cho bản DEV

class Key {
  static const String SERVER_ID = "server_id";
  static const String MSG = "msg";
  static const String SESSION = "session";
  static const String EVENT_NAME = "eventName";
  static const String ARGS = "args";
  static const String FIELDS = "fields";
  static const String REASON = "reason";
  static const String RESULT = "result";
  static const String ERROR = "error";
  static const String COLLECTION = "collection";
  static const String MESSAGES = "messages";
  static const String LASTMESSAGES = "lastMessage";
  static const String ACTIONS = "actions";
  static const String MESSAGESID = "actions";
  static const String ID = "_id";
}

class Event{
  static const String NOTIFY_USER = "stream-notify-user";
  static const String ROOM_CHANGE = "rooms-changed";
  static const String NOTIFY_LOGGED = "stream-notify-logged";
  static const String NOTIFY_ROOM = "stream-notify-room";
  //collection nhận được khi thu hồi tin nhắn
  static const String STREAM_ROOM_MESSAGE = "stream-room-messages";
  static const String REVOKE_MESSAGE_ACTIONS = "actions_message_com.asgl.human_resource";

  static const String USER_STATUS = "user-status";
  static const String TYPING = "/typing";
}

class MsgValue {
  static const String CONNECTED = "connected";
  static const String ADDED = "added";
  static const String RESULT = "result";
  static const String PING = "ping";
  static const String CHANGED = "changed";
  static const String ERROR = "error";
}
//Error

class Error {
  static const String SOCKET_EXCEPTION = "SocketException";
  static const String NETWORK_UNREACHABLE = "Network is unreachable";
  static const String FAILED_HOST_LOOKUP = "Failed host lookup";
  static const String ALREADY_CONNECTED = "Already connected";
  static const String USER_NOT_FOUND = "User not found";
  static const String DUPLICATE_CHANNEL = "error-duplicate-channel-name";
}

const String MESSAGE = "message";
