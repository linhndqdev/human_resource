import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class TaskInfo {
  String taskId;
  String link;
  String name;
  int progress;
  DownloadTaskStatus status = DownloadTaskStatus.undefined;

  TaskInfo(this.link, this.name);
}

//Cần request permission trước khi gọi
class Downloader {
  static String _localPath;

  Downloader._internal();

  static Downloader _instance;
  bool hasPermission = false;

  static Future<Downloader> init() async {
    if (_instance == null) {
      _instance = Downloader._internal();
    }
    return _instance;
  }

  static Future<String> _findLocalPath() async {
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus permission = await Permission.storage.status;
      if (permission != PermissionStatus.granted) {
        PermissionStatus status = await Permission.storage.request();
        return status == PermissionStatus.granted;
      } else {
        return true;
      }
    } else {
      return true;
    }
  }

  void requestDownload({@required TaskInfo task, @required String fileName}) async {
    await _prepare();
    if (hasPermission) {
      String _fileName = fileName;
      task.taskId = await FlutterDownloader.enqueue(
          url: task.link,
          fileName: _fileName,
          savedDir: _localPath,
          showNotification: true,
          openFileFromNotification: true);
    }
  }

  void cancelAllDownload() async {
    await FlutterDownloader.cancelAll();
  }

  void cancelDownload(TaskInfo task) async {
    await FlutterDownloader.cancel(taskId: task.taskId);
  }

  void pauseDownload(TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId);
  }

  void resumeDownload(TaskInfo task) async {
    String newTaskId = await FlutterDownloader.resume(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  void retryDownload(TaskInfo task) async {
    String newTaskId = await FlutterDownloader.retry(taskId: task.taskId);
    task.taskId = newTaskId;
  }

  Future<bool> openDownloadedFile(TaskInfo task) async {
    await _prepare();
    if (hasPermission) {
      return FlutterDownloader.open(taskId: task.taskId);
    }
    return false;
  }

  void delete(TaskInfo task) async {
    await FlutterDownloader.remove(
        taskId: task.taskId, shouldDeleteContent: true);
    await _prepare();
  }

  Future<Null> _prepare() async {
    if (_localPath == null || _localPath == "") {
      _localPath = await _findLocalPath() + Platform.pathSeparator + "Download";
    }
    hasPermission = await _checkPermission();
    if (hasPermission) {
      final savedDir = Directory(_localPath);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        savedDir.create();
      }
    } else {
      Toast.showShort("Vui lòng cấp quyền triu cập bộ nhớ.");
    }
  }
}
