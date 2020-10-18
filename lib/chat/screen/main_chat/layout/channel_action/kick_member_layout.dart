import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/screen/main_chat/chat/layout_action_bloc.dart';
import 'package:human_resource/chat/screen/main_chat/layout/channel_action/kick_member_bloc.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/utils/common/const.dart';
import 'package:human_resource/utils/common/crypto_hex.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';
import 'package:human_resource/core/style.dart' as prefix0;

class KickMemberActionLayout extends StatefulWidget {
  final WsRoomModel roomModel;
  final LayoutActionBloc layoutActionBloc;

  const KickMemberActionLayout({Key key, this.roomModel, this.layoutActionBloc})
      : super(key: key);

  @override
  _KickMemberActionLayoutState createState() => _KickMemberActionLayoutState();
}

class _KickMemberActionLayoutState extends State<KickMemberActionLayout> {
  KickMemberBloc kickMemberBloc = KickMemberBloc();
  WsAccountModel accountModel;
  TextEditingController _searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  AppBloc appBloc;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      kickMemberBloc.getAllUserOnGroup(widget.roomModel);
    });
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    accountModel = WebSocketHelper.getInstance().wsAccountModel;
    String titleName = "";
    if (widget.roomModel.name == Const.FAQ) {
      titleName = "FAQ";
    } else if (widget.roomModel.name == Const.BAN_TIN) {
      titleName = "Bản tin";
    } else if (widget.roomModel.name ==
        "${Const.THONG_BAO}${appBloc.authBloc.asgUserModel.id}") {
      titleName = "Thông báo";
    } else {
      titleName = CryptoHex.deCodeChannelName(widget.roomModel.name);
    }
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        backgroundColor: prefix0.accentColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(60.0)),
              width: ScreenUtil().setWidth(260.0),
              child: InkWell(
                onTap: () {
                  widget.layoutActionBloc.changeState(LayoutActionState.NONE);
                },
                child: Image.asset("asset/images/back@3x.png",
                    fit: BoxFit.contain,
                    color: prefix0.white,
                    width: ScreenUtil().setWidth(63.5),
                    height: ScreenUtil().setHeight(40.4)),
              ),
            ),
            Flexible(
              child: Text(
                titleName,
                style: TextStyle(
                    fontFamily: 'Roboto-Bold',
                    color: prefix0.white,
                    fontSize: ScreenUtil().setSp(50.0),
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: ScreenUtil().setWidth(260.0),
            ),
          ],
        ),
        elevation: 0.0,
      ),
      body: Stack(
        children: <Widget>[
          _buildLayoutKickMember(),
          StreamBuilder(
              initialData: true,
              stream: kickMemberBloc.loadingStream.stream,
              builder: (loadingContext, AsyncSnapshot<bool> loadingSnap) {
                return Visibility(
                  child: Loading(),
                  visible: loadingSnap.data,
                );
              }),
        ],
      ),
    );
  }

  _buildLayoutKickMember() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
