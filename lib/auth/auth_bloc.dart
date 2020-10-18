import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as Http;
import 'package:human_resource/chat/websocket/ws_action.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:human_resource/core/api_respository.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/constant.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/core/fcm/fcm_services.dart';
import 'package:human_resource/core/hive/hive_helper.dart';
import 'package:human_resource/core/platform/platform_helper.dart';
import 'package:human_resource/core/socket/socket_helper_other.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/model/auth_model.dart';
import 'package:human_resource/utils/common/cache_helper.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/common/validator.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';
import 'package:human_resource/utils/widget/fingerprint_button_login.dart';

class AuthBloc {
  ApiRepository _apiRepository = ApiRepository();
  CoreStream<AuthenticationModel> authStream = CoreStream();
  CoreStream<bool> loadingStream = CoreStream();
  CoreStream<bool> rememberPassStream = CoreStream();
  CoreStream<bool> showPassStream = CoreStream();
  CoreStream<bool> showPassStream2 = CoreStream();
  CoreStream<bool> showPassStreamCurrent = CoreStream();
  CoreStream<FingerPrintButtonState> enableAndDisableButton = CoreStream();
  CoreStream<FingerPrintStatusModel> fingerPrintStatusStream = CoreStream();
  bool allowGotoHome = false;
  bool isRememberPass = false;
  bool isShowPass = false;
  bool isShowPass2 = false;
  bool isShowPass_current = false;
  bool isNotLogOut = true;
  ASGUserModel asgUserModel;
  String email;

  CoreStream<RegisterOldValidateState> validateUserStream = CoreStream();
  CoreStream<RegisterOldValidateState> validatePassStream = CoreStream();
  CoreStream<RegisterOldValidateState> validateEmailForgotPass = CoreStream();

  CoreStream<bool> allowUpdateStream = CoreStream();
  CoreStream<ForgotPassModel> forgotPassStream = CoreStream();

  FingerPrintButtonState fingerPrintStatusState = FingerPrintButtonState.HIDE;

  AuthBloc();

  void close() {
    showPassStreamCurrent?.closeStream();
    showPassStream2?.closeStream();
    validateUserStream?.closeStream();
    loadingStream?.closeStream();
    validatePassStream?.closeStream();
    validateEmailForgotPass?.closeStream();
    forgotPassStream?.closeStream();
    rememberPassStream?.closeStream();
  }

  void dispose() {
    authStream?.closeStream();
  }

  Future<bool> getChatUserInfo(AppBloc appBloc) async {
    WsAccountModel accountModel = WebSocketHelper.getInstance().wsAccountModel;
    Uri uri = Uri.https(Constant.SERVER_CHAT_NO_HTTP, "api/v1/users.info",
        {"userId": "${accountModel.id}"});
    String userName = "";
    await Http.get(uri, headers: {
      "X-Auth-Token": "${accountModel.token}",
      "X-User-Id": "${accountModel.id}",
    }).then((response) {
      return response.bodyBytes;
    }).then((body) {
      return jsonDecode(utf8.decode(body));
    }).then((data) {
      if (data != null && data != "") {
        if (data['user'] != null && data['user'] != "") {
          if (data['user']['username'] != null &&
              data['user']['username'] != "") {
            userName = data['user']['username'];
          }
        }
      }
    }).catchError((onError) {
      userName = "";
    });
    if (userName != null && userName != "") {
      WebSocketHelper.getInstance().userName = userName;
      return true;
    } else {
      return false;
    }
  }

  void loginSuccess(AppBloc appBloc) async {
    String jwt = await CacheHelper.getAccessToken();
    String userID = await CacheHelper.getID();
    SocketHelperOther.instance.connectSocketServer(appBloc, jwt, userID);
    if (allowGotoHome) {
      bool isGetDataSuccess = await getChatUserInfo(appBloc);
      if (isGetDataSuccess) {
        allowGotoHome = false;
        AuthenticationModel authenticationModel =
            AuthenticationModel(AuthState.LOGIN_SUCCESS, true, null);
        authStream.notify(authenticationModel);
      } else {
        AuthenticationModel authenticationModel =
            AuthenticationModel(AuthState.REQUEST_LOGIN, false, null);
        authStream.notify(authenticationModel);
      }
    }
  }

