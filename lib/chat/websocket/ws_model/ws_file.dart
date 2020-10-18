import 'package:hive/hive.dart';

part 'ws_file.g.dart';

@HiveType(adapterName: "WsFileAdapter")
class WsFile {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String type;

  WsFile();

  WsFile.createWith(this.id, this.name, this.type);

  factory WsFile.fromJson(Map<String, dynamic> json) {
    String id;
    if (json['id'] != null && json['id'] != "") {
      id = json['id'];
    } else if (json['_id'] != null && json['_id'] != null) {
      id = json['_id'];
    }
    return WsFile.createWith(id, json['name'], json['type']);
  }
}
