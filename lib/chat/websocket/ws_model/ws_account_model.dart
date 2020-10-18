import 'package:hive/hive.dart';
part 'ws_account_model.g.dart';
@HiveType(adapterName: "WsAccountModelAdapter")
class WsAccountModel {
  @HiveField(0)
  String id;
  @HiveField(1)
  String token;
  @HiveField(2)
  int tokenExpires;
  @HiveField(3)
  String type;
  @HiveField(4)
  String userName;

  WsAccountModel(this.id, this.token, this.tokenExpires, this.type);

  factory WsAccountModel.fromJson(Map<String, dynamic> json) {
    return WsAccountModel(
        json['id'], json['token'], json['tokenExpires']['\$date'], json['type']);
  }

  WsAccountModel.createFromRoom(this.id, this.userName);

  factory WsAccountModel.fromJsonRoom(Map<String,dynamic> json){
    return WsAccountModel.createFromRoom(json['_id'], json['username']);
  }
}