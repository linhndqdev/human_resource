import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/size_extension.dart';

class ReactionListButton extends StatefulWidget {
  final VoidCallback onClickAttachment;
  final VoidCallback onClickCamera;
  final VoidCallback onClickPickImage;
  final VoidCallback onClickEmoji;

  const ReactionListButton(
      {Key key,
      this.onClickAttachment,
      this.onClickCamera,
      this.onClickPickImage,
      this.onClickEmoji})
      : super(key: key);

  @override
  _ReactionListButtonState createState() => _ReactionListButtonState();
}

class _ReactionListButtonState extends State<ReactionListButton>
    with TickerProviderStateMixin {
  AnimationController animControlBox;
  Animation pushIconAttachment, pushIconCamera, pushIconImage, pushIconEmoji;

  Animation fadeInBox;
  int durationAnimationBox = 500;
  int currentIconFocus = 0;

  void initAnimation() {
    animControlBox = AnimationController(
        vsync: this, duration: Duration(milliseconds: durationAnimationBox));
    fadeInBox = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.7, 1.0)),
    );
    fadeInBox.addListener(() {
      setState(() {});
    });

    pushIconAttachment = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.3, 1.0)),
    );
    pushIconCamera = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.4, 1.0)),
    );
    pushIconImage = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.5, 1.0)),
    );
    pushIconEmoji = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animControlBox, curve: Interval(0.6, 1.0)),
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
    appBloc = BlocProvider.of(context);
    return StreamBuilder(
        initialData: true,
        stream: appBloc.mainChatBloc.chatBloc.showActionChatStream.stream,
        builder: (buildContext, AsyncSnapshot<bool> showActionSnap) {
          return showActionSnap.data ? renderIcons() : Container();
        });
  }

  AppBloc appBloc;

  Widget renderIcons() {
    return Container(
      height: 129.0.h,
      alignment: Alignment.center,
      child: Row(
        children: <Widget>[
          if (Platform.isAndroid)
            StreamBuilder(
              initialData: false,
              stream: appBloc.mainChatBloc.chatBloc.pickFileLoading.stream,
              builder: (buildContext, AsyncSnapshot<bool> loadingSnapshot) {
                if (!loadingSnapshot.data) {
                  return Opacity(
                    opacity: this.pushIconAttachment.value,
                    child: GestureDetector(
                        onTap: () {
                          widget.onClickAttachment();
                        },
                        child: Container(
                          child: Image.asset(
                            "asset/images/ic_bubble_attachment.png",
                            width: 29.2.w,
                            color: prefix0.color959ca7,
                          ),
                        )),
                  );
                } else {
                  return Container(
                    width: 55.5.w,
                    height: 55.5.w,
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          // icon love
          SizedBox(
            width: 33.1.w,
          ),
          Opacity(
            opacity: this.pushIconCamera.value,
            child: GestureDetector(
              onTap: () {
                widget.onClickCamera();
              },
              child: Icon(
                Icons.camera_alt,
                color: prefix0.color959ca7,
                size: 55.5.w,
              ),
            ),
          ),
          SizedBox(
            width: 33.1.w,
          ),
          Opacity(
            opacity: this.pushIconImage.value,
            child: GestureDetector(
              onTap: () {
                widget.onClickPickImage();
              },
              child: Icon(
                Icons.image,
                color: prefix0.color959ca7,
                size: 55.5.w,
              ),
            ),
          ),
          SizedBox(
            width: 33.1.w,
          ),
          Opacity(
            opacity: this.pushIconEmoji.value,
            child: GestureDetector(
              onTap: () {
                widget.onClickEmoji();
              },
              child: Image.asset(
                "asset/images/ic_emoji.png",
                color: prefix0.color959ca7,
                width: 50.9.w,
              ),
            ),
          ),
          SizedBox(
            width: 33.1.w,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
