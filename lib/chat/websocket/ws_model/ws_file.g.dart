// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_file.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WsFileAdapter extends TypeAdapter<WsFile> {
  @override
  WsFile read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WsFile()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..type = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, WsFile obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type);
  }
}
