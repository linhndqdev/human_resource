class MetaNotificationModel {
  int total;
  int count;
  int per_page;
  int current_page;
  int total_pages;
  Link links;

  MetaNotificationModel();

  MetaNotificationModel.createWith({
    this.total,
    this.count,
    this.per_page,
    this.current_page,
    this.total_pages,
    this.links,
  });

  factory MetaNotificationModel.fromJson(Map<String, dynamic> json) {
    Link links=Link();
    if(json['links']!=null){
      links= Link.fromJson(json['links']);
    }

    return MetaNotificationModel.createWith(
      total: json['total'],
      count: json['count'],
      per_page: json['per_page'],
      current_page: json['current_page'],
      total_pages: json['total_pages'],
      links: links,
    );
  }
}

class Link {
  String next;
  String previews;

  Link();

  Link.createWith({this.next, this.previews});

  factory Link.fromJson(Map<String, dynamic> json) {
    String next = "";
    if (json['next'] != null) {
      next = json['next'];
    }
    String previous = "";
    if (json['previous'] != null) {
      previous = json['previous'];
    }

    return Link.createWith(next: next, previews: previous);
  }
}
