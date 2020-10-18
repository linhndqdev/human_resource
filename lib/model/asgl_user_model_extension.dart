import 'asgl_user_model.dart';

extension PropertiDetail on ASGUserModel {
  String getPosition() {
    String positionName = "Không xác định";
    if (this.position != null &&
        this.position.name != null &&
        this.position.name != "") {
      return position.name;
    }
    return positionName;
  }

  String getDepartment() {
    String departName = "Không xác định";
    if (this.position != null &&
        this.position.department != null &&
        this.position.department.name != null &&
        this.position.department.name != "") {
      return position.department.name;
    }
    return departName;
  }

  String getMobilePhone() {
    if (this.mobile_phone != null && this.mobile_phone != "") {
      return this.mobile_phone;
    } else if (this.secondary_phone != null && this.secondary_phone != "") {
      return this.secondary_phone;
    }
    return "Không xác định";
  }

  String getEmail() {
    if (this.email != null && this.email != "") {
      return this.email;
    } else if (this.secondary_email != null && this.secondary_email != "") {
      return this.secondary_email;
    }
    return "Không xác định";
  }

  String getInfoShow() {
    String positionName = "";
    String departName = "";
    if (this.position != null) {
      if (this.position != null &&
          this.position.name != null &&
          this.position.name != "") {
        positionName = this.position.name;
      }
      if (this.position != null &&
          this.position.department != null &&
          this.position.department.name != null &&
          this.position.department.name != "") {
        departName = this.position.department.name;
      }
      if (positionName != "" && departName != "") {
        return "$positionName - $departName";
      }
      if (positionName != "") {
        return "$positionName";
      }
      if (departName != "") {
        return departName;
      }

      return "Không xác định";
    } else {
      return "Không xác định";
    }
  }
}
