import 'dart:convert';

import 'package:hive/hive.dart';

part 'message_action_model.g.dart';

class JsonKey {
  static final String ACTION = "actions";
  static final String none = "none";
  static final String quote = "quote";
  static final String forward = "forwards";
  static final String delete = "delete";
  static final String mention = "mention";
  static final String mentionData = "mentions";
  static final String actionType = "type";
  static final String message = "msg";
  static final String ownerMsg = "owner";
  static final String contentMSG = "contentMsg";
  static final String mentionType = "mentionType";
  static final String time = "time";
  static final String messageID = "'messageID'";
}

class JsonValue {
  static final String mentionAll = "@all";
  static final String mentionAny = "@other";
  static final String actionTypeNone = ActionType.NONE.toString();
  static final String actionTypeQuote = ActionType.QUOTE.toString();
  static final String actionTypeForward = ActionType.FORWARD.toString();
  static final String actionTypeMention = ActionType.MENTION.toString();
  static final String actionTypeDelete = ActionType.DELETE.toString();
}

@HiveType(adapterName: "ActionTypeAdapter")
enum ActionType {
  @HiveField(0)
  NONE,
  @HiveField(1)
  QUOTE,
  @HiveField(2)
  FORWARD,
  @HiveField(3)
  MENTION,
  @HiveField(4)
  DELETE
}

@HiveType(adapterName: "MessageActionsModelAdapter")
class MessageActionsModel {
  //Nội dung tin nhắn
  @HiveField(0)
  String msg;
  @HiveField(1)
  ActionType actionType = ActionType.NONE;
  @HiveField(2)
  List<MessageForwardModel> forwards;
  @HiveField(3)
  MessageQuoteModel quote;
  @HiveField(4)
  MentionModel mentions;
  @HiveField(5)
  MessageDeleteModel delete;
  @HiveField(6)
  bool isEdited = false;

  MessageActionsModel();

  MessageActionsModel.createWith(this.msg, this.actionType, this.forwards,
      this.quote, this.mentions, this.delete, this.isEdited);

  ///Set main message
  MessageActionsModel setMessage(String message) {
    this.msg = message;
    return this;
  }

  ///Set action type for message
  MessageActionsModel setType(ActionType type) {
    this.actionType = type;
    return this;
  }

  //Set data cho thu hồi tin nhắn
  MessageActionsModel setDelete(MessageDeleteModel deleteModel) {
    this.delete = deleteModel;
    return this;
  }

  //Set data cho forward
  MessageActionsModel setForwards(List<MessageForwardModel> forwards) {
    if (this.forwards == null) {
      this.forwards = List<MessageForwardModel>();
    } else if (this.forwards.length > 0) {
      this.forwards.clear();
    }
    if (forwards != null && forwards.length > 0) {
      this.forwards.addAll(forwards);
    }
    return this;
  }

  //Set data quote
  MessageActionsModel setQuote(MessageQuoteModel quote) {
    this.quote = quote;
    return this;
  }

  //Set data mention
  MessageActionsModel setMention(MentionModel mentionModel) {
    this.mentions = mentionModel;
    return this;
  }

