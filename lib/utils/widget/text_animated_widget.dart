import 'package:flutter/material.dart';
import 'dart:async';

class TextAnimatedWidget extends StatefulWidget {
  /// List of [String] that would be displayed subsequently in the animation.
  final List text;

  /// Gives [TextStyle] to the text strings.
  final TextStyle textStyle;

  /// The [Duration] of the delay between the apparition of each characters
  ///
  /// By default it is set to 40 milliseconds.
  final Duration speed;

  /// Adds the onFinished [VoidCallback] to the animated widget.
  ///
  /// This method will run only if [isRepeatingAnimation] is set to false.
  final VoidCallback onFinished;

  /// Adds the onNext [VoidCallback] to the animated widget.
  ///
  /// Will be called right before the next text, after the pause parameter
  final Function onNext;

  /// Adds the onNextBeforePause [VoidCallback] to the animated widget.
  ///
  /// Will be called at the end of n-1 animation, before the pause parameter
  final Function onNextBeforePause;

  /// Adds [AlignmentGeometry] property to the text in the widget.
  ///
  /// By default it is set to [AlignmentDirectional.topStart]
  final AlignmentGeometry alignment;

  /// Adds [TextAlign] property to the text in the widget.
  ///
  /// By default it is set to [TextAlign.start]
  final TextAlign textAlign;

  /// Set if the animation should not repeat by changing the value of it to false.
  ///
  /// By default it is set to true.
  final bool isRepeatingAnimation;

  /// Should the animation ends up early and display full text if you tap on it ?
  ///
  /// By default it is set to false.
  final bool displayFullTextOnTap;

  const TextAnimatedWidget({
    Key key,
    @required this.text,
    this.textStyle,
    this.onNext,
    this.onNextBeforePause,
    this.onFinished,
    this.alignment = AlignmentDirectional.topStart,
    this.textAlign = TextAlign.start,
    this.isRepeatingAnimation = true,
    this.speed,
    this.displayFullTextOnTap = false,
  }) : super(key: key);

  @override
  _TyperState createState() => new _TyperState();
}

class _TyperState extends State<TextAnimatedWidget>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation _typingText;
  List<Widget> textWidgetList = [];

  Duration _speed;

  List<Map> _texts = [];

  int _index;

  bool _isCurrentlyPausing = false;

  @override
  void initState() {
    super.initState();

    _speed = widget.speed ?? Duration(milliseconds: 40);

    _index = -1;

    for (int i = 0; i < widget.text.length; i++) {
      try {
        if (!widget.text[i].containsKey('text')) throw new Error();

        _texts.add({
          'text': widget.text[i]['text'],
          'speed': widget.text[i].containsKey('speed')
              ? widget.text[i]['speed']
              : _speed,
        });
      } catch (e) {
        _texts.add({'text': widget.text[i], 'speed': _speed});
      }
    }

    // Start animation
    _nextAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    if (_controller != null)
      _controller
        ..stop()
        ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isCurrentlyPausing || !_controller.isAnimating
        ? Text(
            _texts[_index]['text'],
            style: widget.textStyle,
            textAlign: widget.textAlign,
          )
        : AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget child) {
              int offset = _texts[_index]['text'].length < _typingText.value
                  ? _texts[_index]['text'].length
                  : _typingText.value;

              return Text(
                _texts[_index]['text'].substring(0, offset),
                style: widget.textStyle,
                textAlign: widget.textAlign,
              );
            },
          );
  }
  Timer _timer;
  void _nextAnimation() {
    bool isLast = _index == widget.text.length - 1;

    _isCurrentlyPausing = false;

    // Handling onNext callback
    if (_index > -1) {
      if (widget.onNext != null) widget.onNext(_index, isLast);
    }

    if (isLast) {
      if (widget.isRepeatingAnimation) {
        _index = 0;
      } else {
        if (widget.onFinished != null) widget.onFinished();
        return;
      }
    } else {
      _index++;
    }

    _controller?.dispose();
    _controller = null;

//    setState(() {});

    _controller = new AnimationController(
      duration: _texts[_index]['speed'] * _texts[_index]['text'].length,
      vsync: this,
    );

    _typingText = StepTween(begin: 0, end: _texts[_index]['text'].length)
        .animate(_controller);
    _typingText.addStatusListener((status){
      if(status == AnimationStatus.completed){
        _controller.reset();
        setState(() {
          _isCurrentlyPausing = true;
        });
      }
      if(status == AnimationStatus.dismissed){
        if(_timer!= null && _timer.isActive){
          _timer?.cancel();
          _timer = null;
        }
        _timer = Timer(Duration(seconds: 1),(){
          setState(() {
            _isCurrentlyPausing = false;
          });
          _controller.forward();
        });
      }
    });

    _controller.forward();
  }
}