//          _buildLineSearch(),
          Padding(
            padding: EdgeInsets.only(top: ScreenUtil().setHeight(43.9)),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    left: ScreenUtil().setWidth(60.0),
                  ),
                  child: Image.asset(
                    "asset/images/outline-people-24px.png",
                    width: ScreenUtil().setWidth(129.0),
                    height: ScreenUtil().setWidth(129.0),
                    fit: BoxFit.contain,
                    color: prefix0.yellow,
                  ),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(32.0),
                ),
                InkWell(
                  onTap: () {
                    _showDialogRemoveMember(context);
                  },
                  child: Text(
                    "Xóa thành viên",
                    style: TextStyle(
                      color: Color(0xFFe50000),
                      fontFamily: 'Roboto-Regular',
                      fontSize: ScreenUtil().setSp(50.0),
                    ),
                  ),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(178.5),
                )
              ],
            ),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(51.9),
          ),
          Flexible(
            child: StreamBuilder(
              initialData: List<RestUserModel>(),
              stream: kickMemberBloc.listUserModelStream.stream,
              builder: (dataContext,
                  AsyncSnapshot<List<RestUserModel>> listDataSnap) {
                if (listDataSnap.data.length == 0) {
                  return Container(
                    height: 300.0,
                    margin: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Center(
                      child: Text(
                        "Không có thành viên nào.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: prefix0.accentColor, fontSize: 18.0),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(60.0),
                        right: ScreenUtil().setWidth(59.0)),
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemBuilder: (buildContext, index) {
                      return listDataSnap.data[index].id ==
                              widget.roomModel.skAccountModel.id
                          ? _buildItemUser(listDataSnap.data[index], index)
                          : InkWell(
                              onTap: () {
                                searchFocus.unfocus();
                                kickMemberBloc
                                    .pickUserToRemove(listDataSnap.data[index]);
                              },
                              child: _buildItemUser(
                                  listDataSnap.data[index], index),
                            );
                    },
                    separatorBuilder: (buildContext, index) {
                      return Divider(
                        color: prefix0.blackColor,
                      );
                    },
                    itemCount: listDataSnap.data.length);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemUser(RestUserModel restUser, int index) {
    return Container(
      height: 60.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Card(
                elevation: 10.0,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(45.0),
                ),
                child: Container(
                  width: 45.0,
                  height: 45.0,
                  child: Image.asset(
                    "asset/images/baseline-account_circle-24px.png",
                    color: prefix0.accentColor,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 15.0,
          ),
          Expanded(
            child: Container(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      restUser.name,
                      textAlign: TextAlign.start,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: prefix0.text16BlackBold,
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(4.0),
                    ),
                    restUser.id == widget.roomModel.skAccountModel.id
                        ? Text(
                            "Sáng lập nhóm",
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: 'Roboto-Regular',
                                color: Color(0xFF959ca7),
                                fontSize: ScreenUtil().setSp(36.0)),
                          )
                        : Container()
                  ]),
            ),
          ),
          restUser.id == widget.roomModel.skAccountModel.id
              ? Container()
              : kickMemberBloc.userPicked != null &&
                      restUser.id == kickMemberBloc.userPicked.id
                  ? Icon(
                      Icons.check_circle,
                      color: Color(0xFFe18c12),
                      size: ScreenUtil().setHeight(60.0),
                    )
                  : Container(
                      width: ScreenUtil().setHeight(60.0),
                      height: ScreenUtil().setHeight(60.0),
                      decoration: BoxDecoration(
                          color: prefix0.white,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Color(0xFF707070), width: 1.0)),
                    )
        ],
      ),
    );
  }

  _buildLineSearch() {
    return Stack(
      children: <Widget>[
        Container(
          color: Color(0xFFe8e8e8),
          padding: EdgeInsets.only(left: ScreenUtil().setWidth(60.0)),
          width: MediaQuery.of(context).size.width,
          height: ScreenUtil().setHeight(140.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                "asset/images/group-9898@3x.png",
                width: ScreenUtil().setWidth(57.6),
                fit: BoxFit.contain,
              ),
              SizedBox(
                width: ScreenUtil().setWidth(43.0),
              ),
              Expanded(
                child: TextField(
                  focusNode: searchFocus,
                  controller: _searchController,
                  onChanged: (String dataChange) {
                    kickMemberBloc.searchUser(dataChange);
                  },
                  style: TextStyle(
                      color: prefix0.blackColor333,
                      fontSize: ScreenUtil().setSp(44.0)),
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: prefix0.blackColor333,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    hintText: "Tìm theo tên",
                    hintStyle: TextStyle(
                        color: prefix0.blackColor333,
                        fontSize: ScreenUtil().setSp(44.0)),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  void _showDialogRemoveMember(BuildContext context) {
    if (kickMemberBloc.userPicked == null) {
      Toast.showShort("Vui lòng chọn thành viên muốn xóa");
    } else {
      DialogUtils.showDialogRequest(context,
          title: "Xóa thành viên",
          message: "Bạn muốn xóa thành vên?", onClickOK: () {
        kickMemberBloc.kickMember(widget.roomModel);
      });
    }
  }
}
