import 'package:hive/hive.dart';
import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_attachment.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_file.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'dart:convert' as prefix0;

part 'ws_message.g.dart';

@HiveType(adapterName: "ReactionModelAdapter")
class ReactionModel {
  @HiveField(0)
  List<String> reactSLike = List();
  @HiveField(1)
  List<String> reactSDislike = List();
  @HiveField(2)
  List<String> reactSHeart = List();
  @HiveField(3)
  List<String> reactSOk = List();
  @HiveField(4)
  List<String> reactSNo = List();
  @HiveField(5)
  bool isHasReact = false;
  @HiveField(6)
  int sumUserReactions = 0;
  @HiveField(7)
  Map<String, String> mapUserReacted = Map();

  ReactionModel();

  ReactionModel.createWith(
      {this.reactSLike,
      this.reactSDislike,
      this.reactSHeart,
      this.reactSOk,
      this.reactSNo,
      this.isHasReact,
      this.sumUserReactions,
      this.mapUserReacted});

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    Map<String, String> mapUserReacted = Map();
    List<String> _getListReactWith(Map<String, dynamic> json, String key) {
      List<String> listData = List();
      if (json.containsKey(key) && json[key] != null && json[key] != "") {
        dynamic data = json[key];
        if (data['usernames'] != null && data['usernames'] != "") {
          Iterable i = data['usernames'];
          if (i != null && i.length > 0) {
            listData = i.map((userName) => userName.toString()).toList();
            listData?.forEach((userName) {
              mapUserReacted[userName] = key;
            });
          }
        }
      }
      return listData;
    }

    int sumUserReactions = 0;
    List<String> reactSLike = _getListReactWith(json, ":s_like:");
    sumUserReactions += reactSLike.length;
    List<String> reactSDislike = _getListReactWith(json, ":s_dislike:");
    sumUserReactions += reactSDislike.length;
    List<String> reactSHeart = _getListReactWith(json, ":s_heart:");
    sumUserReactions += reactSHeart.length;
    List<String> reactSOk = _getListReactWith(json, ":s_ok:");
    sumUserReactions += reactSOk.length;
    List<String> reactSNo = _getListReactWith(json, ":s_no:");
    sumUserReactions += reactSNo.length;
    bool isHasReact = reactSLike.length > 0 ||
        reactSDislike.length > 0 ||
        reactSNo.length > 0 ||
        reactSOk.length > 0 ||
        reactSHeart.length > 0;
    return ReactionModel.createWith(
        reactSLike: reactSLike,
        reactSDislike: reactSDislike,
        reactSHeart: reactSHeart,
        reactSOk: reactSOk,
        reactSNo: reactSNo,
        isHasReact: isHasReact,
        sumUserReactions: sumUserReactions,
        mapUserReacted: mapUserReacted);
  }
}

@HiveType(adapterName: "WsMessageAdapter")
class WsMessage {
  @HiveField(0)
  String id;
  @HiveField(1)
  String rid;
  @HiveField(2)
  MessageActionsModel messageActionsModel;
  @HiveField(3)
  String msg;
  @HiveField(4)
  int ts;
  @HiveField(5)
  String
      t; //t == 'au' -> add member to group private, t = subscription-role-added => Thêm quyền
  @HiveField(6)
  WsAccountModel skAccountModel;
  @HiveField(7)
  ReactionModel reactions = ReactionModel();
  @HiveField(8)
  dynamic channels;
  @HiveField(9)
  int updatedAt;
  @HiveField(10)
  WsFile file;
  @HiveField(11)
  List<WsAttachment> wsAttachments;
  @HiveField(12)
  bool isSending = false;
  @HiveField(13)
  bool unread = false;
  @HiveField(14)
  bool messageTyping = false;
  @HiveField(15)
  bool isRevokeMessage = false;

  //Message typing local
  WsMessage();

  WsMessage.createMessageWithAnimation(
      String messageText, WsRoomModel roomModel) {
    this.msg = messageText;
    this.file = null;
    this.t = null;
    DateTime dateTime = DateTime.now();
    this.ts = dateTime.millisecondsSinceEpoch;
    this.rid = roomModel.id;
    this.id = dateTime.millisecondsSinceEpoch.toString();
    this.skAccountModel = WebSocketHelper.getInstance().wsAccountModel;
    this.updatedAt = dateTime.millisecondsSinceEpoch;
    this.wsAttachments = List();
    this.channels = List();
    this.isSending = true;
    this.unread = false;
  }

