// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_room_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoomTypeAdapter extends TypeAdapter<RoomType> {
  @override
  RoomType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RoomType.d;
      case 1:
        return RoomType.c;
      case 2:
        return RoomType.p;
      case 3:
        return RoomType.l;
      case 4:
        return RoomType.n;
      default:
        return null;
    }
  }

  @override
  void write(BinaryWriter writer, RoomType obj) {
    switch (obj) {
      case RoomType.d:
        writer.writeByte(0);
        break;
      case RoomType.c:
        writer.writeByte(1);
        break;
      case RoomType.p:
        writer.writeByte(2);
        break;
      case RoomType.l:
        writer.writeByte(3);
        break;
      case RoomType.n:
        writer.writeByte(4);
        break;
    }
  }
}

class WsRoomModelAdapter extends TypeAdapter<WsRoomModel> {
  @override
  WsRoomModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WsRoomModel()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..fname = fields[2] as String
      ..roomType = fields[3] as RoomType
      ..usersCount = fields[4] as int
      ..skAccountModel = fields[5] as WsAccountModel
      ..broadcast = fields[6] as bool
      ..encrypted = fields[7] as bool
      ..ro = fields[8] as bool
      ..sysMes = fields[9] as bool
      ..updatedAt = fields[10] as int
      ..lastMessage = fields[11] as WsMessage
      ..listUserDirect = (fields[12] as List)?.cast<String>()
      ..msgs = fields[13] as int
      ..ts = fields[14] as int;
  }

  @override
  void write(BinaryWriter writer, WsRoomModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fname)
      ..writeByte(3)
      ..write(obj.roomType)
      ..writeByte(4)
      ..write(obj.usersCount)
      ..writeByte(5)
      ..write(obj.skAccountModel)
      ..writeByte(6)
      ..write(obj.broadcast)
      ..writeByte(7)
      ..write(obj.encrypted)
      ..writeByte(8)
      ..write(obj.ro)
      ..writeByte(9)
      ..write(obj.sysMes)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.lastMessage)
      ..writeByte(12)
      ..write(obj.listUserDirect)
      ..writeByte(13)
      ..write(obj.msgs)
      ..writeByte(14)
      ..write(obj.ts);
  }
}
