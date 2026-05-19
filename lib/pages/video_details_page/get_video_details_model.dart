import 'dart:convert';

GetVideoDetailsModel getVideoDetailsModelFromJson(String str) =>
    GetVideoDetailsModel.fromJson(json.decode(str));
String getVideoDetailsModelToJson(GetVideoDetailsModel data) => json.encode(data.toJson());

class GetVideoDetailsModel {
  GetVideoDetailsModel({
    bool? status,
    String? message,
    List<Data>? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  GetVideoDetailsModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(Data.fromJson(v));
      });
    }
  }
  bool? _status;
  String? _message;
  List<Data>? _data;
  GetVideoDetailsModel copyWith({
    bool? status,
    String? message,
    List<Data>? data,
  }) =>
      GetVideoDetailsModel(
        status: status ?? _status,
        message: message ?? _message,
        data: data ?? _data,
      );
  bool? get status => _status;
  String? get message => _message;
  List<Data>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

Data dataFromJson(String str) => Data.fromJson(json.decode(str));
String dataToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    LocationCoordinates? locationCoordinates,
    dynamic soundListId,
    String? id,
    String? uniqueVideoId,
    List<String>? hashTag,
    bool? isActive,
    bool? isAddByAdmin,
    int? shareCount,
    int? like,
    int? dislike,
    String? title,
    int? videoType,
    String? description,
    int? videoTime,
    String? videoUrl,
    String? videoImage,
    int? visibilityType,
    int? audienceType,
    int? ageRestrictionType,
    int? commentType,
    int? scheduleType,
    String? scheduleTime,
    String? location,
    String? userId,
    String? channelId,
    String? createdAt,
    String? updatedAt,
  }) {
    _locationCoordinates = locationCoordinates;
    _soundListId = soundListId;
    _id = id;
    _uniqueVideoId = uniqueVideoId;
    _hashTag = hashTag;
    _isActive = isActive;
    _isAddByAdmin = isAddByAdmin;
    _shareCount = shareCount;
    _like = like;
    _dislike = dislike;
    _title = title;
    _videoType = videoType;
    _description = description;
    _videoTime = videoTime;
    _videoUrl = videoUrl;
    _videoImage = videoImage;
    _visibilityType = visibilityType;
    _audienceType = audienceType;
    _ageRestrictionType = ageRestrictionType;
    _commentType = commentType;
    _scheduleType = scheduleType;
    _scheduleTime = scheduleTime;
    _location = location;
    _userId = userId;
    _channelId = channelId;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Data.fromJson(dynamic json) {
    _locationCoordinates = json['locationCoordinates'] != null
        ? LocationCoordinates.fromJson(json['locationCoordinates'])
        : null;
    _soundListId = json['soundListId'];
    _id = json['_id'];
    _uniqueVideoId = json['uniqueVideoId'];
    _hashTag = json['hashTag'] != null ? json['hashTag'].cast<String>() : [];
    _isActive = json['isActive'];
    _isAddByAdmin = json['isAddByAdmin'];
    _shareCount = json['shareCount'];
    _like = json['like'];
    _dislike = json['dislike'];
    _title = json['title'];
    _videoType = json['videoType'];
    _description = json['description'];
    _videoTime = json['videoTime'];
    _videoUrl = json['videoUrl'];
    _videoImage = json['videoImage'];
    _visibilityType = json['visibilityType'];
    _audienceType = json['audienceType'];
    _ageRestrictionType = json['ageRestrictionType'];
    _commentType = json['commentType'];
    _scheduleType = json['scheduleType'];
    _scheduleTime = json['scheduleTime'];
    _location = json['location'];
    _userId = json['userId'];
    _channelId = json['channelId'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
  }
  LocationCoordinates? _locationCoordinates;
  dynamic _soundListId;
  String? _id;
  String? _uniqueVideoId;
  List<String>? _hashTag;
  bool? _isActive;
  bool? _isAddByAdmin;
  int? _shareCount;
  int? _like;
  int? _dislike;
  String? _title;
  int? _videoType;
  String? _description;
  int? _videoTime;
  String? _videoUrl;
  String? _videoImage;
  int? _visibilityType;
  int? _audienceType;
  int? _ageRestrictionType;
  int? _commentType;
  int? _scheduleType;
  String? _scheduleTime;
  String? _location;
  String? _userId;
  String? _channelId;
  String? _createdAt;
  String? _updatedAt;
  Data copyWith({
    LocationCoordinates? locationCoordinates,
    dynamic soundListId,
    String? id,
    String? uniqueVideoId,
    List<String>? hashTag,
    bool? isActive,
    bool? isAddByAdmin,
    int? shareCount,
    int? like,
    int? dislike,
    String? title,
    int? videoType,
    String? description,
    int? videoTime,
    String? videoUrl,
    String? videoImage,
    int? visibilityType,
    int? audienceType,
    int? ageRestrictionType,
    int? commentType,
    int? scheduleType,
    String? scheduleTime,
    String? location,
    String? userId,
    String? channelId,
    String? createdAt,
    String? updatedAt,
  }) =>
      Data(
        locationCoordinates: locationCoordinates ?? _locationCoordinates,
        soundListId: soundListId ?? _soundListId,
        id: id ?? _id,
        uniqueVideoId: uniqueVideoId ?? _uniqueVideoId,
        hashTag: hashTag ?? _hashTag,
        isActive: isActive ?? _isActive,
        isAddByAdmin: isAddByAdmin ?? _isAddByAdmin,
        shareCount: shareCount ?? _shareCount,
        like: like ?? _like,
        dislike: dislike ?? _dislike,
        title: title ?? _title,
        videoType: videoType ?? _videoType,
        description: description ?? _description,
        videoTime: videoTime ?? _videoTime,
        videoUrl: videoUrl ?? _videoUrl,
        videoImage: videoImage ?? _videoImage,
        visibilityType: visibilityType ?? _visibilityType,
        audienceType: audienceType ?? _audienceType,
        ageRestrictionType: ageRestrictionType ?? _ageRestrictionType,
        commentType: commentType ?? _commentType,
        scheduleType: scheduleType ?? _scheduleType,
        scheduleTime: scheduleTime ?? _scheduleTime,
        location: location ?? _location,
        userId: userId ?? _userId,
        channelId: channelId ?? _channelId,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
      );
  LocationCoordinates? get locationCoordinates => _locationCoordinates;
  dynamic get soundListId => _soundListId;
  String? get id => _id;
  String? get uniqueVideoId => _uniqueVideoId;
  List<String>? get hashTag => _hashTag;
  bool? get isActive => _isActive;
  bool? get isAddByAdmin => _isAddByAdmin;
  int? get shareCount => _shareCount;
  int? get like => _like;
  int? get dislike => _dislike;
  String? get title => _title;
  int? get videoType => _videoType;
  String? get description => _description;
  int? get videoTime => _videoTime;
  String? get videoUrl => _videoUrl;
  String? get videoImage => _videoImage;
  int? get visibilityType => _visibilityType;
  int? get audienceType => _audienceType;
  int? get ageRestrictionType => _ageRestrictionType;
  int? get commentType => _commentType;
  int? get scheduleType => _scheduleType;
  String? get scheduleTime => _scheduleTime;
  String? get location => _location;
  String? get userId => _userId;
  String? get channelId => _channelId;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_locationCoordinates != null) {
      map['locationCoordinates'] = _locationCoordinates?.toJson();
    }
    map['soundListId'] = _soundListId;
    map['_id'] = _id;
    map['uniqueVideoId'] = _uniqueVideoId;
    map['hashTag'] = _hashTag;
    map['isActive'] = _isActive;
    map['isAddByAdmin'] = _isAddByAdmin;
    map['shareCount'] = _shareCount;
    map['like'] = _like;
    map['dislike'] = _dislike;
    map['title'] = _title;
    map['videoType'] = _videoType;
    map['description'] = _description;
    map['videoTime'] = _videoTime;
    map['videoUrl'] = _videoUrl;
    map['videoImage'] = _videoImage;
    map['visibilityType'] = _visibilityType;
    map['audienceType'] = _audienceType;
    map['ageRestrictionType'] = _ageRestrictionType;
    map['commentType'] = _commentType;
    map['scheduleType'] = _scheduleType;
    map['scheduleTime'] = _scheduleTime;
    map['location'] = _location;
    map['userId'] = _userId;
    map['channelId'] = _channelId;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    return map;
  }
}

LocationCoordinates locationCoordinatesFromJson(String str) => LocationCoordinates.fromJson(json.decode(str));
String locationCoordinatesToJson(LocationCoordinates data) => json.encode(data.toJson());

class LocationCoordinates {
  LocationCoordinates({
    String? latitude,
    String? longitude,
  }) {
    _latitude = latitude;
    _longitude = longitude;
  }

  LocationCoordinates.fromJson(dynamic json) {
    _latitude = json['latitude'];
    _longitude = json['longitude'];
  }
  String? _latitude;
  String? _longitude;
  LocationCoordinates copyWith({
    String? latitude,
    String? longitude,
  }) =>
      LocationCoordinates(
        latitude: latitude ?? _latitude,
        longitude: longitude ?? _longitude,
      );
  String? get latitude => _latitude;
  String? get longitude => _longitude;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['latitude'] = _latitude;
    map['longitude'] = _longitude;
    return map;
  }
}
