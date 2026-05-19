import 'dart:convert';

GetWatchHistoryModel getWatchHistoryModelFromJson(String str) =>
    GetWatchHistoryModel.fromJson(json.decode(str));
String getWatchHistoryModelToJson(GetWatchHistoryModel data) => json.encode(data.toJson());

class GetWatchHistoryModel {
  GetWatchHistoryModel({
    bool? status,
    String? message,
    List<WatchHistory>? watchHistory,
  }) {
    _status = status;
    _message = message;
    _watchHistory = watchHistory;
  }

  GetWatchHistoryModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['watchHistory'] != null) {
      _watchHistory = [];
      json['watchHistory'].forEach((v) {
        _watchHistory?.add(WatchHistory.fromJson(v));
      });
    }
  }
  bool? _status;
  String? _message;
  List<WatchHistory>? _watchHistory;
  GetWatchHistoryModel copyWith({
    bool? status,
    String? message,
    List<WatchHistory>? watchHistory,
  }) =>
      GetWatchHistoryModel(
        status: status ?? _status,
        message: message ?? _message,
        watchHistory: watchHistory ?? _watchHistory,
      );
  bool? get status => _status;
  String? get message => _message;
  List<WatchHistory>? get watchHistory => _watchHistory;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_watchHistory != null) {
      map['watchHistory'] = _watchHistory?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

WatchHistory watchHistoryFromJson(String str) => WatchHistory.fromJson(json.decode(str));
String watchHistoryToJson(WatchHistory data) => json.encode(data.toJson());

class WatchHistory {
  WatchHistory({
    String? id,
    String? videoId,
    String? videoTitle,
    int? videoType,
    int? videoTime,
    String? videoUrl,
    String? videoImage,
    int? views,
    String? channelName,
  }) {
    _id = id;
    _videoId = videoId;
    _videoTitle = videoTitle;
    _videoType = videoType;
    _videoTime = videoTime;
    _videoUrl = videoUrl;
    _videoImage = videoImage;
    _views = views;
    _channelName = channelName;
  }

WatchHistory.fromJson(dynamic json) {
  _id          = json['_id']?.toString()        ?? "";
  _videoId     = json['videoId']?.toString()    ?? "";
  _videoTitle  = json['videoTitle']?.toString() ?? "";
  _videoType   = json['videoType']  ?? 1;
  _videoTime   = json['videoTime']  ?? 0;
  _videoUrl    = json['videoUrl']?.toString()   ?? "";
  _videoImage  = json['videoImage']?.toString() ?? "";
  _views       = json['views']      ?? 0;
  _channelName = json['channelName']?.toString() ?? "";
}

  String? _id;
  String? _videoId;
  String? _videoTitle;
  int? _videoType;
  int? _videoTime;
  String? _videoUrl;
  String? _videoImage;
  int? _views;
  String? _channelName;
  WatchHistory copyWith({
    String? id,
    String? videoId,
    String? videoTitle,
    int? videoType,
    int? videoTime,
    String? videoUrl,
    String? videoImage,
    int? views,
    String? channelName,
  }) =>
      WatchHistory(
        id: id ?? _id,
        videoId: videoId ?? _videoId,
        videoTitle: videoTitle ?? _videoTitle,
        videoType: videoType ?? _videoType,
        videoTime: videoTime ?? _videoTime,
        videoUrl: videoUrl ?? _videoUrl,
        videoImage: videoImage ?? _videoImage,
        views: views ?? _views,
        channelName: channelName ?? _channelName,
      );
  String? get id => _id;
  String? get videoId => _videoId;
  String? get videoTitle => _videoTitle;
  int? get videoType => _videoType;
  int? get videoTime => _videoTime;
  String? get videoUrl => _videoUrl;
  String? get videoImage => _videoImage;
  int? get views => _views;
  String? get channelName => _channelName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['videoId'] = _videoId;
    map['videoTitle'] = _videoTitle;
    map['videoType'] = _videoType;
    map['videoTime'] = _videoTime;
    map['videoUrl'] = _videoUrl;
    map['videoImage'] = _videoImage;
    map['views'] = _views;
    map['channelName'] = _channelName;
    return map;
  }
}
