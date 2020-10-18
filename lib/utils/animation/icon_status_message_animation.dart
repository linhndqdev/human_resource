import 'package:flutter/material.dart';

class IconStatusMessageAnimation extends StatefulWidget {
  final Widget widgetAction;

  IconStatusMessageAnimation(this.widgetAction);

  @override
  _IconStatusMessageAnimationState createState() => _IconStatusMessageAnimationState();
}

class _IconStatusMessageAnimationState extends State<IconStatusMessageAnimation>
    with SingleTickerProviderStateMixin {
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
            child: widget.widgetAction,);
        });
  }
}
