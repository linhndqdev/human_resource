import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/home/notifications/notification_services.dart';
import 'package:human_resource/model/socket_notification.dart';

enum ListDataState { NONE, LOADING, SHOW }

class ListDataStreamModel {
  ListDataState state;
  List<SKNotification> data;

  ListDataStreamModel(this.state, this.data);
}

class NotificationBloc {
  List<SKNotification> listNotification = [];
  int sumUnReadNotification = 0;
  CoreStream<ListDataStreamModel> updateListNotificationsStream = CoreStream();
  CoreStream<int> sumNotificationStream = CoreStream();
  _Pagination _pagination = _Pagination.init();
  CoreStream<bool> loadMoreStream = CoreStream();
  bool isLoading = false;

  void _showLoadMore() => loadMoreStream?.notify(true);

  void _hideLoadMore() => loadMoreStream?.notify(false);

  void updateListNotification(SKNotification skNotification) {
    if (listNotification.length == 0) {
      listNotification?.add(skNotification);
    } else {
      listNotification?.insert(0, skNotification);
    }
    _showData();
    updateUnRead(true);
  }

  ///Xóa toàn bộ cache notification khi logOut
  void clearCache() {
    sumUnReadNotification = 0;
    listNotification = [];
    _showListNoData();
    updateUnRead(true);
    isLoading = false;
  }

  ///Lấy về số lượng notification chưa đọc
  void getUnReadNotification() async {
    NotificationServices services = NotificationServices();
    await services.countUnReadNotification((result) {
      sumUnReadNotification = result ??= 0;
      _notifyCountUnReadMessage();
    }, (error) {
      sumUnReadNotification = 0;
      _notifyCountUnReadMessage();
    });
  }

  ///Gửi stream cập nhật số thông báo chưa đọc lên widget
  void _notifyCountUnReadMessage() =>
      sumNotificationStream?.notify(sumUnReadNotification);

  ///Cập nhật số thông báo chưa đọc
  ///Nếu [isUpGrade] => [sumUnReadNotification] += 1
  ///Nếu ![isUpGrade] => [sumUnReadNotification] -=1
  void updateUnRead(bool isUpGrade) {
    sumUnReadNotification += isUpGrade ? 1 : -1;
    _notifyCountUnReadMessage();
  }

  ///Lấy danh sách notification có phân trang
  ///Nếu [isLoadMore] sẽ load dư liệu trang tiếp theo
  ///Nếu ![isLoadMore] sẽ lấy dữ liệu trang đầu tiên
  Future<void> getAllNotification({bool isLoadMore = false}) async {
    NotificationServices notificationServices = NotificationServices();
    int currentPage = 1;
    if (isLoadMore) {
      isLoading = true;
      if (_pagination.isLoadMore) {
        _showLoadMore();
        currentPage = _pagination.current_page + 1;
      } else {
        isLoading = false;
        _hideLoadMore();
        return;
      }
    }
    await notificationServices.getAllNotification(currentPage, (result) {
      if (result.containsKey('meta')) {
        _getMetaData(result['meta']);
      }
      if (result.containsKey('notifications')) {
        Iterable i = result['notifications'];
        if (i != null && i.length > 0) {
          List<SKNotification> listData =
              i.map((data) => SKNotification.fromAPI(data)).toList();
          if (listData != null && listData.length > 0) {
            if (isLoadMore) {
              listNotification?.addAll(listData);
            } else {
              listNotification?.clear();
              listNotification?.addAll(listData);
            }
          }
          listNotification.length > 0 ? _showData() : _showListNoData();
        } else {
          if (isLoadMore) {
            listNotification.length > 0 ? _showData() : _showListNoData();
          } else {
            _showListNoData();
          }
        }
      } else {
        if (isLoadMore) {
          listNotification.length > 0 ? _showData() : _showListNoData();
        } else {
          _showListNoData();
        }
      }
    }, (onError) {
      if (isLoadMore) {
        if (isLoadMore) {
          listNotification.length > 0 ? _showData() : _showListNoData();
        } else {
          _showListNoData();
        }
      } else {
        _showListNoData();
      }
    });
    isLoading = false;
  }

  _showData() {
    ListDataStreamModel model =
        ListDataStreamModel(ListDataState.SHOW, listNotification);
    updateListNotificationsStream?.notify(model);
  }

  _showListNoData() {
    ListDataStreamModel model = ListDataStreamModel(ListDataState.NONE, []);
    updateListNotificationsStream?.notify(model);
  }

  void loadMoreNotification() {
    if (!isLoading) {
      getAllNotification(isLoadMore: true);
    }
  }

  void _getMetaData(result) {
    Map<String, dynamic> metaData = result;
    if (metaData.containsKey('pagination') && result['pagination'] != null) {
      _pagination = _Pagination.fromJson(metaData['pagination']);
    }
  }

  Future<void> refreshData() async {
    _pagination = _Pagination.init();
    isLoading = true;
    await getAllNotification();
  }

  void updateListNotificationElement(SKNotification notification) {
    int index =
        listNotification?.indexWhere((noti) => notification.id == noti.id);
    if (index != -1) {
      listNotification[index].read_at.date = DateTime.now().toIso8601String();
    }
    _showData();
  }
}

class _Pagination {
  int total = 0;
  int count = 0;
  int per_page = 0;
  int current_page = 0;
  int total_pages = 0;

  _Pagination.init();

  _Pagination(this.total, this.count, this.per_page, this.current_page,
      this.total_pages);

  bool get isLoadMore => current_page < total_pages;

  factory _Pagination.fromJson(Map<String, dynamic> json) {
    return _Pagination(
        json['total'] ??= 0,
        json['count'] ??= 0,
        json['per_page'] ??= 0,
        json['current_page'] ??= 0,
        json['total_pages'] ??= 0);
  }
}
