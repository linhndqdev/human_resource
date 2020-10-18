import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/utils/common/const.dart';
import 'package:human_resource/utils/common/crypto_hex.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/widget/item_group_new.dart';
import 'custom_behavior.dart';
import 'loading_indicator.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';

class ListPrivateGroup extends StatefulWidget {
  @override
  _ListPrivateGroupState createState() => _ListPrivateGroupState();
}

class _ListPrivateGroupState extends State<ListPrivateGroup> {
  AppBloc appBloc;
  MessageDeleteModel messageDeleteModel = MessageDeleteModel();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    ListGroupModel model = appBloc.mainChatBloc.listGroups != null &&
            appBloc.mainChatBloc.listGroups.length > 3
        ? ListGroupModel(
            state: ListGroupState.SHOW,
            listGroupModel: appBloc.mainChatBloc.listGroups)
        : ListGroupModel(state: ListGroupState.NO_DATA);
    return Column(
      children: <Widget>[
        Container(
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                    top: 36.0.h, bottom: 40.0.h, left: 60.w, right: 23.3.w),
                child: InkWell(
                  onTap: () {
                    appBloc.homeBloc.openLayoutCreatePrivateRoom();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "asset/images/ic_addchat.png",
                      width: ScreenUtil().setWidth(165.7),
                    ),
                  ),
                ),
              ),
              Text("Tạo nhóm mới",
                  style: TextStyle(
                      color: Color(0xff959ca7),
                      fontSize: ScreenUtil().setSp(50.0),
                      fontFamily: "Roboto-Regular"))
            ],
          ),
        ),
        //title ĐANG TRỰC TUYẾN
        Expanded(
          child: Container(
            child: StreamBuilder(
                initialData: model,
                stream: appBloc.mainChatBloc.listGroupStream.stream,
                builder: (streamBuildContext,
                    AsyncSnapshot<ListGroupModel> snapshot) {
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
                      return ChildNoData(appBloc: appBloc);
                      break;
                    case ListGroupState.SHOW:
                      List<WsRoomModel> listGroupModel = List();
                      listGroupModel.addAll(snapshot.data.listGroupModel);
                      listGroupModel
                          ?.removeWhere((r) => r.name == Const.BAN_TIN);
                      listGroupModel?.removeWhere((r) => r.name == Const.FAQ);
                      listGroupModel?.removeWhere((r) =>
                          r.name ==
                          "${Const.THONG_BAO}${appBloc.authBloc.asgUserModel.id}");
                      listGroupModel
                          ?.removeWhere((r) => r.id == null || r.id == "");
                      listGroupModel?.removeWhere((r) => r == null);
                      String roomQuerry =
                          appBloc.authBloc.asgUserModel.id.toString();
                      listGroupModel?.removeWhere(
                          (r) => r.name.contains(Const.THONG_BAO + roomQuerry));
                      if (listGroupModel != null &&
                          listGroupModel.length == 0) {
                        return ChildNoData(appBloc: appBloc);
                      }

                      return _buildLayoutPrivateGroupMessage(listGroupModel);
                      break;
                    default:
                      return Container();
                      break;
                  }
                }),
          ),
        )
      ],
    );
  }

  Widget chooseGroupIcon(String nameGroup, int index) {
    String keyCheck =
        Const.THONG_BAO + appBloc.authBloc.asgUserModel.id.toString();
    if (nameGroup == Const.FAQ) {
      return Container(
          margin: EdgeInsets.only(
              left: index == 0 ? ScreenUtil().setWidth(60.0) : 0.0,
              right: ScreenUtil().setWidth(41)),
          child: Column(
            children: <Widget>[
              Container(
                width: ScreenUtil().setHeight(294),
                height: ScreenUtil().setHeight(297),
                decoration: BoxDecoration(
                    color: prefix0.accentColor,
                    borderRadius: BorderRadius.circular(
                        SizeRender.renderBorderSize(context, 5.0))),
                child: Image.asset(
                  "asset/images/group_9906.png",
                  fit: BoxFit.fitWidth,
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(29)),
              Text(
                "FAQ",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(48.0),
                  color: prefix0.accentColor,
                  fontFamily: "Roboto-Bold",
                ),
              ),
            ],
          ));
    } else if (nameGroup == keyCheck) {
      return Container(
          margin: EdgeInsets.only(
              left: index == 0 ? ScreenUtil().setWidth(60.0) : 0.0,
              right: ScreenUtil().setWidth(41)),
          child: Column(
            children: <Widget>[
              Container(
                width: ScreenUtil().setHeight(294),
                height: ScreenUtil().setHeight(294),
                decoration: BoxDecoration(
                    color: prefix0.accentColor,
                    borderRadius: BorderRadius.circular(
                        SizeRender.renderBorderSize(context, 5.0))),
                child: Image.asset(
                  "asset/images/group_9907.png",
                  fit: BoxFit.fitWidth,
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(29)),
              Text(
                "Thông báo",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(48.0),
                  color: prefix0.accentColor,
                  fontFamily: "Roboto-Bold",
                ),
              ),
            ],
          ));
    } else if (nameGroup == Const.BAN_TIN) {
      return Container(
          margin: EdgeInsets.only(
              left: index == 0 ? ScreenUtil().setWidth(60.0) : 0.0,
              right: ScreenUtil().setWidth(41)),
          child: Column(
            children: <Widget>[
              Container(
                width: ScreenUtil().setHeight(294),
                height: ScreenUtil().setHeight(294),
                decoration: BoxDecoration(
                    color: prefix0.accentColor,
                    borderRadius: BorderRadius.circular(
                        SizeRender.renderBorderSize(context, 5.0))),
                child: Image.asset(
                  "asset/images/group_9908.png",
                  fit: BoxFit.fitWidth,
                ),
              ),
              SizedBox(height: ScreenUtil().setHeight(29)),
              Text(
                "Bản tin",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(48.0),
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
                left: index == 0 ? ScreenUtil().setWidth(60.0) : 0.0,
                right: ScreenUtil().setWidth(41)),
            child: Column(
              children: <Widget>[
                Container(
                  width: ScreenUtil().setHeight(294),
                  height: ScreenUtil().setHeight(294),
                  decoration: BoxDecoration(
                      color: prefix0.accentColor,
                      borderRadius: BorderRadius.circular(
                          SizeRender.renderBorderSize(context, 5.0))),
                  child: Image.asset(
                    "asset/images/group_9908.png",
                    fit: BoxFit.fitWidth,
                  ),
                ),
                SizedBox(height: ScreenUtil().setHeight(29)),
                Text(
                  roomNameBase64,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(48.0),
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

  _buildLayoutPrivateGroupMessage(List<WsRoomModel> listPrivateGroup) {
    return ScrollConfiguration(
      behavior: MyBehavior(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 1.0,
            width: MediaQuery.of(context).size.width,
            decoration:
                BoxDecoration(color: Color(0xff959ca7).withOpacity(0.5)),
          ),
          //đường gạch
          Container(
            height: ScreenUtil().setHeight(148.0),
            color: Color(0xff959ca7).withOpacity(0.05),
            child: Row(
              children: <Widget>[
                SizedBox(width: ScreenUtil().setWidth(60.0)),
                Text("DANH SÁCH NHÓM",
                    style: TextStyle(
                        color: Color(0xff959ca7),
                        fontSize: ScreenUtil().setSp(50.0),
                        fontFamily: "Roboto-Regular"))
              ],
            ),
          ),
          Expanded(
            child: _buildListPrivateGroup(listPrivateGroup),
          ),
          //title Liên lạc gần đây
        ],
      ),
    );
  }

  _buildListPrivateGroup(List<WsRoomModel> listPrivateGroup) {
  //  print('---------------build list nhóm----------------------------------------------------------------------');
    return ListView.builder(
      itemCount: listPrivateGroup.length,
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: (buildContext, index) {
        return ItemGroupNew(roomModel: listPrivateGroup[index]);
      },
    );
  }
}

class ChildNoData extends StatelessWidget {
  const ChildNoData({
    Key key,
    @required this.appBloc,
  }) : super(key: key);

  final AppBloc appBloc;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ScrollConfiguration(
        behavior: MyBehavior(),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(275.0),
                bottom: ScreenUtil().setHeight(36.2),
                left: ScreenUtil().setWidth(276.0),
                right: ScreenUtil().setWidth(275.7),
              ),
              child: Image.asset(
                "asset/images/illustration.png",
              ),
            ),
            Container(
              child: Text(
                "Không có nhóm nào!",
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(50.0),
                    fontFamily: "Roboto-Regular",
                    fontWeight: FontWeight.bold,
                    color: Color(0xff333333)),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: ScreenUtil().setWidth(848.0),
              margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(14.0),
                left: ScreenUtil().setWidth(116.0),
                right: ScreenUtil().setWidth(116.0),
              ),
              child: Text(
                "Bạn chưa thực hiện cuộc trò chuyện nhóm nào, vui lòng tạo nhóm mới.",
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(50.0),
                    fontFamily: "Roboto-Regular",
                    fontWeight: FontWeight.normal,
                    color: Color(0xff333333)),
                textAlign: TextAlign.justify,
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(15.0),
              ),
              child: InkWell(
                onTap: () {
                  appBloc.homeBloc.openLayoutCreatePrivateRoom();
                },
                child: Text(
                  "Tạo nhóm mới",
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(50.0),
                      fontFamily: "Roboto-Regular",
                      fontWeight: FontWeight.bold,
                      color: Color(0xff005a88)),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListPrivateBloc {}
