import 'dart:convert';

GetDownloadedVideoModel getDownloadedVideoModelFromJson(String str) =>
    GetDownloadedVideoModel.fromJson(json.decode(str));

String getDownloadedVideoModelToJson(GetDownloadedVideoModel data) => json.encode(data.toJson());

class GetDownloadedVideoModel {
  GetDownloadedVideoModel({
    bool? status,
    String? message,
    List<GetdownloadVideoHistory>? getdownloadVideoHistory,
  }) {
    _status = status;
    _message = message;
    _getdownloadVideoHistory = getdownloadVideoHistory;
  }

  GetDownloadedVideoModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['getdownloadVideoHistory'] != null) {
      _getdownloadVideoHistory = [];
      json['getdownloadVideoHistory'].forEach((v) {
        _getdownloadVideoHistory?.add(GetdownloadVideoHistory.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<GetdownloadVideoHistory>? _getdownloadVideoHistory;

  GetDownloadedVideoModel copyWith({
    bool? status,
    String? message,
    List<GetdownloadVideoHistory>? getdownloadVideoHistory,
  }) =>
      GetDownloadedVideoModel(
        status: status ?? _status,
        message: message ?? _message,
        getdownloadVideoHistory: getdownloadVideoHistory ?? _getdownloadVideoHistory,
      );

  bool? get status => _status;

  String? get message => _message;

  List<GetdownloadVideoHistory>? get getdownloadVideoHistory => _getdownloadVideoHistory;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_getdownloadVideoHistory != null) {
      map['getdownloadVideoHistory'] = _getdownloadVideoHistory?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

GetdownloadVideoHistory getdownloadVideoHistoryFromJson(String str) =>
    GetdownloadVideoHistory.fromJson(json.decode(str));

String getdownloadVideoHistoryToJson(GetdownloadVideoHistory data) => json.encode(data.toJson());

class GetdownloadVideoHistory {
  GetdownloadVideoHistory({
    String? id,
    String? videoId,
    String? videoTitle,
    int? videoType,
    int? videoTime,
    String? videoUrl,
    String? videoImage,
    int? views,
    String? channelName,
    String? time,
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
    _time = time;
  }

  GetdownloadVideoHistory.fromJson(dynamic json) {
    _id = json['_id'];
    _videoId = json['videoId'];
    _videoTitle = json['videoTitle'];
    _videoType = json['videoType'];
    _videoTime = json['videoTime'];
    _videoUrl = json['videoUrl'];
    _videoImage = json['videoImage'];
    _views = json['views'];
    _channelName = json['channelName'];
    _time = json['time'];
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
  String? _time;

  GetdownloadVideoHistory copyWith({
    String? id,
    String? videoId,
    String? videoTitle,
    int? videoType,
    int? videoTime,
    String? videoUrl,
    String? videoImage,
    int? views,
    String? channelName,
    String? time,
  }) =>
      GetdownloadVideoHistory(
        id: id ?? _id,
        videoId: videoId ?? _videoId,
        videoTitle: videoTitle ?? _videoTitle,
        videoType: videoType ?? _videoType,
        videoTime: videoTime ?? _videoTime,
        videoUrl: videoUrl ?? _videoUrl,
        videoImage: videoImage ?? _videoImage,
        views: views ?? _views,
        channelName: channelName ?? _channelName,
        time: time ?? _time,
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

  String? get time => _time;

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
    map['time'] = _time;
    return map;
  }
}
