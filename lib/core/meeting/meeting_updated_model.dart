import 'dart:convert';
class MeetingUpdatedModel {
  Meeting meeting;

  MeetingUpdatedModel({
    this.meeting,
  });

  factory MeetingUpdatedModel.fromJson(Map<String, dynamic> json) => MeetingUpdatedModel(
    meeting: Meeting.fromJson(json["meeting"]),
  );

  Map<String, dynamic> toJson() => {
    "meeting": meeting.toJson(),
  };
}

class Meeting {
  int id;
  String topic;
  String description;
  At startAt;
  At endAt;
  Room status;
  String zoomJoinUrl;
  Room room;
  Creator creator;
  List<Participant> participants;

  Meeting({
    this.id,
    this.topic,
    this.description,
    this.startAt,
    this.endAt,
    this.status,
    this.zoomJoinUrl,
    this.room,
    this.creator,
    this.participants,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
    id: json["id"],
    topic: json["topic"],
    description: json["description"],
    startAt: At.fromJson(json["start_at"]),
    endAt: At.fromJson(json["end_at"]),
    status: Room.fromJson(json["status"]),
    zoomJoinUrl: json["zoom_join_url"],
    room: Room.fromJson(json["room"]),
    creator: Creator.fromJson(json["creator"]),
    participants: List<Participant>.from(json["participants"].map((x) => Participant.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "topic": topic,
    "description": description,
    "start_at": startAt.toJson(),
    "end_at": endAt.toJson(),
    "status": status.toJson(),
    "zoom_join_url": zoomJoinUrl,
    "room": room.toJson(),
    "creator": creator.toJson(),
    "participants": List<dynamic>.from(participants.map((x) => x.toJson())),
  };
}

class Creator {
  int id;
  String name;
  String email;

  Creator({
    this.id,
    this.name,
    this.email,
  });

  factory Creator.fromJson(Map<String, dynamic> json) => Creator(
    id: json["id"],
    name: json["name"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
  };
}

class At {
  DateTime date;
  int timezoneType;
  String timezone;

  At({
    this.date,
    this.timezoneType,
    this.timezone,
  });

  factory At.fromJson(Map<String, dynamic> json) => At(
    date: DateTime.parse(json["date"]),
    timezoneType: json["timezone_type"],
    timezone: json["timezone"],
  );

  Map<String, dynamic> toJson() => {
    "date": date.toIso8601String(),
    "timezone_type": timezoneType,
    "timezone": timezone,
  };
}

class Participant {
  int id;
  String name;
  String email;
  int invited;
  int accepted;
  int attended;

  Participant({
    this.id,
    this.name,
    this.email,
    this.invited,
    this.accepted,
    this.attended,
  });

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    invited: json["invited"],
    accepted: json["accepted"],
    attended: json["attended"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "invited": invited,
    "accepted": accepted,
    "attended": attended,
  };
}

class Room {
  int id;
  String name;

  Room({
    this.id,
    this.name,
  });

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
