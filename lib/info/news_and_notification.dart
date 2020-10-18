import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:human_resource/info/infomation_emty_screen.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/info/orient_bloc.dart';

import 'news_and_notification_screen.dart';

class NewAndNotification extends StatefulWidget {
  final String typeId;

  NewAndNotification({this.typeId});

  @override
  _NewAndNotificationState createState() => _NewAndNotificationState();
}

class _NewAndNotificationState extends State<NewAndNotification> {
  AppBloc appBloc;
  ScrollController controller;
  OrientBloc orientBloc = OrientBloc();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      appBloc.orientBloc.resetData();
      appBloc.orientBloc.getInformationNewsAndNotification(
          typeId: widget.typeId, context: context, page: "1");
    });
  }

  @override
  void didUpdateWidget(NewAndNotification oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    Future.delayed(Duration.zero, () {
      appBloc.orientBloc.resetData();
      appBloc.orientBloc.getInformationNewsAndNotification(
          typeId: widget.typeId, context: context, page: "1");
    });
  }


  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return Container(
      child: StreamBuilder(
        initialData: LoadDataNotificationModel(
            loadDataNotificationAndNewsState:
                LoadDataNotificationAndNewsState.LOADDING,
            data: null),
        stream: appBloc.orientBloc.loadDataNotificationModelStream.stream,
        builder:
            (buildContext, AsyncSnapshot<LoadDataNotificationModel> snapshot) {
          switch (snapshot.data.loadDataNotificationAndNewsState) {
            case LoadDataNotificationAndNewsState.HAVEDATA:
              return NewAndNotificationScreen(
                list: snapshot.data.data,
                typeId: widget.typeId,
              );
              break;
            case LoadDataNotificationAndNewsState.NODATA:
              if (widget.typeId.contains("1")) {
                return InformationEmpty(" thông báo ");
              } else {
                return InformationEmpty(" bản tin ");
              }
              break;
            default:
              return Center(
                child: CircularProgressIndicator(),
              );
              break;
          }
        },
      ),
    );
  }
}
