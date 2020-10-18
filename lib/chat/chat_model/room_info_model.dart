class PositionsLevelModel {
  String name;

  PositionsLevelModel();

  PositionsLevelModel.createWith(this.name);

  factory PositionsLevelModel.fromJson(Map<String, dynamic> json) {
    String nameJson;
    if (json['name'] != null && json['name'] != '') {
      nameJson = json['name'];
    }
    return PositionsLevelModel.createWith(
    nameJson,
    );
  }
}

class PositionsDepartmentModel {
  String name;

  PositionsDepartmentModel();

  PositionsDepartmentModel.createWith(this.name);

  factory PositionsDepartmentModel.fromJson(Map<String, dynamic> json) {
    String nameJson;
    if (json['name'] != null && json['name'] != '') {
      nameJson = json['name'];
    }
    return PositionsDepartmentModel.createWith(
    nameJson,
    );
  }
}

class PositionsModel {
  PositionsDepartmentModel department;
  PositionsLevelModel levelName;

  PositionsModel();

  PositionsModel.createWith(this.department, this.levelName);

  factory PositionsModel.fromJson(Map<String, dynamic> json) {
    PositionsDepartmentModel positionsDepartmentModel;
    if (json['department'] != null && json['department'] != '') {
      positionsDepartmentModel =
          PositionsDepartmentModel.fromJson(json['department']);
    }
    PositionsLevelModel positionsLevelModel;
    if (json['level'] != null && json['level'] != '') {
      positionsLevelModel =
          PositionsLevelModel.fromJson(json['level']);
    }
    return PositionsModel.createWith(
      positionsDepartmentModel,
      positionsLevelModel,
    );
  }
}

class RoomInfoModel {
  String fullName;
  String email;
  String asglID;
  String mobilePhone;
  PositionsModel positionsModel;
  String username;

  RoomInfoModel();

  RoomInfoModel.createWith(this.fullName, this.email, this.asglID,
      this.mobilePhone, this.positionsModel,this.username);

  factory RoomInfoModel.fromJson(Map<String, dynamic> json) {
    PositionsModel positionsModel;
    if (json['positions'] != null && json['positions'] != ''&& json['positions'].length >0) {
      positionsModel = PositionsModel.fromJson(json['positions'][0]);
    }
    return RoomInfoModel.createWith(json['full_name'], json['email'],
        json['asgl_id'], json['mobile_phone'], positionsModel,json['username'],);
  }
}