  WsMessage.createMessage(
      this.id,
      this.rid,
      this.msg,
      this.ts,
      this.t,
      this.skAccountModel,
      this.channels,
      this.updatedAt,
      this.file,
      this.wsAttachments,
      this.unread,
      this.messageActionsModel,
      this.reactions);

  factory WsMessage.fromLastMessage(Map<String, dynamic> json) {
    WsAccountModel skAccountModel;
    if (json['u'] != null && json['u'] != "") {
      skAccountModel = WsAccountModel.fromJsonRoom(json['u']);
    }
    WsFile file;
    if (json['file'] != null && json['file'] != "") {
      file = WsFile.fromJson(json['file']);
    }
    List<WsAttachment> wsAttachments = List();
    if (json['attachments'] != null && json[''] != "") {
      Iterable i = json['attachments'];
      if (i != null && i.length > 0) {
        i.forEach((wsAttachment) {
          if (file == null) {
          } else if (file.type.contains('audio')) {
            WsAudioFile audioFile = WsAudioFile.fromJson(wsAttachment);
            wsAttachments.add(audioFile);
          } else if (file.type.contains('image')) {
            WsImageFile imgFile = WsImageFile.fromJSon(wsAttachment);
            wsAttachments.add(imgFile);
          } else {
            WsAttachment wsOtherFile = WsAttachment.fromJson(wsAttachment);
            wsAttachments.add(wsOtherFile);
          }
        });
      }
    }
    bool unread = false;
    if (json['unread'] != null && json['unread'] != "") {
      unread = json['unread'].toString() == "true";
    }
    String t = json['t'];
    if (json['msg'] != null && json['msg'] == skAccountModel.userName) {
      t = "le";
    }
    MessageActionsModel messageActionsModel = MessageActionsModel();
    if (json['msg'] != null &&
        json['msg'] != "" &&
        json['msg']
            .toString()
            .contains("actions_message_com.asgl.human_resource")) {
      dynamic dataConvert = prefix0.json.decode(json['msg']);
      if (dataConvert[JsonKey.actionType] != null &&
          dataConvert[JsonKey.actionType] != "") {
        messageActionsModel = MessageActionsModel.fromJson(dataConvert);
      }
    }
    ReactionModel reactionModel = ReactionModel();
    if (json['reactions'] != null && json['reactions'] != "") {
      reactionModel = ReactionModel.fromJson(json['reactions']);
    }
    int ts = 0;
    if (json['ts'] != null &&
        json['ts'] != "" &&
        json['ts']['\$date'] != null &&
        json['ts']['\$date'] != "") {
      ts = json['ts']['\$date'];
    } else {
      try {
        ts = json['_updatedAt']['\$date'];
      } catch (ex) {
        ts = DateTime.now().millisecondsSinceEpoch;
      }
    }
    return WsMessage.createMessage(
        json['_id'],
        json['rid'],
        json['msg'],
        ts,
        t,
        skAccountModel,
        json['channels'],
        ts,
        file,
        wsAttachments,
        unread,
        messageActionsModel,
        reactionModel);
  }

