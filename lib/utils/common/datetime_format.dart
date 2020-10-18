import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DateTimeFormat {
  static String forMartDateTime(String time) {
    if (time == null || time == "") {
      return 'Không xác định';
    }
    try {
      DateTime dateTime = DateTime.parse(time);
      return DateFormat('HH:mm dd/MM/yyyy').format(dateTime);
    } on Exception catch (ex) {
      return "Không xác định";
    }
  }

  static String getTimeFrom(int time) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    DateTime currentTime = DateTime.now().add(Duration(
        days: -7,
        hours: 0,
        minutes: 0,
        seconds: 0,
        milliseconds: 0,
        microseconds: 0));
    if (currentTime.millisecondsSinceEpoch > time) {
      DateFormat format = DateFormat("dd/MM/yyyy");
      return format.format(dateTime);
    } else {
      timeago.setLocaleMessages('vi', timeago.ViMessages());
      String result = timeago.format(dateTime, locale: "vi");
      if (result.contains("khoảng")) {
        result = result.replaceAll("khoảng", "");
      }
      if (result.contains("một thoáng trước")) {
        return "Vừa xong";
      } else {
        return result;
      }
    }
  }

  static String getHourAndMinuteFrom(int time) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    DateFormat format = DateFormat("HH:mm");
    return format.format(dateTime);
  }

  static String getDay(int ts) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(ts);
    if (dateTime.day != DateTime.now().day) {
      DateFormat format = DateFormat("dd-MM-yyyy");
      return format.format(dateTime);
    } else {
      return "Hôm nay";
    }
  }
  static String convertTimeMessageItem(int time) {
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    if (now.day != dateTime.day) {
      DateFormat format = DateFormat("dd/MM/yyyy");
      String date = format.format(dateTime);
      DateFormat formatTime = DateFormat("HH:mm");
      if (dateTime.hour < 12) {
        return date +" lúc "+  formatTime.format(dateTime);
      } else {
        return date + " lúc "+  formatTime.format(dateTime);
      }
    } else {
      DateFormat format = DateFormat("HH:mm");
      if (dateTime.hour < 12) {
        return "Hôm nay " + format.format(dateTime);
      } else {
        return "Hôm nay " + format.format(dateTime);;
      }
    }
  }
  static String convertTimeMessageItemDetail(int time) {
    DateTime now = DateTime.now();
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    if (now.day != dateTime.day) {
      DateFormat format = DateFormat("dd/MM/yyyy");
      String date = format.format(dateTime);
      DateFormat formatTime = DateFormat("HH:mm");
      if (dateTime.hour < 12) {
        return date +" lúc "+  formatTime.format(dateTime);
      } else {
        return date + " lúc "+  formatTime.format(dateTime);
      }
    } else {
      DateFormat format = DateFormat("HH:mm");
      if (dateTime.hour < 12) {
        return "Hôm nay lúc " + format.format(dateTime);
      } else {
        return "Hôm nay lúc " + format.format(dateTime);;
      }
    }
  }

  static String convertTimeMessageItemNoDate(int time) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    DateFormat format = DateFormat("HH:mm");
    if (dateTime.hour < 12) {
      return "Hôm nay " + format.format(dateTime);
    } else {
      return "Hôm nay " + format.format(dateTime);
    }
  }

  static String convertTimeToDateMonthYeah(int time) {
    DateFormat format = DateFormat("dd/MM/yyyy");
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    String date = format.format(dateTime);
    return date;
  }

  static bool compareDate(int timeBeforeIndex, int timeIndex) {
    if (timeBeforeIndex == null) return false;
    if (timeIndex == null) return false;
    return timeBeforeIndex - timeIndex >= 60000;
  }

  static String convertDurationToDateTime(Duration duration) {
    String sHour = "00";
    String sMinute = "00";
    String sSecond = "00";

    if (duration.inMinutes <= 9) {
      sMinute = "0${duration.inMinutes}";
    } else {
      sMinute = duration.inMinutes.toString();
    }
    if (duration.inSeconds <= 9) {
      sSecond = "0${duration.inSeconds}";
    } else {
      sSecond = duration.inSeconds.toString();
    }
    if (duration.inHours > 0) {
      if (duration.inHours <= 9) {
        sHour = "0${duration.inHours}";
      } else {
        sHour = duration.inHours.toString();
      }
      return sHour + ":" + sMinute + ":" + sSecond;
    } else {
      return sMinute + ":" + sSecond;
    }
  }

  static String convertTimeFromDoubleMilSecond(double position) {
    Duration duration = Duration(milliseconds: position.round());
    return convertDurationToDateTime(duration);
  }

  static String convertTimeFromIntMilSecond(int position) {
    Duration duration = Duration(milliseconds: position);
    return convertDurationToDateTime(duration);
  }

  //So sánh ngày được chọn với thời gian hiện tại
  ///[selectDays] = Ngày cần so sánh với thời gian hiên tại
  ///Trả về true nếu ngày được chọn lớn hơn hoặc = ngày hiện tại
  ///Trả về false nếu ngày được chọn nhỏ hơn ngày hiện tại
  static bool compareDateWithCurrentTime(DateTime selectDays) {

    DateTime currentDate = DateTime.now();
    int currentMonth = currentDate.month;
    int currentYear = currentDate.year;
    int currentDay = currentDate.day;

    int selectMoth = selectDays.month;
    int selectYear = selectDays.year;
    int selectDay = selectDays.day;
    if (currentYear > selectYear) {
      return false;
    } else if (currentYear < selectYear) {
      return true;
    } else {
      if (currentMonth > selectMoth) {
        return false;
      } else if (currentMonth < selectMoth) {
        return true;
      } else {
        if (currentDay > selectDay) {
          return false;
        } else if (currentDay < selectDay) {
          return true;
        } else {
          return true;
        }
      }
    }
  }

  static String getMeetingTime(DateTime dateTime) {
    bool isCurrentDay = DateTimeFormat.compareDateWithCurrentTime(dateTime);
    if (isCurrentDay) {
      DateTime currentDateTime = DateTime.now();
      int hour = currentDateTime.hour;
      if (currentDateTime.hour < 23) {
        hour += 1;
        if (hour < 10) {
          return "0$hour:00";
        } else {
          return "$hour:00";
        }
      } else {
        return "23:00";
      }
    } else {
      return "07:00";
    }
  }

  static String formatMeetingDatePicker(DateTime time) {
    DateFormat dateFormat = DateFormat("EEEE, dd/M/yyyy");
    String formatTime = dateFormat.format(time);
    if (formatTime.contains("Sunday")) {
      return formatTime.replaceAll("Sunday", "CN");
    } else if (formatTime.contains("Monday")) {
      return formatTime.replaceAll("Monday", "Thứ 2");
    } else if (formatTime.contains("Tuesday")) {
      return formatTime.replaceAll("Tuesday", "Thứ 3");
    } else if (formatTime.contains("Wednesday")) {
      return formatTime.replaceAll("Wednesday", "Thứ 4");
    } else if (formatTime.contains("Thursday")) {
      return formatTime.replaceAll("Thursday", "Thứ 5");
    } else if (formatTime.contains("Friday")) {
      return formatTime.replaceAll("Friday", "Thứ 6");
    } else {
      return formatTime.replaceAll("Saturday", "Thứ 7");
    }
  }

  static String formatDateTimeToGetRoomMeeting(int year, int month, int day, int meetingHour, int meetingMinute) {
    DateTime dateTime = DateTime(year,month, day, meetingHour, meetingMinute,0,0);
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
    return dateFormat.format(dateTime);
  }
}
