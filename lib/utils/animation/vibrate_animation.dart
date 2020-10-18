
import 'package:flutter/material.dart';

class VibrateAnimation extends StatefulWidget {
  final Widget widgetAction;

  VibrateAnimation(this.widgetAction);

  @override
  _VibrateAnimationState createState() => _VibrateAnimationState();
}

class _VibrateAnimationState extends State<VibrateAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _animation = Tween<double>(
      begin: 10.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceIn,
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
          return Transform.translate(
            offset: Offset(0, _animation.value),
            child: widget.widgetAction
          );
        });
  }
}
