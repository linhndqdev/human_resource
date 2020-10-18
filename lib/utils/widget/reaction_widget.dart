import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/core/style.dart' as prefix0;

class ReactionWidgetShow extends StatefulWidget {
  final VoidCallback showDetailReact;
  final WsMessage message;

  const ReactionWidgetShow({Key key, this.showDetailReact, this.message})
      : super(key: key);

  @override
  _ReactionWidgetShowState createState() => _ReactionWidgetShowState();
}

class _ReactionWidgetShowState extends State<ReactionWidgetShow>
    with TickerProviderStateMixin {
  AnimationController animControlBox;
  Animation pushIconAttachment,
      pushIconCamera,
      pushIconImage,
      pushIconEmoji,
      pushIconNo;
  int durationAnimationBox = 500;
  int currentIconFocus = 0;

  void initAnimation() {
    animControlBox = AnimationController(
        vsync: this, duration: Duration(milliseconds: durationAnimationBox));
    pushIconAttachment = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Curves.elasticInOut),
    );
    pushIconCamera = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Curves.elasticInOut),
    );
    pushIconImage = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Curves.elasticInOut),
    );
    pushIconEmoji = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Curves.elasticInOut),
    );
    pushIconNo = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Curves.elasticInOut),
    );
    pushIconAttachment.addListener(() {
      setState(() {});
    });
    pushIconCamera.addListener(() {
      setState(() {});
    });
    pushIconImage.addListener(() {
      setState(() {});
    });
    pushIconEmoji.addListener(() {
      setState(() {});
    });
    pushIconNo.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(ReactionWidgetShow oldWidget) {
    if (oldWidget.message.reactions.sumUserReactions <
        widget.message.reactions.sumUserReactions) {
      animControlBox?.reset();
      animControlBox?.forward();
    } else {
      super.didUpdateWidget(oldWidget);
    }
  }

  @override
  void initState() {
    super.initState();
    initAnimation();
    animControlBox.forward();
  }

  @override
  void dispose() {
    animControlBox?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.showDetailReact();
      },
      child: Container(
        height: 46.h,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: prefix0.white,
          boxShadow: [
            BoxShadow(
                color: Color.fromRGBO(0, 90, 136, 0.2),
                blurRadius: ScreenUtil().setWidth(8.0),
                spreadRadius: 0)
          ],
          borderRadius: BorderRadius.circular(22.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.message.reactions.reactSLike.length > 0)
              Transform.scale(
                scale: this.pushIconAttachment.value,
                child: _buildItemStatus(40, "asset/images/ic_like.png"),
              ),
            if (widget.message.reactions.reactSDislike.length > 0)
              Transform.scale(
                scale: this.pushIconCamera.value,
                child: _buildItemStatus(40, "asset/images/ic_dislike.png"),
              ),
            if (widget.message.reactions.reactSHeart.length > 0)
              Transform.scale(
                scale: this.pushIconImage.value,
                child: _buildItemStatus(40, "asset/images/ic_heart.png"),
              ),
            if (widget.message.reactions.reactSOk.length > 0)
              Transform.scale(
                scale: this.pushIconEmoji.value,
                child: _buildItemStatus(40, "asset/images/ic_ok.png"),
              ),
            if (widget.message.reactions.reactSNo.length > 0)
              Transform.scale(
                scale: this.pushIconNo.value,
                child: _buildItemStatus(40, "asset/images/ic_no.png"),
              ),
            SizedBox(
              width: 10.w,
            ),
            Text(
              widget.message.reactions.sumUserReactions.toString(),
              style: TextStyle(
                color: prefix0.accentColor,
                fontSize: 28.sp,
              ),
            ),
            SizedBox(
              width: 12.w,
            ),
          ],
        ),
      ),
    );
//    return ReactionListButton();
  }

  _buildItemStatus(double sizeWidth, String assetImage) {
    return Image.asset(
      assetImage,
      width: sizeWidth.w,
    );
  }
}
