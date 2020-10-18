
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/core/style.dart' as prefix0;

enum ImagePosition { GROUP }

class CustomCircleAvatar extends StatefulWidget {
  final String userName;
  final double size;
  final bool isClearCache;
  final ImagePosition position;

  const CustomCircleAvatar(
      {Key key,
      this.userName,
      this.size = 81.0,
      this.isClearCache = false,
      this.position})
      : super(key: key);

  @override
  _CustomCircleAvatarState createState() => _CustomCircleAvatarState();
}

class _CustomCircleAvatarState extends State<CustomCircleAvatar> {
  @override
  Widget build(BuildContext context) {
    String url;
    if (widget.position != null && widget.position == ImagePosition.GROUP) {
      url = "${Constant.SERVER_BASE_CHAT}/avatar/${widget.userName}";
    } else {
      url = "${Constant.SERVER_BASE_CHAT}/avatar/${widget.userName}" +
          "?v=${DateTime.now().millisecondsSinceEpoch}";
    }
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.size.w),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        color: prefix0.whiteColor,
        width: ScreenUtil().setWidth(widget.size),
        height: ScreenUtil().setWidth(widget.size),
        child: CachedNetworkImage(
          imageBuilder: (buildContext, imageProvider) {
            String pathImage = imageProvider.toString();
            if (pathImage.contains(".svg+xml") || pathImage.contains(".svg")) {
              return Image.asset(
                "asset/images/baseline-account_circle-24px.png",
                color: prefix0.accentColor,
                fit: BoxFit.contain,
                width: widget.size.w,
                height: widget.size.w,
              );
            }
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
          useOldImageOnUrlChange: true,
          imageUrl: url,
          errorWidget: (buildContext, url, error) {
            return Image.asset(
              "asset/images/baseline-account_circle-24px.png",
              color: prefix0.accentColor,
              fit: BoxFit.contain,
              width: widget.size.w,
              height: widget.size.w,
            );
          },
        ),
      ),
    );
  }
}
/*
* */
