import 'package:flutter/material.dart';

enum VerticalType { UP_TO_DOWN, DOWN_TO_UP }

class TranslateVertical extends StatefulWidget {
  final Widget child;
  final Curve curveAnimated;
  final double startPosition;
  final int duration;
  final VerticalType translateType;
  final VoidCallback onAnimatedFinish;
  final bool isResetWhenUpdateWidget;

  const TranslateVertical(
      {Key key,
        this.child,
        this.curveAnimated = Curves.easeInOutQuart,
        this.startPosition = 0.0,
        this.duration = 500,
        this.translateType = VerticalType.DOWN_TO_UP,
        this.onAnimatedFinish,
        this.isResetWhenUpdateWidget = true})
      : super(key: key);

  @override
  _TranslateVerticalState createState() => _TranslateVerticalState();
}

class _TranslateVerticalState extends State<TranslateVertical>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  @override
  void didUpdateWidget(TranslateVertical oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isResetWhenUpdateWidget) {
      animationController?.reset();
      animationController?.forward();
    }
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    )..addListener(() => setState(() {}));
    animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: widget.curveAnimated,
      ),
    );
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onAnimatedFinish != null) {
          widget.onAnimatedFinish();
        }
      }
    });
    animationController?.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: Offset(
           widget.translateType == VerticalType.UP_TO_DOWN
                ? getPositionUpToDown()
                : getPositionDownToUp(), 0.0,),
        child: widget.child);
  }

  double getPositionDownToUp() =>
      widget.startPosition - widget.startPosition * animation.value;

  double getPositionUpToDown() =>
      widget.startPosition * animation.value - widget.startPosition;
}
