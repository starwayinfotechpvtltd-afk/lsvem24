class FetchNewVideoModel {
  bool? status;
  String? message;
  Data? data;

  FetchNewVideoModel({this.status, this.message, this.data});

  FetchNewVideoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<NewVideos>? videos;
  List<NewShorts>? shorts;

  Data({this.videos, this.shorts});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['videos'] != null) {
      videos = <NewVideos>[];
      json['videos'].forEach((v) {
        videos!.add(new NewVideos.fromJson(v));
      });
    }
    if (json['shorts'] != null) {
      shorts = <NewShorts>[];
      json['shorts'].forEach((v) {
        shorts!.add(new NewShorts.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.videos != null) {
      data['videos'] = this.videos!.map((v) => v.toJson()).toList();
    }
    if (this.shorts != null) {
      data['shorts'] = this.shorts!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NewVideos {
  String? id;
  String? channelId;
  int? scheduleType;
  String? scheduleTime;
  String? title;
  int? videoType;
  int? videoTime;
  String? videoUrl;
  String? videoImage;
  int? videoPrivacyType;
  String? userId;
  String? createdAt;
  int? views;
  int? channelType;
  int? subscriptionCost;
  int? videoUnlockCost;
  String? channelName;
  String? channelImage;
  bool? isSubscribed;
  bool? isSaveToWatchLater;
  String? time;

  NewVideos(
      {this.id,
      this.channelId,
      this.scheduleType,
      this.scheduleTime,
      this.title,
      this.videoType,
      this.videoTime,
      this.videoUrl,
      this.videoImage,
      this.videoPrivacyType,
      this.userId,
      this.createdAt,
      this.views,
      this.channelType,
      this.subscriptionCost,
      this.videoUnlockCost,
      this.channelName,
      this.channelImage,
      this.isSubscribed,
      this.isSaveToWatchLater,
      this.time});

  NewVideos.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    channelId = json['channelId'];
    scheduleType = json['scheduleType'];
    scheduleTime = json['scheduleTime'];
    title = json['title'];
    videoType = json['videoType'];
    videoTime = json['videoTime'];
    videoUrl = json['videoUrl'];
    videoImage = json['videoImage'];
    videoPrivacyType = json['videoPrivacyType'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    views = json['views'];
    channelType = json['channelType'];
    subscriptionCost = json['subscriptionCost'];
    videoUnlockCost = json['videoUnlockCost'];
    channelName = json['channelName'];
    channelImage = json['channelImage'];
    isSubscribed = json['isSubscribed'];
    isSaveToWatchLater = json['isSaveToWatchLater'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['channelId'] = this.channelId;
    data['scheduleType'] = this.scheduleType;
    data['scheduleTime'] = this.scheduleTime;
    data['title'] = this.title;
    data['videoType'] = this.videoType;
    data['videoTime'] = this.videoTime;
    data['videoUrl'] = this.videoUrl;
    data['videoImage'] = this.videoImage;
    data['videoPrivacyType'] = this.videoPrivacyType;
    data['userId'] = this.userId;
    data['createdAt'] = this.createdAt;
    data['views'] = this.views;
    data['channelType'] = this.channelType;
    data['subscriptionCost'] = this.subscriptionCost;
    data['videoUnlockCost'] = this.videoUnlockCost;
    data['channelName'] = this.channelName;
    data['channelImage'] = this.channelImage;
    data['isSubscribed'] = this.isSubscribed;
    data['isSaveToWatchLater'] = this.isSaveToWatchLater;
    data['time'] = this.time;
    return data;
  }
}

class NewShorts {
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
  bool? isSubscribed;
  bool? isSaveToWatchLater;
  bool? isLike;
  bool? isDislike;
  int? views;

  NewShorts(
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
      this.isSubscribed,
      this.isSaveToWatchLater,
      this.isLike,
      this.isDislike,
      this.views});

  NewShorts.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    hashTag = json['hashTag'].cast<String>();
    shareCount = json['shareCount'];
    like = json['like'];
    dislike = json['dislike'];
    channelId = json['channelId'];
    title = json['title'];
    description = json['description'];
    videoType = json['videoType'];
    videoTime = json['videoTime'];
    videoUrl = json['videoUrl'];
    videoImage = json['videoImage'];
    commentType = json['commentType'];
    videoPrivacyType = json['videoPrivacyType'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    channelType = json['channelType'];
    subscriptionCost = json['subscriptionCost'];
    videoUnlockCost = json['videoUnlockCost'];
    channelName = json['channelName'];
    channelImage = json['channelImage'];
    totalComments = json['totalComments'];
    isSubscribed = json['isSubscribed'];
    isSaveToWatchLater = json['isSaveToWatchLater'];
    isLike = json['isLike'];
    isDislike = json['isDislike'];
    views = json['views'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['hashTag'] = this.hashTag;
    data['shareCount'] = this.shareCount;
    data['like'] = this.like;
    data['dislike'] = this.dislike;
    data['channelId'] = this.channelId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['videoType'] = this.videoType;
    data['videoTime'] = this.videoTime;
    data['videoUrl'] = this.videoUrl;
    data['videoImage'] = this.videoImage;
    data['commentType'] = this.commentType;
    data['videoPrivacyType'] = this.videoPrivacyType;
    data['userId'] = this.userId;
    data['createdAt'] = this.createdAt;
    data['channelType'] = this.channelType;
    data['subscriptionCost'] = this.subscriptionCost;
    data['videoUnlockCost'] = this.videoUnlockCost;
    data['channelName'] = this.channelName;
    data['channelImage'] = this.channelImage;
    data['totalComments'] = this.totalComments;
    data['isSubscribed'] = this.isSubscribed;
    data['isSaveToWatchLater'] = this.isSaveToWatchLater;
    data['isLike'] = this.isLike;
    data['isDislike'] = this.isDislike;
    data['views'] = this.views;
    return data;
  }
}
