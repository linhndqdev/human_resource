import 'dart:math';

import 'package:flutter/material.dart';

class ImagesAnimation extends StatefulWidget {
  Widget widgetAction;

  ImagesAnimation(this.widgetAction);

  @override
  _ImagesAnimationState createState() => _ImagesAnimationState();
}

class _ImagesAnimationState extends State<ImagesAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
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
              alignment: FractionalOffset.center,
              scale: _animation.value,
              child: widget.widgetAction);
        });
  }
}
