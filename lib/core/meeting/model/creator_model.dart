class CreatorModel {
  int id;
  String name;
  String email;

  CreatorModel();

  CreatorModel.createWith(this.id, this.name, this.email);

  factory CreatorModel.fromJson(Map<String, dynamic> json) {
    return CreatorModel.createWith(json['id'], json['name'], json['email']);
  }
}
