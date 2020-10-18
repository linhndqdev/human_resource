import 'dart:convert';
import 'package:convert/convert.dart';

class CryptoHex {
  //Todo: Encode group name from utf-8 to Hex
  ///[data] Group Name user input
  /// return String of data encrypted type hex
  static String enCodeChannelName(String data) {
    var mData = utf8.encode(data);
    String encrypted = hex.encode(mData);
    return encrypted;
  }

  //Todo: Decode group name from Hex to utf-8
  ///[roomName] Name of room type hex
  ///return String of roomName decrypted
  static String deCodeChannelName(String roomName) {
    var decrypted = hex.decode(roomName);
    return utf8.decode(decrypted);
  }
}
