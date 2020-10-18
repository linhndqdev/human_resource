import 'dart:collection';

import 'package:human_resource/model/time_model.dart';

class NotificationModel {
  int id;
  String title;
  String content;
  String datePost;
  List<FileAttachment> files = [];
  Author author;
  Property type;
  Property status;

  NotificationModel();

  NotificationModel.createWith(
      {this.id,
      this.title,
      this.content,
      this.datePost,
      this.files,
      this.author,
      this.type,
      this.status});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    List<FileAttachment> listFile = [];
    if (json['attachments'] != null && json['attachments'].length > 0) {
      Iterable i = json['attachments'];
      if (i != null && i.length > 0) {
        listFile = i.map((f) => FileAttachment.fromJson(f)).toList();
      }
    }
    Author author;
    if (json.containsKey('author') &&
        json['author'] != null &&
        json['author'] != "") {
      author = Author.fromJson(json['author']);
    }

    Property type;
    if (json.containsKey('type') &&
        json['type'] != null &&
        json['type'] != '') {
      type = Property.fromJson(json['type']);
    }
    Property status;
    if (json.containsKey('status') &&
        json['status'] != null &&
        json['status'] != "") {
      status = Property.fromJson(json['status']);
    }
    String postSchedule = "";
    dynamic date = json['post_schedule'];
    if (date is String) {
      postSchedule = date;
    } else if (date is LinkedHashMap) {
      TimeModel timeModel = TimeModel.fromJson(json['post_schedule']);
      postSchedule = timeModel.date ??= DateTime.now().toIso8601String();
    }
    return NotificationModel.createWith(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        datePost: postSchedule,
        files: listFile,
        author: author,
        type: type,
        status: status);
  }
}

class Property {
  int id;
  String name;

  Property();

  Property.create({this.id, this.name});

  factory Property.fromJson(Map<String, dynamic> json) {
    int id ;
    if (json.containsKey('id')) {
      id = json['id'];
    }
    String name = "Không xác định";
    if (json.containsKey('name')) {
      name = json['name'] ??= "Không xác định";
    }

    return Property.create(id: id, name: name);
  }
}

class FileAttachment {
  int id;
  String src;

  FileAttachment({this.id, this.src});

  factory FileAttachment.fromJson(Map<String, dynamic> json) {
    return FileAttachment(id: json['id'], src: json['file']);
  }
}

class Author {
  int id;
  String username;
  String email;
  String full_name;
  String asgl_id;
  int is_active;
  String mobile_phone;

  Author.create(
      {this.id,
      this.username,
      this.email,
      this.full_name,
      this.asgl_id,
      this.is_active,
      this.mobile_phone});

  factory Author.fromJson(Map<String, dynamic> json) {
    int id = -1;
    if (json.containsKey('id')) {
      id = json['id'] ??= -1;
    }
    int is_active = 0;
    if (json.containsKey('is_active')) {
      id = json['is_active'] ??= 0;
    }
    String userName = "Không xác định";
    if (json.containsKey('username')) {
      userName = json['username'] ??= "Không xác định";
    }
    String email = "Không xác định";
    if (json.containsKey('email')) {
      email = json['email'] ??= "Không xác định";
    }
    String asgl_id = "Không xác định";
    if (json.containsKey('asgl_id')) {
      asgl_id = json['asgl_id'] ??= "Không xác định";
    }
    String full_name = "Không xác định";
    if (json.containsKey('full_name')) {
      full_name = json['full_name'] ??= "Không xác định";
    }
    String mobile_phone = "Không xác định";
    if (json.containsKey('mobile_phone')) {
      mobile_phone = json['mobile_phone'] ??= "Không xác định";
    }
    return Author.create(
        id: id,
        username: userName,
        email: email,
        asgl_id: asgl_id,
        full_name: full_name,
        is_active: is_active,
        mobile_phone: mobile_phone);
  }
}
