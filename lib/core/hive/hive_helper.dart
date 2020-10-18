import 'dart:io';

import 'package:human_resource/chat/chat_model/message_action_model.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_attachment.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_file.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_message.dart';
import 'package:human_resource/model/asgl_user_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_room_model.dart';
import 'package:human_resource/chat/websocket/ws_model/ws_account_model.dart';
import 'package:path_provider/path_provider.dart';

import 'package:hive/hive.dart';

enum BoxName { CONTACTS, BOX_LIST_GROUP, BOX_LIST_MESSAGE, USER_INFO }
enum BoxKey {
  List_CONTACT,
  LIST_USER_CHAT_SYSTEM,
  LIST_ROOM_PRIVATE,
  LIST_ROOM_DIRECT
}

class HiveHelper {
  static Future<void> init() async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();

    Directory directory = await Directory(appDocDirectory.path + '/' + 'dir')
        .create(recursive: true);
    String path = directory.path;
    Hive.init(path);
    //Không được phép xóa bất kỳ 1 resigter nào ở đây
    Hive.registerAdapter(ASGLUserModelAdapter(), 0);
    Hive.registerAdapter(PositionsAdapter(), 1);
    Hive.registerAdapter(DepartmentsAdapter(), 2);
    Hive.registerAdapter(LevelAdapter(), 3);
    Hive.registerAdapter(WsRoomModelAdapter(), 4);
    Hive.registerAdapter(RoomTypeAdapter(), 5);
    Hive.registerAdapter(ReactionModelAdapter(), 6);
    Hive.registerAdapter(WsMessageAdapter(), 7);
    Hive.registerAdapter(WsFileAdapter(), 8);
    Hive.registerAdapter(WsAttachmentAdapter(), 9);
    Hive.registerAdapter(WsImageFileAdapter(), 10);
    Hive.registerAdapter(WsAudioFileAdapter(), 11);
    Hive.registerAdapter(ImageDimensionsAdapter(), 12);
    Hive.registerAdapter(WsAccountModelAdapter(), 13);
    Hive.registerAdapter(MessageActionsModelAdapter(), 14);
    Hive.registerAdapter(ActionTypeAdapter(), 15);
    Hive.registerAdapter(AddressBookModelAdapter(), 16);
    Hive.registerAdapter(MessageForwardModelAdapter(), 17);
    Hive.registerAdapter(MentionTypeAdapter(), 18);
    Hive.registerAdapter(MessageQuoteModelAdapter(), 19);
    Hive.registerAdapter(MentionModelAdapter(), 20);
    Hive.registerAdapter(UserMentionAdapter(), 21);
    Hive.registerAdapter(MessageDeleteModelAdapter(), 22);

