import 'package:flutter/material.dart';

class MessageActionAnimation extends StatefulWidget {
  Widget widgetAction;

  MessageActionAnimation(this.widgetAction);

  @override
  _MessageActionAnimationState createState() => _MessageActionAnimationState();
}

class _MessageActionAnimationState extends State<MessageActionAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
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