  factory MessageActionsModel.fromJson(Map<String, dynamic> mJson) {
    ActionType actionType = ActionType.NONE;
    if (mJson[JsonKey.actionType] != null && mJson[JsonKey.actionType] != "") {
      if (mJson[JsonKey.actionType] == JsonValue.actionTypeForward) {
        //ForwardModel
        actionType = ActionType.FORWARD;
      } else if (mJson[JsonKey.actionType] == JsonValue.actionTypeMention) {
        actionType = ActionType.MENTION;
      } else if (mJson[JsonKey.actionType] == JsonValue.actionTypeQuote) {
        actionType = ActionType.QUOTE;
      } else if (mJson[JsonKey.actionType] == JsonValue.actionTypeDelete) {
        actionType = ActionType.DELETE;
      }
    }
    List<MessageForwardModel> forwards = List();
    if (mJson[JsonKey.forward] != null && mJson[JsonKey.forward] != "") {
      Iterable i = json.decode(mJson[JsonKey.forward]);
      if (i != null && i.length > 0) {
        forwards = i.map((data) => MessageForwardModel.fromJson(data)).toList();
        try {
          if (forwards.length > 1) {
            forwards.sort((o1, o2) {
              if (o2.time != null && o1.time != null) {
                int time1 = int.parse(o2.time);
                int time2 = int.parse(o1.time);
                if (time2 > time1)
                  return 1;
                else if (time2 < time1)
                  return -1;
                else
                  return 0;
              } else {
                return o2.time.compareTo(o1.time);
              }
            });
          }
        } catch (ex) {}
      }
    }
    MessageQuoteModel quoteData = MessageQuoteModel();
    if (actionType == ActionType.QUOTE) {
      if (mJson[JsonKey.quote] != null && mJson[JsonKey.quote] != "") {
        quoteData =
            MessageQuoteModel.fromJson(json.decode(mJson[JsonKey.quote]));
      }
    }
    MentionModel mentions = MentionModel();
    if (actionType == ActionType.MENTION) {
      if (mJson[JsonKey.mention] != null && mJson[JsonKey.mention] != "") {
        mentions = MentionModel.fromJson(json.decode(mJson[JsonKey.mention]));
      }
    }

    MessageDeleteModel delete = MessageDeleteModel();
    if (actionType == ActionType.DELETE) {
      if (mJson[JsonKey.delete] != null && mJson[JsonKey.delete] != "") {
        delete =
            MessageDeleteModel.fromJson(json.decode(mJson[JsonKey.delete]));
      }
    }
    bool isEdited = false;
    if (mJson['isEdited'] != null && mJson['isEdited'] != "") {
      isEdited = mJson['isEdited'].toString() == 'true';
    }
    return MessageActionsModel.createWith(mJson[JsonKey.message], actionType,
        forwards, quoteData, mentions, delete, isEdited);
  }

  Map<String, dynamic> toJson() {
    return {
      JsonKey.ACTION: "actions_message_com.asgl.human_resource",
      JsonKey.message: this.msg,
      JsonKey.actionType: this.actionType.toString(),
      JsonKey.forward: json.encode(this.forwards),
      JsonKey.mention: json.encode(this.mentions),
      JsonKey.quote: json.encode(this.quote?.toJson()),
      JsonKey.delete: json.encode(this.delete?.toJson()),
      "isEdited": this.isEdited
    };
  }
}

///Toàn bộ nội dung tin nhắn forward sẽ được lưu trong [MessageForwardModel]
@HiveType(adapterName: "MessageForwardModelAdapter")
class MessageForwardModel {
  @HiveField(0)
  String ownerMsg;
  @HiveField(1)
  String contentMsg;
  @HiveField(2)
  String time;

  MessageForwardModel();

  MessageForwardModel.createWith(this.ownerMsg, this.contentMsg, this.time);

  factory MessageForwardModel.fromJson(Map<String, dynamic> json) {
    String ownerMsg = "";
    if (json[JsonKey.ownerMsg] != null && json[JsonKey.ownerMsg] != "") {
      ownerMsg = json[JsonKey.ownerMsg];
    }
    String contentMsg = "";
    if (json[JsonKey.contentMSG] != null && json[JsonKey.contentMSG] != "") {
      contentMsg = json[JsonKey.contentMSG];
    }
    String time = "";
    if (json[JsonKey.time] != null && json[JsonKey.time] != "") {
      time = json[JsonKey.time];
    }
    return MessageForwardModel.createWith(ownerMsg, contentMsg, time);
  }

  Map<String, String> toJson() {
    return {
      JsonKey.ownerMsg: this.ownerMsg,
      JsonKey.contentMSG: this.contentMsg,
      JsonKey.time: this.time
    };
  }
}

@HiveType(adapterName: "MessageQuoteModelAdapter")
class MessageQuoteModel {
  @HiveField(0)
  String ownerMessage;
  @HiveField(1)
  String contentQuote;
  @HiveField(2)
  String timeOfMessage;
  @HiveField(3)
  String quoteType = "TEXT";
  @HiveField(4)
  String quoteImageUrl;

  MessageQuoteModel();

  MessageQuoteModel.createWith(this.ownerMessage, this.contentQuote,
      this.timeOfMessage, this.quoteType, this.quoteImageUrl);

