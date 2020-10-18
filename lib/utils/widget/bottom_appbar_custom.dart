import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:human_resource/chat/screen/main_chat/main_chat_bloc.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/custom_size_render.dart';

import 'custom_nav_widget.dart';

class BottomAppbarCustom extends StatelessWidget {
  const BottomAppbarCustom({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppBloc appBloc = BlocProvider.of(context);
    return BottomAppBar(
        notchMargin: SizeRender.renderBorderSize(context, 18.0),
        elevation: 20.0,
//        color: prefix0.white,
        color: Color(0xfff7f7f7),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: ScreenUtil().setHeight(230.6),
          child: StreamBuilder(
              initialData: appBloc.homeBloc.bottomBarCurrentIndex,
              stream: appBloc.homeBloc.bottomBarStream.stream,
              builder: (buildContext, AsyncSnapshot<int> snapshotData) {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: CustomNAVWidget(
                        title: "Trang chủ",
                        onClickItem: () {
                          appBloc.homeBloc.clickItemBottomBar(0);
                        },
                        iconDataNormal: "asset/images/ic_home.png",
                        iconDataSelected: "asset/images/ic_home.png",
                        isSelected: snapshotData.data == 0,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: CustomNAVWidget(
                        title: "Trò chuyện",
                        onClickItem: () {
                          appBloc.homeBloc.clickItemBottomBar(1,
                              listTabState: ListTabState.NHAN_TIN);
                        },
                        iconDataNormal: "asset/images/ic_chat.png",
                        iconDataSelected: "asset/images/ic_chat_selected.png",
                        isSelected: snapshotData.data == 1,
                        haveBottomBarIconBadge: true,

                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: CustomNAVWidget(
                        title: "Lịch họp",
                        onClickItem: () {
                          appBloc.homeBloc.clickItemBottomBar(3);
                        },
                        iconDataSelected: "asset/images/ic_calendar.png",
                        iconDataNormal: "asset/images/ic_calendar.png",
                        isSelected: snapshotData.data == 3,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: CustomNAVWidget(
                        title: "Danh bạ",
                        onClickItem: () {
                          appBloc.homeBloc.clickItemBottomBar(4);
                        },
                        iconDataSelected: "asset/images/ic_addressbook.png",
                        iconDataNormal: "asset/images/ic_addressbook.png",
                        isSelected: snapshotData.data == 4,
                      ),
                    )
                  ],
                );
              }),
        ));
  }
}