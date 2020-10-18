import 'package:flutter/material.dart';

class BoundButtonAnimation extends StatefulWidget {
  final Widget child;
  final AnimationController animationController;
  final maxWidth;

  BoundButtonAnimation({this.child, this.animationController, this.maxWidth});
  @override
  _BoundButtonAnimationState createState() => _BoundButtonAnimationState();
}

class _BoundButtonAnimationState extends State<BoundButtonAnimation> {
  Animation _zoomWidthAnimation;
  @override
  void initState() {
    _zoomWidthAnimation = Tween<double>(begin: 100.0, end: widget.maxWidth)
        .animate(CurvedAnimation(
            parent: widget.animationController, curve: Curves.easeInSine));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(width: _zoomWidthAnimation.value, child: widget.child);
  }
}
