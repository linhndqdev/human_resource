
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/utils/common/const.dart';
import 'package:human_resource/utils/common/crypto_hex.dart';

import 'package:human_resource/core/style.dart' as prefix0;
import 'custom_behavior.dart';
import 'loading_indicator.dart';

class ListDefaultGroup extends StatefulWidget {
  @override
  _ListDefaultGroupState createState() => _ListDefaultGroupState();
}

class _ListDefaultGroupState extends State<ListDefaultGroup> {
  AppBloc appBloc;

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return Container(
      height: ScreenUtil().setHeight( 400),
      child: StreamBuilder(
        initialData: ListGroupModel(state: ListGroupState.LOADING),
        stream: appBloc.mainChatBloc.listGroupStream.stream,
        builder: (streamBuildContext, AsyncSnapshot<ListGroupModel> snapshot) {
          switch (snapshot.data.state) {
            case ListGroupState.LOADING:
              return Center(
                child: LoadingIndicator(
                  color: prefix0.accentColor,
                ),
              );
              break;
            case ListGroupState.ERROR:
              return Container();
              break;
            case ListGroupState.NO_DATA:
              return Container();
              break;
            case ListGroupState.SHOW:
              return ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: snapshot.data.listGroupModel.length,
                    itemBuilder: (buildContext, index) {
                      return InkWell(
                          onTap: () {
                            appBloc.mainChatBloc.openRoom(
                                appBloc, snapshot.data.listGroupModel[index]);
                          },
                          child: chooseGroupIcon(
                              snapshot.data.listGroupModel[index].name, index));
                    },
                  ));
              break;
            default:
              return Container();
              break;
          }
        },
      ),
    );
  }

  Widget chooseGroupIcon(String nameGroup, int index) {
    String keyCheck = Const.THONG_BAO+appBloc.authBloc.asgUserModel.id.toString();
    if (nameGroup == Const.FAQ) {
      return Container(
          margin: EdgeInsets.only(
              left: index == 0 ? ScreenUtil().setWidth( 60.0) : 0.0,
              right: ScreenUtil().setWidth( 41)),
          child: Column(
            children: <Widget>[
              Container(
                width: ScreenUtil().setHeight( 294),
                height: ScreenUtil().setHeight( 297),
                decoration: BoxDecoration(
                    color: prefix0.accentColor,
                    borderRadius: BorderRadius.circular(
                        SizeRender.renderBorderSize(context, 5.0))),
                child: Image.asset(
                  "asset/images/group_9906.png",
                  fit: BoxFit.fitWidth,
//ngocanh2
//                  color: prefix0.whiteColor,
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight( 29)),
              Text(
                "FAQ",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp( 48.0),
                    color: prefix0.accentColor,
                    fontFamily: "Roboto-Bold",
                    ),
              ),
            ],
          ));
    } else if (nameGroup == keyCheck) {
      return Container(
          margin: EdgeInsets.only(
              left: index == 0 ? ScreenUtil().setWidth( 60.0) : 0.0,
              right: ScreenUtil().setWidth( 41)),
          child: Column(
            children: <Widget>[
              Container(
                width: ScreenUtil().setHeight( 294),
                height: ScreenUtil().setHeight( 294),
                decoration: BoxDecoration(
                    color: prefix0.accentColor,
                    borderRadius: BorderRadius.circular(
                        SizeRender.renderBorderSize(context, 5.0))),
                child: Image.asset(
                  "asset/images/group_9907.png",
                  fit: BoxFit.fitWidth,
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight( 29)),
              Text(
                "Thông báo",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp( 48.0),
                    color: prefix0.accentColor,
                    fontFamily: "Roboto-Bold",
                    ),
              ),
            ],
          ));
    } else if (nameGroup == Const.BAN_TIN) {
      return Container(
          margin: EdgeInsets.only(
              left: index == 0 ? ScreenUtil().setWidth( 60.0) : 0.0,
              right: ScreenUtil().setWidth( 41)),
          child: Column(
            children: <Widget>[
              Container(
                width: ScreenUtil().setHeight( 294),
                height: ScreenUtil().setHeight( 294),
                decoration: BoxDecoration(
                    color: prefix0.accentColor,
                    borderRadius: BorderRadius.circular(
                        SizeRender.renderBorderSize(context, 5.0))),
                child: Image.asset(
                  "asset/images/group_9908.png",
                  fit: BoxFit.fitWidth,
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight( 29)),
              Text(
                "Bản tin",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp( 48.0),
                    color: prefix0.accentColor,
                    fontFamily: "Roboto-Bold",
                   ),
              ),
            ],
          ));
    } else {
      try {
        String roomNameBase64 = CryptoHex.deCodeChannelName(nameGroup);
        return Container(
            margin: EdgeInsets.only(
                left:
                    index == 0 ? ScreenUtil().setWidth( 60.0) : 0.0,
                right: ScreenUtil().setWidth( 41)),
            child: Column(
              children: <Widget>[
                Container(
                  width: ScreenUtil().setHeight( 294),
                  height: ScreenUtil().setHeight( 294),
                  decoration: BoxDecoration(
                      color: prefix0.accentColor,
                      borderRadius: BorderRadius.circular(
                          SizeRender.renderBorderSize(context, 5.0))),
                  child: Image.asset(
                    "asset/images/group_9908.png",
                    fit: BoxFit.fitWidth,
                  ),
                ),
                SizedBox(height: ScreenUtil().setHeight( 29)),
                Text(
                  roomNameBase64,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp( 48.0),
                      color: prefix0.accentColor,
                      fontFamily: "Roboto-Bold",
                      ),
                ),
              ],
            ));
      } catch (ex) {
        return Container();
      }
    }
  }


}
