import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/model/asgl_user_model_extension.dart';
import 'package:human_resource/utils/animation/animation_vertical.dart';

typedef OnClickItem = Function(ASGUserModel);

class ContactItem extends StatelessWidget {
//  final Map<String,List<String>> mapAddressBook;
  final String keyCategory;
  final List<ASGUserModel> listUser;
  final OnClickItem onClickItem;

  ContactItem(this.keyCategory, this.listUser, {@required this.onClickItem});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(
        bottom: ScreenUtil().setHeight(24),
      ),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: listUser.length + 1,
      addAutomaticKeepAlives: false,
      itemBuilder: (BuildContext buildContext, int index) {
        if (index == 0) {
          return Container(
            padding: EdgeInsets.only(
              left: ScreenUtil().setWidth(60),
              top: ScreenUtil().setHeight(36),
              bottom: ScreenUtil().setHeight(40),
            ),
            margin: EdgeInsets.only(
              bottom: ScreenUtil().setHeight(40),
            ),
            width: MediaQuery.of(context).size.width,
            color: Color(0xff959ca7).withOpacity(0.05),
            child: Text(
              keyCategory.toUpperCase(),
              style: TextStyle(
                  fontSize: ScreenUtil().setWidth(60),
                  fontFamily: 'Roboto-Regular',
                  color: Color(0xff959ca7)),
            ),
          );
        }
        index -= 1;
        return InkWell(
          onTap: () {
            onClickItem(listUser[index]);
          },
          child: Container(
            padding: EdgeInsets.only(
                left: ScreenUtil().setWidth(60),
                top: ScreenUtil().setHeight(19),
                bottom: ScreenUtil().setHeight(21.5)),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: ScreenUtil().setWidth(71.9)),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(115.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                "asset/images/baseline-account_circle-24px.png",
                              ))),
                      width: ScreenUtil().setWidth(115.0),
                      height: ScreenUtil().setWidth(115.0),
                      child: FadeInImage(
                        placeholder: new AssetImage(
                            'asset/images/baseline-account_circle-24px.png'),
                        image: CachedNetworkImageProvider(
                            "${Constant.SERVER_BASE_CHAT}/avatar/${listUser[index].username}"),
                      ),
                    ),
                  ),
                ),
                Flexible(
                    fit: FlexFit.tight,
                    flex: 15,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          listUser[index].full_name ?? "Không xác định",
                          style: TextStyle(
                            fontFamily: 'Roboto-Regular',
                            color: prefix0.blackColor333,
                            fontSize: ScreenUtil().setSp(48),
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 30.0),
                          child: Text(
                            listUser[index].getInfoShow(),
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
}
