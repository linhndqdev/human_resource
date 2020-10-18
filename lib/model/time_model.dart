class TimeModel {
  String date;
  int timezoneType;
  String timezone;
  TimeModel({this.date, this.timezoneType, this.timezone});
  TimeModel.createWith(this.date, this.timezoneType, this.timezone);

  factory TimeModel.fromJson(Map<String, dynamic> json) {
    String date = json['date'] ?? "";
    int timezoneType = json['timezone_type'] ?? -1;
    String timezone = json['timezone'] ?? "Không xác định";
    return TimeModel.createWith(date, timezoneType, timezone);
  }
}