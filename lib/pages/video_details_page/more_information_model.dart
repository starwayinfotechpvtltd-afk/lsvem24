class MoreInformationModel {
  String videoId;
  String channelId;

  String title;
  int videoType;
  int videoTime;
  String videoUrl;
  bool isSave;

  String channelName;
  String videoImage;
  int views;

  MoreInformationModel({
    required this.channelId,
    required this.videoId,
    required this.title,
    required this.videoType,
    required this.videoTime,
    required this.videoUrl,
    required this.videoImage,
    required this.channelName,
    required this.views,
    required this.isSave,
  });
}
