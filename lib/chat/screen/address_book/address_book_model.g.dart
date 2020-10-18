// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_book_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AddressBookModelAdapter extends TypeAdapter<AddressBookModel> {
  @override
  AddressBookModel read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AddressBookModel()
      ..id = fields[0] as String
      ..status = fields[1] as String
      ..name = fields[2] as String
      ..username = fields[3] as String;
  }

  @override
  void write(BinaryWriter writer, AddressBookModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.username);
  }
}