  void loginWith(BuildContext context, String account, String password,
      {bool isLoginFormFingerPrint = false}) async {
    if (WebSocketHelper.getInstance().isConnected) {
      loadingStream.notify(true);
      if (account != null && account != "") {
        if (password != null && password.trim().toString() != "") {
          ApiServices apiServices = ApiServices();
          await apiServices.loginASGL(
              account: account,
              password: password,
              onResultData: (resultData) async {
                if (resultData != null &&
                    resultData['data'] != null &&
                    resultData['data'] != "") {
                  PlatformHelper.resetNewDomain();
                  String token = resultData['data']['token'];
                  CacheHelper.saveAccessToken(token);
                  CacheHelper.saveUserName(userName: account);
                  CacheHelper.savePassword(password: password);
//                  PlatformHelper.authenticateWithFingerPrint(true);
                  if (isLoginFormFingerPrint) {
                    CacheHelper.saveStatusFingerPrint(status: false);
                  } else {
                    CacheHelper.saveStatusFingerPrint(status: true);
                  }
                  FCMServices fcmServices = FCMServices();
                  fcmServices.postTokenToServer();
                  asgUserModel =
                      ASGUserModel.fromJsonLogin(resultData['data']['user']);
                  if (asgUserModel != null) {
                    await HiveHelper.saveUserInfo(asgUserModel);
                  }
                  CacheHelper.saveIdUser(id: asgUserModel.id.toString());
                  loginChat(context, account, password);
                }
              },
              onErrorApiCallback: (onError) {
                loadingStream.notify(false);
                Toast.showShort(onError.toString());
                requestLogin();
              });
        } else {
          loadingStream.notify(false);
          Toast.showShort("Vui lòng nhập mật khẩu!");
        }
      } else {
        loadingStream.notify(false);
        Toast.showShort("Vui lòng nhập mã nhân viên.");
      }
    } else {
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Vui lòng kiểm tra kết nối mạng của bạn và thử lại.");
    }
    loadingStream.notify(false);
  }

  loginChat(BuildContext context, String account, String password) {
    if (WebSocketHelper.getInstance().isConnected) {
      WebSocketHelper.getInstance().isAutoLogin = true;
      allowGotoHome = true;
      WebSocketHelper.getInstance()
          .connectWithAction(ActionState.WS_LOGIN, requestData: {
        "username": "$account",
        "password": "$password",
      });
    } else {
      loadingStream.notify(false);
      DialogUtils.showDialogResult(
          context, DialogType.FAILED, ErrorModel.netError);
      requestLogin();
    }
  }

  loginChatNoContext(String account, String pass) {
    if (WebSocketHelper.getInstance().isConnected) {
      WebSocketHelper.getInstance().isAutoLogin = true;
      allowGotoHome = true;
      WebSocketHelper.getInstance()
          .connectWithAction(ActionState.WS_LOGIN, requestData: {
        "username": "$account",
        "password": "$pass",
      });
    } else {
      requestLogin(error: ErrorType.CONNECTION_ERROR);
    }
  }

  void requestLogin({ErrorType error}) {
    if (error == ErrorType.CONNECTION_ERROR) {
      Toast.showShort(
          "Kết nối mạng của bạn không ổn định. Vui lòng kiểm tra lại kết nối của bạn.");
    } else if (error == ErrorType.DATA_ERROR) {
      Toast.showShort(
          "Không tìm thấy thông tin của bạn. Vui lòng đăng nhập lại để cập nhật thông tin mới nhất.");
    }
    AuthenticationModel authenticationModel =
        AuthenticationModel(AuthState.REQUEST_LOGIN, false, error);
    loadingStream.notify(false);
    authStream.notify(authenticationModel);
  }

  void updateUser(String maNhanVien) {
    this.email = maNhanVien;
    if (this.email == null || this.email.trim() == "") {
      validateUserStream.notify(RegisterOldValidateState.NONE);
    } else {
      validateUserStream.notify(maNhanVien.length >= 4
          ? RegisterOldValidateState.MATCHED
          : RegisterOldValidateState.ERROR);
    }
  }

