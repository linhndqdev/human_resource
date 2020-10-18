import 'package:flutter/material.dart';
typedef onTab = Function();
class ButtomCalendarAnimation extends StatefulWidget {
  Widget widgetAction;
  onTab onTap;
  ButtomCalendarAnimation(this.widgetAction,{this.onTap});

  @override
  _BottomCalendarAnimationState createState() =>
      _BottomCalendarAnimationState();
}

class _BottomCalendarAnimationState extends State<ButtomCalendarAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;
  bool isAnimating = false;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: 0.9,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutBack,
      ),
    );
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isAnimating = false;
        });
        _controller.reset();
        widget.onTap();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        setState(() {
          isAnimating = true;
        });
        _controller.forward();
      },
      child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget child) {
            return Transform.scale(
                alignment: FractionalOffset.center,
                scale: isAnimating ? _animation.value: 1.0,
                child: widget.widgetAction);
          }),
    );
  }
}
