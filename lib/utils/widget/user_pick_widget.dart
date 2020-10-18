import 'package:flutter/material.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/style.dart' as prefix0;

typedef OnPickUser = Function(bool);

class UserPickWidget extends StatefulWidget {
  final OnPickUser onPickUser;
  final String userName;
  final bool isCheckedAll;

  const UserPickWidget(
      {Key key,
      @required this.userName,
      @required this.onPickUser,
      this.isCheckedAll = false})
      : super(key: key);

  @override
  _UserPickWidgetState createState() => _UserPickWidgetState();
}

class _UserPickWidgetState extends State<UserPickWidget> {
  bool isChecked = false;
  _UserPickedBloc bloc = _UserPickedBloc();

  @override
  Widget build(BuildContext context) {
    if (widget.isCheckedAll) {
      bloc.isChecked = widget.isCheckedAll;
    }
    return InkWell(
        splashColor: prefix0.accentColor.withOpacity(0.2),
        onTap: () {
          bloc.changeState();
          widget.onPickUser(bloc.isChecked);
        },
        child: Container(
          height: 60.0,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Card(
                    elevation: 10.0,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45.0),
                    ),
                    child: Container(
                      width: 45.0,
                      height: 45.0,
                      child: Image.asset(
                        "asset/images/baseline-account_circle-24px.png",
                        color: prefix0.accentColor,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 15.0,
              ),
              Expanded(
                child: Container(
                  child: Text(
                    widget.userName,
                    textAlign: TextAlign.start,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: prefix0.text16BlackBold,
                  ),
                ),
              ),
              StreamBuilder(
                  initialData: bloc.isChecked,
                  stream: bloc.changeStatePickStream.stream,
                  builder: (buildContext, AsyncSnapshot<bool> checkedState) {
                    return Icon(
                      bloc.isChecked
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color:
                          bloc.isChecked ? prefix0.accentColor : prefix0.blackColor,
                    );
                  })
            ],
          ),
        ));
  }
}

class _UserPickedBloc {
  CoreStream<bool> changeStatePickStream = CoreStream();
  bool isChecked = false;

  void changeState() {
    isChecked = false;
    changeStatePickStream.notify(isChecked);
  }
}
