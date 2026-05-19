import 'dart:convert';

PreviewShortsModel previewShortsModelFromJson(String str) => PreviewShortsModel.fromJson(json.decode(str));
String previewShortsModelToJson(PreviewShortsModel data) => json.encode(data.toJson());

class PreviewShortsModel {
  PreviewShortsModel({
    bool? status,
    String? message,
    List<Shorts>? shorts,
  }) {
    _status = status;
    _message = message;
    _shorts = shorts;
  }

  PreviewShortsModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['shorts'] != null) {
      _shorts = [];
      json['shorts'].forEach((v) {
        _shorts?.add(Shorts.fromJson(v));
      });
    }
  }
  bool? _status;
  String? _message;
  List<Shorts>? _shorts;
  PreviewShortsModel copyWith({
    bool? status,
    String? message,
    List<Shorts>? shorts,
  }) =>
      PreviewShortsModel(
        status: status ?? _status,
        message: message ?? _message,
        shorts: shorts ?? _shorts,
      );
  bool? get status => _status;
  String? get message => _message;
  List<Shorts>? get shorts => _shorts;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_shorts != null) {
      map['shorts'] = _shorts?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

Shorts shortsFromJson(String str) => Shorts.fromJson(json.decode(str));
String shortsToJson(Shorts data) => json.encode(data.toJson());

class Shorts {
  Shorts({
    String? id,
    List<String>? hashTag,
    int? shareCount,
    int? like,
    int? dislike,
    String? title,
    int? videoType,
    String? description,
    int? videoTime,
    String? videoUrl,
    String? videoImage,
    String? userId,
    String? channelId,
    String? createdAt,
    String? channelName,
    String? channelImage,
    int? totalComments,
    bool? isSubscribed,
    bool? isLike,
    bool? isDislike,
    int? views,
  }) {
    _id = id;
    _hashTag = hashTag;
    _shareCount = shareCount;
    _like = like;
    _dislike = dislike;
    _title = title;
    _videoType = videoType;
    _description = description;
    _videoTime = videoTime;
    _videoUrl = videoUrl;
    _videoImage = videoImage;
    _userId = userId;
    _channelId = channelId;
    _createdAt = createdAt;
    _channelName = channelName;
    _channelImage = channelImage;
    _totalComments = totalComments;
    _isSubscribed = isSubscribed;
    _isLike = isLike;
    _isDislike = isDislike;
    _views = views;
  }

  Shorts.fromJson(dynamic json) {
    _id = json['_id']?.toString() ?? "";
    _hashTag =
        (json['hashTag'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
    _shareCount = json['shareCount'] ?? 0;
    _like = json['like'] ?? 0;
    _dislike = json['dislike'] ?? 0;
    _title = json['title']?.toString() ?? "";
    _videoType = json['videoType'] ?? 0;
    _description = json['description']?.toString() ?? "";
    _videoTime = json['videoTime'] ?? 0;
    _videoUrl = json['videoUrl']?.toString() ?? "";
    _videoImage = json['videoImage']?.toString() ?? "";
    _userId = json['userId']?.toString() ?? "";
    _channelId = json['channelId']?.toString() ?? "";
    _createdAt = json['createdAt']?.toString() ?? "";
    _channelName = json['channelName']?.toString() ?? "";
    _channelImage = json['channelImage']?.toString() ?? "";
    _totalComments = json['totalComments'] ?? 0;
    _isSubscribed = json['isSubscribed'] ?? false;
    _isLike = json['isLike'] ?? false;
    _isDislike = json['isDislike'] ?? false;
    _views = json['views'] ?? 0;
  }
  String? _id;
  List<String>? _hashTag;
  int? _shareCount;
  int? _like;
  int? _dislike;
  String? _title;
  int? _videoType;
  String? _description;
  int? _videoTime;
  String? _videoUrl;
  String? _videoImage;
  String? _userId;
  String? _channelId;
  String? _createdAt;
  String? _channelName;
  String? _channelImage;
  int? _totalComments;
  bool? _isSubscribed;
  bool? _isLike;
  bool? _isDislike;
  int? _views;
  Shorts copyWith({
    String? id,
    List<String>? hashTag,
    int? shareCount,
    int? like,
    int? dislike,
    String? title,
    int? videoType,
    String? description,
    int? videoTime,
    String? videoUrl,
    String? videoImage,
    String? userId,
    String? channelId,
    String? createdAt,
    String? channelName,
    String? channelImage,
    int? totalComments,
    bool? isSubscribed,
    bool? isLike,
    bool? isDislike,
    int? views,
  }) =>
      Shorts(
        id: id ?? _id,
        hashTag: hashTag ?? _hashTag,
        shareCount: shareCount ?? _shareCount,
        like: like ?? _like,
        dislike: dislike ?? _dislike,
        title: title ?? _title,
        videoType: videoType ?? _videoType,
        description: description ?? _description,
        videoTime: videoTime ?? _videoTime,
        videoUrl: videoUrl ?? _videoUrl,
        videoImage: videoImage ?? _videoImage,
        userId: userId ?? _userId,
        channelId: channelId ?? _channelId,
        createdAt: createdAt ?? _createdAt,
        channelName: channelName ?? _channelName,
        channelImage: channelImage ?? _channelImage,
        totalComments: totalComments ?? _totalComments,
        isSubscribed: isSubscribed ?? _isSubscribed,
        isLike: isLike ?? _isLike,
        isDislike: isDislike ?? _isDislike,
        views: views ?? _views,
      );
  String? get id => _id;
  List<String>? get hashTag => _hashTag;
  int? get shareCount => _shareCount;
  int? get like => _like;
  int? get dislike => _dislike;
  String? get title => _title;
  int? get videoType => _videoType;
  String? get description => _description;
  int? get videoTime => _videoTime;
  String? get videoUrl => _videoUrl;
  String? get videoImage => _videoImage;
  String? get userId => _userId;
  String? get channelId => _channelId;
  String? get createdAt => _createdAt;
  String? get channelName => _channelName;
  String? get channelImage => _channelImage;
  int? get totalComments => _totalComments;
  bool? get isSubscribed => _isSubscribed;
  bool? get isLike => _isLike;
  bool? get isDislike => _isDislike;
  int? get views => _views;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['hashTag'] = _hashTag;
    map['shareCount'] = _shareCount;
    map['like'] = _like;
    map['dislike'] = _dislike;
    map['title'] = _title;
    map['videoType'] = _videoType;
    map['description'] = _description;
    map['videoTime'] = _videoTime;
    map['videoUrl'] = _videoUrl;
    map['videoImage'] = _videoImage;
    map['userId'] = _userId;
    map['channelId'] = _channelId;
    map['createdAt'] = _createdAt;
    map['channelName'] = _channelName;
    map['channelImage'] = _channelImage;
    map['totalComments'] = _totalComments;
    map['isSubscribed'] = _isSubscribed;
    map['isLike'] = _isLike;
    map['isDislike'] = _isDislike;
    map['views'] = _views;
    return map;
  }
}
