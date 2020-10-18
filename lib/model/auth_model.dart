enum AuthState {
  REQUEST_LOGIN,
  LOGIN_SUCCESS,
  LOGIN_FAILED,
  SPLASH,
  FORGOTPASS,
  CONFIRMFORGOTPASS,
}

class AuthenticationModel {
  AuthState state;
  bool isAuth; //Login hay chưa login
  dynamic data;

  AuthenticationModel(this.state, this.isAuth, this.data);
}
