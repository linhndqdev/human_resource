import 'package:flutter/material.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/animation/BoundButtonAnimation.dart';
class PopUpConfirmDetailsWidget extends StatefulWidget {
  final AppBloc appBloc;
  final bool isSucess;

  PopUpConfirmDetailsWidget(this.appBloc,this.isSucess);

  @override
  _PopUpConfirmDetailsWidgetState createState() => _PopUpConfirmDetailsWidgetState();
}

class _PopUpConfirmDetailsWidgetState extends State<PopUpConfirmDetailsWidget> with SingleTickerProviderStateMixin  {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);
    super.initState();
    _animationController.forward();

  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(
                      left: 5.0, right: 5.0, top: 10.0),
                  child: Text("Thông báo",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 20.0, color: Colors.black))),
              Padding(
                  padding: EdgeInsets.only(
                      left: 5.0, right: 5.0, top: 10.0, bottom: 5.0),
                  child: Text(widget.isSucess?"Chúc mừng bạn đã gửi ảnh thành công !":"Gửi ảnh thất bại bạn vui lòng kiểm tra lại kết nối và gửi lại!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14.0, color: Colors.black))),
              SizedBox(height: 5.0,),
              _buildLineButton(),
                  SizedBox(height: 30.0,),

    ]));

  }
  _buildLineButton() {
    double buttonSizeWidth = MediaQuery.of(context).size.width;
    return Container(
        margin: EdgeInsets.only(left: 20.0,right: 20.0),
        width: MediaQuery.of(context).size.width,
        child:BoundButtonAnimation(
            animationController: _animationController,
//                  maxWidth: buttonSizeWidth,
            child: prefix0.buttonThemeWithPopup(
              onClickButton: (){

              },
              btnMinWith:buttonSizeWidth*0.35,
              title:"Đóng",
              borderColor: prefix0.blackColor,
            )
        ),

    );
  }
}
