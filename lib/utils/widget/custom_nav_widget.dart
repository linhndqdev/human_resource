import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/animation/bottomBarAnimation.dart';

typedef OnClickItem = Function();

class CustomNAVWidget extends StatelessWidget {
  final OnClickItem onClickItem;
  final bool isSelected;
  final String iconDataSelected;
  final String iconDataNormal;
  final String title;
  final bool haveBottomBarIconBadge;

  const CustomNAVWidget(
      {Key key,
      @required this.onClickItem,
      this.isSelected,
      this.iconDataSelected,
      this.iconDataNormal,
      this.title,
      this.haveBottomBarIconBadge = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppBloc appBloc = BlocProvider.of(context);
    double maxIconWidth = ScreenUtil().setWidth(71.0);
    SizedBox sizedBox = SizedBox(
      height: ScreenUtil().setHeight(10.0),
    );
    return isSelected
        ? BottomBarAnimation(_buildChild(appBloc))
        : _buildChild(appBloc);
  }

  _buildChild(AppBloc appBloc) {
    double maxIconWidth = ScreenUtil().setWidth(71.0);
    SizedBox sizedBox = SizedBox(
      height: ScreenUtil().setHeight(10.0),
    );
    return Center(
      child: InkWell(
        onTap: () {
          onClickItem();
        },
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                Image.asset(
                  isSelected ? iconDataSelected : iconDataNormal,
                  color:
                      isSelected ? prefix0.accentColor : prefix0.blackColor333,
                  fit: BoxFit.contain,
                  width: maxIconWidth,
                  height: maxIconWidth,
                ),
                if (haveBottomBarIconBadge) ...{
                  StreamBuilder(
                      initialData: appBloc.mainChatBloc.unReadDirectAndPrivate,
                      stream: appBloc.mainChatBloc
                          .countUnreadSumDirectAndPrivateStream.stream,
                      builder: (buildContext,
                          AsyncSnapshot<int> countAllUnreadPrivateAndDirect) {
                        if (countAllUnreadPrivateAndDirect.data != 0 &&
                            countAllUnreadPrivateAndDirect.data != null
                        ) {
                          return Positioned(
                            right: -20.w,
                            top: -20.h,
                            child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.w)),
                                child: Container(
                                  constraints: BoxConstraints(
                                    minWidth: 50.w
                                  ),
                                  padding: EdgeInsets.all(7.w),
                                  color: Colors.red[900],
                                  child: Center(
                                    child: Text(
                                      countAllUnreadPrivateAndDirect.data.toString(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 30.sp),
                                    ),
                                  ),
                                )),
                          );
                        } else {
                          return Positioned(
                            right: -20.w,
                            top: -20.h,
                            child: Container(),
                          );
                        }
                      })
                }
              ],
            ),
            sizedBox,
            isSelected
                ? Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: "Roboto-Regular",
                      color:
                          isSelected ? prefix0.accentColor : Color(0xFF959ca7),
                      fontSize:
                          ScreenUtil().setSp(40.0, allowFontScalingSelf: false),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
