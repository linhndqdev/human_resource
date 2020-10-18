import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';

class CacheHelper {
  static Future<String> getAccessToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String accessToken = pref.getString(Const.ACCESS_TOKEN);
    return accessToken ?? "";
  }

  static Future<void> saveAccessToken(String accessToken) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(Const.ACCESS_TOKEN, accessToken);
  }

  static Future<void> saveLanguage(String languageCode) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(Const.LOCALE, languageCode);
  }

  static Future<String> getLocale() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String locale = pref.getString(Const.LOCALE) ?? Const.VI;
    return locale;
  }

  static Future<void> saveFCMToken(String token) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(Const.TOKEN, token);
  }

  static Future<String> getFCMToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String fcmToken = pref.getString(Const.TOKEN) ?? "";
    return fcmToken;
  }

  static Future<void> saveStateRememberPass(bool isRememberPass) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(Const.REMEMBERPASS, isRememberPass.toString());
  }

  static Future<bool> getStateRememberPass() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String remember = pref.getString(Const.REMEMBERPASS) ?? "true";
    return remember == "true";
  }

  static Future<void> removeCachedWhenLogOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(Const.emailKey);
//    await preferences.remove(Const.chatPasswordKey);
//    await preferences.remove(Const.chatUserNameKey);
    await preferences.remove(Const.ID);
    await preferences.setString(Const.REMEMBERPASS, "false");
  }

  static Future<void> saveUserName({@required String userName}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(Const.chatUserNameKey, userName);
  }
  static Future<void> saveStatusFingerPrint({@required bool status}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(Const.statusFingerPrint, status.toString());
  }
  static Future<bool> getStatusFingerPrint() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String status = preferences.getString(Const.statusFingerPrint)??"false";
    return status == "true";



  }
  static Future<String> getUserName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userName = preferences.getString(Const.chatUserNameKey);
    return userName;
  }

  static Future<void> savePassword({@required String password}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(Const.chatPasswordKey, password);
  }

  static Future<void> saveIdUser({@required String id}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(Const.ID, id);
  }

  static Future<String> getPassword() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String password = preferences.getString(Const.chatPasswordKey);
    return password;
  }

  static Future<String> getID() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String ID = preferences.getString(Const.ID);
    return ID;
  }

  static Future<void> saveLastTimeUpdateJWT(int timestamp) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(Const.lastTimeUpdateJWTKey, "$timestamp");
  }

  static Future<String> getLastTimeUpdateJWT() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String time = preferences.getString(Const.lastTimeUpdateJWTKey);
    return time;
  }

  static void saveLatestImageId(String imageId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(Const.latestImageID, imageId);
  }

  static Future<String> getLatestImageId(String imageId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String latestID = preferences.getString(Const.latestImageID);
    if (latestID == null) latestID = "";
    return latestID;
  }
}
