import 'package:human_resource/model/time_model.dart';

class CalendarDataModel{
  TimeModel startAt;
  TimeModel endAt;
  int id;
  ClassModel classModel;

  CalendarDataModel(this.startAt, this.endAt, this.id, this.classModel);

  factory CalendarDataModel.fromJson(Map<String, dynamic> json) {
    TimeModel beginAt;
    if (json['begin_at'] != null && json['begin_at'] != "") {
      beginAt = TimeModel.fromJson(json['begin_at']);
    }
    TimeModel endAt;
    if (json['end_at'] != null && json['end_at'] != "") {
      endAt = TimeModel.fromJson(json['end_at']);
    }
    ClassModel classModel;
    if (json['class'] != null &&
        json['class'] != '' &&
        json['class']['data'] != null &&
        json['class']['data'] != "") {
      classModel = ClassModel.fromJson(json['class']['data']);
    }
    return CalendarDataModel(beginAt, endAt, json['id'], classModel);
  }

  ProcessType checkInsideTime() {
    DateTime currentDate = DateTime.now();
    DateTime start = DateTime.parse(this.startAt.date);
    DateTime end = DateTime.parse(this.endAt.date);
    int currentTimeMil = currentDate.millisecondsSinceEpoch;
    int startMil = start.millisecondsSinceEpoch;
    int endMil = end.millisecondsSinceEpoch;
    if (currentTimeMil < startMil) {
      return ProcessType.NOT_START;
    } else if (currentTimeMil > endMil) {
      return ProcessType.ENDED;
    } else {
      return ProcessType.PROCESSING;
    }
  }
}

class Archives {
  int id;
  String url;
  dynamic created_at;
  dynamic updated_at;

  Archives(this.id, this.url, this.created_at, this.updated_at);

  factory Archives.fromJson(Map<String, dynamic> json) {
    return Archives(
        json['id'], json['url'], json['created_at'], json['updated_at']);
  }
}

class OnlineLink {
  int id;
  String url;
  dynamic created_at;
  dynamic updated_at;

  OnlineLink(this.id, this.url, this.created_at, this.updated_at);

  factory OnlineLink.fromJson(Map<String, dynamic> json) {
    return OnlineLink(
        json['id'], json['url'], json['created_at'], json['updated_at']);
  }
}

enum ProcessType { PROCESSING, NOT_START, ENDED }

class ClassModel {
  int id;
  String name;
  String description;
  CourseModel course;
  List<Archives> archives;
  List<OnlineLink> onlineLinks;

  ClassModel(this.id, this.name, this.description, this.course, this.archives,
      this.onlineLinks);

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    CourseModel courseModel;
    if (json['course'] != null &&
        json['course'] != null &&
        json['course']['data'] != null &&
        json['course']['data'] != "") {
      courseModel = CourseModel.fromJson(json['course']['data']);
    }
    List<Archives> archives;
    if (json['archives'] != null &&
        json['archives'] != "" &&
        json['archives']['data'] != null &&
        json['archives']['data'] != "") {
      Iterable i = json['archives']['data'];
      if (i != null && i.length > 0) {
        archives = i.map((archive) => Archives.fromJson(archive)).toList();
      }
    }
    List<OnlineLink> onlineLinks;
    if (json['onlineLinks'] != null &&
        json['onlineLinks'] != "" &&
        json['onlineLinks']['data'] != null &&
        json['onlineLinks']['data'] != "") {
      Iterable i = json['onlineLinks']['data'];
      if (i != null && i.length > 0) {
        onlineLinks =
            i.map((onlineLink) => OnlineLink.fromJson(onlineLink)).toList();
      }
    }
    return ClassModel(json['id'], json['name'], json['description'],
        courseModel, archives, onlineLinks);
  }
}

class CourseModel {
  int id;
  String name;
  String description;

  CourseModel(this.id, this.name, this.description);

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(json['id'], json['name'], json['description']);
  }
}
