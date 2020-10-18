import 'package:flutter/material.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/core/style.dart' as prefix0;

class ItemStatusPick extends StatefulWidget {
  final String assetImage;
  final VoidCallback onClickItem;

  const ItemStatusPick({Key key, this.assetImage, this.onClickItem})
      : super(key: key);

  @override
  _ItemStatusPickState createState() => _ItemStatusPickState();
}

class _ItemStatusPickState extends State<ItemStatusPick> with SingleTickerProviderStateMixin{
  AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.h,
      padding:
          EdgeInsets.only(bottom: 14.0.h, top: 14.h, left: 15.w, right: 15.w),
      child: widget.assetImage != ""
          ? Image.asset(
              widget.assetImage,
              width: 170.w,
            )
          : Icon(
              Icons.flip,
              color: prefix0.accentColor,
            ),
    );
  }
}
