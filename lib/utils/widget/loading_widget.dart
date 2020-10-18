import 'package:flutter/material.dart';
import 'package:human_resource/core/style.dart' as prefix0;

class Loading extends StatelessWidget {
  const Loading({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(prefix0.accentColor)),
        ),
        ModalBarrier(
          dismissible: false,
          color: prefix0.blackColor.withOpacity(0.3),
        ),
      ],
    );
  }
}