    //====Open Box ========//
    await Hive.openBox(BoxName.CONTACTS.toString());
    await Hive.openBox(BoxName.BOX_LIST_GROUP.toString());
  }

  static void saveListContact(List<ASGUserModel> listASGUserModel,
      {bool isClearBeforeSave = true}) async {
    Box box = Hive.box(BoxName.CONTACTS.toString());
    if (box != null) {
      if (box.containsKey(BoxKey.List_CONTACT.toString()))
        box.delete(BoxKey.List_CONTACT.toString());
      if (listASGUserModel != null && listASGUserModel.length > 0) {
        await box.put(BoxKey.List_CONTACT.toString(), listASGUserModel);
      }
    }
  }

  static List<ASGUserModel> getListContact() {
    Box box = Hive.box(BoxName.CONTACTS.toString());
    Iterable data = box.get(BoxKey.List_CONTACT.toString());
    List<ASGUserModel> listData = List();
    if (data != null && data.length > 0) {
      listData = data.map((data) => data as ASGUserModel).toList();
    }
    return listData;
  }

  static ASGUserModel getOnlyUserFromListContact(String userName) {
    Box box = Hive.box(BoxName.CONTACTS.toString());
    Iterable data = box.get(BoxKey.List_CONTACT.toString());
    ASGUserModel userModel;
    List<ASGUserModel> listData = List();
    if (data != null && data.length > 0) {
      listData = data.map((data) => data as ASGUserModel).toList();
      if (listData != null && listData.length > 0) {
        userModel = listData.firstWhere((user) => user.username == userName,
            orElse: () => null);
        return userModel;
      }
      return null;
    }
    return userModel;
  }

  //Chỉ dùng cho private room
  static void saveAllPrivateRoom(List<WsRoomModel> listRoom) async {
    Box box = Hive.box(BoxName.BOX_LIST_GROUP.toString());
    if (box != null) {
      if (box.containsKey(BoxKey.LIST_ROOM_PRIVATE.toString())) {
        await box.delete(BoxKey.LIST_ROOM_PRIVATE.toString());
      }
      if (listRoom != null && listRoom.length > 0) {
        await box.put(BoxKey.LIST_ROOM_PRIVATE.toString(), listRoom);
      }
    }
  }

  //Chỉ dùng cho private room
  static List<WsRoomModel> getListPrivateRoom() {
    Box box = Hive.box(BoxName.BOX_LIST_GROUP.toString());
    Iterable data = box.get(BoxKey.LIST_ROOM_PRIVATE.toString());
    List<WsRoomModel> listData = List();
    if (data != null && data.length > 0) {
      listData = data.map((data) => data as WsRoomModel).toList();
    }
    return listData;
  }

  //Chỉ dùng cho private room
  static WsRoomModel getPrivateRoomInfoByRoomID(String roomID) {
    Box box = Hive.box(BoxName.BOX_LIST_GROUP.toString());
    Iterable data = box.get(BoxKey.LIST_ROOM_PRIVATE.toString());
    WsRoomModel roomModel;
    List<WsRoomModel> listData = List();
    if (data != null && data.length > 0) {
      listData = data.map((data) => data as WsRoomModel).toList();
      if (listData != null && listData.length > 0) {
        roomModel = listData?.firstWhere((room) => room.id == roomID,
            orElse: () => null);
      }
    }
    return roomModel;
  }

  //Chỉ dùng cho private room
  static void saveAllDirectRoom(List<WsRoomModel> listRoom) async {
    Box box = Hive.box(BoxName.BOX_LIST_GROUP.toString());
    if (box != null) {
      if (box.containsKey(BoxKey.LIST_ROOM_DIRECT.toString())) {
        await box.delete(BoxKey.LIST_ROOM_DIRECT.toString());
      }
      if (listRoom != null && listRoom.length > 0) {
        await box.put(BoxKey.LIST_ROOM_DIRECT.toString(), listRoom);
      }
    }
  }

  //Chỉ dùng cho roomDireact
  static List<WsRoomModel> getListDirectRoom() {
    Box box = Hive.box(BoxName.BOX_LIST_GROUP.toString());
    Iterable data = box.get(BoxKey.LIST_ROOM_DIRECT.toString());
    List<WsRoomModel> listData = List();
    if (data != null && data.length > 0) {
      listData = data.map((data) => data as WsRoomModel).toList();
    }
    return listData;
  }

  //Chỉ dùng cho private room
  static WsRoomModel getDirectRoomInfoByRoomID(String roomID) {
    Box box = Hive.box(BoxName.BOX_LIST_GROUP.toString());
    Iterable data = box.get(BoxKey.LIST_ROOM_DIRECT.toString());
    WsRoomModel roomModel;
    List<WsRoomModel> listData = List();
    if (data != null && data.length > 0) {
      listData = data.map((data) => data as WsRoomModel).toList();
      if (listData != null && listData.length > 0) {
        roomModel = listData?.firstWhere((room) => room.id == roomID,
            orElse: () => null);
      }
    }
    return roomModel;
  }

  static void saveAllUserChatSystem(
      List<AddressBookModel> listAddressBookModel) async {
    Box box = Hive.box(BoxName.CONTACTS.toString());
    if (box != null) {
      if (box.containsKey(BoxKey.LIST_USER_CHAT_SYSTEM.toString()))
        await box.delete(BoxKey.LIST_USER_CHAT_SYSTEM.toString());
      if (listAddressBookModel != null && listAddressBookModel.length > 0) {
        await box.put(
            BoxKey.LIST_USER_CHAT_SYSTEM.toString(), listAddressBookModel);
      }
    }
  }

  //Lấy toàn bộ danh sách user trong hệ thống chat nếu được cache
  static List<AddressBookModel> getAllUserChatSystem() {
    Box box = Hive.box(BoxName.CONTACTS.toString());
    List<AddressBookModel> listData = List();
    if (box != null) {
      if (box.containsKey(BoxKey.LIST_USER_CHAT_SYSTEM.toString())) {
        Iterable data = box.get(BoxKey.LIST_USER_CHAT_SYSTEM.toString());
        if (data != null && data.length > 0) {
          listData = data.map((data) => data as AddressBookModel).toList();
        }
      }
    }
    return listData;
  }

  //Lưu 50 tin nhắn mới nhất của room theo roomID
  static Future<void> saveListMessageWithRoomID(
      String roomID, List<WsMessage> listMessage) async {
    Box box = await Hive.openBox(roomID.toString());
    if (box != null) {
      await box.clear();
      await box.put(roomID, listMessage);
    }
    await box.close();
  }

  //Lấy danh sách tin nhắn được cache theo roomID
  static Future<List<WsMessage>> getListMessageByRoomID(String roomID) async {
    List<WsMessage> listMessage = List();
    if (roomID != null && roomID != "") {
      Box box = await Hive.openBox(roomID.toString());
      if (box != null) {
        Iterable data = box.get(roomID);
        if (data != null && data.length > 0) {
          listMessage = List<WsMessage>.from(data);
        }
      }
      await box.close();
    }

    return listMessage;
  }

  //Lưu 1 message mới nhất theo room id
  static Future<void> saveOnlyMessageWithRoomID(WsMessage message) async {
    if (!message.isSending) {
      Box box = await Hive.openBox(message.rid.toString());
      List<WsMessage> listMessage = List();
      if (box != null) {
        if (box.containsKey(message.rid)) {
          Iterable data = box.get(message.rid);
          if (data != null && data.length > 0) {
            listMessage = data.map((model) => model as WsMessage).toList();
            if (listMessage.length > 0 && listMessage.length <= 50) {
              listMessage.removeAt(listMessage.length - 1);
              listMessage.insert(0, message);
            } else if (listMessage.length == 0) {
              listMessage.add(message);
            } else if (listMessage.length > 0) {
              List<WsMessage> listDatas = listMessage.take(49).toList();
              listMessage.clear();
              listMessage.addAll(listDatas);
              listMessage.insert(0, message);
            }
          }
        }
      }
      await box.clear();
      await box.put(message.rid, listMessage);
    }
  }

  // Xóa cache khi người dùng đăng xuất
  static Future<void> removeCacheWhenLogOut() async {
    List<WsRoomModel> listRoomPrivate = getListPrivateRoom();
    if (listRoomPrivate != null && listRoomPrivate.length > 0) {
      for (WsRoomModel room in listRoomPrivate) {
        Box box = await Hive.openBox(room.id);
        if (box != null) {
          await box.clear();
          await box.close();
        }
      }
    }
    List<WsRoomModel> listDirectRoom = getListDirectRoom();
    if (listDirectRoom != null && listDirectRoom.length > 0) {
      for (WsRoomModel room in listDirectRoom) {
        Box box = await Hive.openBox(room.id);
        if (box != null) {
          await box.clear();
          await box.close();
        }
      }
    }
    Box box = Hive.box(BoxName.BOX_LIST_GROUP.toString());
    await box.clear();
  }

  //Goi khi xoa nhom hoac roi nhom
  static void removeCacheRoomMessage(String id) async {
    removeRomByRoomID(id);
    await removeMessageByRoomID(id);
  }

  //Xoa 1 room theo room id
  static void removeRomByRoomID(String rid) {
    List<WsRoomModel> listPrivateRoom = getListPrivateRoom();
    listPrivateRoom?.removeWhere((room) => room.id == rid);
    saveAllPrivateRoom(listPrivateRoom);
  }

  //Xoa toan bo tin nhan trong room theo room id
  static Future<void> removeMessageByRoomID(String rid) async {
    Box box = await Hive.openBox(rid.toString());
    if (box != null) {
      await box.deleteFromDisk();
    }
    await box.close();
  }

  //Lưu trữ thông tin user info sau khi đăng nhập thành công
  static Future<void> saveUserInfo(ASGUserModel userModel) async {
    Box box = await Hive.openBox(BoxName.USER_INFO.toString());
    if (box != null) {
      await box.clear();
      await box.put(BoxName.USER_INFO.toString(), userModel);
    }
    await box.close();
  }

  //Get user info
  static Future<ASGUserModel> getCurrentUserInfo() async {
    ASGUserModel asgUserModel;
    Box box = await Hive.openBox(BoxName.USER_INFO.toString());
    if (box != null) {
      try {
        dynamic data = box.get(BoxName.USER_INFO.toString());
        if (data != null) asgUserModel = data as ASGUserModel;
      } catch (ex) {
      }
    }
    await box.close();
    return asgUserModel;
  }

  static Future<void> removeUserInfo() async {
    Box box = await Hive.openBox(BoxName.USER_INFO.toString());
    if (box != null) {
      try {
        if (box.containsKey(BoxName.USER_INFO.toString())) {
          await box.delete(BoxName.USER_INFO.toString());
        }
      } catch (ex) {
      }
    }
    await box.close();
  }
}
