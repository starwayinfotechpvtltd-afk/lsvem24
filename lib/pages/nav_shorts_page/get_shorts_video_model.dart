class GetShortsVideoModel {
  bool? status;
  String? message;
  List<Shorts>? shorts;

  GetShortsVideoModel({this.status, this.message, this.shorts});

  GetShortsVideoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['shorts'] != null) {
      shorts = <Shorts>[];
      json['shorts'].forEach((v) {
        shorts!.add(new Shorts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.shorts != null) {
      data['shorts'] = this.shorts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Shorts {
  String? id;
  List<String>? hashTag;
  int? shareCount;
  int? like;
  int? dislike;
  String? title;
  String? description;
  int? videoType;
  int? videoTime;
  String? videoUrl;
  String? videoImage;
  int? commentType;
  String? userId;
  String? channelId;
  String? createdAt;
  int? videoPrivacyType;
  String? channelName;
  String? channelImage;
  int? totalComments;
  bool? isSubscribed;
  bool? isSaveToWatchLater;
  bool? isLike;
  bool? isDislike;
  int? views;
  int? channelType;
  int? subscriptionCost;
  int? videoUnlockCost;

  Shorts(
      {this.id,
      this.hashTag,
      this.shareCount,
      this.like,
      this.dislike,
      this.title,
      this.description,
      this.videoType,
      this.videoTime,
      this.videoUrl,
      this.videoImage,
      this.commentType,
      this.userId,
      this.channelId,
      this.createdAt,
      this.videoPrivacyType,
      this.channelName,
      this.channelImage,
      this.totalComments,
      this.isSubscribed,
      this.isSaveToWatchLater,
      this.isLike,
      this.isDislike,
      this.views,
      this.channelType,
      this.subscriptionCost,
      this.videoUnlockCost});

  Shorts.fromJson(Map<String, dynamic> json) {
    id = json['_id']?.toString() ?? "";
    hashTag =
        (json['hashTag'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
    shareCount = json['shareCount'] ?? 0;
    like = json['like'] ?? 0;
    dislike = json['dislike'] ?? 0;
    title = json['title']?.toString() ?? "";
    description = json['description']?.toString() ?? "";
    videoType = json['videoType'] ?? 0;
    videoTime = json['videoTime'] ?? 0;
    videoUrl = json['videoUrl']?.toString() ?? "";
    videoImage = json['videoImage']?.toString() ?? "";
    commentType = json['commentType'] ?? 0;
    userId = json['userId']?.toString() ?? "";
    channelId = json['channelId']?.toString() ?? "";
    createdAt = json['createdAt']?.toString() ?? "";
    videoPrivacyType = json['videoPrivacyType'] ?? 0;
    channelName = json['channelName']?.toString() ?? "";
    channelImage = json['channelImage']?.toString() ?? "";
    totalComments = json['totalComments'] ?? 0;
    isSubscribed = json['isSubscribed'] ?? false;
    isSaveToWatchLater = json['isSaveToWatchLater'] ?? false;
    isLike = json['isLike'] ?? false;
    isDislike = json['isDislike'] ?? false;
    views = json['views'] ?? 0;
    channelType = json['channelType'] ?? 0;
    subscriptionCost = json['subscriptionCost'] ?? 0;
    videoUnlockCost = json['videoUnlockCost'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['hashTag'] = this.hashTag;
    data['shareCount'] = this.shareCount;
    data['like'] = this.like;
    data['dislike'] = this.dislike;
    data['title'] = this.title;
    data['description'] = this.description;
    data['videoType'] = this.videoType;
    data['videoTime'] = this.videoTime;
    data['videoUrl'] = this.videoUrl;
    data['videoImage'] = this.videoImage;
    data['commentType'] = this.commentType;
    data['userId'] = this.userId;
    data['channelId'] = this.channelId;
    data['createdAt'] = this.createdAt;
    data['videoPrivacyType'] = this.videoPrivacyType;
    data['channelName'] = this.channelName;
    data['channelImage'] = this.channelImage;
    data['totalComments'] = this.totalComments;
    data['isSubscribed'] = this.isSubscribed;
    data['isSaveToWatchLater'] = this.isSaveToWatchLater;
    data['isLike'] = this.isLike;
    data['isDislike'] = this.isDislike;
    data['views'] = this.views;
    data['channelType'] = this.channelType;
    data['subscriptionCost'] = this.subscriptionCost;
    data['videoUnlockCost'] = this.videoUnlockCost;
    return data;
  }
}