  void updateEmailForgotPass(String email) {
    this.email = email;
    if (this.email == null || this.email.trim() == "") {
      validateEmailForgotPass.notify(RegisterOldValidateState.NONE);
    } else {
      Validators validators = Validators();
      validateEmailForgotPass.notify(validators.validUser(this.email)
          ? RegisterOldValidateState.MATCHED
          : RegisterOldValidateState.ERROR);
    }
  }

  static bool regexName(String name) {
    RegExp regExp = RegExp('[a-zA-Z]');
    return regExp.hasMatch(name);
  }

  //Chuyen trang thai loadding man ForgotPassword
  void changeStateToLoadingForgotPass() async {
    ForgotPassModel forgotPassModel =
        ForgotPassModel(ForgotPassState.LOADING, null);
    forgotPassStream.notify(forgotPassModel);
  }

  Future<void> logOut(BuildContext context) async {
    WebSocketHelper.getInstance().isAutoLogin = false;
    AppBloc appBloc = BlocProvider.of(context);
    appBloc.homeBloc.loadingStream.notify(true);
    ApiServices apiServices = ApiServices();
    await apiServices.logOutChat(resultData: (onResult) async {
      appBloc?.notificationBloc?.clearCache();
      SocketHelperOther.instance.disconnect();
      isNotLogOut = false;
      await HiveHelper.removeCacheWhenLogOut();
      FCMServices services = FCMServices();
      DefaultCacheManager manager = new DefaultCacheManager();
      try {
        manager.emptyCache();
      } catch (ex) {} // data in cache.
      await services.removeToken();
      await CacheHelper.removeCachedWhenLogOut();
      WebSocketHelper.getInstance().clearCacheWhenLogOut();

      appBloc.homeBloc.bottomBarCurrentIndex = 0;
      appBloc.homeBloc.indexStackHome = 0;
      appBloc.mainChatBloc.clearCache();
      appBloc.homeBloc.loadingStream.notify(false);
      requestLogin();
    }, onErrorApiCallback: (onError) {
      WebSocketHelper.getInstance().isAutoLogin = true;
      appBloc.homeBloc.loadingStream.notify(false);
      DialogUtils.showDialogResult(
          context, DialogType.FAILED, onError.toString());
    });
  }

//Hàm quên mật khẩu khi nhấn vào nút Quên mật khẩu
  void forgotPassword(BuildContext context, String account) async {
    loadingStream.notify(true);
    if (account.length >= 4) {
      var response = await _apiRepository.createPostNoJWT(
          Constant.SERVER_BASE, "/api/auth/password/email",
          body: {"login": "$account"});

      if (response == null) {
        loadingStream.notify(false);
        DialogUtils.showDialogLogin(context, false, "Thông báo",
            "Vui lòng kiểm tra lại kết nối internet và thử lại");
      } else {
        if (response is int) {
          loadingStream.notify(false);
          DialogUtils.showDialogLogin(context, false, "Thông báo",
              "Không đăng nhập được vui lòng liên hệ với đội support để được hỗ trợ");
        } else {
          dynamic data = json.decode(response.body);
          if (data != null &&
              data['success'].toString() == "true" &&
              data['message'].toString() != "") {
            try {
              loadingStream.notify(false);
              loadingStream.notify(false);
//              appBloc.authBloc.authStream.notify(AuthenticationModel(AuthState.CONFIRMFORGOTPASS, null, data['message']));
              if (data['data']['email'] == null ||
                  data['data']['email'] == "") {
                DialogUtils.showDialogForgotSuccess(
                    context,
                    false,
                    "Quên mật khẩu",
                    "Vui lòng liên hệ bộ phận hỗ trợ để nhận được hướng dẫn!",
                    "",
                    false);
              } else {
                DialogUtils.showDialogForgotSuccess(
                    context,
                    false,
                    "Quên mật khẩu",
                    data['message'],
                    data['data']['email'],
                    true);
              }
            } catch (onError) {
              loadingStream.notify(false);
              DialogUtils.showDialogLogin(
                  context, false, "Thông báo", onError.toString());
            }
          } else {
            loadingStream.notify(false);
            DialogUtils.showDialogLogin(
                context, false, "Thông báo", data['message'] ?? data['errors']);
          }
          //Thanh cong chuyen ve man dang nhap
//          _changeStateAuth(state: AuthState.REQUEST_LOGIN,data: null);
        }
      }
    } else {
      loadingStream.notify(false);
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Vui lòng điền mã nhân viên đúng định dạng !");
    }
  }

