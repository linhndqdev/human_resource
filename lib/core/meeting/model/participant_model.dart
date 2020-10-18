
//class ParticipantModel {
//  List<Participant> participants;
//
//  ParticipantModel({
//    this.participants,
//  });
//
//  factory ParticipantModel.fromJson(Map<String, dynamic> json) => ParticipantModel(
//    participants: List<Participant>.from(json["participants"].map((x) => Participant.fromJson(x))),
//  );
//
//  Map<String, dynamic> toJson() => {
//    "participants": List<dynamic>.from(participants.map((x) => x.toJson())),
//  };
//}

class ParticipantModel {
  int id;
  String name;
  String email;
  int invited;
  int accepted;
  int attended;
  List<Position> positions;

  ParticipantModel({
    this.id,
    this.name,
    this.email,
    this.invited,
    this.accepted,
    this.attended,
    this.positions,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) => ParticipantModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    invited: json["invited"],
    accepted: json["accepted"],
    attended: json["attended"],
    positions: List<Position>.from(json["positions"].map((x) => Position.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "invited": invited,
    "accepted": accepted,
    "attended": attended,
    "positions": List<dynamic>.from(positions.map((x) => x.toJson())),
  };
}

class Position {
  int id;
  String name;
  Level level;
  Department department;

  Position({
    this.id,
    this.name,
    this.level,
    this.department,
  });

  factory Position.fromJson(Map<String, dynamic> json) => Position(
    id: json["id"],
    name: json["name"],
    level: Level.fromJson(json["level"]),
    department: Department.fromJson(json["department"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "level": level.toJson(),
    "department": department.toJson(),
  };
}

class Department {
  int id;
  String systemCode;
  String name;
  String shortCode;
  int parentId;
  Level level;

  Department({
    this.id,
    this.systemCode,
    this.name,
    this.shortCode,
    this.parentId,
    this.level,
  });

  factory Department.fromJson(Map<String, dynamic> json) => Department(
    id: json["id"],
    systemCode: json["system_code"],
    name: json["name"],
    shortCode: json["short_code"],
    parentId: json["parent_id"],
    level: Level.fromJson(json["level"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "system_code": systemCode,
    "name": name,
    "short_code": shortCode,
    "parent_id": parentId,
    "level": level.toJson(),
  };
}

class Level {
  int id;
  String name;

  Level({
    this.id,
    this.name,
  });

  factory Level.fromJson(Map<String, dynamic> json) => Level(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
//
//class ParticipantModel {
//  int id;
//  String name;
//  String email;
//  int invited; //Default: 0
//  int accepted; //Default: 0
//  int attended; //Default: 0
//  Positions positions;
//
//  ParticipantModel();
//
//  ParticipantModel.createWith(this.id, this.name, this.email, this.invited,
//      this.accepted, this.attended, this.positions);
//
//  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
//    return ParticipantModel.createWith(
//        json['id'] ?? -1,
//        json['name'] ?? "",
//        json['email'] ?? "",
//        json['invited'] ?? 0,
//        json['accepted'] ?? 0,
//        json['attended'] ?? 0,
//        json['positions'] );
//  }
//}
//class Positions {
//  List<Position> positions;
//
//  Positions({
//    this.positions,
//  });
//
//  factory Positions.fromJson(Map<String, dynamic> json) => Positions(
//    positions: List<Position>.from(json["positions"].map((x) => Position.fromJson(x))),
//  );
//
//  Map<String, dynamic> toJson() => {
//    "positions": List<dynamic>.from(positions.map((x) => x.toJson())),
//  };
//}
//
//class Position {
//  int id;
//  String name;
//  Level level;
//  Department department;
//
//  Position({
//    this.id,
//    this.name,
//    this.level,
//    this.department,
//  });
//
//  factory Position.fromJson(Map<String, dynamic> json) => Position(
//    id: json["id"],
//    name: json["name"],
//    level: Level.fromJson(json["level"]),
//    department: Department.fromJson(json["department"]),
//  );
//
//  Map<String, dynamic> toJson() => {
//    "id": id,
//    "name": name,
//    "level": level.toJson(),
//    "department": department.toJson(),
//  };
//}
//
//class Department {
//  int id;
//  String systemCode;
//  String name;
//  String shortCode;
//  int parentId;
//  Level level;
//
//  Department({
//    this.id,
//    this.systemCode,
//    this.name,
//    this.shortCode,
//    this.parentId,
//    this.level,
//  });
//
//  factory Department.fromJson(Map<String, dynamic> json) => Department(
//    id: json["id"],
//    systemCode: json["system_code"],
//    name: json["name"],
//    shortCode: json["short_code"],
//    parentId: json["parent_id"],
//    level: Level.fromJson(json["level"]),
//  );
//
//  Map<String, dynamic> toJson() => {
//    "id": id,
//    "system_code": systemCode,
//    "name": name,
//    "short_code": shortCode,
//    "parent_id": parentId,
//    "level": level.toJson(),
//  };
//}
//
//class Level {
//  int id;
//  String name;
//
//  Level({
//    this.id,
//    this.name,
//  });
//
//  factory Level.fromJson(Map<String, dynamic> json) => Level(
//    id: json["id"],
//    name: json["name"],
//  );
//
//  Map<String, dynamic> toJson() => {
//    "id": id,
//    "name": name,
//  };
//}
