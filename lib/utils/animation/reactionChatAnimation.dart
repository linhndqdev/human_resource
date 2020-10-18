import 'package:flutter/material.dart';

class ReactionChatAnimation extends StatefulWidget {
  Widget widgetAction;

  ReactionChatAnimation(this.widgetAction);

  @override
  _ReactionChatAnimationState createState() => _ReactionChatAnimationState();
}

class _ReactionChatAnimationState extends State<ReactionChatAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _animation = Tween<double>(
      begin: 1.2,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );
//    _controller.addStatusListener((AnimationStatus status) {
//      if (status == AnimationStatus.completed) {
//        _controller.repeat();
//        //_controller.reset();
//
//      }
//    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return
      AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget child) {
            return
              Transform.scale(
                  alignment: FractionalOffset.center,
                  scale: _animation.value,
                  child: widget.widgetAction
              );
          });
  }

}
