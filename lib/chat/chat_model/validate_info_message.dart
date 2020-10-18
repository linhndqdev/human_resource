import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/websocket/ws_helper.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/core/app_bloc.dart';
import 'package:human_resource/utils/common/const.dart';
import 'package:intl/intl.dart';

class ValidateInfoMessage {
  WsRoomModel _roomModel;
  int _positionOfItem;
  WsMessage message;

  ValidateInfoMessage setRoomModel(WsRoomModel roomModel) {
    this._roomModel = roomModel;
    return this;
  }

  ValidateInfoMessage setMessage(WsMessage message) {
    this.message = message;
    return this;
  }

  ValidateInfoMessage setPositionOfItem(int positionOfItem) {
    this._positionOfItem = positionOfItem;
    return this;
  }

  bool checkShowTime(List<WsMessage> listMessageSnap,) {
    if (_roomModel.name.contains(Const.THONG_BAO) ||
        _roomModel.name.contains(Const.BAN_TIN)) {
      return true;
    } else {
      if (listMessageSnap[_positionOfItem].t == "uj") {
        return false;
      } else if (listMessageSnap.length == 1 || _positionOfItem == 0) {
        return true;
      } else {
        if (_positionOfItem == listMessageSnap.length - 1)
          return false;
        else {
          if (listMessageSnap[_positionOfItem - 1]?.skAccountModel?.id !=
              listMessageSnap[_positionOfItem]?.skAccountModel?.id) {
            return true;
          } else {
            return false;
          }
        }
      }
    }
  }

  bool checkMessageOwner(List<WsMessage> listMessage) {
    return listMessage[_positionOfItem].skAccountModel?.id ==
        WebSocketHelper
            .getInstance()
            .wsAccountModel
            ?.id;
  }

  String getNameShow(AppBloc appBloc, List<WsMessage> listMessage) {
    String userName;
    if (_roomModel.name == Const.BAN_TIN ||
        _roomModel.name == Const.FAQ ||
        _roomModel.name.contains(Const.THONG_BAO) ||
        _roomModel.roomType == RoomType.d) {
      return userName;
    } else {
      if (listMessage.length == 1 ||
          _positionOfItem == listMessage.length - 1) {
        return _getFullName(appBloc, listMessage);
      } else {
        if (listMessage[_positionOfItem]?.skAccountModel?.id ==
            listMessage[_positionOfItem + 1]?.skAccountModel?.id) {
          return userName;
        } else {
          return _getFullName(appBloc, listMessage);
        }
      }
    }
  }

  String _getFullName(AppBloc appBloc, List<WsMessage> listMessage) {
    WsMessage message = listMessage[_positionOfItem];
    String userName;
    Iterable i = appBloc.mainChatBloc.listUserOnChatSystem
        ?.where((user) => user.id == message.skAccountModel?.id);
    if (i != null && i.length > 0) {
      userName = (i.elementAt(0) as AddressBookModel).name;
    }
    return userName;
  }

  bool checkShowDateTime(List<WsMessage> listMessage) {
    if (_roomModel.name.contains(Const.THONG_BAO) ||
        _roomModel.name.contains(Const.BAN_TIN)) {
      DateFormat format = DateFormat("dd/MM/yyyy");
      String date = format.format(
          DateTime.fromMillisecondsSinceEpoch(listMessage[_positionOfItem].ts));
      if (_positionOfItem > 0) {
        String dateOld = format.format(DateTime.fromMillisecondsSinceEpoch(
            listMessage[_positionOfItem - 1].ts)) ==
            null
            ? ""
            : format.format(DateTime.fromMillisecondsSinceEpoch(
            listMessage[_positionOfItem - 1].ts));
        if (date.contains(dateOld) && dateOld != "") {
          return false;
        } else {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  bool get isRevokeMessage =>
      this.message?.messageActionsModel?.actionType != null &&
          this.message?.messageActionsModel?.actionType == ActionType.DELETE;

  bool get isFile => this.message?.file != null;
}
