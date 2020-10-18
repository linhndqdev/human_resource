class MeetingRoomModel {
  int id;
  String name;
  MeetingRoomModel(this.id, this.name);

  factory MeetingRoomModel.fromJson(Map<String, dynamic> json) {
    return MeetingRoomModel(json['id'], json['name']);
  }

//  compareTo(MeetingRoomModel b) {}


}


