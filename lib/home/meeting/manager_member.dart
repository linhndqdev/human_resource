import 'package:flutter/material.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/meeting/model/participant_model.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:human_resource/home/meeting/action_meeting/edit_meeting_bloc.dart';

//Callback được sử dụng như này:
// dynamic ở đây có thể thay thế = List<Participaint>()
typedef OnResultData = Function(dynamic);
typedef OnBack = Function(dynamic);
typedef OnInit = Function();

class ManagerMember extends StatefulWidget {
  //final EditParticipantsModel editParticipantsModel;
//  final List<ParticipantModel> participant;
  final OnBack onBack;
  final OnResultData resultData;
  final OnInit onInit;
  final EditMeetingBloc editMeetingBloc;

  ManagerMember(
      {this.onBack, this.resultData, this.onInit, this.editMeetingBloc});

  @override
  _ManagerMemberState createState() => _ManagerMemberState();
}

class _ManagerMemberState extends State<ManagerMember> {
  //Muốn truyền về dữ liệu thì anh gọiL
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) {
    AppBloc appBloc = BlocProvider.of(context);
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 0.0,
          backgroundColor: prefix0.accentColor,
          title: Container(
            width: MediaQuery.of(context).size.width,
            height: 178.5.h,
            child: Stack(
              children: <Widget>[
                Positioned(
                  left: 0,
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 60.w, right: 59.w, bottom: 66.2.h, top: 60.h),
                      child: Image.asset(
                        "asset/images/ic_meeting_back_white.png",
                        color: prefix0.white,
                        width: ScreenUtil().setWidth(49.9),
                      ),
                    ),
                    onTap: () {
                      widget.onBack(1);
                    },
                  ),
                ),
                Center(
                  child: Text(
                    "Quản lý thành viên",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(60),
                        color: prefix0.whiteColor,
                        fontFamily: 'Roboto-Bold'),
                  ),
                )
              ],
            ),
          ),
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      Container(
                        color: Color(0xff959ca7).withOpacity(0.05),
                        padding: EdgeInsets.only(
                            top: ScreenUtil().setHeight(40),
                            bottom: ScreenUtil().setHeight(42),
                            left: ScreenUtil().setWidth(56)),
                        margin: EdgeInsets.only(
                          bottom: ScreenUtil().setHeight(29),
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              "Thành viên tham dự: ".toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Roboto-Regular',
                                fontSize: ScreenUtil().setSp(50),
                                color: Color(0xff959ca7),
                              ),
                            ),
                            StreamBuilder<int>(
                                initialData:
                                    widget.editMeetingBloc.listMember.length,
                                stream: widget
                                    .editMeetingBloc.countMemberStream.stream,
                                builder: (context, snapshot) {
                                  return Text(
                                    snapshot.data.toString(),
                                    style: TextStyle(
                                      fontFamily: 'Roboto-Bold',
                                      fontSize: ScreenUtil().setSp(50),
                                      color: prefix0.blackColor333,
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                      Positioned(
                        top: ScreenUtil().setHeight(28.0),
                        right: ScreenUtil().setWidth(59),
                        child: InkWell(
                          onTap: () {
                            widget.editMeetingBloc.openAddMember(true);
                          },
                          child: Image.asset(
                            "asset/images/ic_addMember.png",
                            width: ScreenUtil().setWidth(92.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  StreamBuilder<List<ParticipantModel>>(
                      initialData: widget.editMeetingBloc.listMember,
                      stream: widget.editMeetingBloc.listMemberStream.stream,
                      builder: (context, snapshot) {
                        return Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
//                              physics: AlwaysScrollableScrollPhysics(),
                            itemCount: snapshot.data.length,
                            itemBuilder: (buildContex, index) {
                              ParticipantModel data_pa = snapshot.data[index];
                              return Container(
                                margin: EdgeInsets.only(
                                  bottom: ScreenUtil().setHeight(37),
                                  left: ScreenUtil().setWidth(60),
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Image.asset(
                                          "asset/images/baseline-account_circle-24px.png",
                                          width: ScreenUtil().setWidth(114.0),
                                          height: ScreenUtil().setWidth(114.0),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: ScreenUtil().setWidth(60)),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                data_pa.name,
                                                style: TextStyle(
                                                  fontFamily: 'Roboto-Regular',
                                                  fontSize:
                                                      ScreenUtil().setSp(50),
                                                  color: prefix0.blackColor333,
                                                ),
                                              ),
                                              Text(
                                                getDepartment(data_pa),
                                                style: TextStyle(
                                                  fontFamily: 'Roboto-Regular',
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                  color: Color(0xff959ca7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: ScreenUtil().setHeight(10)),
                                          child: Icon(
                                            Icons.brightness_1,
                                            color: (data_pa.accepted == 1)
                                                ? Color(0xff3baae2)
                                                : Color(0xff959ca7),
                                            size: ScreenUtil().setWidth(34),
                                          ),
                                        )
                                      ],
                                    ),
                                    Positioned(
                                      top: ScreenUtil().setHeight(10),
                                      right: ScreenUtil().setWidth(75),
                                      child: InkWell(
                                        onTap: () {
                                          widget.editMeetingBloc.removeUser(
                                              data: data_pa,
                                              context: context,
                                              appBloc: appBloc);
                                        },
                                        child: Container(
                                            width: ScreenUtil().setWidth(60),
                                            height: ScreenUtil().setWidth(60),
                                            decoration: BoxDecoration(
                                                color: Color(0xffe10606),
                                                shape: BoxShape.circle),
                                            child: Center(
                                              child: Icon(
                                                Icons.close,
                                                color: prefix0.white,
                                                size:
                                                    ScreenUtil().setWidth(47.4),
                                              ),
                                            )),
                                      ),
                                    ) //đấu x đỏ
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      }),
                  SizedBox(
                    height: ScreenUtil().setHeight(450.0),
                  ),
                ],
              ),
            ),
            Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: <Widget>[
                      ButtonTheme(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: ScreenUtil().setHeight(163.0),
                          padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(129),
                            right: ScreenUtil().setWidth(128),
                          ),
                          child: new ButtonTheme(
                            child: RaisedButton.icon(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      ScreenUtil().setWidth(10.0))),
                              elevation: 0.0,
                              icon: Text(''),
                              color: prefix0.accentColor,
                              highlightColor: prefix0.accentColor,
                              label: Text('Hoàn tất',
                                  style: TextStyle(
                                    fontFamily: 'Roboto-Bold',
                                    fontSize: ScreenUtil().setSp(60.0),
                                    color: prefix0.whiteColor,
                                  )),
                              onPressed: () {
                                widget.resultData(1);
                              },
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border(
                          top: BorderSide(
                            color: Color(0xfff2f2f2),
                            width: 1.0,
                          ),
                        )),
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(
                          top: ScreenUtil().setWidth(54),
                        ),
                        padding: EdgeInsets.only(
                          top: ScreenUtil().setWidth(46),
                          bottom: ScreenUtil().setWidth(41.6),
                          left: ScreenUtil().setWidth(129),
                          right: ScreenUtil().setWidth(128),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.brightness_1,
                                  color: Color(0xff3baae2),
                                  size: ScreenUtil().setWidth(34),
                                ),
                                SizedBox(
                                  width: ScreenUtil().setWidth(20),
                                ),
                                Flexible(
                                  child: Text(
                                    "Đã xác nhận",
                                    style: TextStyle(
                                        fontFamily: 'Roboto-Regular',
                                        color: Color(0xff959ca7)),
                                  ),
                                )
                              ],
                            ),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.brightness_1,
                                    color: Color(0xff959ca7),
                                    size: ScreenUtil().setWidth(34),
                                  ),
                                  SizedBox(
                                    width: ScreenUtil().setWidth(20),
                                  ),
                                  Flexible(
                                    child: Text(
                                      "Chưa xác nhận",
                                      style: TextStyle(
                                          fontFamily: 'Roboto-Regular',
                                          color: Color(0xff959ca7)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.brightness_1,
                                  color: Color(0xffe10606),
                                  size: ScreenUtil().setWidth(34),
                                ),
                                SizedBox(
                                  width: ScreenUtil().setWidth(20),
                                ),
                                Flexible(
                                  child: Text(
                                    "Từ chối",
                                    style: TextStyle(
                                        fontFamily: 'Roboto-Regular',
                                        color: Color(0xff959ca7)),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
          ],
        ));
  }

  String getDepartment(ParticipantModel member) {
    List<Position> position = member?.positions;
    if (position != null && position.length > 0) {
      return position[0]?.department?.name ?? "Không xác định";
    } else {
      return "Không xác định";
    }
  }
}