  void updateStateRememberPass() async {
    isRememberPass = !isRememberPass;
    await CacheHelper.saveStateRememberPass(isRememberPass);
    rememberPassStream?.notify(isRememberPass);
  }

  void updateStateShowPassCurrent() async {
    isShowPass_current = !isShowPass_current;
    showPassStreamCurrent?.notify(isShowPass_current);
  }

  void updateStateShowPass() async {
    isShowPass = !isShowPass;
    showPassStream?.notify(isShowPass);
  }

  void updateStateShowPass2() async {
    isShowPass2 = !isShowPass2;
    showPassStream2?.notify(isShowPass2);
  }

  void changeStateBackToLogin() {
    AuthenticationModel authenticationModel =
        AuthenticationModel(AuthState.REQUEST_LOGIN, false, null);
    authStream.notify(authenticationModel);
  }

  //Chuyển màn
  //chuyen man Quen mat khau
  void moveToForgotPassScreen() async {
    AuthenticationModel authenticationModel =
        AuthenticationModel(AuthState.FORGOTPASS, null, null);
    authStream.notify(authenticationModel);
  }

  //Chuyển màn login
  void moveToLoginScreen() async {
    AuthenticationModel authenticationModel =
        AuthenticationModel(AuthState.REQUEST_LOGIN, null, null);
    authStream.notify(authenticationModel);
  }

