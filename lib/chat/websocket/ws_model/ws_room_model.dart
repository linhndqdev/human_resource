import 'package:hive/hive.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';

part 'ws_room_model.g.dart';

@HiveType(adapterName: "RoomTypeAdapter")
enum RoomType {
  @HiveField(0)
  d, //Direct chat
  @HiveField(1)
  c, // Chat (Kênh public)
  @HiveField(2)
  p, // Private chat
  @HiveField(3)
  l, // Livechat,
  @HiveField(4)
  n, //unknow//Tự thêm vào
}

@HiveType(adapterName: "WsRoomModelAdapter")
class WsRoomModel {
  @HiveField(0)
  String id; //key _
  @HiveField(1) // id
  String name;
  @HiveField(2)
  String fname;
  @HiveField(3)
  RoomType roomType;
  @HiveField(4)
  int usersCount;
  @HiveField(5)
  WsAccountModel skAccountModel;
  @HiveField(6)
  bool broadcast;
  @HiveField(7)
  bool encrypted;
  @HiveField(8)
  bool ro;
  @HiveField(9)
  bool sysMes;
  @HiveField(10)
  int updatedAt;
  @HiveField(11)
  WsMessage lastMessage;
  @HiveField(12)
  List<String> listUserDirect;
  @HiveField(13)
  int msgs;
  @HiveField(14)
  int ts;

  WsRoomModel();

  WsRoomModel.createWith(
    this.id,
    this.name,
    this.fname,
    this.roomType,
    this.usersCount,
    this.skAccountModel,
    this.broadcast,
    this.encrypted,
    this.ro,
    this.sysMes,
    this.updatedAt,
    this.lastMessage,
  );

  WsRoomModel.createWithRoomDirect(
      this.name,
      this.id,
      this.roomType,
      this.usersCount,
      this.updatedAt,
      this.lastMessage,
      this.msgs,
      this.listUserDirect);

  WsRoomModel.createRoomDirect(this.id, this.roomType, this.usersCount,
      this.updatedAt, this.lastMessage);

  WsRoomModel.createWithGroup(
    this.id,
    this.name,
    this.fname,
    this.roomType,
    this.usersCount,
    this.skAccountModel,
    this.ro,
    this.sysMes,
    this.updatedAt,
    this.lastMessage,
  );

  factory WsRoomModel.fromGroup(Map<String, dynamic> json) {
    RoomType roomType = RoomType.n;
    if (json['t'] != null && json['t'] != '') {
      switch (json['t']) {
        case 'd':
          roomType = RoomType.d;
          break;
        case 'c':
          roomType = RoomType.c;
          break;
        case 'p':
          roomType = RoomType.p;
          break;
        case 'l':
          roomType = RoomType.l;
          break;
      }
    }
    int updateAt;
    if (json['_updatedAt'] != null && json['_updatedAt'] != "") {
      String timeUpdate = json['_updatedAt'];
      DateTime dateTime = DateTime.parse(timeUpdate);
      updateAt = dateTime.millisecondsSinceEpoch;
    }
    WsAccountModel skAccountModel;
    if (json['u'] != null && json['u'] != "") {
      skAccountModel = WsAccountModel.fromJsonRoom(json['u']);
    }
    WsMessage lastMessage;
    if (json['lastMessage'] != null && json['lastMessage'] != "") {
      lastMessage = WsMessage.fromGroupMessage(json['lastMessage']);
    }

    return WsRoomModel.createWithGroup(
        json['_id'],
        json['name'],
        json['fname'],
        roomType,
        json['usersCount'],
        skAccountModel,
        json['ro'].toString() == "true",
        false,
        updateAt,
        lastMessage);
  }

  factory WsRoomModel.fromJson(Map<String, dynamic> json) {
    RoomType roomType = RoomType.n;
    if (json['t'] != null && json['t'] != '') {
      switch (json['t']) {
        case 'd':
          roomType = RoomType.d;
          break;
        case 'c':
          roomType = RoomType.c;
          break;
        case 'p':
          roomType = RoomType.p;
          break;
        case 'l':
          roomType = RoomType.l;
          break;
      }
    }

    if (roomType != RoomType.d) {
      WsAccountModel skAccountModel;
      if (json['u'] != null && json['u'] != "") {
        skAccountModel = WsAccountModel.fromJsonRoom(json['u']);
      }
      WsMessage lassMessage;
      if (json['lastMessage'] != null && json['lastMessage'] != "") {
        lassMessage = WsMessage.fromLastMessage(json['lastMessage']);
      }
      int updateAt;
      if (json.containsKey("_updatedAt") &&
          json['_updatedAt'].containsKey("\$date")) {
        try {
          updateAt = json['_updatedAt']['\$date'] ??
              DateTime.now().millisecondsSinceEpoch;
        } catch (ex) {
          updateAt = DateTime.now().millisecondsSinceEpoch;
        }
      }
      return WsRoomModel.createWith(
          json['_id'],
          json['name'],
          json['fname'],
          roomType,
          json['usersCount'],
          skAccountModel,
          json['broadcast'],
          json['encrypted'],
          json['ro'],
          false,
          updateAt,
          lassMessage);
    } else {
      WsMessage lassMessage;
      if (json['lastMessage'] != null && json['lastMessage'] != "") {
        lassMessage = WsMessage.fromLastMessage(json['lastMessage']);
      }

      return WsRoomModel.createRoomDirect(json['_id'], roomType,
          json['usersCount'], json['_updatedAt']['\$date'], lassMessage);
    }
  }

  factory WsRoomModel.fromDirectRoomJson(Map<String, dynamic> json) {
    RoomType roomType = RoomType.n;
    if (json['t'] != null && json['t'] != '') {
      switch (json['t']) {
        case 'd':
          roomType = RoomType.d;
          break;
        case 'c':
          roomType = RoomType.c;
          break;
        case 'p':
          roomType = RoomType.p;
          break;
        case 'l':
          roomType = RoomType.l;
          break;
      }
    }
    int updateAt;
    if (json['_updatedAt'] != null && json['_updatedAt'] != "") {
      String timeUpdate = json['_updatedAt'];
      DateTime dateTime = DateTime.parse(timeUpdate);
      updateAt = dateTime.millisecondsSinceEpoch;
    }
    WsMessage lassMessage;
    if (json['lastMessage'] != null && json['lastMessage'] != "") {
      lassMessage = WsMessage.fromDirectMessage(json['lastMessage']);
    }
    List<String> listUser = List();
    if (json['usernames'] != null && json['usernames'] != "") {
      Iterable i = json['usernames'];
      if (i != null && i.length > 0) {
        listUser = i.map((data) => data.toString()).toList();
      }
    }
    String name;
    if (listUser != null && listUser.length > 0) {
      String currentUser = WebSocketHelper.getInstance().email;
      listUser?.forEach((sName) {
        if (sName != currentUser) {
          name = sName;
        }
      });
    }

    return WsRoomModel.createWithRoomDirect(
        name ?? "Không xác định",
        json['_id'],
        roomType,
        json['usersCount'],
        updateAt,
        lassMessage,
        json['msgs'],
        listUser);
  }
}
