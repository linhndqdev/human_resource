import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/home/home_bloc.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/utils/widget/custom_behavior.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';
import 'create_private_channel_bloc.dart';

typedef OnOpenRoom = Function(WsRoomModel);

class CreatePrivateChannelLayout extends StatefulWidget {
  final OnOpenRoom onOpenRoom;
  final bool isOpenFromAddressBook;
  final VoidCallback onClickLeading;

  const CreatePrivateChannelLayout(
      {Key key,
      this.onOpenRoom,
      this.isOpenFromAddressBook = false,
      this.onClickLeading})
      : super(key: key);

  @override
  _CreatePrivateChannelLayoutState createState() =>
      _CreatePrivateChannelLayoutState();
}

class _CreatePrivateChannelLayoutState
    extends State<CreatePrivateChannelLayout> {
  AppBloc appBloc;
  CreatePrivateChannelBloc bloc = CreatePrivateChannelBloc();
  TextEditingController _channelNameController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  FocusNode channelNameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      bloc.setMapData(appBloc.mainChatBloc.listUserOnChatSystem,
          appBloc.mainChatBloc.listDirectRoom);
    });
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel =
        FocusWidgetModel(state: isFocusWidget.CREATE_PRIVATE_GROUP);
    return WillPopScope(
      onWillPop: () async {
        _showDialogBack();
        appBloc.backStateBloc.focusWidgetModel =
            FocusWidgetModel(state: isFocusWidget.HOME); //đ
        return false;
      },
      child: StreamBuilder(
          initialData: false,
          stream: bloc.loadAllDataStream.stream,
          builder: (loadAllDataContext, AsyncSnapshot<bool> snapshotData) {
            if (!snapshotData.hasData ||
                snapshotData.data == null ||
                snapshotData.data == false) {
              return Container(
                color: prefix0.white,
                child: Loading(),
              );
            }
            return Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  titleSpacing: 0.0,
                  backgroundColor: prefix0.accentColor,
                  title: Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: 178.5.h,
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          child: InkWell(
                              onTap: () {
                                _showDialogExit();
                              },
                              child: Container(
                                height: 178.5.h,
                                padding: EdgeInsets.only(
                                    left: 60.w, right: 60.w, bottom: 66.2.h,top: 60.h),
                                child: Image.asset(
                                    "asset/images/ic_meeting_back_white.png",
                                    fit: BoxFit.contain,
                                    color: prefix0.whiteColor,
                                    width: ScreenUtil().setWidth(49)),
                              )
                          ),
                        ),
                        Center(
                          child:  Text(
                            "Tạo nhóm mới",
                            style: TextStyle(
                                fontFamily: 'Roboto-Bold',
                                color: prefix0.whiteColor,
                                fontSize: ScreenUtil().setSp(60.0),
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.normal),
                          ),
                        )
                      ],
                    ),
                  ),
                  elevation: 0.0,
                  centerTitle: true,
                ),
                body: GestureDetector(
                    onTap: () {
                      if (searchFocus.hasFocus) {
                        _searchController.clear();
                        searchFocus.unfocus();
                        bloc.enableSearchStream.notify(false);
                      }
                      if (channelNameFocus.hasFocus) {
                        channelNameFocus.unfocus();
                      }
//              FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Stack(
                      children: <Widget>[
                        _buildMainLayout(),
                        StreamBuilder(
                            initialData: false,
                            stream: bloc.loadingStream.stream,
                            builder: (loadingContext,
                                AsyncSnapshot<bool> snapshotData) {
                              return Visibility(
                                  visible: snapshotData.data, child: Loading());
                            }),
                      ],
                    )));
          }),
    );
  }

  //Tạo nhóm
  _buildMainLayout() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    left: ScreenUtil().setWidth(60.0),
                  ),
                  child: Image.asset("asset/images/outline-people-24px.png",
                      width: ScreenUtil().setWidth(129.0),
                      height: ScreenUtil().setWidth(129.0),
                      fit: BoxFit.contain,
                      color: Color(0xffe18c12)),
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(32.0),
                ),
                Expanded(
                    child: Stack(
                  children: <Widget>[
                    TextField(
                      focusNode: channelNameFocus,
                      controller: _channelNameController,
                      onChanged: (String dataChange) {
                        bloc.checkInputData(dataChange);
                      },
                      style: prefix0.text16BlackBold,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      cursorColor: prefix0.blackColor,
                      decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.only(bottom: 5.5.h, right: 100.0.h),
                        isDense: true,
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: prefix0.accentColor, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        hintText: "Đặt Tên nhóm",
                        hintStyle: TextStyle(
                            color: Color(0xFF959ca7),
                            fontFamily: "Roboto-Regular",
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(50.0)),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: StreamBuilder(
                          initialData: false,
                          stream: bloc.showButtonCreateStream.stream,
                          builder:
                              (streamContext, AsyncSnapshot<bool> snapshot) {
                            if (snapshot.data) {
                              return Image.asset(
                                "asset/images/path-233@3x.png",
                                fit: BoxFit.contain,
                                width: ScreenUtil().setWidth(55.7),
                                height: ScreenUtil().setWidth(42.4),
                              );
                            } else {
                              return Container();
                            }
                          }),
                    )
                  ],
                )),
                SizedBox(
                  width: ScreenUtil().setWidth(178.5),
                )
              ],
            ),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(60.0),
          ),

          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: StreamBuilder(
                      initialData: false,
                      stream: bloc.updateTagsStream.stream,
                      builder:
                          (tagsContext, AsyncSnapshot<dynamic> snapdhotData) {
                        List<Widget> tags = List();
                        bloc.mapUserPicked.keys.forEach((user) {
                          if (bloc.mapUserPicked[user]) {
                            tags.add(
                              InkWell(
                                  onTap: () {
                                    bloc.removeUserPicked(user);
                                  },
                                  child: _buildItemUserPicked(user)),
                            );
                          }
                        });
                        if (tags != null && tags.length > 0) {
                          return Container(
                            padding: EdgeInsets.only(
                              left: 60.0.h,
                            ),
                            height: 195.0.h,
                            child: ScrollConfiguration(
                                behavior: MyBehavior(),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: tags.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return tags[index];
                                  },
                                )),
                          );
                        } else {
                          return Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(
                                top: ScreenUtil().setWidth(33.0),
                                left: ScreenUtil().setWidth(60.0)),
                            child: Text(
                              "0 thành viên",
                              style: TextStyle(
                                  fontFamily: "Roboto-Regular",
                                  color: Color(0xFF333333),
                                  fontSize: ScreenUtil().setSp(50.0),
                                  fontWeight: FontWeight.normal),
                            ),
                          );
                        }
                      })),
              StreamBuilder(
                  initialData: false,
                  stream: bloc.showButtonCreateStream.stream,
                  builder: (streamContext, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.data) {
                      return InkWell(
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          bloc.createPrivateChannel(context, appBloc,
                              _channelNameController.text.toString(),
                              onCreateSuccess: (WsRoomModel roomModel) {
                            widget.onOpenRoom(roomModel);
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              right: ScreenUtil().setWidth(59.0),
                              bottom: 15.h,
                              left: 20.0.w
                          ),
                          decoration: BoxDecoration(
                              color: prefix0.accentColor,
                              shape: BoxShape.circle),
                          width: ScreenUtil().setWidth(150.0),
                          height: ScreenUtil().setWidth(223.0),
                          child: Image.asset(
                            "asset/images/ic_next_action.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
            ],
          ),
          StreamBuilder(
              initialData: false,
              stream: bloc.updateTagsStream.stream,
              builder: (tagsContext, AsyncSnapshot<dynamic> snapdhotData) {
                int count = 0;
                bloc.mapUserPicked.keys?.forEach((user) {
                  if (bloc.mapUserPicked[user]) {
                    count += 1;
                  }
                });
                return count != 0
                    ? Container(
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.only(
                            top: ScreenUtil().setWidth(29.0),
                            left: ScreenUtil().setWidth(60.0)),
                        child: Text(
                          "$count thành viên",
                          style: TextStyle(
                              fontFamily: "Roboto-Regular",
                              color: Color(0xFF333333),
                              fontSize: ScreenUtil().setSp(50.0),
                              fontWeight: FontWeight.normal),
                        ),
                      )
                    : Container();
              }),
          StreamBuilder<FilterTabStreamModel>(
              initialData: FilterTabStreamModel(
                  state: FilterMemberTabState.LIEN_LAC_GAN_DAY),
              stream: bloc.clickTabStream.stream,
              builder: (context, snapshot) {
                return Container(
                  height: ScreenUtil().setHeight(148.0),
                  color: Color(0xff959ca7).withOpacity(0.05),
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: ScreenUtil().setWidth(60.0)),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            bloc.changeTab(
                                FilterMemberTabState.LIEN_LAC_GAN_DAY);
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text("LIÊN LẠC GẦN ĐÂY",
                                style: TextStyle(
                                    color: snapshot.data.state ==
                                            FilterMemberTabState
                                                .LIEN_LAC_GAN_DAY
                                        ? Color(0xff005a88)
                                        : Color(0xff959ca7),
                                    fontSize: ScreenUtil().setSp(50.0),
                                    fontFamily: "Roboto-Regular",
                                    fontWeight: FontWeight.normal)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            bloc.changeTab(FilterMemberTabState.THEO_DANH_BA);
                          },
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Text("THEO DANH BẠ",
                                style: TextStyle(
                                    color: snapshot.data.state ==
                                            FilterMemberTabState.THEO_DANH_BA
                                        ? Color(0xff005a88)
                                        : Color(0xff959ca7),
                                    fontSize: ScreenUtil().setSp(50.0),
                                    fontFamily: "Roboto-Regular",
                                    fontWeight: FontWeight.normal)),
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(60.0))
                    ],
                  ),
                );
              }),
          //ô tìm kiếm
          _buildLineSearch(),

          Expanded(
            child: StreamBuilder<FilterTabStreamModel>(
                initialData: FilterTabStreamModel(
                    state: FilterMemberTabState.LIEN_LAC_GAN_DAY),
                stream: bloc.clickTabStream.stream,
                builder: (context, snapshot) {
                  return _buildListUserSearchAndSystem(snapshot.data.state);
                }),
          )
        ],
      ),
    );
  }

  _buildListUserSearchAndSystem(FilterMemberTabState state) {
    return StreamBuilder(
        initialData: false,
        stream: bloc.enableSearchStream.stream,
        builder: (enableSearchContext, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data) {
            return StreamBuilder(
                initialData: false,
                stream: bloc.updateTagsStream.stream,
                builder:
                    (checkAllContext, AsyncSnapshot<bool> snapshotCheckedAll) {
                  String searchData = _searchController.text.trim().toString();
                  Map<AddressBookModel, bool> mapData = Map();
                  if (state == FilterMemberTabState.LIEN_LAC_GAN_DAY) {
                    bloc.listUserFromDirectRoom?.forEach((user) {
                      if (user.name.contains(searchData) ||
                          user.name
                              .toLowerCase()
                              .contains(searchData.toLowerCase()) ||
                          user.name
                              .toUpperCase()
                              .contains(searchData.toUpperCase())) {
                        mapData[user] = bloc.mapUserPicked[user];
                      }
                    });
                  } else {
                    bloc.listAllUserOnSystem?.forEach((user) {
                      if (user.name.contains(searchData) ||
                          user.name
                              .toLowerCase()
                              .contains(searchData.toLowerCase()) ||
                          user.name
                              .toUpperCase()
                              .contains(searchData.toUpperCase())) {
                        mapData[user] = bloc.mapUserPicked[user];
                      }
                    });
                  }
                  if (mapData.keys.length > 0) {
                    return ListView.builder(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(60.0),
                          right: ScreenUtil().setWidth(59.0)),
                      itemCount: mapData.keys.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (buildContext, index) {
                        return InkWell(
                          onTap: () {
                            AddressBookModel model =
                                mapData.keys.elementAt(index);
                            bloc.pickUser(model);
                          },
                          child: _buildItemUser(
                              mapData.keys.elementAt(index), index, state),
                        );
                      },
                    );
                  } else {
                    return Container(
                      height: 150.0,
                      child: Center(
                        child: Text(
                          "Không tìm thấy người dùng",
                          style: TextStyle(
                            fontFamily: "Roboto-Regular",
                            color: prefix0.blackColor333,
                            fontSize: ScreenUtil().setSp(48.0),
                          ),
                        ),
                      ),
                    );
                  }
                });
          } else {
            if (state == FilterMemberTabState.THEO_DANH_BA) {
              if (bloc.listAllUserOnSystem == null ||
                  bloc.listAllUserOnSystem.length < 1) {
                return Container(
                  height: 150.0,
                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Center(
                    child: Text("Không có người dùng nào trong danh bạ.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Roboto-Regular",
                          color: prefix0.blackColor333,
                          fontSize: ScreenUtil().setSp(48.0),
                        )),
                  ),
                );
              }
            } else {
              if (bloc.listUserFromDirectRoom == null ||
                  bloc.listUserFromDirectRoom.length < 1) {
                return Container(
                  height: 150.0,
                  margin: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: Center(
                    child: Text(
                        "Không có người dùng trong danh sách liên lạc gần đây.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "Roboto-Regular",
                          color: prefix0.blackColor333,
                          fontSize: ScreenUtil().setSp(48.0),
                        )),
                  ),
                );
              }
            }
            return StreamBuilder(
                initialData: false,
                stream: bloc.updateTagsStream.stream,
                builder:
                    (checkAllContext, AsyncSnapshot<bool> snapshotCheckedAll) {
                  return ListView.builder(
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(60.0),
                        right: ScreenUtil().setWidth(59.0)),
                    itemCount: state == FilterMemberTabState.THEO_DANH_BA
                        ? bloc.listAllUserOnSystem.length
                        : bloc.listUserFromDirectRoom.length,
                    addAutomaticKeepAlives: false,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (buildContext, index) {
                      AddressBookModel model =
                          state == FilterMemberTabState.THEO_DANH_BA
                              ? bloc.listAllUserOnSystem[index]
                              : bloc.listUserFromDirectRoom[index];
                      return InkWell(
                        onTap: () {
                          bloc.pickUser(model);
                        },
                        child: _buildItemUser(model, index, state),
                      );
                    },
                  );
                });
          }
        });
  }

  Widget _buildItemUser(AddressBookModel addressBookModel, int index,
      FilterMemberTabState state) {
    return Column(
      children: <Widget>[
        index == 0
            ? Container(
                margin: EdgeInsets.only(
                    bottom: ScreenUtil().setHeight(19.5),
                    top: ScreenUtil().setHeight(34.0)),
                child: Divider(
                  color: Color(0xFF707070),
                ),
              )
            : Container(),
        Container(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              CustomCircleAvatar(
                position: ImagePosition.GROUP,
                userName: addressBookModel.username,
                size: 114.0,
              ),
              SizedBox(
                width: ScreenUtil().setWidth(89.9),
              ),
              Expanded(
                child: Container(
                  child: Text(
                    addressBookModel.name,
                    textAlign: TextAlign.start,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: "Roboto-Regular",
                        color: prefix0.blackColor333,
                        fontSize: ScreenUtil().setSp(48.0)),
                  ),
                ),
              ),
              bloc.mapUserPicked[addressBookModel]
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
        ),
        SizedBox(
          height: ScreenUtil().setWidth(21.5),
        ),
        Divider(
          color: Color(0xFF707070),
        ),
        SizedBox(
          height: ScreenUtil().setWidth(19.5),
        ),
      ],
    );
  }

  //Phần search
  _buildLineSearch() {
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
              left: ScreenUtil().setWidth(60),
              right: ScreenUtil().setWidth(59),
              bottom: ScreenUtil().setHeight(56)),
          padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(46),
              top: ScreenUtil().setHeight(29),
              bottom: ScreenUtil().setHeight(34.9)),
          width: ScreenUtil().setWidth(961),
          decoration: BoxDecoration(
            color: Color(0xffe8e8e8),
            borderRadius: BorderRadius.circular(ScreenUtil().setWidth(57.0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: Image.asset(
                  "asset/images/group_9898.png",
                  color: prefix0.blackColor333,
                  width: ScreenUtil().setWidth(58.0),
                  height: ScreenUtil().setHeight(58.0),
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(30.7),
              ),
              Expanded(
                child: TextField(
                  focusNode: searchFocus,
                  controller: _searchController,
                  onChanged: (String dataChange) {
                    bloc.searchUser(dataChange);
                  },
                  style: TextStyle(
                      color: prefix0.blackColor333,
                      fontSize: ScreenUtil().setSp(44.0)),
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor:prefix0.blackColor333,
                  decoration: InputDecoration(
                    isDense: true,
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
                        fontFamily: "Roboto-Regular",
                        fontSize: ScreenUtil().setSp(44.0)),
                  ),
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(107.5),
              ),
            ],
          ),
        ),
        Positioned(
          top: ScreenUtil().setHeight(38),
          right: ScreenUtil().setWidth(96.7),
          child: Image.asset(
            "asset/images/ic_dismiss.png",
            color: prefix0.blackColor333,
            width: ScreenUtil().setWidth(49),
          ),
        )
      ],
    );
  }

  _buildItemUserPicked(AddressBookModel user) {
    final double maxSize = ScreenUtil().setWidth(160.0);
    return Container(
      margin: EdgeInsets.only(right: ScreenUtil().setWidth(20.0)),
      child: Stack(
        children: <Widget>[
          Container(
            width: maxSize,
            height: maxSize,
          ),
          CustomCircleAvatar(
            userName: user.username,
            size: 160.0,
            position: ImagePosition.GROUP,
          ),
          Positioned(
            right: ScreenUtil().setWidth(8.0),
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                color: prefix0.blackColor333,
                shape: BoxShape.circle,
              ),
              width: ScreenUtil().setWidth(40.0),
              height: ScreenUtil().setWidth(40.0),
              child: Icon(
                Icons.clear,
                color: prefix0.white,
                size: ScreenUtil().setWidth(40.0),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showDialogExit() {
    DialogUtils.showDialogRequest(context,
        title: "Hủy tạo nhóm",
        message: "Bạn muốn hủy tạo nhóm này?", onClickOK: () {
      if (widget.isOpenFromAddressBook) {
        appBloc.mainChatBloc.showLayoutActionStream.notify(false);
      } else {
        widget.onClickLeading();
      }
    });
  }

  void _showDialogBack() {
    DialogUtils.showDialogRequest(context,
        title: "Hủy tạo nhóm",
        message: "Bạn muốn hủy tạo nhóm này?", onClickOK: () {
      if (widget.isOpenFromAddressBook) {
        //appBloc.mainChatBloc.showLayoutActionStream.notify(false);
        appBloc.homeBloc
            .changeActionMeeting(state: LayoutNotBottomBarState.NONE);
      } else {
        widget.onClickLeading();
      }
    });
  }
}
