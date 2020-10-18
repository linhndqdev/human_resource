enum HomeState {
  ACCOUNT,
  SCHEDULE,
  INVOICE,
  SCHEDULEDETAIL,
  DETAILSRESGISTERSCHOOL,
  STUDENT_REGISTERED,
  INVOICESUCCESS,
  INVOICE_DETAIL,
  IVOICECUSTOM,
  MANAGERACOUNTFAMILY,
  PAYMENT_SERVICES,
  PAYMENT_SERVICES_SUCCESS,
  PAYMENT_SERVICES_ERROR,
  PAYMENT_SERVICES_DETAILS,
  PAYMENT_SERVICES_DETAILS_SUCCESS,
  PAYMENT_HISTORY,
  CHAT,
}

class HomeModel {
  dynamic data;
  int bottomBarIndex;
  HomeState homeState;
  bool isShowBottomBar;

  HomeModel(this.data, this.homeState,
      {this.bottomBarIndex, this.isShowBottomBar});
}

enum HomeChildState {
  INIT,
  ADDRESS_BOOK,
  MY_PROFILE,
  ADDRESS_BOOK_SEARCH
}

class HomeChildModel {
  HomeChildState state;
  dynamic data;
  dynamic roomId;

  HomeChildModel(this.state, this.data,this.roomId);
}
