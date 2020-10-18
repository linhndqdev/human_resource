import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/main.dart';
import 'package:human_resource/utils/common/local_notification.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'core/hive/hive_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveHelper.init();
  DefaultCacheManager manager = new DefaultCacheManager();
  try {
    manager.emptyCache();
  } catch (ex) {} // data in cache.
  await FlutterDownloader.initialize();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  LocalNotification.getInstance().initLocalNotification();
  Constant.setEnvironment(Environment.PROD);
  final appBloc = AppBloc();
  WebSocketHelper.getInstance().init(appBloc);
  //  runApp(configuredApp);
  initializeDateFormatting().then(
    (_) => runApp(App(
      appBloc: appBloc,
    )),
  );
}