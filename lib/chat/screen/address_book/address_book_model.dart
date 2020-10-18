import 'package:hive/hive.dart';
part 'address_book_model.g.dart';
@HiveType(adapterName: "AddressBookModelAdapter")
class AddressBookModel {
  @HiveField(0)
  String id;
  @HiveField(1)
  String status;
  @HiveField(2)
  String name;
  @HiveField(3)
  String username;
  AddressBookModel();
  AddressBookModel.createAddressBookInfo(
      this.id, this.name, this.status, this.username);

  factory AddressBookModel.fromGetAllAddressBookInfo(
      Map<String, dynamic> json) {
    return AddressBookModel.createAddressBookInfo(
        json['_id'], json['name'], json['status'], json['username']);
  }

  String getLastName() {
    if (this.name == null || this.name == "") {
      return "Không xác định";
    } else {
      List<String> _listData = List();
      _listData = this.name.split(" ");
      if (_listData != null && _listData.length > 0) {
        return "... " + _listData[_listData.length - 1];
      } else {
        return this.name;
      }
    }
  }
}
