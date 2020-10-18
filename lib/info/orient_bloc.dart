import 'package:flutter/material.dart';
import 'package:human_resource/core/api_services.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/core/core_stream.dart';
import 'package:human_resource/info/meta_notification_model.dart';
import 'package:human_resource/model/notification_model.dart';
import 'package:human_resource/utils/common/const.dart';
import 'dart:io';
import 'package:path/path.dart';
//enum OrientDetailState { MASTER, DETAIL }

//class OrientLayoutDetailModel {
//  bool isShowDetail;
//  dynamic data;
//
//  OrientLayoutDetailModel({this.isShowDetail, this.data});
//}

enum OrientState { BAN_TIN, FAQ, THONG_BAO, NONE, LOADING }

class OrientLayoutModel {
  OrientState state;
  dynamic data;

  OrientLayoutModel({this.state, this.data});
}

class OrientBloc {
  CoreStream<OrientLayoutModel> layoutStream = CoreStream();
  CoreStream<LoadMoreTextModel> loadMoreTextStream = CoreStream();

  //CoreStream<OrientLayoutDetailModel> layoutDetailStream = CoreStream();
  CoreStream<bool> loaddingStream = CoreStream();
  List<NotificationModel> listNewsModel;
  List<NotificationModel> listNotificationModel;
  bool isContentLoadMore = true;
  int currentNews = 0;
  int currentNotification = 0;


  //giá trị xác định khi nào đã request hết danh sách notification và news
  bool haveRequestNews = true;
  bool haveRequestNotification = true;
  CoreStream<LoadDataNotificationModel> loadDataNotificationModelStream =
      CoreStream<LoadDataNotificationModel>();

  Future<void> reloadData(BuildContext context, String typeId) async {
    resetData();
    getInformationNewsAndNotification(
        typeId: typeId, context: context, page: "1");
  }

  void showLoading() => loaddingStream?.notify(true);

  void hideLoading() => loaddingStream?.notify(false);

  void resetData() {
    haveRequestNews = true;
    haveRequestNotification = true;
    currentNews = 0;
    currentNotification = 0;
  }

  void checkLoadingLoadMore({String typeId, BuildContext context, String page}){
      showLoading();
      getInformationNewsAndNotification(typeId: typeId,context: context,page: page);
  }

  void getInformationNewsAndNotification(
      {String typeId, BuildContext context, String page}) async {
    ApiServices apiServices = ApiServices();
    AppBloc appBloc = BlocProvider.of(context);
    await apiServices.getNewAndNotificationData(
        onResultData: (result) {
          hideLoading();
          if (result.containsKey('announcements')) {
            Iterable i = result['announcements'];
            if (i != null && i.length > 0) {
              if (typeId.contains("2")) {
                if (page.contains("1")) {
                  listNewsModel = i
                      .map((data) => NotificationModel.fromJson(data))
                      .toList();
                } else {
                  if (haveRequestNews) {
                    List<NotificationModel> list = i
                        .map((data) => NotificationModel.fromJson(data))
                        .toList();
                    listNewsModel.addAll(list);
                  }
                }
                if (haveRequestNews) {
                  appBloc.orientBloc.loadDataNotificationModelStream
                      .notify(LoadDataNotificationModel(
                    loadDataNotificationAndNewsState:
                        LoadDataNotificationAndNewsState.HAVEDATA,
                    data: listNewsModel,
                  ));
                }
              } else {
                if (page.contains("1")) {
                  listNotificationModel = i
                      .map((data) => NotificationModel.fromJson(data))
                      .toList();
                } else {
                  if (haveRequestNews) {
                    if (haveRequestNotification) {
                      List<NotificationModel> list = i
                          .map((data) => NotificationModel.fromJson(data))
                          .toList();
                      listNewsModel.addAll(list);
                    }
                  }
                }
                if (haveRequestNotification) {
                  appBloc.orientBloc.loadDataNotificationModelStream
                      .notify(LoadDataNotificationModel(
                    loadDataNotificationAndNewsState:
                        LoadDataNotificationAndNewsState.HAVEDATA,
                    data: listNotificationModel,
                  ));
                }
              }
            }
          } else {
            loadDataNotificationModelStream.notify(LoadDataNotificationModel(
              loadDataNotificationAndNewsState:
                  LoadDataNotificationAndNewsState.NODATA,
              data: null,
            ));
          }

          if (result.containsKey('meta')) {
            if (result['meta']['pagination'] != null) {
              Map<String, dynamic> y = result['meta']['pagination'];
              if (y != null) {
                MetaNotificationModel metaNotificationModel =
                    MetaNotificationModel.fromJson(y);
                if (metaNotificationModel.links != null &&
                    metaNotificationModel.links.next != null &&
                    metaNotificationModel.links.next != "" &&
                    metaNotificationModel.current_page != null) {
                  if (typeId.contains("2")) {
                    if (currentNews != metaNotificationModel.current_page) {
                      currentNews = metaNotificationModel.current_page;
                    }
                  } else {
                    if (currentNotification !=
                        metaNotificationModel.current_page) {
                      currentNotification = metaNotificationModel.current_page;
                    }
                  }
                } else {
                  if (typeId.contains("2")) {
                    haveRequestNews = false;
                  } else {
                    haveRequestNotification = false;
                  }
                }
              }
            }
          }
        },
        onErrorApiCallback: (error) {
          print(error);
          hideLoading();

        },
        typeId: typeId,
        pagination: "true",
        page: page);
  }

  void dispose() {
    layoutStream?.closeStream();
    //layoutDetailStream?.closeStream();
  }

  LoadMoreTextState checkLongContent(String msg) {
    if (msg.length < 200) {
      return LoadMoreTextState.NONE;
    } else {
      return LoadMoreTextState.HAVEDATA;
    }
  }

  String covertTextSoLong(String msg) {
    if (msg.length > 200) {
      String message;
      message = msg.substring(0, 199).trim() + " ...";
      return message;
    } else {
      return msg;
    }
  }

  void changeStateLoadmoreContentStream(
      NotificationModel newAndNotificationModel,
      LoadMoreTextState loadMoreTextState) {
    isContentLoadMore = !isContentLoadMore;
    loadMoreTextStream
        .notify(LoadMoreTextModel(newAndNotificationModel, loadMoreTextState));
  }

  TypeFile checkTypeFile(String url) {

    String subString = extension(url);
    if (Const.imageFileExtensions.contains(subString)) {
      return TypeFile.IMAGE;
    } else if (subString.contains(".pdf")) {
      return TypeFile.PDF;
    } else {
      return TypeFile.OTHER;
    }
  }

  String getNameFileInURL(String url) {
    File file = new File(url);
    print(basename(file.path));
    return basename(file.path);
  }
}

enum LoadMoreTextState { HAVEDATA, NODATA, NONE }

class LoadMoreTextModel {
  NotificationModel newAndNotificationModel;
  LoadMoreTextState loadMoreTextState;

  LoadMoreTextModel(this.newAndNotificationModel, this.loadMoreTextState);
}

enum TypeFile { PDF, IMAGE, OTHER }

enum LoadDataNotificationAndNewsState { LOADDING, NODATA, HAVEDATA }

class LoadDataNotificationModel {
  LoadDataNotificationAndNewsState loadDataNotificationAndNewsState;
  dynamic data;

  LoadDataNotificationModel({this.loadDataNotificationAndNewsState, this.data});
}
