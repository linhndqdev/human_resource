class ImageNativeModel {
  String imageId;
  String imageName;
  String imagePath;
  int imageSize;
  String imageType;
  int timeAddImage;

  ImageNativeModel();

  ImageNativeModel.create(this.imageId, this.imageName, this.imagePath,
      this.imageSize, this.imageType, this.timeAddImage);

  factory ImageNativeModel.fromJson(Map<String, dynamic> json) {
    int imgSize = 0;
    try {
      if (json['imageSize'] != null && json['imageSize'] != "") {
        imgSize = int.parse(json['imageSize']);
      }
    } catch (ex) {
      imgSize = 0;
    }
    DateTime dateTime = DateTime.now();
    return ImageNativeModel.create(
        json['imageId'],
        json['imageName'],
        json['imagePath'],
        imgSize,
        json['imageType'],
        dateTime.millisecondsSinceEpoch);
  }

  void printData() {
    print(
        " Image id: ${this.imageId} \n Image Name: ${this.imageName} \n Image Path: ${this.imagePath} \n Image Size: ${this.imageSize} \n Image Type: ${this.imageType}");
  }
}
