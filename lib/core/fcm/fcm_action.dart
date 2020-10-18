import 'package:human_resource/core/api_services.dart';

abstract class FCMAction {
  //Gửi FCM token lên server
  Future<void> postTokenToServer(
      {OnResultData onResultData, OnErrorApiCallback onErrorApiCallback});

  //Gửi FCM message
  Future<void> sendFCMMessage(
      {
      OnResultData onResultData,
      OnErrorApiCallback onErrorApiCallback});

  //Remove Token
  Future<void> removeToken(
      {OnResultData onResultData, OnErrorApiCallback onErrorApiCallback});
}
