import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/chat/screen/address_book/address_book_bloc.dart';
import 'package:human_resource/chat/screen/main_chat/layout/channel_action/member_profile_bloc.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/utils/animation/fade_animation.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';

import 'package:human_resource/utils/widget/contact_item.dart';
import 'package:human_resource/utils/widget/loading_widget.dart';
import 'package:human_resource/home/home_bloc.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:flutter/cupertino.dart';
import 'package:human_resource/utils/animation/animation_vertical.dart';

class AddressBookScreen extends StatefulWidget {
  final AppBloc appBloc;

  AddressBookScreen(this.appBloc);

  @override
  _AddressBookScreenState createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  AddressBookBloc addressBloc = AddressBookBloc();
  MemberProfileBloc memberBloc = MemberProfileBloc();
  FocusNode _focusSearch; // = FocusNode();
  TextEditingController _textEditingController = TextEditingController();
  AppBloc appBloc;

  @override
  void initState() {
    _focusSearch = FocusNode();

    super.initState();
    Future.delayed(Duration.zero, () {
      addressBloc.getAllUserASGL(context);
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    addressBloc?.close();
    _focusSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _focusSearch?.unfocus();

    appBloc = widget.appBloc;
    addressBloc.checkAndReloadData();
    return buildWidget();
  }

  Widget buildWidget() {
    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: prefix0.whiteColor,
          appBar: AppBar(
            title: StreamBuilder(
              initialData: AddressModel(AddressState.NONE, null),
              stream: addressBloc.addressBookStream.stream,
              builder: (buildContext, AsyncSnapshot<AddressModel> snapshot) {
                switch (snapshot.data.addressState) {
                  case AddressState.SHOW_DATA_SEARCH:
                    return Text(
                      "Tìm kiếm",
                      style: TextStyle(
                        fontFamily: 'Roboto-Bold',
                        color: prefix0.white,
                        fontSize: ScreenUtil().setSp(60),
                      ),
                    );
                    break;
                  case AddressState.NO_DATA_SEARCH:
                    return Text(
                      "Tìm kiếm",
                      style: TextStyle(
                        fontFamily: 'Roboto-Bold',
                        color: prefix0.white,
                        fontSize: ScreenUtil().setSp(60),
                      ),
                    );
                    break;
                  default:
                    return Container(
                      child: Text(
                        "Danh bạ",
                        style: TextStyle(
                          fontFamily: 'Roboto-Bold',
                          color: prefix0.white,
                          fontSize: ScreenUtil().setSp(60),
                        ),
                      ),
                    );
                    break;
                }
              },
            ),
            elevation: 0,
            centerTitle: true,
            backgroundColor: prefix0.accentColor,
          ),
          body: Column(
            children: <Widget>[
              Container(
                  color: prefix0.accentColor,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    height: ScreenUtil().setHeight(113),
                    margin: EdgeInsets.only(
                        left: ScreenUtil().setWidth(60),
                        right: ScreenUtil().setWidth(59),
                        bottom: ScreenUtil().setHeight(56)),
                    padding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(46),
                    ),
                    width: ScreenUtil().setWidth(961),
                    decoration: BoxDecoration(
                      color: Color(0xff2f769b),
                      borderRadius: BorderRadius.circular(
                          SizeRender.renderBorderSize(context, 57.0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil().setHeight(113),
                          padding: EdgeInsets.only(top: 28.h, bottom: 35.5.h),
                          child: Image.asset(
                            "asset/images/group_9898.png",
                            color: prefix0.whiteColor,
                            width: ScreenUtil().setWidth(49.0),
                            height: ScreenUtil().setHeight(49.1),
                          ),
                        ),
                        SizedBox(
                          width: ScreenUtil().setWidth(30.7),
                        ),
                        Flexible(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: ScreenUtil().setHeight(113),
                                child: TextField(
                                  autofocus: false,
                                  focusNode: _focusSearch,
                                  onChanged: (text) {
                                    addressBloc.filterSearchResults(
                                        _textEditingController.text);
                                  },
                                  cursorColor: Color(0xffe8e8e8),
                                  style: TextStyle(
                                    fontFamily: "Roboto-Regular",
                                    fontSize: ScreenUtil().setSp(50.0),
                                    color: Color(0xffe8e8e8),
                                  ),
                                  controller: _textEditingController,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                      top: ScreenUtil().setHeight(22),
                                      bottom: ScreenUtil().setHeight(30),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintText: "Tìm theo tên",
                                    hintStyle: TextStyle(
                                      fontFamily: "Roboto-Regular",
                                      fontSize: ScreenUtil().setSp(50.0),
                                      color: prefix0.whiteColor,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: ScreenUtil().setHeight(35),
                                  right: ScreenUtil().setWidth(44.5),
                                  child: InkWell(
                                      onTap: () {
                                        _textEditingController?.clear();
                                        _focusSearch?.unfocus();
                                        addressBloc.backToDefaultAddressBook();
                                      },
                                      child: Container(
                                        width: ScreenUtil().setWidth(49.0),
                                        height: ScreenUtil().setHeight(49.1),
                                        child: Image.asset(
                                          "asset/images/ic_dismiss.png",
                                          color: prefix0.whiteColor,
                                          width: ScreenUtil().setWidth(31.5),
                                          height: ScreenUtil().setHeight(31.5),
                                        ),
                                      ))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              Expanded(
                  child: StreamBuilder(
                initialData: AddressModel(AddressState.NONE, null),
                stream: addressBloc.addressBookStream.stream,
                builder: (buildContext, AsyncSnapshot<AddressModel> snapshot) {
                  switch (snapshot.data.addressState) {
                    case AddressState.NONE:
                      return Center(child: Loading());
                      break;
                    case AddressState.NO_DATA:
                      return Container(
                        height: MediaQuery.of(context).size.height,
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: InkWell(
                            onTap: () {
                              addressBloc.addressBookStream.notify(
                                  AddressModel(AddressState.NONE, null));
                              addressBloc.getAllUserASGL(context);
                            },
                            child: Center(
                                child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text("Không tìm thấy thông tin người dùng",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: "Roboto-Regular",
                                        fontSize: 50.0.sp,
                                        color: prefix0.blackColor333)),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  " Nhấn để cập nhật dữ liệu.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: "Roboto-Regular",
                                      fontSize: 50.0.sp,
                                      color: prefix0.accentColor),
                                ),
                              ],
                            ))),
                      );
                      break;
                    case AddressState.SHOW:
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                              child: InkWell(
                            onTap: () {
                              _focusSearch?.unfocus();
                            },
                            child: _buildListAddressBook(snapshot.data),
                          ))
                        ],
                      );
                      break;
                    case AddressState.SHOW_DATA_SEARCH:
                      return Container(
                        margin: EdgeInsets.only(
                          top: ScreenUtil().setHeight(64.0),
                        ),
                        child:
                            _buildListSearItem(snapshot.data.listSearchResult),
                      );
                      break;
                    case AddressState.NO_DATA_SEARCH:
                      return Container(
                        height: MediaQuery.of(context).size.height,
                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Center(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text("Không tìm thấy thông tin người dùng",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: "Roboto-Regular",
                                    fontSize: 50.0.sp,
                                    color: prefix0.blackColor333)),
                          ],
                        )),
                      );
                      break;
                    default:
                      return Container(
                        child: Loading(),
                      );
                      break;
                  }
                },
              ))
            ],
          ),
        ),
        StreamBuilder(
            initialData: false,
            stream: addressBloc.loadingStream.stream,
            builder: (buildContext, AsyncSnapshot<bool> loadingSnap) {
              if (!loadingSnap.data) {
                return Container();
              } else {
                return Loading();
              }
            })
      ],
    );
  }

  Widget _buildListAddressBook(AddressModel data) {
    return LiquidPullToRefresh(
      color: prefix0.accentColor,
      showChildOpacityTransition: false,
      child: ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: data.listKey
            .map(
              (key) => ContactItem(key, addressBloc.getDataASGUSerModel(key),
                  onClickItem: (addressBookModel) {
                _focusSearch?.unfocus();
                if (!isRefreshingData) {
                  widget.appBloc.homeBloc.changeActionMeeting(
                      state: LayoutNotBottomBarState.OPEN_PROFILE_MEMBER,
                      data: {
                        "owner": false,
                        "user": addressBookModel,
                        "openNotification": false,
                      });
                }
              }),
            )
            .toList(),
      ),
      onRefresh: _refreshData,
    );
  }

  bool isRefreshingData = false;

  Future<void> _refreshData() async {
    isRefreshingData = true;
    await addressBloc.reloadData(context);
    isRefreshingData = false;
  }

  Widget _buildListSearItem(List<ASGUserModel> listSearchResult) {
    AppBloc appBloc = BlocProvider.of(context);
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: listSearchResult.length,
      itemBuilder: (BuildContext buildContext, int index) {
        return InkWell(
          onTap: () {
            _focusSearch?.unfocus();

//            widget.addressBloc.openChatLayout(
//                context, widget.addressBloc, listSearchResult[index]);
            appBloc.homeBloc.changeActionMeeting(
                state: LayoutNotBottomBarState.OPEN_PROFILE_MEMBER,
                data: {
                  "owner": false,
                  "user": listSearchResult[index],
                  "openNotification": false,
                });
          },
          child: Container(
            margin: EdgeInsets.only(
              bottom: ScreenUtil().setHeight(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                    left: ScreenUtil().setWidth(60),
                    right: ScreenUtil().setWidth(71.9),
                  ),
                  height: ScreenUtil().setWidth(119),
                  width: ScreenUtil().setWidth(119),
                  child: CustomCircleAvatar(
                    size: 191.0,
                    userName: listSearchResult[index].username,
                    position: ImagePosition.GROUP,
                  ),
//                  Image.asset(
//                      "asset/images/baseline-account_circle-24px.png"),
                ),
                Flexible(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      listSearchResult[index].full_name ?? "",
                      style: TextStyle(
                        fontFamily: "Roboto-Regular",
                        color: prefix0.blackColor333,
                        fontSize: ScreenUtil().setSp(44),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 30.0),
                      child: Text(
                        getInfoShow(listSearchResult[index]),
                        style: TextStyle(
                          fontFamily: 'Roboto-Regular',
                          color: prefix0.color959ca7,
                          fontSize: 40.0.sp,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    )
                  ],
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  String getInfoShow(ASGUserModel listUser) {
    String positionName = "";
    String departName = "";
    if (listUser != null) {
      if (listUser.position != null &&
          listUser.position.name != null &&
          listUser.position.name != "") {
        positionName = listUser.position.name;
      }
      if (listUser.position != null &&
          listUser.position.department != null &&
          listUser.position.department.name != null &&
          listUser.position.department.name != "") {
        departName = listUser.position.department.name;
      }
      if (positionName != "" && departName != "") {
        return "$positionName - $departName";
      }
      if (positionName != "") {
        return "$positionName";
      }
      if (departName != "") {
        return departName;
      }

      return "Không xác định";
    } else {
      return "Không xác định";
    }
  }
}
