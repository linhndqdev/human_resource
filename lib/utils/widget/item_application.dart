import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/platform/platform_helper.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/home/dashboard/Applicationlist.dart';
import 'package:human_resource/utils/common/cache_helper.dart';
import 'package:human_resource/utils/common/toast.dart';

class ItemApplicationList extends StatefulWidget {
  final String title;
  final String imageAsset;
  final String pkNameAndroid;
  final String pkNameIOS;
  final ApplicationBloc applicationBloc;

  const ItemApplicationList(
      {Key key,
      this.pkNameAndroid,
      this.pkNameIOS,
      this.title,
      this.imageAsset,
      this.applicationBloc})
      : super(key: key);

  @override
  _ItemApplicationListState createState() => _ItemApplicationListState();
}

class _ItemApplicationListState extends State<ItemApplicationList> {
  ItemApplicationListBloc bloc = ItemApplicationListBloc();

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: false,
        stream: bloc.loadingStream.stream,
        builder: (buildContext, AsyncSnapshot<bool> snapshot) {
          widget.applicationBloc.isLoading = snapshot.data;
          if (snapshot.data) {
            return Container(
              width: 174.0.w,
              height: (175 + 18 + 50).h,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(prefix0.accentColor),
                ),
              ),
            );
          }
          return Container(
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                if (widget.pkNameAndroid != null &&
                    widget.pkNameAndroid != "") {
                  bloc.checkAndOpenAppWithPackageName(
                      context, widget.pkNameAndroid, widget.pkNameIOS);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Image.asset(
                      widget.imageAsset,
                      height: ScreenUtil().setWidth(174.0),
                      width: ScreenUtil().setWidth(175.0),
                    ),
                    decoration: BoxDecoration(
                        color: prefix0.white, shape: BoxShape.circle),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(18.0),
                  ),
                  Container(
//                  width: ScreenUtil().setWidth(174.0),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(40.0),
                          fontFamily: "Roboto-Regular",
                          color: Color(0xff0333333),
                          height: 1),
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}

class ItemApplicationListBloc {
  CoreStream<bool> loadingStream = CoreStream();

  void dispose() {
    loadingStream?.closeStream();
  }

  void checkAndOpenAppWithPackageName(
      BuildContext context, String pkNameAndroid, String urlSchemeIOS) async {
    loadingStream?.notify(true);
    if (Platform.isAndroid) {
      bool isInstalledApplication =
          await PlatformHelper.checkAppInstalled(packageName: pkNameAndroid);
      if (isInstalledApplication) {
        String jwt = await CacheHelper.getAccessToken();
        if (jwt != null && jwt != "") {
          String userName = await CacheHelper.getUserName();
          String password = await CacheHelper.getPassword();
          loadingStream?.notify(false);
          PlatformHelper.openAppWithPackageName(
              packageName: pkNameAndroid,
              jwt: jwt,
              userName: userName,
              password: password);
        } else {
          //Không có jwt
          loadingStream?.notify(false);
          AppBloc appBloc = BlocProvider.of(context);
          appBloc.authBloc.logOut(context);
        }
      } else {
        loadingStream?.notify(false);
        Toast.showShort("Ứng dụng chưa được cài đặt.");
        //Đưa lên ChPlay để tải ứng dụng
      }
    } else if (Platform.isIOS) {
      String jwt = await CacheHelper.getAccessToken();
      if (jwt != null && jwt != "") {
        String userName = await CacheHelper.getUserName();
        String password = await CacheHelper.getPassword();
        loadingStream?.notify(false);
        PlatformHelper.openIOSAppWithData(
            urlScheme: urlSchemeIOS,
            jwt: jwt,
            userName: userName,
            password: password);
      } else {
        //Không có jwt
        loadingStream?.notify(false);
        AppBloc appBloc = BlocProvider.of(context);
        appBloc.authBloc.logOut(context);
      }
    }
  }
}
