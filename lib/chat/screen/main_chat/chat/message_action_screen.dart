import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:human_resource/chat/screen/main_chat/chat/chat_bloc.dart';
import 'package:human_resource/chat/screen/main_chat/chat/layout_action_bloc.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/back_state.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/custom_size_render.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/size_extension.dart';
import 'package:human_resource/utils/animation/ZoomInAnimation.dart';
import 'package:human_resource/utils/widget/item_mesage_action_widget.dart';

typedef OnCloseAction = Function();
enum IMessageType { TEXT, FILE }

enum IAction { NONE, QUOTE, COPY, SHARE, DELETE, EDIT, DETECT_TEXT, CANCEL }

typedef OnChooseStatus = Function(String);

class MessageActionScreen extends StatefulWidget {
  final OnCloseAction onCloseAction;
  final IMessageType iMessageType;
  final bool isOwnerOfMessage;
  final VoidCallback onQuoteAction;
  final VoidCallback onCopyAction;
  final VoidCallback onRevokeAction;
  final VoidCallback onChooseMultiMessage;
  final VoidCallback onDetectImage;
  final Offset offsetStatus;
  final VoidCallback onEditAction;
  final VoidCallback onShare;
  final OnChooseStatus chooseStatus;
  final VoidCallback removeReact;

//  final VoidCallback onCancel;
  final isCheckChooseMultilMessage;

  const MessageActionScreen({
    Key key,
    @required this.onCloseAction,
    @required this.iMessageType,
    this.isOwnerOfMessage = false,
    @required this.onQuoteAction,
    @required this.onEditAction,
    @required this.onCopyAction,
    @required this.onRevokeAction,
    @required this.onChooseMultiMessage,
    @required this.onDetectImage,
//    @required this.onCancel,
    this.isCheckChooseMultilMessage = false,
    this.onShare,
    this.chooseStatus,
    this.removeReact,
    @required this.offsetStatus,
  }) : super(key: key);

  @override
  _MessageActionScreenState createState() => _MessageActionScreenState();
}

class _MessageActionScreenState extends State<MessageActionScreen>
    with TickerProviderStateMixin {
  List<IAction> listActionLineOne = List();
  List<IAction> listActionLineTwo = List();
  AnimationController animControlIconWhenDrag;
  AnimationController animControlIconWhenRelease;
  Animation zoomIconChosen;
  Animation zoomIconWhenRelease, moveUpIconWhenRelease;

  // 0 = nothing, 1 = like, 2 = love, 3 = haha, 4 = wow, 5 = sad, 6 = angry
//  int whichIconUserChoose = 0;
  @override
  void dispose() {
    animControlIconWhenDrag?.dispose();
    animControlIconWhenRelease?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animControlIconWhenDrag = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    zoomIconChosen =
        Tween(begin: 1.0, end: 1.8).animate(animControlIconWhenDrag);
    animControlIconWhenRelease = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));

    zoomIconWhenRelease = Tween(begin: 1.2, end: 0.0).animate(CurvedAnimation(
        parent: animControlIconWhenRelease, curve: Curves.decelerate));

    moveUpIconWhenRelease = Tween(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(
            parent: animControlIconWhenRelease, curve: Curves.decelerate));
