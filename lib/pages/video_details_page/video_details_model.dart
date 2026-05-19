class VideoDetailsModel {
  bool? status;
  String? message;
  DetailsOfVideo? detailsOfVideo;

  VideoDetailsModel({this.status, this.message, this.detailsOfVideo});

  VideoDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    detailsOfVideo = json['detailsOfVideo'] != null ? DetailsOfVideo.fromJson(json['detailsOfVideo']) : DetailsOfVideo();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (detailsOfVideo != null) {
      data['detailsOfVideo'] = detailsOfVideo!.toJson();
    }
    return data;
  }
}

class DetailsOfVideo {
  String? id;
  List<String>? hashTag;
  int? shareCount;
  int? like;
  int? dislike;
  String? channelId;
  String? title;
  String? description;
  int? videoType;
  int? videoTime;
  String? videoUrl;
  String? videoImage;
  int? commentType;
  int? videoPrivacyType;
  String? userId;
  String? createdAt;
  int? channelType;
  int? subscriptionCost;
  int? videoUnlockCost;
  String? channelName;
  String? channelImage;
  int? totalComments;
  int? totalSubscribers;
  int? views;
  bool? isSubscribed;
  bool? isSaveToWatchLater;
  bool? isLike;
  bool? isDislike;
  String? time;

  DetailsOfVideo(
      {this.id,
      this.hashTag,
      this.shareCount,
      this.like,
      this.dislike,
      this.channelId,
      this.title,
      this.description,
      this.videoType,
      this.videoTime,
      this.videoUrl,
      this.videoImage,
      this.commentType,
      this.videoPrivacyType,
      this.userId,
      this.createdAt,
      this.channelType,
      this.subscriptionCost,
      this.videoUnlockCost,
      this.channelName,
      this.channelImage,
      this.totalComments,
      this.totalSubscribers,
      this.views,
      this.isSubscribed,
      this.isSaveToWatchLater,
      this.isLike,
      this.isDislike,
      this.time});

  DetailsOfVideo.fromJson(Map<String, dynamic> json) {
    id = json['_id']?.toString() ?? "";
    hashTag = (json['hashTag'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
    shareCount = json['shareCount'] ?? 0;
    like = json['like'] ?? 0;
    dislike = json['dislike'] ?? 0;
    channelId = json['channelId']?.toString() ?? "";
    title = json['title']?.toString() ?? "";
    description = json['description']?.toString() ?? "";
    videoType = json['videoType'] ?? 0;
    videoTime = json['videoTime'] ?? 0;
    videoUrl = json['videoUrl']?.toString() ?? "";
    videoImage = json['videoImage']?.toString() ?? "";
    commentType = json['commentType'] ?? 0;
    videoPrivacyType = json['videoPrivacyType'] ?? 0;
    userId = json['userId']?.toString() ?? "";
    createdAt = json['createdAt']?.toString() ?? "";
    channelType = json['channelType'] ?? 0;
    subscriptionCost = json['subscriptionCost'] ?? 0;
    videoUnlockCost = json['videoUnlockCost'] ?? 0;
    channelName = json['channelName']?.toString() ?? "";
    channelImage = json['channelImage']?.toString() ?? "";
    totalComments = json['totalComments'] ?? 0;
    totalSubscribers = json['totalSubscribers'] ?? 0;
    views = json['views'] ?? 0;
    isSubscribed = json['isSubscribed'] ?? false;
    isSaveToWatchLater = json['isSaveToWatchLater'] ?? false;
    isLike = json['isLike'] ?? false;
    isDislike = json['isDislike'] ?? false;
    time = json['time']?.toString() ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['hashTag'] = hashTag;
    data['shareCount'] = shareCount;
    data['like'] = like;
    data['dislike'] = dislike;
    data['channelId'] = channelId;
    data['title'] = title;
    data['description'] = description;
    data['videoType'] = videoType;
    data['videoTime'] = videoTime;
    data['videoUrl'] = videoUrl;
    data['videoImage'] = videoImage;
    data['commentType'] = commentType;
    data['videoPrivacyType'] = videoPrivacyType;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['channelType'] = channelType;
    data['subscriptionCost'] = subscriptionCost;
    data['videoUnlockCost'] = videoUnlockCost;
    data['channelName'] = channelName;
    data['channelImage'] = channelImage;
    data['totalComments'] = totalComments;
    data['totalSubscribers'] = totalSubscribers;
    data['views'] = views;
    data['isSubscribed'] = isSubscribed;
    data['isSaveToWatchLater'] = isSaveToWatchLater;
    data['isLike'] = isLike;
    data['isDislike'] = isDislike;
    data['time'] = time;
    return data;
  }
}
