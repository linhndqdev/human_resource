class RestUserModel {
  String id;
  String type;
  String status;
  bool active;
  String name;
  String username;
  int utcOffset;
  String statusText;
  RestUserModel();
  RestUserModel.createFromAddressBook(
      this.id, this.status, this.name, this.username);

  RestUserModel.createUserInfo(this.id, this.type, this.status, this.active,
      this.name, this.username, this.utcOffset, this.statusText);

  factory RestUserModel.fromGetAllUser(Map<String, dynamic> json) {
    return RestUserModel.createUserInfo(
        json['_id'],
        json['type'],
        json['status'],
        json['active'],
        json['name'] ?? "",
        json['username'] ?? "",
        json['utcOffset'],
        json['statusText'] ?? "");
  }
}
