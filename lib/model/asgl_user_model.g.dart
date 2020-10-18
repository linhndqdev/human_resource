// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asgl_user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ASGLUserModelAdapter extends TypeAdapter<ASGUserModel> {
  @override
  ASGUserModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ASGUserModel(
      id: fields[0] as int,
      full_name: fields[1] as String,
      mobile_phone: fields[2] as String,
      secondary_phone: fields[3] as dynamic,
      email: fields[4] as String,
      secondary_email: fields[5] as String,
      username: fields[6] as String,
      created_by: fields[7] as int,
      is_active: fields[8] as int,
      deleted_at: fields[9] as dynamic,
      created_at: fields[10] as String,
      updated_at: fields[11] as String,
      asgl_id: fields[12] as String,
      dob: fields[13] as String,
      gender: fields[14] as String,
      religion_id: fields[15] as int,
      nation_id: fields[16] as int,
      dentification_id: fields[17] as dynamic,
      passport_id: fields[18] as dynamic,
      household_book_id: fields[19] as dynamic,
      address: fields[20] as String,
      blood_type: fields[21] as String,
    )..position = fields[22] as Positions;
  }

  @override
  void write(BinaryWriter writer, ASGUserModel obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.full_name)
      ..writeByte(2)
      ..write(obj.mobile_phone)
      ..writeByte(3)
      ..write(obj.secondary_phone)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.secondary_email)
      ..writeByte(6)
      ..write(obj.username)
      ..writeByte(7)
      ..write(obj.created_by)
      ..writeByte(8)
      ..write(obj.is_active)
      ..writeByte(9)
      ..write(obj.deleted_at)
      ..writeByte(10)
      ..write(obj.created_at)
      ..writeByte(11)
      ..write(obj.updated_at)
      ..writeByte(12)
      ..write(obj.asgl_id)
      ..writeByte(13)
      ..write(obj.dob)
      ..writeByte(14)
      ..write(obj.gender)
      ..writeByte(15)
      ..write(obj.religion_id)
      ..writeByte(16)
      ..write(obj.nation_id)
      ..writeByte(17)
      ..write(obj.dentification_id)
      ..writeByte(18)
      ..write(obj.passport_id)
      ..writeByte(19)
      ..write(obj.household_book_id)
      ..writeByte(20)
      ..write(obj.address)
      ..writeByte(21)
      ..write(obj.blood_type)
      ..writeByte(22)
      ..write(obj.position);
  }
}

class PositionsAdapter extends TypeAdapter<Positions> {
  @override
  Positions read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Positions()
      ..id = fields[0] as int
      ..name = fields[1] as String
      ..level = fields[2] as Level
      ..department = fields[3] as Departments;
  }

  @override
  void write(BinaryWriter writer, Positions obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.level)
      ..writeByte(3)
      ..write(obj.department);
  }
}

class DepartmentsAdapter extends TypeAdapter<Departments> {
  @override
  Departments read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Departments()
      ..id = fields[0] as int
      ..system_code = fields[1] as String
      ..name = fields[2] as String
      ..short_code = fields[3] as String
      ..parent_id = fields[4] as int
      ..level = fields[5] as Level;
  }

  @override
  void write(BinaryWriter writer, Departments obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.system_code)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.short_code)
      ..writeByte(4)
      ..write(obj.parent_id)
      ..writeByte(5)
      ..write(obj.level);
  }
}

class LevelAdapter extends TypeAdapter<Level> {
  @override
  Level read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Level()
      ..id = fields[0] as int
      ..name = fields[1] as String;
  }

  @override
  void write(BinaryWriter writer, Level obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name);
  }
}