  void checkAuth(AppBloc appBloc, {bool checkFromFingerPrint = false}) async {
    dynamic _jsonDataOpenApp = await PlatformHelper.getDataOpenApp();
    if (_jsonDataOpenApp != null && _jsonDataOpenApp != "") {
      if (Platform.isIOS) {
        dynamic data = json.decode(_jsonDataOpenApp);
        await CacheHelper.saveAccessToken(data['jwt']);
        await CacheHelper.savePassword(password: data['password']);
        await CacheHelper.saveUserName(userName: data['userName']);
        bool isConnectedWebSocket = WebSocketHelper.getInstance().isConnected;
        if (isConnectedWebSocket) {
          reLoginASGL(appBloc, data['userName'], data['password']);
        } else {
          requestLogin();
        }
      } else if (Platform.isAndroid) {
        print("Open from app: $_jsonDataOpenApp");
        await CacheHelper.saveAccessToken(_jsonDataOpenApp['jwt']);
        await CacheHelper.savePassword(password: _jsonDataOpenApp['password']);
        await CacheHelper.saveUserName(userName: _jsonDataOpenApp['userName']);
        bool isConnectedWebSocket = WebSocketHelper.getInstance().isConnected;
        if (isConnectedWebSocket) {
          reLoginASGL(appBloc, _jsonDataOpenApp['userName'],
              _jsonDataOpenApp['password']);
        } else {
          requestLogin();
        }
      }
    } else if (checkFromFingerPrint) {
      String userName = await CacheHelper.getUserName();
      String password = await CacheHelper.getPassword();
      String jwt = await CacheHelper.getAccessToken();
      if (userName == null || userName == "") {
        requestLogin();
      } else if (password == null || password == "") {
        requestLogin();
      } else if (jwt == null || jwt == "") {
        requestLogin();
      } else {
        String time = await CacheHelper.getLastTimeUpdateJWT();
        bool isConnectedWebSocket = WebSocketHelper.getInstance().isConnected;
        if (isConnectedWebSocket) {
          ASGUserModel userModel = await HiveHelper.getCurrentUserInfo();
          if (userModel != null) {
            asgUserModel = userModel;
            if (time == null || time == "") {
              CacheHelper.saveStatusFingerPrint(status: false);
              loginChatNoContext(userName, password);
            } else {
              int iTime = int.parse(time);
              DateTime currentDate = DateTime.now();
              int iCurrent = currentDate.millisecondsSinceEpoch;
              //60 * 24 * 3600000: 60 ngày tính theo timestamp
              if (iCurrent - iTime > (60 * 24 * 3600000)) {
                CacheHelper.saveStatusFingerPrint(status: false);
                reLoginASGL(appBloc, userName, password);
              } else {
                CacheHelper.saveStatusFingerPrint(status: false);
                loginChatNoContext(userName, password);
              }
            }
          } else {
            requestLogin(error: ErrorType.DATA_ERROR);
          }
        } else {
          requestLogin(error: ErrorType.CONNECTION_ERROR);
        }
      }
    } else {
      print("Check remember pass");
      bool isRememberPass = await CacheHelper.getStateRememberPass();
      if (isRememberPass) {
        String userName = await CacheHelper.getUserName();
        String password = await CacheHelper.getPassword();
        String jwt = await CacheHelper.getAccessToken();
        if (userName == null || userName == "") {
          requestLogin();
        } else if (password == null || password == "") {
          requestLogin();
        } else if (jwt == null || jwt == "") {
          requestLogin();
        } else {
          String time = await CacheHelper.getLastTimeUpdateJWT();
          bool isConnectedWebSocket = WebSocketHelper.getInstance().isConnected;
          if (isConnectedWebSocket) {
            ASGUserModel userModel = await HiveHelper.getCurrentUserInfo();
            if (userModel != null) {
              asgUserModel = userModel;
              if (time == null || time == "") {
                loginChatNoContext(userName, password);
              } else {
                int iTime = int.parse(time);
                DateTime currentDate = DateTime.now();
                int iCurrent = currentDate.millisecondsSinceEpoch;
                //60 * 24 * 3600000: 60 ngày tính theo timestamp
                if (iCurrent - iTime > (60 * 24 * 3600000)) {
                  reLoginASGL(appBloc, userName, password);
                } else {
                  loginChatNoContext(userName, password);
                }
              }
            } else {
              requestLogin(error: ErrorType.DATA_ERROR);
            }
          } else {
            requestLogin(error: ErrorType.CONNECTION_ERROR);
          }
        }
      } else {
        Future.delayed(Duration(seconds: 2), () {
          authStream.notify(
            AuthenticationModel(AuthState.REQUEST_LOGIN, false, null),
          );
        });
      }
    }
  }

  //Chỉ dùng khi webSocket check auth
  void reLoginASGL(AppBloc appBloc, String account, String pass) async {
    ApiServices apiServices = ApiServices();
    await apiServices.loginASGL(
        account: account,
        password: pass,
        onResultData: (resultData) async {
          if (resultData != null &&
              resultData['data'] != null &&
              resultData['data'] != "") {
            String token = resultData['data']['token'];
            CacheHelper.saveAccessToken(token);
            CacheHelper.saveUserName(userName: account);
            CacheHelper.savePassword(password: pass);
            FCMServices fcmServices = FCMServices();
            fcmServices.postTokenToServer();
            asgUserModel =
                ASGUserModel.fromJsonLogin(resultData['data']['user']);
            if (asgUserModel != null) {
              await HiveHelper.saveUserInfo(asgUserModel);
            }
            CacheHelper.saveIdUser(id: asgUserModel.id.toString());
            loginChatNoContext(account, pass);
          }
        },
        onErrorApiCallback: (onError) {
          loadingStream.notify(false);
          Toast.showShort(onError.toString());
          requestLogin();
        });
  }

