// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_attachment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WsAttachmentAdapter extends TypeAdapter<WsAttachment> {
  @override
  WsAttachment read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WsAttachment()
      ..title = fields[0] as String
      ..type = fields[1] as String
      ..description = fields[2] as String
      ..title_link = fields[3] as String
      ..title_link_download = fields[4] as bool;
  }

  @override
  void write(BinaryWriter writer, WsAttachment obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.title_link)
      ..writeByte(4)
      ..write(obj.title_link_download);
  }
}

class WsImageFileAdapter extends TypeAdapter<WsImageFile> {
  @override
  WsImageFile read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WsImageFile()
      ..title = fields[0] as String
      ..type = fields[1] as String
      ..description = fields[2] as String
      ..title_link = fields[3] as String
      ..title_link_download = fields[4] as bool
      ..image_url = fields[5] as String
      ..image_type = fields[6] as String
      ..image_size = fields[7] as int
      ..image_dimensions = fields[8] as ImageDimensions
      ..image_preview = fields[9] as String;
  }

  @override
  void write(BinaryWriter writer, WsImageFile obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.title_link)
      ..writeByte(4)
      ..write(obj.title_link_download)
      ..writeByte(5)
      ..write(obj.image_url)
      ..writeByte(6)
      ..write(obj.image_type)
      ..writeByte(7)
      ..write(obj.image_size)
      ..writeByte(8)
      ..write(obj.image_dimensions)
      ..writeByte(9)
      ..write(obj.image_preview);
  }
}

class WsAudioFileAdapter extends TypeAdapter<WsAudioFile> {
  @override
  WsAudioFile read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WsAudioFile()
      ..title = fields[0] as String
      ..type = fields[1] as String
      ..description = fields[2] as String
      ..title_link = fields[3] as String
      ..title_link_download = fields[4] as bool
      ..audio_url = fields[5] as String
      ..audio_type = fields[6] as String
      ..audio_size = fields[7] as int;
  }

  @override
  void write(BinaryWriter writer, WsAudioFile obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.title_link)
      ..writeByte(4)
      ..write(obj.title_link_download)
      ..writeByte(5)
      ..write(obj.audio_url)
      ..writeByte(6)
      ..write(obj.audio_type)
      ..writeByte(7)
      ..write(obj.audio_size);
  }
}

class ImageDimensionsAdapter extends TypeAdapter<ImageDimensions> {
  @override
  ImageDimensions read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageDimensions(
      fields[0] as int,
      fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ImageDimensions obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.width)
      ..writeByte(1)
      ..write(obj.height);
  }
}
