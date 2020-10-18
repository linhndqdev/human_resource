import 'package:flutter/material.dart';
import 'package:human_resource/utils/animation/icon_status_message_animation.dart';
import 'package:flutter_screenutil/size_extension.dart';

class IconStatusShowWidget extends StatefulWidget {
  final String assetImage;
  final double sizeWidth;

  IconStatusShowWidget(this.assetImage, this.sizeWidth);

  @override
  _IconStatusShowWidgetState createState() => _IconStatusShowWidgetState();
}

class _IconStatusShowWidgetState extends State<IconStatusShowWidget> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );
    _controller.forward();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget child) {
          return Transform.scale(
              scale: _animation.value,
              child: Image.asset(
                widget.assetImage,
                width: widget.sizeWidth.w,
              ));
        });
  }
}
