import 'package:hive/hive.dart';
part 'asgl_user_model.g.dart';

@HiveType(adapterName: "ASGLUserModelAdapter")
class ASGUserModel {
  @HiveField(0)
  int id;
  @HiveField(1)
  String full_name;
  @HiveField(2)
  String mobile_phone;
  @HiveField(3)
  dynamic secondary_phone;
  @HiveField(4)
  String email;
  @HiveField(5)
  String secondary_email;
  @HiveField(6)
  String username;
  @HiveField(7)
  int created_by;
  @HiveField(8)
  int is_active;
  @HiveField(9)
  dynamic deleted_at;
  @HiveField(10)
  String created_at;
  @HiveField(11)
  String updated_at;
  @HiveField(12)
  String asgl_id;
  @HiveField(13)
  String dob;
  @HiveField(14)
  String gender;
  @HiveField(15)
  int religion_id;
  @HiveField(16)
  int nation_id;
  @HiveField(17)
  dynamic dentification_id;
  @HiveField(18)
  dynamic passport_id;
  @HiveField(19)
  dynamic household_book_id;
  @HiveField(20)
  String address;
  @HiveField(21)
  String blood_type;
  @HiveField(22)
  Positions position;

  ASGUserModel(
      {this.id,
      this.full_name,
      this.mobile_phone,
      this.secondary_phone,
      this.email,
      this.secondary_email,
      this.username,
      this.created_by,
      this.is_active,
      this.deleted_at,
      this.created_at,
      this.updated_at,
      this.asgl_id,
      this.dob,
      this.gender,
      this.religion_id,
      this.nation_id,
      this.dentification_id,
      this.passport_id,
      this.household_book_id,
      this.address,
      this.blood_type});

  ASGUserModel.createFromLogin(
      this.id,
      this.full_name,
      this.mobile_phone,
      this.secondary_phone,
      this.email,
      this.secondary_email,
      this.username,
      this.created_by,
      this.is_active,
      this.deleted_at,
      this.created_at,
      this.updated_at,
      this.asgl_id,
      this.dob,
      this.gender,
      this.religion_id,
      this.nation_id,
      this.dentification_id,
      this.passport_id,
      this.household_book_id,
      this.address,
      this.blood_type,
      this.position);

  ASGUserModel.createWith(
      this.id,
      this.full_name,
      this.mobile_phone,
      this.secondary_phone,
      this.email,
      this.secondary_email,
      this.username,
      this.created_by,
      this.is_active,
      this.deleted_at,
      this.created_at,
      this.updated_at,
      this.asgl_id,
      this.gender,
      this.religion_id,
      this.nation_id,
      this.dentification_id,
      this.passport_id,
      this.household_book_id,
      this.address,
      this.blood_type,
      this.position);

  factory ASGUserModel.fromJsonLogin(Map<String, dynamic> json) {
    Positions position = Positions();
    if (json['positions'] != null && json['positions'] != "") {
      Iterable i = json['positions'];
      if (i != null && i.length > 0) {
        List<Positions> datas =
            i.map((model) => Positions.fromJson(model)).toList();
        if (datas != null && datas.length > 0) {
          position = datas[0];
        }
      }
    }
    return ASGUserModel.createFromLogin(
        json['id'],
        json['full_name'],
        json['mobile_phone'],
        json['secondary_phone'],
        json['email'],
        json['secondary_email'],
        json['username'],
        json['created_by'],
        json['is_active'],
        json['deleted_at'],
        json['created_at'],
        json['updated_at'],
        json['asgl_id'],
        json['dob'],
        json['gender'],
        json['religion_id'],
        json['nation_id'],
        json['dentification_id'],
        json['passport_id'],
        json['household_book_id'],
        json['address'],
        json['blood_type'],
        position);
  }

  factory ASGUserModel.fromJson(Map<String, dynamic> json) {
    Positions position = Positions();
    if (json['positions'] != null && json['positions'] != "") {
      Iterable i = json['positions'];
      if (i != null && i.length > 0) {
        List<Positions> datas =
            i.map((model) => Positions.fromJson(model)).toList();
        if (datas != null && datas.length > 0) {
          position = datas[0];
        }
      }
    }
    return ASGUserModel.createWith(
        json['id'],
        json['full_name'],
        json['mobile_phone'],
        json['secondary_phone'],
        json['email'],
        json['secondary_email'],
        json['username'],
        json['created_by'],
        json['is_active'],
        json['deleted_at'],
        json['created_at'],
        json['updated_at'],
        json['asgl_id'],
        json['gender'],
        json['religion_id'],
        json['nation_id'],
        json['dentification_id'],
        json['passport_id'],
        json['household_book_id'],
        json['address'],
        json['blood_type'],
        position);
  }
}
@HiveType(adapterName: "PositionsAdapter")
class Positions {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  Level level;
  @HiveField(3)
  Departments department;

  Positions();

  Positions.createWith(this.id, this.name, this.level, this.department);

  factory Positions.fromJson(Map<String, dynamic> json) {
    Level level = Level();
    if (json['level'] != null && json['level'] != '') {
      level = Level.fromJson(json['level']);
    }
    Departments department = Departments();
    if (json['department'] != null && json['department'] != "") {
      department = Departments.fromJson(json['department']);
    }
    return Positions.createWith(json['id'], json['name'], level, department);
  }
}
@HiveType(adapterName: "DepartmentsAdapter")
class Departments {
  @HiveField(0)
  int id;
  @HiveField(1)
  String system_code;
  @HiveField(2)
  String name;
  @HiveField(3)
  String short_code;
  @HiveField(4)
  int parent_id;
  @HiveField(5)
  Level level;

  Departments();

  Departments.createWith(this.id, this.system_code, this.name, this.short_code,
      this.parent_id, this.level);

  factory Departments.fromJson(Map<String, dynamic> json) {
    Level level = Level();
    if (json['level'] != null && json['level'] != "") {
      level = Level.fromJson(json['level']);
    }
    return Departments.createWith(json['id'], json['system_code'], json['name'],
        json['short_code'], json['parent_id'], level);
  }
}
@HiveType(adapterName: "LevelAdapter")
class Level {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;

  Level();

  Level.createWith(this.id, this.name);

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level.createWith(json['id'], json['name']);
  }
}

class ASGUserModel_Thin {
  int id;
  String name;
  String email;
  int invited;
  int accepted;
  dynamic positions;

  ASGUserModel_Thin(
      {this.id, this.name, this.email, this.invited, this.positions});
}
