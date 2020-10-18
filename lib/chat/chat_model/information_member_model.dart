import 'package:human_resource/core/meeting/model/participant_model.dart';

class InformationMemberModel {
  String username;
  bool isCheckListBlock;
  String roomId;

  InformationMemberModel({this.username, this.isCheckListBlock,this.roomId});

  InformationMemberModel.createWith(this.username, this.isCheckListBlock,this.roomId);
}
