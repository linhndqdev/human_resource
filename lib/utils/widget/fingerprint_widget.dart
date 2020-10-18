import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:human_resource/auth/auth_bloc.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/platform/platform_helper.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/dialog_fingerprint_widget.dart';
import 'package:human_resource/utils/widget/fingerprint_button_login.dart';

class FingerprintWidget extends StatefulWidget {
  final AppBloc appBloc;
  final BuildContext context;
  final bool statusFingerPrintKey;

  FingerprintWidget(this.appBloc, this.context, this.statusFingerPrintKey);

  @override
  _FingerprintWidgetState createState() => _FingerprintWidgetState();
}

class _FingerprintWidgetState extends State<FingerprintWidget> {
  String content = "Auth";
  bool haveUsernameAndPass = false;
  final MethodChannel methodChannel =
      MethodChannel("com.asgl.human_resource.fingerprint_channel");

  @override
  void initState() {
    super.initState();
//    AppBloc appBloc = BlocProvider.of(context);
    //Khởi tạo xác thực vân tay trong hệ thống
    PlatformHelper.authenticateWithFingerPrint(widget.statusFingerPrintKey);
//      if(widget.statusFingerPrintKey) CacheHelper.saveStatusFingerPrint(status: false);
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == "com.asgl.human_resource.auth_result") {
        if (call.arguments is int) {
          int state = call.arguments as int;
//            Toast.showShort(state.toString());
          switch (state) {
            case -4:
              //Người dùng cập nhật vân tay mới hoặc xóa 1 vân tay
              content =
                  "Dữ liệu vân tay được cập nhật. Vui lòng đăng nhập lại với Tài khoản và mật khẩu.";
              widget.appBloc.authBloc.enableAndDisableButton
                  .notify(FingerPrintButtonState.HIDE);
              widget.appBloc.authBloc.fingerPrintStatusStream
                  .notify(FingerPrintStatusModel(
                      FingerPrintStatusState.UPADATE,
                      "Thất bại",
                      content,
                      false,
                      TextStyle(
                        color: Color(0xffee8800),
                        fontFamily: 'Roboto-Bold',
                        fontSize: 50.sp,
                      ),
                      false));
//                PlatformHelper.authenticateWithFingerPrint(true);
              //  CacheHelper.saveStatusFingerPrint(status: true);
              break;
            case -3:
              //Lỗi tạo key xác thực
              content =
                  "Xác thực vân tay không thành công vui lòng sử dụng tài khoản và mật khẩu để đăng nhập.";
              widget.appBloc.authBloc.fingerPrintStatusStream
                  .notify(FingerPrintStatusModel(
                      FingerPrintStatusState.KEYVERYFY,
                      "Thất bại",
                      content,
                      false,
                      TextStyle(
                        color: Color(0xffee8800),
                        fontFamily: 'Roboto-Bold',
                        fontSize: 50.sp,
                      ),
                      false));
              break;
            case -2:
              //Nếu người dùng chưa cài đặt vân tay cho ứng dụng
              content =
                  "Vui lòng cài đặt vân tay cho thiết bị để sử dụng tính năng này.";
              widget.appBloc.authBloc.fingerPrintStatusStream
                  .notify(FingerPrintStatusModel(
                      FingerPrintStatusState.HAVENFINGERPRINT,
                      "Thất bại",
                      content,
                      false,
                      TextStyle(
                        color: Color(0xffee8800),
                        fontFamily: 'Roboto-Bold',
                        fontSize: 50.sp,
                      ),
                      false));
              break;
            case -1:
              //Nếu người dùng chưa cài đặt khóa màn hình thì hiển thị thông báo ở đây
              content =
                  "Vui lòng cài đặt khóa màn hình cho thiết bị để sử dụng tính năng này.";
              widget.appBloc.authBloc.fingerPrintStatusStream
                  .notify(FingerPrintStatusModel(
                      FingerPrintStatusState.HAVENLOCKSCREEN,
                      "Thất bại",
                      content,
                      false,
                      TextStyle(
                        color: Color(0xffee8800),
                        fontFamily: 'Roboto-Bold',
                        fontSize: 50.sp,
                      ),
                      false));
              break;
            case 0:
              //Authenticate thất bại do sai vân tay
              content = "Xác thực thất bại vui lòng thử lại.";
              widget.appBloc.authBloc.fingerPrintStatusStream
                  .notify(FingerPrintStatusModel(
                      FingerPrintStatusState.ERRORFINGERPRINT,
                      "Thử lại",
                      content,
                      false,
                      TextStyle(
                        color: prefix0.accentColor,
                        fontFamily: 'Roboto-Bold',
                        fontSize: 50.sp,
                      ),
                      false));
              break;
            case 1:
              Toast.showShort("Xác thực thành công.");
              widget.appBloc.authBloc
                  .checkAuth(widget.appBloc, checkFromFingerPrint: true);
              await _cancelFingerprint();
              Navigator.of(context).pop();
              break;
            case 2:
              //Xác thực thất bại quá nhiều lần hoặc thao tác dùng vân tay bị hủy
              _cancelFingerprint();
              widget.appBloc.authBloc.enableAndDisableButton
                  .notify(FingerPrintButtonState.HIDE);
              content =
                  "Xác thực thất bại quá 5 lần. Vui lòng sử dụng tài khoản và mật khẩu để đăng nhập.";
              widget.appBloc.authBloc.fingerPrintStatusStream
                  .notify(FingerPrintStatusModel(
                      FingerPrintStatusState.MULTIVERYFIFINGERPRINT,
                      "Thất bại",
                      content,
                      false,
                      TextStyle(
                        color: Color(0xffee8800),
                        fontFamily: 'Roboto-Bold',
                        fontSize: 50.sp,
                      ),
                      false));
              break;
            case 3:
              Navigator.of(context).pop();
              break;
          }
        }
      }
    });
  }

  _cancelFingerprint() {
    methodChannel.invokeMethod("com.asgl.human_resource.cancel_authenticate");
  }

  @override
  void dispose() {
    //Hủy luồng xác thực vân tay dưới native
    _cancelFingerprint();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: FingerPrintStatusModel(
            FingerPrintStatusState.NONE, null, null, null, null, null),
        stream: widget.appBloc.authBloc.fingerPrintStatusStream.stream,
        builder:
            (buildContent, AsyncSnapshot<FingerPrintStatusModel> snapshot) {
          switch (snapshot.data.state) {
            case FingerPrintStatusState.UPADATE:
              return DialogFingerPrint(
                  snapshot.data.title,
                  snapshot.data.message,
                  snapshot.data.haveButton,
                  snapshot.data.styleTitle,
                  snapshot.data.fingerPrintDisable);
              break;
            case FingerPrintStatusState.KEYVERYFY:
              return DialogFingerPrint(
                  snapshot.data.title,
                  snapshot.data.message,
                  snapshot.data.haveButton,
                  snapshot.data.styleTitle,
                  snapshot.data.fingerPrintDisable);
              break;
            case FingerPrintStatusState.HAVENFINGERPRINT:
              return DialogFingerPrint(
                  snapshot.data.title,
                  snapshot.data.message,
                  snapshot.data.haveButton,
                  snapshot.data.styleTitle,
                  snapshot.data.fingerPrintDisable);
              break;
            case FingerPrintStatusState.HAVENLOCKSCREEN:
              return DialogFingerPrint(
                  snapshot.data.title,
                  snapshot.data.message,
                  snapshot.data.haveButton,
                  snapshot.data.styleTitle,
                  snapshot.data.fingerPrintDisable);
              break;
            case FingerPrintStatusState.ERRORFINGERPRINT:
              return DialogFingerPrint(
                  snapshot.data.title,
                  snapshot.data.message,
                  snapshot.data.haveButton,
                  snapshot.data.styleTitle,
                  snapshot.data.fingerPrintDisable);
              break;
            case FingerPrintStatusState.SUCCERFINGERPRINT:
              //thành công

              return Container();
              break;
            case FingerPrintStatusState.MULTIVERYFIFINGERPRINT:
              return DialogFingerPrint(
                  snapshot.data.title,
                  snapshot.data.message,
                  snapshot.data.haveButton,
                  snapshot.data.styleTitle,
                  snapshot.data.fingerPrintDisable);
              break;
            case FingerPrintStatusState.NONE:
              return DialogFingerPrint(
                  "Đăng nhập bằng vân tay",
                  "Vui lòng quét vân tay để đăng nhập (Lưu ý: Có thể sử dụng vân tay đã đăng ký thành công trên thiết bị)",
                  true,
                  TextStyle(
                    color: prefix0.accentColor,
                    fontFamily: 'Roboto-Bold',
                    fontSize: 50.sp,
                  ),
                  false);

              break;
            default:
              return Container();
              break;
          }
        });

//      Container(
//      child: Column(
//        mainAxisSize: MainAxisSize.min,
//        children: <Widget>[
//          Text("Đăng nhậ1111p"),
//          Text(
//            content,
//            style: TextStyle(color: Colors.black),
//          ),
//          RaisedButton(onPressed: (){
//              PlatformHelper.authenticateWithFingerPrint(true);
//          })
//        ],
//      ),
//    );
  }
}
