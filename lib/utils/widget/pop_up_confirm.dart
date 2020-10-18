import 'package:flutter/material.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/utils/widget/popup_confirm_details.dart';
class PopUpConfirmWidget extends StatefulWidget {
  final AppBloc appBloc;
  final bool isSucces;
  PopUpConfirmWidget(this.appBloc,this.isSucces);

  @override
  _PopUpConfirmWidgetState createState() => _PopUpConfirmWidgetState();
}

class _PopUpConfirmWidgetState extends State<PopUpConfirmWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return;
        },
        child: Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: PopUpConfirmDetailsWidget(widget.appBloc,widget.isSucces)));

  }
}
