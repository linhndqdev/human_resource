import 'dart:math';

import 'package:flutter/material.dart';

class BottomBarAnimation extends StatefulWidget {
  Widget widgetAction;

  BottomBarAnimation(this.widgetAction);

  @override
  _BottomBarAnimationState createState() => _BottomBarAnimationState();
}

class _BottomBarAnimationState extends State<BottomBarAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;
//  Animation _arrowAnimation, _heartAnimation;
//  AnimationController _arrowAnimationController, _heartAnimationController;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
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
//    _arrowAnimationController?.dispose();
//    _heartAnimationController?.dispose();
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
//                Center(
//                  child: Icon(
//                    Icons.favorite,
//                    color: Colors.red,
//                    size: _animation.value,
//                  ),
//                ),
          );
        });
  }


//  Widget secondChild() {
//    return  InkWell(
//      onTap: (){
//        _heartAnimationController.forward();
//      },
//      child: Expanded(
//        child: AnimatedBuilder(
//          animation: _heartAnimationController,
//          builder: (context, child) {
//            return Center(
//              child: Container(
//                child: Center(
//                  child: Icon(
//                    Icons.favorite,
//                    color: Colors.red,
//                    size: _heartAnimation.value,
//                  ),
//                ),
//              ),
//            );
//          },
//        ),
//      ),
//    );
//  }
}
