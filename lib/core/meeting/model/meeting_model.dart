import 'package:human_resource/core/meeting/model/creator_model.dart';
import 'package:human_resource/core/meeting/model/meeting_room_model.dart';
import 'package:human_resource/core/meeting/model/participant_model.dart';
import 'package:human_resource/model/time_model.dart';
import 'package:intl/intl.dart';

class MeetingModel {
  int id;
  String topic;
  String description;
  TimeModel start_at;
  TimeModel end_at;
  MeetingStatus status;
  String zoom_join_url;
  MeetingRoomModel room;
  CreatorModel creator;
  List<ParticipantModel> participants;
  String record;

  bool get hasRecord => record != null && record.trim().toString() != "";

  MeetingModel(
      {this.id,
      this.topic,
      this.description,
      this.start_at,
      this.end_at,
      this.status,
      this.zoom_join_url,
      this.room,
      this.creator,
      this.participants,
      this.record});

  MeetingModel.createWith(
      this.id,
      this.topic,
      this.description,
      this.start_at,
      this.end_at,
      this.status,
      this.zoom_join_url,
      this.room,
      this.creator,
      this.participants,
      this.record);

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    TimeModel startAtModel;
    if (json['start_at'] != null && json['start_at'] != "") {
      startAtModel = TimeModel.fromJson(json['start_at']);
    }
    TimeModel endAtModel;
    if (json['end_at'] != null && json['end_at'] != "") {
      endAtModel = TimeModel.fromJson(json['end_at']);
    }
    MeetingRoomModel meetingRoomModel;
    if (json['room'] != null && json['room'] != "") {
      meetingRoomModel = MeetingRoomModel.fromJson(json['room']);
    }
    CreatorModel creator = CreatorModel();
    if (json['creator'] != null && json['creator'] != "") {
      try {
        creator = CreatorModel.fromJson(json['creator']);
      } catch (ex) {
        creator = CreatorModel();
      }
    }
    List<ParticipantModel> listMember = List();
    if (json['participants'] != null && json['participants'] != "") {
      Iterable i = json['participants'];
      if (i != null && i.length > 0) {
        listMember =
            i.map((jsonModel) => ParticipantModel.fromJson(jsonModel)).toList();
      }
    }
    MeetingStatus meetingStatus = MeetingStatus();
    if (json['status'] != null && json['status'] != "") {
      meetingStatus = MeetingStatus.fromJson(json['status']);
    }
    String record;
    if (json['record'] != null && json['record'] != "") {
      dynamic i = json['record'];
      if (i != null && i.length > 0) {
        record = i['play_url'] ?? "";
      }
    }
    return MeetingModel.createWith(
        json['id'],
        json['topic'],
        json['description'],
        startAtModel,
        endAtModel,
        meetingStatus,
        json['zoom_join_url'],
        meetingRoomModel,
        creator,
        listMember,
        record);
  }

  String getTimeLimit() {
    try {
      DateTime start = DateTime.parse(this.start_at.date);
      DateTime end = DateTime.parse(this.end_at.date);
      int time = end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      double minus = time / (60000);
      return "${minus.floor().toString()} p";
    } catch (ex) {
      return "0 p";
    }
  }

  String getStartTime() {
    DateTime dateTime = DateTime.parse(this.start_at.date);
    int minute = dateTime.minute;
    int hour = dateTime.hour;
    String sHour = "00";
    if (hour < 10) {
      sHour = "0$hour";
    } else {
      sHour = "$hour";
    }
    String sMinute = "00";
    if (minute < 10) {
      sMinute = "0$minute";
    } else {
      sMinute = "$minute";
    }
    return "$sHour:$sMinute";
  }

  String getDate() {
    DateFormat dateFormat = DateFormat("dd/MM/yyyy");
    if (this.start_at != null && this.start_at.date != null) {
      DateTime dateTime = DateTime.parse(this.start_at.date);
      if (dateTime != null) {
        return dateFormat.format(dateTime);
      } else {
        return "dd/MM/yyyy";
      }
    } else {
      return "dd/MM/yyyy";
    }
  }
}

class MeetingStatus {
  int id;
  String name;

  MeetingStatus.createWith(this.id, this.name);

  MeetingStatus();

  factory MeetingStatus.fromJson(Map<String, dynamic> json) {
    return MeetingStatus.createWith(json['id'], json['name']);
  }
}

//1 - New - Chưa diễn ra,
//2 -In progess - Đang diễn ra
//3 - Cancelled - Đã hủy
//4 - Ended - Đã kết thúc
