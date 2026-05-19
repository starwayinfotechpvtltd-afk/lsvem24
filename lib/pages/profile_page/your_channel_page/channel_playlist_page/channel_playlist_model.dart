import 'dart:convert';
ChannelPlaylistModel channelPlaylistModelFromJson(String str) => ChannelPlaylistModel.fromJson(json.decode(str));
String channelPlaylistModelToJson(ChannelPlaylistModel data) => json.encode(data.toJson());
class ChannelPlaylistModel {
  ChannelPlaylistModel({
      bool? status, 
      String? message, 
      List<PlayListsOfChannel>? playListsOfChannel,}){
    _status = status;
    _message = message;
    _playListsOfChannel = playListsOfChannel;
}

  ChannelPlaylistModel.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['playListsOfChannel'] != null) {
      _playListsOfChannel = [];
      json['playListsOfChannel'].forEach((v) {
        _playListsOfChannel?.add(PlayListsOfChannel.fromJson(v));
      });
    }
  }
  bool? _status;
  String? _message;
  List<PlayListsOfChannel>? _playListsOfChannel;
ChannelPlaylistModel copyWith({  bool? status,
  String? message,
  List<PlayListsOfChannel>? playListsOfChannel,
}) => ChannelPlaylistModel(  status: status ?? _status,
  message: message ?? _message,
  playListsOfChannel: playListsOfChannel ?? _playListsOfChannel,
);
  bool? get status => _status;
  String? get message => _message;
  List<PlayListsOfChannel>? get playListsOfChannel => _playListsOfChannel;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_playListsOfChannel != null) {
      map['playListsOfChannel'] = _playListsOfChannel?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

PlayListsOfChannel playListsOfChannelFromJson(String str) => PlayListsOfChannel.fromJson(json.decode(str));
String playListsOfChannelToJson(PlayListsOfChannel data) => json.encode(data.toJson());
class PlayListsOfChannel {
  PlayListsOfChannel({
      String? id, 
      String? channelId, 
      String? userId, 
      String? playListName, 
      int? playListType, 
      String? channelName, 
      List<Videos>? videos, 
      int? totalVideo,}){
    _id = id;
    _channelId = channelId;
    _userId = userId;
    _playListName = playListName;
    _playListType = playListType;
    _channelName = channelName;
    _videos = videos;
    _totalVideo = totalVideo;
}

  PlayListsOfChannel.fromJson(dynamic json) {
    _id = json['_id'];
    _channelId = json['channelId'];
    _userId = json['userId'];
    _playListName = json['playListName'];
    _playListType = json['playListType'];
    _channelName = json['channelName'];
    if (json['videos'] != null) {
      _videos = [];
      json['videos'].forEach((v) {
        _videos?.add(Videos.fromJson(v));
      });
    }
    _totalVideo = json['totalVideo'];
  }
  String? _id;
  String? _channelId;
  String? _userId;
  String? _playListName;
  int? _playListType;
  String? _channelName;
  List<Videos>? _videos;
  int? _totalVideo;
PlayListsOfChannel copyWith({  String? id,
  String? channelId,
  String? userId,
  String? playListName,
  int? playListType,
  String? channelName,
  List<Videos>? videos,
  int? totalVideo,
}) => PlayListsOfChannel(  id: id ?? _id,
  channelId: channelId ?? _channelId,
  userId: userId ?? _userId,
  playListName: playListName ?? _playListName,
  playListType: playListType ?? _playListType,
  channelName: channelName ?? _channelName,
  videos: videos ?? _videos,
  totalVideo: totalVideo ?? _totalVideo,
);
  String? get id => _id;
  String? get channelId => _channelId;
  String? get userId => _userId;
  String? get playListName => _playListName;
  int? get playListType => _playListType;
  String? get channelName => _channelName;
  List<Videos>? get videos => _videos;
  int? get totalVideo => _totalVideo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = _id;
    map['channelId'] = _channelId;
    map['userId'] = _userId;
    map['playListName'] = _playListName;
    map['playListType'] = _playListType;
    map['channelName'] = _channelName;
    if (_videos != null) {
      map['videos'] = _videos?.map((v) => v.toJson()).toList();
    }
    map['totalVideo'] = _totalVideo;
    return map;
  }

}

Videos videosFromJson(String str) => Videos.fromJson(json.decode(str));
String videosToJson(Videos data) => json.encode(data.toJson());
class Videos {
  Videos({
      String? videoId, 
      String? videoName, 
      String? videoUrl, 
      String? videoImage, 
      int? videoTime,}){
    _videoId = videoId;
    _videoName = videoName;
    _videoUrl = videoUrl;
    _videoImage = videoImage;
    _videoTime = videoTime;
}

  Videos.fromJson(dynamic json) {
    _videoId = json['videoId'];
    _videoName = json['videoName'];
    _videoUrl = json['videoUrl'];
    _videoImage = json['videoImage'];
    _videoTime = json['videoTime'];
  }
  String? _videoId;
  String? _videoName;
  String? _videoUrl;
  String? _videoImage;
  int? _videoTime;
Videos copyWith({  String? videoId,
  String? videoName,
  String? videoUrl,
  String? videoImage,
  int? videoTime,
}) => Videos(  videoId: videoId ?? _videoId,
  videoName: videoName ?? _videoName,
  videoUrl: videoUrl ?? _videoUrl,
  videoImage: videoImage ?? _videoImage,
  videoTime: videoTime ?? _videoTime,
);
  String? get videoId => _videoId;
  String? get videoName => _videoName;
  String? get videoUrl => _videoUrl;
  String? get videoImage => _videoImage;
  int? get videoTime => _videoTime;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['videoId'] = _videoId;
    map['videoName'] = _videoName;
    map['videoUrl'] = _videoUrl;
    map['videoImage'] = _videoImage;
    map['videoTime'] = _videoTime;
    return map;
  }

}