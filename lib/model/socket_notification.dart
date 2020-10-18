import 'package:human_resource/core/meeting/model/meeting_model.dart';
import 'package:human_resource/model/notification_model.dart';
import 'package:human_resource/model/time_model.dart';
import 'package:intl/intl.dart';

enum SKNotificationType { MEETING, ANNOUNCEMENT }

class SKNotification {
  String id;
  String title;
  String message;
  SKNotificationType skNotificationType;
  dynamic data;
  TimeModel read_at;
  TimeModel created_at;

  bool get read => read_at != null && read_at?.date != null;

  String get createed => _getTimeCreated();

  SKNotification();

  SKNotification.createWith(this.id, this.title, this.message,
      this.skNotificationType, this.data, this.read_at, this.created_at);

  factory SKNotification.fromSocketJson(Map<String, dynamic> json) {
    SKNotificationType type;
    dynamic data;
    dynamic read_at = json['read_at'];
    TimeModel timeModel = TimeModel();
    if (json.containsKey('created_at') &&
        json['created_at'] != null &&
        json['created_at'] != "") {
      timeModel = TimeModel.fromJson(json['created_at']);
    }
    if (json.containsKey("meeting")) {
      type = SKNotificationType.MEETING;
    }
    if (type == SKNotificationType.MEETING) {
      if (json['meeting'] != null && json['meeting'] != "") {
        data = MeetingModel.fromJson(json['meeting']);
      }
    }
    String title = "";
    if (json.containsKey('title')) {
      title = json['title'] ??= " ";
    }
    String message = "";
    if (json.containsKey('message')) {
      message = json['message'] ??= " ";
    }
    String id = "";
    if (json.containsKey('id')) {
      id = json['id'] ??= "";
    }
    return SKNotification.createWith(
        id, title, message, type, data, read_at, timeModel);
  }

  factory SKNotification.fromAPI(Map<String, dynamic> json) {
    SKNotificationType type;
    dynamic data;
    Map<String, dynamic> dataJson = json['data'];
    TimeModel read_at;
    if (json.containsKey('read_at') &&
        json['read_at'] != null &&
        json['read_at'] != "") {
      read_at = TimeModel.fromJson(json['read_at']);
    }
    TimeModel timeModel = TimeModel();
    if (json.containsKey('created_at') &&
        json['created_at'] != null &&
        json['created_at'] != "") {
      timeModel = TimeModel.fromJson(json['created_at']);
    }
    if (dataJson.containsKey("meeting")) {
      type = SKNotificationType.MEETING;
      if (dataJson['meeting'] != null && dataJson['meeting'] != "") {
        data = MeetingModel.fromJson(dataJson['meeting']);
      }
    } else if (dataJson.containsKey("announcement")) {
      type = SKNotificationType.ANNOUNCEMENT;
      if (dataJson['announcement'] != null && dataJson['announcement'] != "") {
        data = NotificationModel.fromJson(dataJson['announcement']);
      }
    }
    String title = "";
    if (dataJson.containsKey('title')) {
      title = dataJson['title'] ??= " ";
    }

    String message = "";
    if (dataJson.containsKey('message')) {
      message = dataJson['message'] ??= " ";
    }
    String id = "";
    if (json.containsKey('id')) {
      id = json['id'] ??= "";
    }
    return SKNotification.createWith(
        id, title, message, type, data, read_at, timeModel);
  }

  String _getTimeCreated() {
    DateFormat format = DateFormat("HH:mm dd/MM/yyyy");
    DateTime dateTime;
    if (this.created_at == null) {
      dateTime = DateTime.now();
    } else {
      if (this.created_at.date == null || this.created_at.date == "") {
        dateTime = DateTime.now();
      } else {
        try {
          dateTime = DateTime.parse(this.created_at.date);
        } catch (ex) {
          dateTime = DateTime.now();
        }
      }
    }
    return format.format(dateTime);
  }
}