//    moveUpIconWhenRelease.addListener(() {
//      setState(() {});
//    });
    animControlIconWhenDrag.forward();
    animControlIconWhenRelease.forward();
  }

  @override
  Widget build(BuildContext context) {
    LayoutActionBloc layoutActionBloc = LayoutActionBloc();
    ChatBloc chatBloc = ChatBloc();
    AppBloc appBloc = BlocProvider.of(context);
    appBloc.backStateBloc.focusWidgetModel.state =
        isFocusWidget.MESSAGE_ACTION_SCREEN;
    if (!widget.isCheckChooseMultilMessage) {
      if (widget.isOwnerOfMessage) {
        if (widget.iMessageType == IMessageType.TEXT) {
          listActionLineOne = [
            IAction.QUOTE,
            IAction.COPY,
            IAction.EDIT,
            IAction.DELETE
          ];
        } else {
          listActionLineOne = [
            IAction.QUOTE,
            IAction.DETECT_TEXT,
            IAction.DELETE
          ];
        }
      } else {
        if (widget.iMessageType == IMessageType.TEXT) {
          listActionLineOne = [
            IAction.QUOTE,
            IAction.COPY,
          ];
        } else {
          listActionLineOne = [
            IAction.QUOTE,
            IAction.DETECT_TEXT,
          ];
        }
      }
    } else {
      listActionLineOne = [
        IAction.CANCEL,
        IAction.SHARE,
      ];
    }

    return GestureDetector(
      onTap: () {
        widget.onCloseAction();
      },
      child: widget.isCheckChooseMultilMessage
          ? Stack(
              //Khi chọn nhiều tin nhắn
              children: <Widget>[
                Positioned(
                    bottom: 0.0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(
                              left: 250.0.w,
                              top: 37.0.h,
                              right: 250.0.w,
                              bottom: 25.6.h),
                          decoration: BoxDecoration(
                              color: prefix0.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25.0),
                                topRight: Radius.circular(25.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: prefix0.blackColor333,
                                  offset: Offset(0, 13.w),
                                  blurRadius: 20.h,
                                )
                              ]),
                          child: Column(
                            children: <Widget>[
                              if (listActionLineOne != null &&
                                  listActionLineOne.length > 0)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: genderListItem(listActionLineOne),
                                ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ],
            )
          : StreamBuilder<int>(
              initialData: 0,
              stream: layoutActionBloc.chosenIconFeelingStream.stream,
              builder: (context, snapshot) {
                return Stack(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: snapshot.data == 0
                          ? prefix0.color959ca7.withOpacity(0.5)
                          : Colors.transparent,
                    ),
                    snapshot.data == 0
                        ? Positioned(
                            bottom: 0.0,
                            right: 0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: widget.onChooseMultiMessage,
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        right: 59.w, bottom: 32.5.h),
                                    padding: EdgeInsets.only(
                                        left: 15.w,
                                        top: 20.0.h,
                                        right: 15.0.w,
                                        bottom: 20.0.h),
                                    decoration: BoxDecoration(
                                        color: prefix0.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                SizeRender.renderBorderSize(
                                                    context, 32.0)))),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "Chọn nhiều tin nhắn",
                                          style: TextStyle(
                                            color: Color(0xff959ca7),
                                            fontFamily: 'Roboto-Regular',
                                            fontSize: 30.0.sp,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ), //chọn nhiều tin nhắn
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.only(
                                    left: 60.0.w,
                                    right: 58.0.w,
                                  ),
                                  decoration: BoxDecoration(
                                      color: prefix0.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(25.0),
                                        topRight: Radius.circular(25.0),
                                      )),
                                  child: Column(
                                    children: <Widget>[
                                      if (listActionLineOne != null &&
                                          listActionLineOne.length > 0)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children:
                                              genderListItem(listActionLineOne),
                                        ),
                                      if (listActionLineTwo != null &&
                                          listActionLineTwo.length > 0)
                                        SizedBox(
                                          height: 45.0.h,
                                        ),
                                      if (listActionLineTwo != null &&
                                          listActionLineTwo.length > 0)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children:
                                              genderListItem(listActionLineTwo),
                                        )
                                    ],
                                  ),
                                ),
                              ],
                            ))
                        : Container(),
                    widget.offsetStatus != null
                        ? Positioned(
                            top: appBloc.mainChatBloc.chatBloc.positionStatusBar
                                            .dy -
                                        105.h >
                                    0
                                ? appBloc.mainChatBloc.chatBloc
                                        .positionStatusBar.dy -
                                    150.h
                                : 50.0,
                            left: appBloc.mainChatBloc.chatBloc.sizeStatusBar
                                    .width.w -
                                230.w,
                            child: snapshot.data == 0
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      GestureDetector(
                                        child: Container(
                                          width: 650.0.w,
                                          margin: EdgeInsets.only(
                                              right: 23.9.w, bottom: 32.5.h),
                                          padding: EdgeInsets.only(
                                            left: 10.w,
                                            right: 10.w,
                                          ),
                                          decoration: BoxDecoration(
                                            color: prefix0.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    SizeRender.renderBorderSize(
                                                        context, 70.0))),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.29),
                                                  blurRadius: 12.h,
                                                  offset: Offset(0, 5.h))
                                            ],
                                          ),
                                          child: Stack(
                                            children: <Widget>[
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  _buildItemStatus(100,
                                                      "asset/images/ic_like.png",
                                                      () {
                                                    layoutActionBloc
                                                        .chosenIconFeelingStream
                                                        .notify(1);
                                                    disposeAnimation();
                                                    widget.chooseStatus(
                                                        ":s_like:");
                                                  }),
                                                  _buildItemStatus(100,
                                                      "asset/images/ic_dislike.png",
                                                      () {
                                                    layoutActionBloc
                                                        .chosenIconFeelingStream
                                                        .notify(2);
                                                    disposeAnimation();
                                                    widget.chooseStatus(
                                                        ":s_dislike:");
                                                  }),
                                                  _buildItemStatus(100,
                                                      "asset/images/ic_heart.png",
                                                      () {
                                                    layoutActionBloc
                                                        .chosenIconFeelingStream
                                                        .notify(3);
                                                    disposeAnimation();
                                                    widget.chooseStatus(
                                                        ":s_heart:");
                                                  }),
                                                  _buildItemStatus(100,
                                                      "asset/images/ic_ok.png",
                                                      () {
                                                    layoutActionBloc
                                                        .chosenIconFeelingStream
                                                        .notify(4);
                                                    disposeAnimation();
                                                    widget
                                                        .chooseStatus(":s_ok:");
                                                  }),
                                                  _buildItemStatus(100,
                                                      "asset/images/ic_no.png",
                                                      () {
                                                    layoutActionBloc
                                                        .chosenIconFeelingStream
                                                        .notify(5);
                                                    disposeAnimation();
                                                    widget.chooseStatus("s_no");
                                                  }),
                                                ],
                                              ),
                                            ],
                                          ), //dòng các icon cảm xúc
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          widget.removeReact();
                                        },
                                        child: Container(
                                            padding: EdgeInsets.only(
                                                left: 7.5.w,
                                                right: 7.5.w,
                                                bottom: 7.5.h,
                                                top: 7.5.h),
                                            height: 160.h,
                                            margin:
                                                EdgeInsets.only(bottom: 32.5.h),
                                            decoration: BoxDecoration(
                                                color: prefix0.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(SizeRender
                                                        .renderBorderSize(
                                                            context, 90.0)))),
                                            child: Image.asset(
                                              "asset/images/ic_unheart_outline.png",
                                              height: 100.0.h,
                                            )),
                                      ),
                                    ],
                                  )
                                : Container())
                        : Container(),
                    Positioned(
                      top: appBloc.mainChatBloc.chatBloc.positionStatusBar.dy +
                          appBloc.mainChatBloc.chatBloc.sizeStatusBar.height -
                          106.h,
                      left: appBloc.mainChatBloc.chatBloc.positionStatusBar.dx -
                          100.h,
                      //appBloc.mainChatBloc.chatBloc.sizeStatusBar.width.w - 500.w,
                      child: StreamBuilder<int>(
                          initialData: 0,
                          stream:
                              layoutActionBloc.chosenIconFeelingStream.stream,
                          builder: (context, snapshotData) {
                            if (snapshotData.data == 0) return Container();

                            return Container(
                              width: 650.0.w,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  snapshotData.data == 1
                                      ? _buildItemStatusAnimation(
                                          "asset/images/ic_like.png",
                                          snapshotData.data)
                                      : Container(),
                                  snapshotData.data == 2
                                      ? _buildItemStatusAnimation(
                                          "asset/images/ic_dislike.png",
                                          snapshotData.data)
                                      : Container(),
                                  snapshotData.data == 3
                                      ? _buildItemStatusAnimation(
                                          "asset/images/ic_heart.png",
                                          snapshotData.data)
                                      : Container(),
                                  snapshotData.data == 4
                                      ? _buildItemStatusAnimation(
                                          "asset/images/ic_ok.png",
                                          snapshotData.data)
                                      : Container(),
                                  snapshotData.data == 5
                                      ? _buildItemStatusAnimation(
                                          "asset/images/ic_no.png",
                                          snapshotData.data)
                                      : Container(),
                                ],
                              ),
                            );
                          }),
                    )
                  ],
                );
              }),
    );
  }

  genderListItem(List<IAction> listAction) {
    return listAction.map<Widget>((action) {
      if (action == IAction.QUOTE) {
        return ItemMessageActionWidget(() {
          widget.onQuoteAction();
        }, 87.7, "Trả lời", "asset/images/action/ic_quote.png");
      } else if (action == IAction.COPY) {
        return ItemMessageActionWidget(() {
          widget.onCopyAction();
        }, 57.6, "Sao chép", "asset/images/action/ic_copy.png");
      } else if (action == IAction.SHARE) {
        return ItemMessageActionWidget(() {
          widget.onShare();
        }, 80.7, "Chia sẻ", "asset/images/action/ic_share.png");
      } else if (action == IAction.DELETE) {
        return ItemMessageActionWidget(() {
          widget.onRevokeAction();
        }, 81.5, "Thu hồi", "asset/images/action/ic_delete.png");
      } else if (action == IAction.EDIT) {
        return ItemMessageActionWidget(() {
          widget.onEditAction();
        }, 87.7, "Chỉnh sửa", "asset/images/action/ic_edit.png");
      } else if (action == IAction.DETECT_TEXT) {
        return ItemMessageActionWidget(() {
          widget.onDetectImage();
        }, 87.7, "Trích xuất", "");
      } else if (action == IAction.CANCEL) {
        return ItemMessageActionWidget(
          () {
            widget.onCloseAction();
          },
          40.3,
          "Hủy bỏ",
          "asset/images/action/ic_close_action.png",
        );
      } else {
        return Flexible(
          child: Container(),
          fit: FlexFit.tight,
          flex: 1,
        );
      }
    }).toList();
  }

  _buildItem(double sizeWidth, String summary, String assetImage,
      VoidCallback onClickItem) {
    return ZoomInAnimation(Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: GestureDetector(
          onDoubleTap: () {
            //Do not nothing in here
          },
          onTap: () {
            onClickItem();
          },
          child: Container(
            padding: EdgeInsets.only(top: 37.h, bottom: 25.6.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 90.0.h,
                  child: assetImage != ""
                      ? Image.asset(
                          assetImage,
                          width: sizeWidth.w,
                        )
                      : Icon(
                          Icons.flip,
                          color: prefix0.accentColor,
                        ),
                ),
                SizedBox(
                  height: 17.3.h,
                ),
                Text(
                  summary,
                  style: TextStyle(
                      fontFamily: "Roboto-Regular",
                      fontSize: 42.0.sp,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFFb1afaf)),
                )
              ],
            ),
          )),
    ));
  }

  _buildItemStatus(
      double sizeWidth, String assetImage, VoidCallback onClickItem) {
    return Flexible(
      flex: 1,
      fit: FlexFit.tight,
      child: GestureDetector(
        onTap: () {
          onClickItem();
        },
        child: Container(
          height: 160.h,
          padding: EdgeInsets.only(
              bottom: 14.0.h, top: 14.h, left: 15.w, right: 15.w),
          child: assetImage != ""
              ? Image.asset(
                  assetImage,
                  width: 170.w,
                )
              : Icon(
                  Icons.flip,
                  color: prefix0.accentColor,
                ),
        ),
      ),
    );
  }

  _buildItemStatusAnimation(String assetImage, int i) {
    return AnimatedBuilder(
        animation: animControlIconWhenRelease,
        builder: (BuildContext context, Widget child) {
          return Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: GestureDetector(
              onTap: () {},
              child: Transform.scale(
                scale: this.zoomIconWhenRelease.value,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 10.0,
                    left: this.moveUpIconWhenRelease.value,
                  ),
                  height: 160.h,
                  padding: EdgeInsets.only(
                      bottom: 14.0.h, top: 14.h, left: 15.w, right: 15.w),
                  child: assetImage != ""
                      ? Image.asset(
                          assetImage,
                          width: 170.w,
                        )
                      : Icon(
                          Icons.flip,
                          color: prefix0.accentColor,
                        ),
                ),
              ),
            ),
          );
        });
  }

  void disposeAnimation() {
    animControlIconWhenDrag.reset();
    animControlIconWhenDrag.forward();
    animControlIconWhenRelease.reset();
    animControlIconWhenRelease.forward();
  }
}
