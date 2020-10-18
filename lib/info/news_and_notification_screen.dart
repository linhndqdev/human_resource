import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:human_resource/chat/screen/main_chat/chat/chat_bloc.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/core/bloc_provider.dart';
import 'package:human_resource/utils/widget/image_item_news_and_notification.dart';
import 'package:human_resource/utils/widget/other_file_item_news_and_notification.dart';
import 'package:human_resource/utils/widget/pdf_item_news_and_notification.dart';
import 'package:human_resource/model/notification_model.dart';
import 'package:human_resource/utils/common/download_provider.dart';
import 'package:human_resource/utils/common/toast.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:human_resource/core/style.dart' as prefix0;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/widget/message_item_news_and_notification.dart';
import 'orient_bloc.dart';

class NewAndNotificationScreen extends StatefulWidget {
  final List<NotificationModel> list;
  final String typeId;

  const NewAndNotificationScreen({Key key, this.list, this.typeId})
      : super(key: key);

  @override
  _NewAndNotificationScreenState createState() =>
      _NewAndNotificationScreenState();
}

enum RoomAction { ADD_MEMBER, REMOVE_MEMBER }

class _NewAndNotificationScreenState extends State<NewAndNotificationScreen> {
  ScrollController _scrollController = ScrollController();
  AppBloc appBloc;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    appBloc = BlocProvider.of(context);
    return Stack(
      children: <Widget>[
        _buildLayoutChat(),
      ],
    );
  }

  Widget _buildLayoutChat() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height,
                //Lấy danh sach tin nhắn trong nhóm
                child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        if (isLoading) {
                          isLoading = false;
                          if (widget.typeId.toString().contains("2")) {
                            appBloc.orientBloc.checkLoadingLoadMore(
                                typeId: widget.typeId,
                                context: context,
                                page: (appBloc.orientBloc.currentNews + 1)
                                    .toString());
                          } else {
                            appBloc.orientBloc.checkLoadingLoadMore(
                                typeId: widget.typeId,
                                context: context,
                                page:
                                    (appBloc.orientBloc.currentNotification + 1)
                                        .toString());
                          }
                        }
                      }

                      return false;
                    },
                    child: LiquidPullToRefresh(
                      color: prefix0.accentColor,
                      showChildOpacityTransition: false,
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 64.5.h),
                        cacheExtent: MediaQuery.of(context).size.height,
                        controller: _scrollController,
                        addAutomaticKeepAlives: true,
                        itemCount: widget.list.length,
                        itemBuilder: (buildContext, index) {
                          NotificationModel newAndNotificationModel =
                              widget.list[index];
                          if (newAndNotificationModel.files == null ||
                              newAndNotificationModel.files.length == 0) {
                            return InkWell(
                              onTap: () {
                                appBloc.mainChatBloc.chatBloc.layoutDetailStream
                                    .notify(OrientLayoutDetailModel(
                                        isShowDetail: true,
                                        data: newAndNotificationModel));
                                // print(widget.message.id);
                              },
                              child: MessageItemNewsAndNotification(
                                newAndNotificationModel:
                                    newAndNotificationModel,
                              ),
                            );
                          } else {
                            switch (appBloc.orientBloc.checkTypeFile(
                                newAndNotificationModel.files[0].src)) {
                              case TypeFile.IMAGE:
                                return InkWell(
                                    onTap: () {
                                      appBloc.mainChatBloc.chatBloc
                                          .showOtherLayoutStream
                                          ?.notify(OtherLayoutModelStream(
                                              OtherLayoutState.IMAGE_SHOW,
                                              newAndNotificationModel
                                                  .files[0].src));
                                    },
                                    child: ImageItemNewsAndNotification(
                                      newAndNotificationModel:
                                          newAndNotificationModel,
                                    ));
                                break;
                              case TypeFile.PDF:
                                return InkWell(
                                  onTap: () async {
                                    if (await canLaunch(
                                        newAndNotificationModel.files[0].src)) {
                                      await launch(
                                          newAndNotificationModel.files[0].src);
                                    } else {
                                      Toast.showShort("Không thể mở đường dẫn");
                                    }
                                  },
                                  child: PDFItemNewsAndNotification(
                                      newAndNotificationModel:
                                          newAndNotificationModel),
                                );
                                break;
                              default:
                                return InkWell(
                                  onTap: () {
                                    _onDownloadFile(
                                        newAndNotificationModel.files[0].src,
                                        appBloc.orientBloc.getNameFileInURL(
                                            newAndNotificationModel
                                                .files[0].src));
                                  },
                                  child: OtherFileItemNewsAndNotification(
                                    newAndNotificationModel:
                                        newAndNotificationModel,
                                  ),
                                );
                                break;
                            }
                          }
                        },
                      ),
                      onRefresh: _refreshData,
                    )),
              ),
            ),
            StreamBuilder(
              initialData: false,
              stream: appBloc.orientBloc.loaddingStream.stream,
              builder: (buildContext, snapshot) {
                if (snapshot.data) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  bool isRefreshingData = false;

  Future<void> _refreshData() async {
    isLoading = true;
    isRefreshingData = true;
    await appBloc.orientBloc.reloadData(context, widget.typeId);
    isRefreshingData = false;
  }

  bool isDownloading = false;

  void _onDownloadFile(String url, String name) async {
    if (!isDownloading) {
      isDownloading = true;
      TaskInfo task = TaskInfo(url, name);
      Downloader downloader = await Downloader.init();
      downloader.requestDownload(task: task, fileName: name);
      isDownloading = false;
    }
  }
}