  factory WsMessage.fromDirectMessage(Map<String, dynamic> json) {
    WsAccountModel skAccountModel;
    if (json['u'] != null && json['u'] != "") {
      skAccountModel = WsAccountModel.fromJsonRoom(json['u']);
    }
    WsFile file;
    if (json['file'] != null && json['file'] != "") {
      file = WsFile.fromJson(json['file']);
    }
    List<WsAttachment> wsAttachments = List();
    if (json['attachments'] != null && json[''] != "") {
      Iterable i = json['attachments'];
      if (i != null && i.length > 0) {
        i.forEach((wsAttachment) {
          if (file.type.contains('audio')) {
            WsAudioFile audioFile = WsAudioFile.fromJson(wsAttachment);
            wsAttachments.add(audioFile);
          } else if (file.type.contains('image')) {
            WsImageFile imgFile = WsImageFile.fromJSon(wsAttachment);
            wsAttachments.add(imgFile);
          } else {
            WsAttachment wsOtherFile = WsAttachment.fromJson(wsAttachment);
            wsAttachments.add(wsOtherFile);
          }
        });
      }
    }
    int _ts;
    if (json['ts'] != null && json['ts'] != "") {
      String time = json['ts'];
      DateTime dateTime = DateTime.parse(time);
      _ts = dateTime.millisecondsSinceEpoch;
    }
    int _updatedAt;
    if (json['_updatedAt'] != null && json['_updatedAt'] != "") {
      String time = json['_updatedAt'];
      DateTime dateTime = DateTime.parse(time);
      _updatedAt = dateTime.millisecondsSinceEpoch;
    }
    bool unread = false;
    if (json['unread'] != null && json['unread'] != "") {
      unread = json['unread'].toString() == "true";
    }
    MessageActionsModel messageActionsModel = MessageActionsModel();
    if (json['msg'] != null &&
        json['msg'] != "" &&
        json['msg']
            .toString()
            .contains("actions_message_com.asgl.human_resource")) {
      dynamic dataConvert = prefix0.json.decode(json['msg']);
      if (dataConvert[JsonKey.actionType] != null &&
          dataConvert[JsonKey.actionType] != "") {
        messageActionsModel = MessageActionsModel.fromJson(dataConvert);
      }
    }
    ReactionModel reactionModel = ReactionModel();
    if (json['reactions'] != null && json['reactions'] != "") {
      reactionModel = ReactionModel.fromJson(json['reactions']);
    }
    String t = json['t'];
    if (json['msg'] != null && json['msg'] == skAccountModel.userName) {
      t = "le";
    }
    return WsMessage.createMessage(
        json['_id'],
        json['rid'],
        json['msg'],
        _ts,
        t,
        skAccountModel,
        json['channels'],
        _updatedAt,
        file,
        wsAttachments,
        unread,
        messageActionsModel,
        reactionModel);
  }

  factory WsMessage.fromGroupMessage(Map<String, dynamic> json) {
    WsAccountModel skAccountModel;
    if (json['u'] != null && json['u'] != "") {
      skAccountModel = WsAccountModel.fromJsonRoom(json['u']);
    }
    WsFile file;
    if (json['file'] != null && json['file'] != "") {
      file = WsFile.fromJson(json['file']);
    }
    List<WsAttachment> wsAttachments = List();
    if (json['attachments'] != null && json[''] != "") {
      Iterable i = json['attachments'];
      if (i != null && i.length > 0) {
        i.forEach((wsAttachment) {
          if (file == null) {
          } else if (file.type.contains('audio')) {
            WsAudioFile audioFile = WsAudioFile.fromJson(wsAttachment);
            wsAttachments.add(audioFile);
          } else if (file.type.contains('image')) {
            WsImageFile imgFile = WsImageFile.fromJSon(wsAttachment);
            wsAttachments.add(imgFile);
          } else {
            WsAttachment wsOtherFile = WsAttachment.fromJson(wsAttachment);
            wsAttachments.add(wsOtherFile);
          }
        });
      }
    }
    bool unread = false;
    if (json['unread'] != null && json['unread'] != "") {
      unread = json['unread'].toString() == "true";
    }
    int ts;
    if (json['ts'] != null && json['ts'] != "") {
      DateTime dateTime = DateTime.parse(json['ts']);
      ts = dateTime.millisecondsSinceEpoch;
    }
    int updateAt;
    if (json['_updatedAt'] != null && json['_updatedAt'] != "") {
      DateTime dateTime = DateTime.parse(json['_updatedAt']);
      updateAt = dateTime.millisecondsSinceEpoch;
    }
    String t = json['t'];
    if (json['msg'] != null && json['msg'] == skAccountModel.userName) {
      t = "le";
    }
    MessageActionsModel messageActionsModel = MessageActionsModel();
    if (json[JsonKey.ACTION] != null && json[JsonKey.ACTION] != "") {
      messageActionsModel = MessageActionsModel.fromJson(json[JsonKey.ACTION]);
    }
    ReactionModel reactionModel = ReactionModel();
    if (json['reactions'] != null && json['reactions'] != "") {
      reactionModel = ReactionModel.fromJson(json['reactions']);
    }
    return WsMessage.createMessage(
        json['_id'],
        json['rid'],
        json['msg'],
        ts,
        t,
        skAccountModel,
        json['channels'],
        updateAt,
        file,
        wsAttachments,
        unread,
        messageActionsModel,
        reactionModel);
  }
}