  factory MessageQuoteModel.fromJson(Map<String, dynamic> json) {
    String ownerMessage = "";
    if (json[JsonKey.ownerMsg] != null && json[JsonKey.ownerMsg] != "") {
      ownerMessage = json[JsonKey.ownerMsg];
    }
    String contentQuote = "";
    if (json[JsonKey.contentMSG] != null && json[JsonKey.contentMSG] != "") {
      contentQuote = json[JsonKey.contentMSG];
    }
    String timeOfMessage = "";
    if (json[JsonKey.time] != null && json[JsonKey.time] != "") {
      timeOfMessage = json[JsonKey.time];
    }
    String quoteType = "TEXT";
    if (json["quoteType"] != null && json["quoteType"] != "") {
      quoteType = json["quoteType"];
    }
    String quoteImageUrl = "";
    if (json["quoteImageUrl"] != null && json["quoteImageUrl"] != "") {
      quoteImageUrl = json["quoteImageUrl"];
    }
    return MessageQuoteModel.createWith(
        ownerMessage, contentQuote, timeOfMessage, quoteType, quoteImageUrl);
  }

  Map<String, String> toJson() {
    return {
      JsonKey.ownerMsg: this.ownerMessage,
      JsonKey.contentMSG: this.contentQuote,
      JsonKey.time: this.timeOfMessage,
      "quoteType": this.quoteType,
      "quoteImageUrl": this.quoteImageUrl,
    };
  }
}

@HiveType(adapterName: "MentionTypeAdapter")
enum MentionType {
  @HiveField(0)
  ALL,
  @HiveField(1)
  OTHER,
}

@HiveType(adapterName: "MentionModelAdapter")
class MentionModel {
  @HiveField(0)
  MentionType mentionType;
  @HiveField(1)
  List<UserMention> mentions = List();

  MentionModel();

  MentionModel.createWith(this.mentionType, this.mentions);

  factory MentionModel.fromJson(Map<String, dynamic> json) {
    MentionType mentionType;
    if (json.containsKey(JsonKey.mentionType) &&
        json[JsonKey.mentionType] != null &&
        json[JsonKey.mentionType] != "") {
      String mt = json[JsonKey.mentionType];
      if (mt == JsonValue.mentionAll)
        mentionType = MentionType.ALL;
      else if (mt == JsonValue.mentionAny) mentionType = MentionType.OTHER;
    }
    List<UserMention> mentions = List();
    if (json[JsonKey.mentionData] != null && json[JsonKey.mentionData] != "") {
      Iterable i = json[JsonKey.mentionData];
      if (i != null && i.length > 0) {
        mentions = i.map((data) => UserMention.fromJSon(data)).toList();
      }
    }

    return MentionModel.createWith(mentionType, mentions);
  }

  Map<String, dynamic> toJson() {
    String mt = "";
    if (this.mentionType == MentionType.ALL) {
      mt = JsonValue.mentionAll;
    } else if (this.mentionType == MentionType.OTHER) {
      mt = JsonValue.mentionAny;
    }

    return {JsonKey.mentionType: mt, JsonKey.mentionData: this.mentions};
  }
}

@HiveType(adapterName: "UserMentionAdapter")
class UserMention {
  @HiveField(0)
  String content;
  @HiveField(1)
  String userID;
  @HiveField(2)
  String fullName;

  UserMention();

  UserMention.createAt(this.content, this.userID, this.fullName);

  factory UserMention.fromJSon(Map<String, dynamic> json) {
    return UserMention.createAt(
        json['content'], json['userID'], json['fullName']);
  }

  Map<String, dynamic> toJson() {
    return {
      "content": this.content,
      "userID": this.userID,
      "fullName": this.fullName,
    };
  }
}

@HiveType(adapterName: "MessageDeleteModelAdapter")
class MessageDeleteModel {
  //Nội dung sẽ hiển thị
  @HiveField(0)
  String messageContent = "Tin nhắn đã được thu hồi";

  //ID tin nhắn bị thu hồi
  @HiveField(1)
  String messageID;

  MessageDeleteModel();

  MessageDeleteModel.createWith(this.messageID);

  factory MessageDeleteModel.fromJson(Map<String, dynamic> json) {
    return MessageDeleteModel.createWith(json[JsonKey.messageID]);
  }

  Map<String, dynamic> toJson() {
    return {JsonKey.messageID: this.messageID};
  }
}
