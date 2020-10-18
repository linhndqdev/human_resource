import 'package:flutter/material.dart';
import 'package:human_resource/core/api_services.dart';

abstract class MeetingAction {
  //Lấy ra danh sách phòng trống theo thời gian
  Future<void> getRoomAvailableAtTime(
      {@required String dateTime,
      @required int meetingTimeLimit,
      @required OnResultData resultData,
      @required OnErrorApiCallback onErrorApiCallback});

  //Khởi tạo lịch họp
  Future<void> createMeeting(
      {@required String topic,
      @required String description,
      @required String startAt,
      @required int duration,
      @required int roomId,
      @required List<int> listParticipantID,
      @required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback});

  Future<void> getDetailMeeting(
      {@required String meetingID,
      @required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback});

  Future<void> deleteMeeting(
      {@required String meetingID,
      @required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback});

  Future<void> updateMeetingInfo(
      {@required String topic,
      @required String description,
      @required String startAt,
      @required int duration,
      @required int roomId,
      @required List<int> listParticipantID,
      @required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback});

  Future<void> getMemberInfo(
      {@required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback});

  Future<void> getAllMember(
      {@required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback});

  Future<void> getAllMeeting(
      {@required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback});

  Future<void> acceptOrRefuseMeeting(
      {@required String meetingID,
      @required bool isAccept,
      @required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback});

  Future<void> attendMeeting(
      {@required String meetingID,
      @required OnResultData onResultData,
      @required OnErrorApiCallback onErrorApiCallback});
}
