import 'package:hive/hive.dart';
part 'ws_attachment.g.dart';

@HiveType(adapterName: "WsAttachmentAdapter")
class WsAttachment {
  @HiveField(0)
  String title;
  @HiveField(1)
  String type;
  @HiveField(2)
  String description;
  @HiveField(3)
  String title_link;
  @HiveField(4)
  bool title_link_download;
  WsAttachment();
  WsAttachment.create(this.title, this.type, this.description, this.title_link,
      this.title_link_download);

  factory WsAttachment.fromJson(Map<String, dynamic> json) {
    return WsAttachment.create(json['title'], json['type'], json['description'],
        json['title_link'], json['title_link_download']);
  }
}

@HiveType(adapterName: "WsImageFileAdapter")
class WsImageFile extends WsAttachment {
  @HiveField(0)
  @override
  String title;
  @HiveField(1)
  @override
  String type;
  @HiveField(2)
  @override
  String description;
  @HiveField(3)
  @override
  String title_link;
  @HiveField(4)
  @override
  bool title_link_download;
  @HiveField(5)
  String image_url;
  @HiveField(6)
  String image_type;
  @HiveField(7)
  int image_size;
  @HiveField(8)
  ImageDimensions image_dimensions;
  @HiveField(9)
  String image_preview;
  WsImageFile();
  WsImageFile.create(
      this.title,
      this.type,
      this.description,
      this.title_link,
      this.title_link_download,
      this.image_url,
      this.image_type,
      this.image_size,
      this.image_dimensions,
      this.image_preview)
      : super.create(title, type, description, title_link, title_link_download);

  factory WsImageFile.fromJSon(Map<String, dynamic> json) {
    ImageDimensions dimensions;
    if (json['image_dimensions'] != null && json['image_dimensions'] != '') {
      dimensions = ImageDimensions.fromJson(json['image_dimensions']);
    }
    return WsImageFile.create(
        json['title'],
        json['type'],
        json['description'],
        json['title_link'],
        json['title_link_download'],
        json['image_url'],
        json['image_type'],
        json['image_size'],
        dimensions,
        json['image_preview']);
  }
}

@HiveType(adapterName: "WsAudioFileAdapter")
class WsAudioFile extends WsAttachment {
  @HiveField(0)
  @override
  String title;
  @HiveField(1)
  @override
  String type;
  @HiveField(2)
  @override
  String description;
  @HiveField(3)
  @override
  String title_link;
  @HiveField(4)
  @override
  bool title_link_download;
  @HiveField(5)
  String audio_url;
  @HiveField(6)
  String audio_type;
  @HiveField(7)
  int audio_size;
  WsAudioFile();
  WsAudioFile.create(
      this.title,
      this.type,
      this.description,
      this.title_link,
      this.title_link_download,
      this.audio_url,
      this.audio_size,
      this.audio_type)
      : super.create(title, type, description, title_link, title_link_download);

  factory WsAudioFile.fromJson(Map<String, dynamic> json) {
    return WsAudioFile.create(
        json['title'],
        json['type'],
        json['description'],
        json['title_link'],
        json['title_link_download'],
        json['audio_url'],
        json['audio_size'],
        json['audio_type']);
  }
}

@HiveType(adapterName: "ImageDimensionsAdapter")
class ImageDimensions {
  @HiveField(0)
  int width;
  @HiveField(1)
  int height;

  ImageDimensions(this.width, this.height);

  factory ImageDimensions.fromJson(Map<String, dynamic> json) {
    return ImageDimensions(json['width'], json['height']);
  }
}
