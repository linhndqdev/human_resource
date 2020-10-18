// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_action_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActionTypeAdapter extends TypeAdapter<ActionType> {
  @override
  ActionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ActionType.NONE;
      case 1:
        return ActionType.QUOTE;
      case 2:
        return ActionType.FORWARD;
      case 3:
        return ActionType.MENTION;
      case 4:
        return ActionType.DELETE;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, ActionType obj) {
    switch (obj) {
      case ActionType.NONE:
        writer.writeByte(0);
        break;
      case ActionType.QUOTE:
        writer.writeByte(1);
        break;
      case ActionType.FORWARD:
        writer.writeByte(2);
        break;
      case ActionType.MENTION:
        writer.writeByte(3);
        break;
      case ActionType.DELETE:
        writer.writeByte(4);
        break;
    }
  }
}

class MentionTypeAdapter extends TypeAdapter<MentionType> {
  @override
  MentionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MentionType.ALL;
      case 1:
        return MentionType.OTHER;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, MentionType obj) {
    switch (obj) {
      case MentionType.ALL:
        writer.writeByte(0);
        break;
      case MentionType.OTHER:
        writer.writeByte(1);
        break;
    }
  }
}

class MessageActionsModelAdapter extends TypeAdapter<MessageActionsModel> {
  @override
  MessageActionsModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageActionsModel()
      ..msg = fields[0] as String
      ..actionType = fields[1] as ActionType
      ..forwards = (fields[2] as List)?.cast<MessageForwardModel>()
      ..quote = fields[3] as MessageQuoteModel
      ..mentions = fields[4] as MentionModel
      ..delete = fields[5] as MessageDeleteModel
      ..isEdited = fields[6] as bool;
  }

  @override
  void write(BinaryWriter writer, MessageActionsModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.msg)
      ..writeByte(1)
      ..write(obj.actionType)
      ..writeByte(2)
      ..write(obj.forwards)
      ..writeByte(3)
      ..write(obj.quote)
      ..writeByte(4)
      ..write(obj.mentions)
      ..writeByte(5)
      ..write(obj.delete)
      ..writeByte(6)
      ..write(obj.isEdited);
  }
}

class MessageForwardModelAdapter extends TypeAdapter<MessageForwardModel> {
  @override
  MessageForwardModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageForwardModel()
      ..ownerMsg = fields[0] as String
      ..contentMsg = fields[1] as String
      ..time = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, MessageForwardModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.ownerMsg)
      ..writeByte(1)
      ..write(obj.contentMsg)
      ..writeByte(2)
      ..write(obj.time);
  }
}

class MessageQuoteModelAdapter extends TypeAdapter<MessageQuoteModel> {
  @override
  MessageQuoteModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageQuoteModel()
      ..ownerMessage = fields[0] as String
      ..contentQuote = fields[1] as String
      ..timeOfMessage = fields[2] as String
      ..quoteType = fields[3] as String
      ..quoteImageUrl = fields[4] as String;
  }

  @override
  void write(BinaryWriter writer, MessageQuoteModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.ownerMessage)
      ..writeByte(1)
      ..write(obj.contentQuote)
      ..writeByte(2)
      ..write(obj.timeOfMessage)
      ..writeByte(3)
      ..write(obj.quoteType)
      ..writeByte(4)
      ..write(obj.quoteImageUrl);
  }
}

class MentionModelAdapter extends TypeAdapter<MentionModel> {
  @override
  MentionModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MentionModel()
      ..mentionType = fields[0] as MentionType
      ..mentions = (fields[1] as List)?.cast<UserMention>();
  }

  @override
  void write(BinaryWriter writer, MentionModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.mentionType)
      ..writeByte(1)
      ..write(obj.mentions);
  }
}

class UserMentionAdapter extends TypeAdapter<UserMention> {
  @override
  UserMention read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserMention()
      ..content = fields[0] as String
      ..userID = fields[1] as String
      ..fullName = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, UserMention obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.content)
      ..writeByte(1)
      ..write(obj.userID)
      ..writeByte(2)
      ..write(obj.fullName);
  }
}

class MessageDeleteModelAdapter extends TypeAdapter<MessageDeleteModel> {
  @override
  MessageDeleteModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageDeleteModel()
      ..messageContent = fields[0] as String
      ..messageID = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, MessageDeleteModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.messageContent)
      ..writeByte(1)
      ..write(obj.messageID);
  }
}
