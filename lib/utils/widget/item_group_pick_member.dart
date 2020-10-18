import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';

import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/common/crypto_hex.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:flutter_screenutil/size_extension.dart';
typedef OnPickAllMemberOnRoom = Function(bool isPicked, List<RestUserModel>);

class ItemGroupPickMember extends StatefulWidget {
  final WsRoomModel roomModel;
  final OnPickAllMemberOnRoom onPickAllMemberOnRoom;

  const ItemGroupPickMember(
      {Key key, this.roomModel, this.onPickAllMemberOnRoom})
      : super(key: key);

  @override
  _ItemGroupPickMemberState createState() => _ItemGroupPickMemberState();
}

class _ItemGroupPickMemberState extends State<ItemGroupPickMember> {
  String roomName;
  ItemGroupPickMemberBloc _bloc = ItemGroupPickMemberBloc();

  @override
  void didUpdateWidget(ItemGroupPickMember oldWidget) {
    // TODO: implement didUpdateWidget
//    super.didUpdateWidget(oldWidget);
    Future.delayed(Duration.zero, () {
      if (mounted) _bloc.getMemberGroup(widget.roomModel);
    });
  }

//  @override
//  void didChangeDependencies() {
//    // TODO: implement didChangeDependencies
//    super.didChangeDependencies();
//    Future.delayed(Duration.zero, () {
//      _bloc.getMemberGroup(context, widget.roomModel);
//    });
//  }
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) _bloc.getMemberGroup(widget.roomModel);
    });
  }

  @override
  Widget build(BuildContext context) {
    roomName = CryptoHex.deCodeChannelName(widget.roomModel.name);
    return GestureDetector(
        onTap: () {
          setState(() {
            _bloc.changeState();
            widget.onPickAllMemberOnRoom(_bloc.isAdded, _bloc.listUserGroup);
          });
        },
        child: Stack(
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                    color: prefix0.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 90, 136, 0.2),
                          blurRadius: ScreenUtil().setWidth(8.0),
                          spreadRadius: 0)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Center(
                        child: CustomCircleAvatar(
                      size: 195.0,
                      userName: widget.roomModel.skAccountModel.userName,
                      position: ImagePosition.GROUP,
                    )),
                    SizedBox(height: ScreenUtil().setHeight(10.0)),
                    Center(
                      child: Text(
                        roomName ?? "Không xác định",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(50.0),
                            fontFamily: "Roboto-Regular",
                            fontWeight: FontWeight.normal,
                            color: Color(0xff333333)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    StreamBuilder(
                        initialData: null,
                        stream: _bloc.listMemberStream.stream,
                        builder: (buildContext,
                            AsyncSnapshot<List<RestUserModel>> listSnapshot) {
                          int size = 0;
                          if (!listSnapshot.hasData ||
                              listSnapshot.data == null ||
                              listSnapshot.data.length == 0) {
                            return Container(
                              width: ScreenUtil().setWidth(74.0),
                              height: ScreenUtil().setHeight(74.0),
                              margin: EdgeInsets.only(
                                top: ScreenUtil().setHeight(14.0),
                                left: ScreenUtil().setWidth(106),
                                right: ScreenUtil().setWidth(106),
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: ScreenUtil().setWidth(2.0),
                                ),
                              ),
                            );
                          }
                          if (listSnapshot.data.length > 5)
                            size = 5;
                          else
                            size = listSnapshot.data.length;
                          return Container(
                            margin: EdgeInsets.only(
                              left: ScreenUtil().setWidth(106),
                              right: ScreenUtil().setWidth(106),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Stack(
                                  children: [
                                    for (int i = 0; i < size; i++)
                                      Container(
                                        width: ScreenUtil().setWidth(74.0),
                                        height: ScreenUtil().setHeight(74.0),
                                        margin: EdgeInsets.only(
                                          top: ScreenUtil().setHeight(14.0),
                                          left: ScreenUtil().setWidth(i * 40),
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: ScreenUtil().setWidth(2.0),
                                          ),
                                        ),
                                        child: CustomCircleAvatar(
                                          position: ImagePosition.GROUP,
                                          size: 75.0,
                                          userName:
                                              listSnapshot.data[i].username,
                                        ),
                                      ),
                                  ],
                                )
                              ],
                            ),
                          );
                        }),
                    Center(
                      child: new Text(
                        widget.roomModel.usersCount.toString() + " thành viên",
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(40.0),
                            fontFamily: "Roboto-Regular",
                            fontWeight: FontWeight.normal,
                            color: Color(0xff959ca7)),
                      ),
                    ),
                    SizedBox(height: 64.0.h,),
                  ],
                )),
            Positioned(
              top: ScreenUtil().setHeight(28.0),
              right: ScreenUtil().setWidth(26),
              child: Container(
                  height: ScreenUtil().setHeight(60),
                  child: StreamBuilder(
                      initialData: false,
                      stream: _bloc.pickedStream.stream,
                      builder: (buildContext,
                          AsyncSnapshot<bool> isAddedMemberSnap) {
                        return isAddedMemberSnap.data
                            ? Image.asset(
                                "asset/images/ic_confirm_a_memmber.png")
                            : Image.asset("asset/images/ic_dismiss_member.png");
                      })),
            ),
          ],
        ));
  }
}

class ItemGroupPickMemberBloc {
  CoreStream<List<RestUserModel>> listMemberStream = CoreStream();
  CoreStream<bool> pickedStream = CoreStream();
  List<RestUserModel> listUserGroup = List();
  bool isAdded = false;

  void changeState() {
    isAdded = !isAdded;
    pickedStream.notify(isAdded);
  }

  void getMemberGroup(WsRoomModel roomModel) async {
    ApiServices apiServices = ApiServices();
    await apiServices.getAllUserOnGroup(roomModel, resultData: (resultData) {
      try {
        Iterable iterable = resultData['members'];
        if (iterable != null && iterable.length > 0) {
          listUserGroup = iterable
              .map((user) => RestUserModel.fromGetAllUser(user))
              .toList();
          listMemberStream.notify(listUserGroup);
        }
      } catch (ex) {
        listMemberStream.notify(listUserGroup);
      }
    }, onErrorApiCallback: (onError) {
      listMemberStream.notify(listUserGroup);
    });
  }
}