  void authenticateFingerPrintIOS(BuildContext context) async {
    bool isAllowCreateNewDOmain = await CacheHelper.getStatusFingerPrint();
    PlatformHelper.authenticateWithFingerPrint(isAllowCreateNewDOmain);
    MethodChannel methodChannel =
        MethodChannel("com.asgl.human_resource.fingerprint_channel");
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == "com.asgl.human_resource.auth_result") {
        if (call.arguments is int) {
          int state = call.arguments as int;
          print("IOS state fringerprint: $state");
          switch (state) {
            case -5:
              //userCancel
              break;
            case -4:
              // systemCancel touch id
              break;
            case -3:
              //touchIDNotAvailable
              DialogUtils.showDialogAuthenticateFinger(context,
                  title: "Thất bại",
                  message:
                      "Vui lòng bật xác thực vân tay hoặc xác thực khuôn mặt trên thiết bị để có thể sử dụng tính năng này.",
                  styleTitle: TextStyle(
                    color: Color(0xffee8800),
                    fontFamily: 'Roboto-Bold',
                    fontSize: 50.sp,
                  ),
                  haveButton: false,
                  fingerPrintDisable: false);
              break;
            case -2:
              //Nếu người dùng chưa cài đặt vân tay cho ứng dụng
              DialogUtils.showDialogAuthenticateFinger(context,
                  title: "Thất bại",
                  message:
                      "Vui lòng cài đặt vân tay cho thiết bị để sử dụng tính năng này.",
                  styleTitle: TextStyle(
                    color: Color(0xffee8800),
                    fontFamily: 'Roboto-Bold',
                    fontSize: 50.sp,
                  ),
                  haveButton: false,
                  fingerPrintDisable: false);
              break;
            case -1:
              //Có lỗi ngoài ý muốn
              DialogUtils.showDialogAuthenticateFinger(context,
                  title: "Thất bại",
                  message:
                      "Vui lòng cài đặt khóa màn hình cho thiết bị để sử dụng tính năng này.",
                  styleTitle: TextStyle(
                    color: Color(0xffee8800),
                    fontFamily: 'Roboto-Bold',
                    fontSize: 50.sp,
                  ),
                  haveButton: false,
                  fingerPrintDisable: false);
              break;
            case 0:
              //Xác thực thất bại do sai vân tay
              //authenticationFailed
              DialogUtils.showDialogAuthenticateFinger(context,
                  title: "Thất bại",
                  message: "Xác thực thất bại vui lòng thử lại.",
                  styleTitle: TextStyle(
                    color: Color(0xffee8800),
                    fontFamily: 'Roboto-Bold',
                    fontSize: 50.sp,
                  ),
                  haveButton: false,
                  fingerPrintDisable: false);
              break;
            case 1:
              //Xác thực thành công
              Toast.showShort("Xác thực thành công.");
              AppBloc appBloc = BlocProvider.of(context);
              appBloc.authBloc.checkAuth(appBloc, checkFromFingerPrint: true);
              break;
            case 2:
              //TouchIdLockout
              DialogUtils.showDialogAuthenticateFinger(context,
                  title: "Thất bại",
                  message:
                      "Xác thực thất bại quá 5 lần. Vui lòng sử dụng tài khoản và mật khẩu để đăng nhập.",
                  styleTitle: TextStyle(
                    color: Color(0xffee8800),
                    fontFamily: 'Roboto-Bold',
                    fontSize: 50.sp,
                  ),
                  haveButton: false,
                  fingerPrintDisable: false);
              break;
            case 4:
              //touchIDNotAvailable
              DialogUtils.showDialogAuthenticateFinger(context,
                  title: "Thất bại",
                  message:
                      "Dữ liệu vân tay được cập nhật. Vui lòng đăng nhập lại với Tài khoản và Mật khẩu.",
                  styleTitle: TextStyle(
                    color: Color(0xffee8800),
                    fontFamily: 'Roboto-Bold',
                    fontSize: 50.sp,
                  ),
                  haveButton: false,
                  fingerPrintDisable: false);
              break;
          }
        }
      }
    });
  }

  //Ham kiem tra trong cache da co username va password hay chua
  Future<void> checkUserNamePassWord({BuildContext context}) async {
    String userName;
    String password;
    try {
      userName = await CacheHelper.getUserName();
      password = await CacheHelper.getPassword();
    } catch (error) {
      userName = null;
      password = null;
    }
    if (userName != null &&
        password != null &&
        userName != '' &&
        password != '') {
      fingerPrintStatusState = FingerPrintButtonState.ENABLE;
      enableAndDisableButton.notify(fingerPrintStatusState);
    } else {
      fingerPrintStatusState = FingerPrintButtonState.HIDE;
      enableAndDisableButton.notify(fingerPrintStatusState);
    }
  }

  String newJwt = "";
  String newPassword = "";
  String newUserName = "";

  void setData(dynamic arguments) async {
    newJwt = arguments['jwt'];
    newPassword = arguments['password'];
    newUserName = arguments['userName'];
  }

  void logOutAndReLogin(BuildContext context) async {
    WebSocketHelper.getInstance().isAutoLogin = false;
    if (WebSocketHelper.getInstance().wsAccountModel != null) {
      WebSocketHelper.getInstance().isAutoLogin = false;
      AppBloc appBloc = BlocProvider.of(context);
      appBloc.homeBloc.loadingStream.notify(true);
      ApiServices apiServices = ApiServices();
      await apiServices.logOutChat(resultData: (onResult) async {
        await CacheHelper.saveStatusFingerPrint(status: false);
        await HiveHelper.removeCacheWhenLogOut();
        FCMServices services = FCMServices();
        DefaultCacheManager manager = new DefaultCacheManager();
        try {
          manager.emptyCache();
        } catch (ex) {} // data in cache.
        await services.removeToken();
        await CacheHelper.removeCachedWhenLogOut();
        WebSocketHelper.getInstance().clearCacheWhenLogOut();

        appBloc.homeBloc.bottomBarCurrentIndex = 0;
        appBloc.homeBloc.indexStackHome = 0;
        appBloc.homeBloc.clickItemBottomBar(0);
        appBloc.mainChatBloc.clearCache();
        appBloc.homeBloc.loadingStream.notify(false);
        await CacheHelper.saveAccessToken(newJwt);
        await CacheHelper.saveUserName(userName: newUserName);
        await CacheHelper.savePassword(password: newPassword);
        authStream.notify(AuthenticationModel(AuthState.SPLASH, false, null));
        loginWith(context, newUserName, newPassword);
        removeNewDataFromOtherApp();
      }, onErrorApiCallback: (onError) {
        appBloc.homeBloc.loadingStream.notify(false);
        DialogUtils.showDialogResult(
            context, DialogType.FAILED, onError.toString());
      });
    } else {
      await CacheHelper.saveAccessToken(newJwt);
      await CacheHelper.saveUserName(userName: newUserName);
      await CacheHelper.savePassword(password: newPassword);
      authStream.notify(AuthenticationModel(AuthState.SPLASH, false, null));
      loginWith(context, newUserName, newPassword);
      removeNewDataFromOtherApp();
    }
  }

  void removeNewDataFromOtherApp() {
    newJwt = "";
    newPassword = "";
    newUserName = "";
  }
}

