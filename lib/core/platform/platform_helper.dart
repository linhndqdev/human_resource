import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:human_resource/utils/widget/dialog_utils.dart';

class PlatformHelper {
  //Key share data Flutter -> Native và S-Conenct -> Other App
  static const String _keyPackageName = "pkName";
  static const String _keyUserName = "userName";
  static const String _keyPassWord = "password";
  static const String _keyJWT = "jwt";

  //Key call phone with number
  static const String _keyPhoneNumber = "phoneNumber";

  //Create key
  static const String _obligatoryCreateKey = "obligatoryCreateKey";
  static const String _resetNewDomain = "resetNewDomain";

  //============================================//
  ///S-Connect channel
  static MethodChannel _methodChannel =
      MethodChannel("com.asgl.human_resource");

  ///S-Connect check app installed method name
  static String _checkAppInstalledMethodName =
      "com.asgl.human_resource.checkAppInstalled";

  //S-Connect open app method name
  static String _openOtherApp = "com.asgl.human_resource.openOtherApp";

  //S-Connect call phone
  static String _createCallPhoneMethod =
      "com.asgl.human_resource.createCallPhone";

  //S-Connect authenticate with fingerprint
  static String _authenticateFingerprint =
      "com.asgl.human_resource.fingerprints";
//S-Connect authenticate with fingerprint
  static String _resetNewDomainkey =
      "com.asgl.human_resource.login_success";

  static String _getDataOpenAppMethod =
      "com.asgl.human_resource.getDataOpenApp";
  //============================================//

  ///Kiểm tra xem ứng dụng đã được cài đặt hay chưa.
  ///[packageName] Tên gói ứng dụng cần kiểm tra
  static Future<bool> checkAppInstalled({@required String packageName}) async {
    bool result = await _methodChannel
        .invokeMethod(_checkAppInstalledMethodName, {"pkName": "$packageName"});
    return result;
  }

  ///[packageName] : Tên gói ứng dụng sẽ được mở
  ///[jwt] : Json Web Token sẽ được truyền từ S-Connect sang ứng dụng khác
  ///[userName] : Tài khoản đăng nhập từ S-Connect
  ///[password] : Mật khẩu đăng nhập trên S-Connect
  static void openAppWithPackageName(
      {@required String packageName,
      @required String jwt,
      @required String userName,
      @required String password}) async {
    await _methodChannel.invokeMethod(_openOtherApp, {
      _keyPackageName: "$packageName",
      _keyJWT: jwt,
      _keyUserName: userName,
      _keyPassWord: password
    });
  }

  /// Chỉ sử dụng cho IOS
  /// [urlScheme] Kiểu url định nghĩa cho ứng dụng
  /// [jwt] JWT of S-Connect
  /// [userName] Tài khoản S-Connect
  /// [password] Mật khẩu S-Connect
  static void openIOSAppWithData(
      {@required String urlScheme,
      @required String jwt,
      @required String userName,
      @required String password}) async {
    dynamic data = await _methodChannel.invokeMethod(_openOtherApp, {
      _keyPackageName: "$urlScheme",
      _keyJWT: jwt,
      _keyUserName: userName,
      _keyPassWord: password
    });
    if (data is int) {
      Toast.showShort("Ứng dụng chưa được cài đặt");
    }
  }

  ///Tạo cuộc gọi
  ///Sử dụng cho cả Android - IOS
  /// [context] This's context
  /// [userName] Số điện thoại của người cần gọi
  static void createCallPhoneWith(
      {@required BuildContext context, @required String userName}) async {
    List<String> splitUserNames = userName.split("-");
    if (splitUserNames.length >= 2) {
      String asglId = splitUserNames[1];
      try {
        int id = int.parse(asglId);
        dynamic result = await _methodChannel?.invokeMethod(
            _createCallPhoneMethod, {_keyPhoneNumber: "1599+$id"});
        if (result is int) {
          DialogUtils.showDialogResult(context, DialogType.FAILED,
              "Vui lòng cho phép quyền khởi tạo cuộc gọi để tạo cuộc gọi đến người dùng khác.");
        }
      } catch (ex) {
        DialogUtils.showDialogResult(context, DialogType.FAILED,
            "Không tìm thấy thông tin liên hệ của thành viên này.");
      }
    } else {
      DialogUtils.showDialogResult(context, DialogType.FAILED,
          "Không tìm thấy thông tin liên hệ của thành viên này.");
    }
  }

  ///  Tạo yêu cầu xác thực vân tay
  ///  Nếu được gọi lần đầu thì [obligatoryCreateKey] chắc chắn = false
  ///  Nếu được gọi lại thêm 1 lần nữa khi gặp lỗi -4 thì
  ///  [obligatoryCreateKey] = true để buộc application tạo 1 key mới
  ///  Để có thể xác thực theo key mới
  static Future<dynamic> authenticateWithFingerPrint(
      bool obligatoryCreateKey) async {
    _methodChannel?.invokeMethod(
        _authenticateFingerprint, {_obligatoryCreateKey: obligatoryCreateKey});
  }

  static void resetNewDomain()async{
    if(Platform.isIOS) {
      _methodChannel?.invokeMethod(
          _resetNewDomainkey, {_resetNewDomain: _resetNewDomain});
    }
  }
  ///Check and get data when app is open
  ///If [_data] = "" => Không được mở từ bất kỳ ứng dụng nào khác
  ///Nếu [_data] != null && data !="" => Kiểm tra data nhận được và loading theo dữ liệu mới nhất
  static Future<dynamic> getDataOpenApp() async {
    dynamic _data = await _methodChannel.invokeMethod(_getDataOpenAppMethod);
    return _data;
  }
}
