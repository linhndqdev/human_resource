// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_account_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WsAccountModelAdapter extends TypeAdapter<WsAccountModel> {
  @override
  WsAccountModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WsAccountModel(
      fields[0] as String,
      fields[1] as String,
      fields[2] as int,
      fields[3] as String,
    )..userName = fields[4] as String;
  }

  @override
  void write(BinaryWriter writer, WsAccountModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.token)
      ..writeByte(2)
      ..write(obj.tokenExpires)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.userName);
  }
}
