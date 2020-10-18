import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/chat_model/res_chat_user_model.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/screen/main_chat/chat/layout_action_bloc.dart';
import 'package:human_resource/chat/screen/main_chat/layout/channel_action/add_member_bloc.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/home/meeting/manager_member.dart';
import 'package:human_resource/utils/common/crypto_hex.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';

import 'create_private_channel_bloc.dart';

class AddMemberLayout extends StatefulWidget {
  final WsRoomModel roomModel;
  final LayoutActionBloc layoutActionBloc;
  final List<RestUserModel> listMember;
  final OnBack onBack;

  const AddMemberLayout(
      {Key key,
      this.roomModel,
      this.layoutActionBloc,
      this.listMember,
      this.onBack})
      : super(key: key);

  @override
  _AddMemberLayoutState createState() => _AddMemberLayoutState();
}

class _AddMemberLayoutState extends State<AddMemberLayout> {
  AddMemberBloc addMemberBloc = AddMemberBloc();
  WsAccountModel accountModel;
  TextEditingController _searchController = TextEditingController();
  FocusNode searchFocus = FocusNode();
  TextEditingController _channelNameController = TextEditingController();
  FocusNode channelNameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      addMemberBloc.setMapData(
          context,
          widget.roomModel,
          appBloc.mainChatBloc.listUserOnChatSystem,
          appBloc.mainChatBloc.listDirectRoom,
          widget.listMember);
    });
  }

  AppBloc appBloc;

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    accountModel = WebSocketHelper.getInstance().wsAccountModel;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        backgroundColor: prefix0.accentColor,
        title: Container(
          height: 178.5.h,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              Positioned(
                child: InkWell(
                    onTap: () {
                      widget.onBack(addMemberBloc.isHasRefreshData);
                    },
                    child: Container(
                      height: 178.5.h,
                      padding: EdgeInsets.only(
                          left: 60.w, right: 60.w, bottom: 66.2.h, top: 60.h),
                      child: Image.asset(
                        "asset/images/ic_meeting_back_white.png",
                        fit: BoxFit.contain,
                        color: prefix0.white,
                        width: ScreenUtil().setWidth(49.0),
                      ),
                    )),
              ),
              Center(
                child: Text(
                  "Thêm thành viên",
                  style: TextStyle(
                      fontFamily: 'Roboto-Bold',
                      color: prefix0.white,
                      fontSize: ScreenUtil().setSp(60.0),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        elevation: 0.0,
      ),
      body: Stack(
        children: <Widget>[
          _buildLayoutAddMember(),
          StreamBuilder(
              initialData: false,
              stream: addMemberBloc.loadingStream.stream,
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

  _buildLayoutAddMember() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildNameGroup(),
          SizedBox(
            height: ScreenUtil().setHeight(37.0),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: StreamBuilder(
                      initialData: false,
                      stream: addMemberBloc.updateTagsStream.stream,
                      builder:
                          (tagsContext, AsyncSnapshot<dynamic> snapdhotData) {
                        List<Widget> tags = List();
                        if (addMemberBloc.userPicked != null) {
                          tags.add(
                            InkWell(
                                child: _buildItemUserPicked(
                                    addMemberBloc.userPicked)),
                          );
                        }
                        if (tags.length > 0) {
                          return Container(
                            margin: EdgeInsets.only(
                                left: ScreenUtil().setHeight(60.0)),
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              children: tags,
                              runSpacing: 5.0,
                            ),
                          );
                        } else {
                          return Container();
                        }
                      })),
              StreamBuilder(
                  initialData: false,
                  stream: addMemberBloc.updateTagsStream.stream,
                  builder: (streamContext, AsyncSnapshot<dynamic> snapshot) {
                    if (addMemberBloc.userPicked != null) {
                      return InkWell(
                        onTap: () {
                          _showDialogRequestAddMember();
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              right: ScreenUtil().setWidth(59.0)),
                          decoration: BoxDecoration(
                              color: prefix0.accentColor,
                              shape: BoxShape.circle),
                          width: ScreenUtil().setWidth(98.0),
                          height: ScreenUtil().setWidth(98.0),
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
          StreamBuilder<FilterTabStreamModel>(
              initialData: FilterTabStreamModel(
                  state: FilterMemberTabState.LIEN_LAC_GAN_DAY),
              stream: addMemberBloc.clickTabStream.stream,
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
                            addMemberBloc.changeTab(
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
                            addMemberBloc
                                .changeTab(FilterMemberTabState.THEO_DANH_BA);
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
                stream: addMemberBloc.clickTabStream.stream,
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
        stream: addMemberBloc.enableSearchStream.stream,
        builder: (enableSearchContext, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data) {
            return StreamBuilder(
                initialData: false,
                stream: addMemberBloc.updateTagsStream.stream,
                builder:
                    (checkAllContext, AsyncSnapshot<bool> snapshotCheckedAll) {
                  String searchData = _searchController.text.trim().toString();
                  List<AddressBookModel> listDataShow = List();
                  if (state == FilterMemberTabState.LIEN_LAC_GAN_DAY) {
                    addMemberBloc.listUserFromDirectRoom?.forEach((user) {
                      if (user.name.contains(searchData) ||
                          user.name
                              .toLowerCase()
                              .contains(searchData.toLowerCase()) ||
                          user.name
                              .toUpperCase()
                              .contains(searchData.toUpperCase())) {
                        listDataShow.add(user);
                      }
                    });
                  } else {
                    addMemberBloc.listAllUserOnSystem?.forEach((user) {
                      if (user.name.contains(searchData) ||
                          user.name
                              .toLowerCase()
                              .contains(searchData.toLowerCase()) ||
                          user.name
                              .toUpperCase()
                              .contains(searchData.toUpperCase())) {
                        listDataShow.add(user);
                      }
                    });
                  }
                  if (listDataShow.length > 0) {
                    return ListView.builder(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(60.0),
                          right: ScreenUtil().setWidth(59.0)),
                      itemCount: listDataShow.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (buildContext, index) {
                        return InkWell(
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            AddressBookModel model = listDataShow[index];
                            addMemberBloc.pickUser(model);
                          },
                          child:
                              _buildItemUser(listDataShow[index], index, state),
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
            return StreamBuilder(
                initialData: false,
                stream: addMemberBloc.updateTagsStream.stream,
                builder:
                    (checkAllContext, AsyncSnapshot<bool> snapshotCheckedAll) {
                  if (state == FilterMemberTabState.THEO_DANH_BA) {
                    if (addMemberBloc.listAllUserOnSystem == null ||
                        addMemberBloc.listAllUserOnSystem.length < 1) {
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
                    if (addMemberBloc.listUserFromDirectRoom == null ||
                        addMemberBloc.listUserFromDirectRoom.length < 1) {
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
                  return ListView.builder(
                    padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(60.0),
                        right: ScreenUtil().setWidth(59.0)),
                    itemCount: state == FilterMemberTabState.THEO_DANH_BA
                        ? addMemberBloc.listAllUserOnSystem.length
                        : addMemberBloc.listUserFromDirectRoom.length,
                    addAutomaticKeepAlives: false,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (buildContext, index) {
                      AddressBookModel model =
                          state == FilterMemberTabState.THEO_DANH_BA
                              ? addMemberBloc.listAllUserOnSystem[index]
                              : addMemberBloc.listUserFromDirectRoom[index];
                      return InkWell(
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          addMemberBloc.pickUser(model);
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
              addMemberBloc.userPicked != null &&
                      addMemberBloc.userPicked.username ==
                          addressBookModel.username
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

  _buildNameGroup() {
    String roomName = CryptoHex.deCodeChannelName(widget.roomModel.name);
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(62),
//          bottom: ScreenUtil().setHeight(64.2)
          ),
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
                width: ScreenUtil().setWidth(60.0),
              ),
              Expanded(
                  child: Stack(
                children: <Widget>[
                  TextField(
                    controller: _channelNameController,
                    onChanged: (String dataChange) {
                      addMemberBloc.searchUser(dataChange);
                    },
                    enabled: false,
                    style: prefix0.text16BlackBold,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    cursorColor: prefix0.blackColor,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding:
                          EdgeInsets.only(bottom: ScreenUtil().setHeight(8.7)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: prefix0.accentColor, width: 1.0),
                      ),
                      disabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: prefix0.accentColor, width: 1.0),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: prefix0.accentColor, width: 1.0),
                      ),
                      border: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: prefix0.accentColor, width: 1.0),
                      ),
                      hintText: roomName,
                      hintStyle: TextStyle(
                          color: Color(0xFF959ca7),
                          fontFamily: "Roboto-Regular",
                          fontWeight: FontWeight.bold,
                          fontSize: ScreenUtil().setSp(50.0)),
                    ),
                  ),

                  /// CHỗ này ai làm logic thì viết lại bloc để nó show cái icon ở cuối ô text "Đặt tên nhóm"
                  Align(
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        "asset/images/path-233@3x.png",
                        fit: BoxFit.contain,
                        width: ScreenUtil().setWidth(55.7),
                        height: ScreenUtil().setWidth(42.4),
                      ))
                ],
              )),
              SizedBox(
                width: ScreenUtil().setWidth(178.5),
              )
            ],
          ),
        ),
      ],
    );
  }

  _buildLineSearch() {
    return Stack(
      children: <Widget>[
        Container(
          color: prefix0.white,
          margin: EdgeInsets.only(
              left: ScreenUtil().setWidth(60.0),
              right: ScreenUtil().setWidth(59.0),
              top: ScreenUtil().setHeight(65.0),
              bottom: ScreenUtil().setHeight(50.0)),
          width: MediaQuery.of(context).size.width,
          height: ScreenUtil().setHeight(113.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: ScreenUtil().setWidth(46.0),
              ),
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
                    addMemberBloc.searchUser(dataChange);
                  },
                  style: TextStyle(
                      color: prefix0.blackColor333,
                      fontSize: ScreenUtil().setSp(44.0)),
                  keyboardType: TextInputType.text,
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: prefix0.blackColor333,
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
                        fontSize: ScreenUtil().setSp(44.0)),
                  ),
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(120.5),
              ),
            ],
          ),
        ),
        Positioned(
          right: 105.0.w,
          top: 85.0.h,
          child: InkWell(
            onTap: () {
//              FocusScope.of(context).requestFocus(FocusNode());
              _searchController.clear();
              if (searchFocus.hasFocus) {
                searchFocus?.unfocus();
                Future.delayed(Duration(milliseconds: 200), () {
                  addMemberBloc.searchUser("");
                });
              }
            },
            child: Image.asset(
              "asset/images/ic_dismiss.png",
              width: 60.0.w,
            ),
          ),
        )
      ],
    );
  }

  void _showDialogRequestAddMember() {
    if (addMemberBloc.userPicked == null) {
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Bạn chưa chọn thành viên nào để thêm vào nhóm");
    } else {
      DialogUtils.showDialogRequestAddMember(context, addMemberBloc.userPicked,
          onClickOK: () {
        addMemberBloc.addUserToGroup(context, widget.roomModel);
      });
    }
  }
}
