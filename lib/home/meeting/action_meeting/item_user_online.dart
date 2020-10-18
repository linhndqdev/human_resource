import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/utils/widget/circle_avatar.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/size_extension.dart';

class ItemUserOnline extends StatelessWidget {
  final AddressBookModel addressBookModel;
  final AppBloc appBloc;

  const ItemUserOnline({Key key, this.addressBookModel, this.appBloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(195),
      margin: EdgeInsets.only(right: ScreenUtil().setWidth(32.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 169.0.w,
            child: Stack(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        appBloc.mainChatBloc
                            .openNewChatRoom(context, addressBookModel);
                      },
                      child: Container(
                        child: CustomCircleAvatar(
                          position: ImagePosition.GROUP,
                          userName: addressBookModel.username,
                          size: 169.0,
                        ),
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  ],
                ),
                Positioned(
                  right: 0,
                  bottom: ScreenUtil().setHeight(8.0),
                  child: Container(
                    width: ScreenUtil().setWidth(31.0),
                    height: ScreenUtil().setWidth(31.0),
                    decoration: BoxDecoration(
                      color: Color(0xffe18c12),
                      shape: BoxShape.circle,
                      border: new Border.all(
                        color: Color(0xffffffff),
                        width: SizeRender.renderBorderSize(context, 1.0),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: ScreenUtil().setHeight(20.0)),
          Expanded(
            child: Container(
              child: Text(addressBookModel.getLastName(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Roboto-Regular",
                      fontSize: ScreenUtil().setSp(40.0),
                      color: prefix0.blackColor333),
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}
