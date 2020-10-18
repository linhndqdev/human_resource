import 'package:flutter/material.dart';

class ZoomInAnimation extends StatefulWidget {
  Widget widgetAction;

  ZoomInAnimation(this.widgetAction);

  @override
  _ZoomInAnimationState createState() => _ZoomInAnimationState();
}

class _ZoomInAnimationState extends State<ZoomInAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _animation = Tween<double>(
      begin: 0.5,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutBack,
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
            child: widget.widgetAction,);
        });
  }
}
