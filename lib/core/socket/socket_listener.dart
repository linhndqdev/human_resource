class SocketListener {
  SocketListener() {
    //lobby
    onSocketStatus = [];
    onMatching = [];
    onSubcribed = [];
    authentication = [];
    onCompetitorAccept = [];
  }

  //lobby
  List<Function(String)> onSocketStatus;

  List<Function(Map<dynamic, dynamic>)> onMatching;
  List<Function(Map<dynamic, dynamic>)> onSubcribed;
  List<Function(bool)> authentication;

  //play with friend
  List<Function(Map<dynamic, dynamic>)> onCompetitorAccept;
  Function() onCompetitorReject;

  void notifyOnSocketStatus(String data) {
    if (onSocketStatus != null && onSocketStatus.isNotEmpty) {
      onSocketStatus.last(data);
    }
  }

  void notifyOnSubcribed(Map<dynamic, dynamic> data) {
    if (onSubcribed != null && onSubcribed.isNotEmpty) {
      onSubcribed.last(data);
    }
  }

  void notifyAuthentication(bool data) {
    if (authentication != null && authentication.isNotEmpty) {
      authentication.last(data);
    }
  }

  void notifyOnCompetitorAccept(Map<dynamic, dynamic> data) {
    if (onCompetitorAccept != null && onCompetitorAccept.isNotEmpty) {
      onCompetitorAccept.last(data);
    }
  }
}
