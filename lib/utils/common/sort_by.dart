import 'package:flutter/foundation.dart';
import 'package:human_resource/chat/screen/address_book/address_book_model.dart';
import 'package:human_resource/model/asgl_user_model.dart';

class Sort {
  Map<String, String> _dataConvert = {
    "á": "a",
    "à": "a",
    "ã": "a",
    "ả": "a",
    "ạ": "a",
    "ă": "a",
    "ắ": "a",
    "ẵ": "a",
    "ằ": "a",
    "ẳ": "a",
    "ặ": "a",
    "â": "a",
    "ầ": "a",
    "ẫ": "a",
    "ẩ": "a",
    "ậ": "a",
    "ấ": "a",
    "ó": "o",
    "ỏ": "o",
    "õ": "o",
    "ỏ": "o",
    "ọ": "o",
    "ô": "o",
    "ố": "o",
    "ổ": "o",
    "ỗ": "o",
    "ồ": "o",
    "ộ": "o",
    "ơ": "o",
    "ớ": "o",
    "ờ": "o",
    "ợ": "o",
    "ở": "o",
    "ỡ": "o",
    "ú": "u",
    "ù": "u",
    "ủ": "u",
    "ũ": "u",
    "ụ": "u",
    "ứ": "u",
    "ừ": "u",
    "ử": "u",
    "ữ": "u",
    "ự": "u",
    "è": "e",
    "é": "e",
    "ẻ": "e",
    "ẽ": "e",
    "ẹ": "e",
    "ề": "e",
    "ế": "e",
    "ể": "e",
    "ễ": "e",
    "ệ": "e",
    "đ": "d",
    "ư": "u"
  };
  String getEndOfName(String endName){
    return _dataConvert.containsKey(endName) ? _dataConvert[endName] : endName;
  }
  List<AddressBookModel> sortAddressBookModelByNameUTF8(
      List<AddressBookModel> inputList) {
    Map<int, dynamic> params = {0: _dataConvert, 1: inputList};
    List<AddressBookModel> result = _sortListAddressBookModel(params);
    return result;
  }

  List<ASGUserModel> sortASGUserModelByNameUTF8(List<ASGUserModel> inputList) {
    Map<int, dynamic> params = {0: _dataConvert, 1: inputList};
    List<ASGUserModel> result = _sortListASGUserModel(params);
    return result;
  }

  List<AddressBookModel> _sortListAddressBookModel(Map<int, dynamic> input) {
    Map<String, String> _dataConvert = input[0];
    String _convertUtf8ToNonUtf8(String input) {
      var sourceSymbols = [];
      final converted = [];
      sourceSymbols = input.split("");

      for (String s in sourceSymbols) {
        converted.add(_dataConvert.containsKey(s) ? _dataConvert[s] : s);
      }
      return converted?.join();
    }

    List<AddressBookModel> _result = List();
    if (input[1] != null && input[1].length > 0) {
      _result?.addAll(input[1]);
      _result?.sort((o1, o2) {
        List<String> listWord1;
        List<String> listWord2;
        if (o1.name != null && o1.name != "") {
          listWord1 = o1.name.split(" ");
        }
        if (o2.name != null && o2.name != "") {
          listWord2 = o2.name.split(" ");
        }
        if (listWord1 != null &&
            listWord1.length > 0 &&
            listWord2 != null &&
            listWord2.length > 0) {
          String s1 = _convertUtf8ToNonUtf8(
              listWord1[listWord1.length - 1].toLowerCase().toString());
          String s2 = _convertUtf8ToNonUtf8(
              listWord2[listWord2.length - 1].toLowerCase().toString());
          return s1.compareTo(s2);
        }
        return -1;
      });
    }

    return _result;
  }

  List<ASGUserModel> _sortListASGUserModel(Map<int, dynamic> input) {
    Map<String, String> _dataConvert = input[0];
    String _convertUtf8ToNonUtf8(String input) {
      var sourceSymbols = [];
      final converted = [];
      sourceSymbols = input.split("");

      for (String s in sourceSymbols) {
        converted.add(_dataConvert.containsKey(s) ? _dataConvert[s] : s);
      }
      return converted?.join();
    }

    List<ASGUserModel> _result = List();
    if (input[1] != null && input[1].length > 0) {
      _result?.addAll(input[1]);
      _result?.sort((o1, o2) {
        List<String> listWord1;
        List<String> listWord2;
        if (o1.full_name != null && o1.full_name != "") {
          listWord1 = o1.full_name.split(" ");
        }
        if (o2.full_name != null && o2.full_name != "") {
          listWord2 = o2.full_name.split(" ");
        }
        if (listWord1 != null &&
            listWord1.length > 0 &&
            listWord2 != null &&
            listWord2.length > 0) {
          String s1 = _convertUtf8ToNonUtf8(
              listWord1[listWord1.length - 1].toLowerCase().toString());
          String s2 = _convertUtf8ToNonUtf8(
              listWord2[listWord2.length - 1].toLowerCase().toString());
          return s1.compareTo(s2);
        }
        return -1;
      });
    }

    return _result;
  }

  bool compareStringUTF8(String o1, String o2) {
    String _convertUtf8ToNonUtf8(String input) {
      var sourceSymbols = [];
      final converted = [];
      sourceSymbols = input.split("");

      for (String s in sourceSymbols) {
        converted.add(_dataConvert.containsKey(s) ? _dataConvert[s] : s);
      }
      return converted?.join();
    }

    List<String> listWord1;
    List<String> listWord2;
    if (o1 != null && o1.trim().toString() != "") {
      listWord1 = o1.split(" ");
    }
    if (o2 != null && o2.trim().toString() != "") {
      listWord2 = o2.split(" ");
    }
    if (listWord1 != null &&
        listWord1.length > 0 &&
        listWord2 != null &&
        listWord2.length > 0) {
      String s1 = _convertUtf8ToNonUtf8(o1.toLowerCase().toString());
      String s2 = _convertUtf8ToNonUtf8(o2.toLowerCase().toString());
      return s2.contains(s1);
    }
    return false;
  }
}
