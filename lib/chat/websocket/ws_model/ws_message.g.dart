// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReactionModelAdapter extends TypeAdapter<ReactionModel> {
  @override
  ReactionModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReactionModel()
      ..reactSLike = (fields[0] as List)?.cast<String>()
      ..reactSDislike = (fields[1] as List)?.cast<String>()
      ..reactSHeart = (fields[2] as List)?.cast<String>()
      ..reactSOk = (fields[3] as List)?.cast<String>()
      ..reactSNo = (fields[4] as List)?.cast<String>()
      ..isHasReact = fields[5] as bool
      ..sumUserReactions = fields[6] as int
      ..mapUserReacted = (fields[7] as Map)?.cast<String, String>();
  }

  @override
  void write(BinaryWriter writer, ReactionModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.reactSLike)
      ..writeByte(1)
      ..write(obj.reactSDislike)
      ..writeByte(2)
      ..write(obj.reactSHeart)
      ..writeByte(3)
      ..write(obj.reactSOk)
      ..writeByte(4)
      ..write(obj.reactSNo)
      ..writeByte(5)
      ..write(obj.isHasReact)
      ..writeByte(6)
      ..write(obj.sumUserReactions)
      ..writeByte(7)
      ..write(obj.mapUserReacted);
  }
}

class WsMessageAdapter extends TypeAdapter<WsMessage> {
  @override
  WsMessage read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WsMessage()
      ..id = fields[0] as String
      ..rid = fields[1] as String
      ..messageActionsModel = fields[2] as MessageActionsModel
      ..msg = fields[3] as String
      ..ts = fields[4] as int
      ..t = fields[5] as String
      ..skAccountModel = fields[6] as WsAccountModel
      ..reactions = fields[7] as ReactionModel
      ..channels = fields[8] as dynamic
      ..updatedAt = fields[9] as int
      ..file = fields[10] as WsFile
      ..wsAttachments = (fields[11] as List)?.cast<WsAttachment>()
      ..isSending = fields[12] as bool
      ..unread = fields[13] as bool
      ..messageTyping = fields[14] as bool
      ..isRevokeMessage = fields[15] as bool;
  }

  @override
  void write(BinaryWriter writer, WsMessage obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.rid)
      ..writeByte(2)
      ..write(obj.messageActionsModel)
      ..writeByte(3)
      ..write(obj.msg)
      ..writeByte(4)
      ..write(obj.ts)
      ..writeByte(5)
      ..write(obj.t)
      ..writeByte(6)
      ..write(obj.skAccountModel)
      ..writeByte(7)
      ..write(obj.reactions)
      ..writeByte(8)
      ..write(obj.channels)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.file)
      ..writeByte(11)
      ..write(obj.wsAttachments)
      ..writeByte(12)
      ..write(obj.isSending)
      ..writeByte(13)
      ..write(obj.unread)
      ..writeByte(14)
      ..write(obj.messageTyping)
      ..writeByte(15)
      ..write(obj.isRevokeMessage);
  }
}