enum RegisterOldValidateState { NONE, ERROR, MATCHED }

enum ForgotPassState { NONE, ERROR, SUCESS, LOADING }

class ForgotPassModel {
  ForgotPassState state;
  dynamic data;

  ForgotPassModel(this.state, this.data);
}

enum FingerPrintStatusState {
  //Người dùng cập nhật vân tay mới hoặc xóa 1 vân tay
  UPADATE,
  //Lỗi tạo key xác thực
  KEYVERYFY,
  //Nếu người dùng chưa cài đặt vân tay cho ứng dụng
  HAVENFINGERPRINT,
  //Nếu người dùng chưa cài đặt khóa màn hình thì hiển thị thông báo ở đây
  HAVENLOCKSCREEN,
  //Authenticate thất bại do sai vân tay
  ERRORFINGERPRINT,
  //THÀNH CÔNG
  SUCCERFINGERPRINT,
  //Xác thực thất bại quá nhiều lần hoặc thao tác dùng vân tay bị hủy
  MULTIVERYFIFINGERPRINT,
  //None
  NONE
}

class FingerPrintStatusModel {
  FingerPrintStatusState state;
  String title;
  String message;
  bool haveButton;
  TextStyle styleTitle;
  bool fingerPrintDisable;

  FingerPrintStatusModel(this.state, this.title, this.message, this.haveButton,
      this.styleTitle, this.fingerPrintDisable);
}
