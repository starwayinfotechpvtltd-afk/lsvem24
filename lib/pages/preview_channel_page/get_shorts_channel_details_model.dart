// import 'dart:convert';
//
// GetShortsChannelDetailsModel getShortsChannelDetailsModelFromJson(String str) =>
//     GetShortsChannelDetailsModel.fromJson(json.decode(str));
// String getShortsChannelDetailsModelToJson(GetShortsChannelDetailsModel data) => json.encode(data.toJson());
//
// class GetShortsChannelDetailsModel {
//   GetShortsChannelDetailsModel({
//     bool? status,
//     String? message,
//     int? totalShortsOfChannel,
//     int? totalSubscribers,
//     bool? isSubscribed,
//     String? channelName,
//     String? channelImage,
//     List<DetailsOfShorts>? detailsOfShorts,
//   }) {
//     _status = status;
//     _message = message;
//     _totalShortsOfChannel = totalShortsOfChannel;
//     _totalSubscribers = totalSubscribers;
//     _isSubscribed = isSubscribed;
//     _channelName = channelName;
//     _channelImage = channelImage;
//     _detailsOfShorts = detailsOfShorts;
//   }
//
//   GetShortsChannelDetailsModel.fromJson(dynamic json) {
//     _status = json['status'];
//     _message = json['message'];
//     _totalShortsOfChannel = json['totalShortsOfChannel'];
//     _totalSubscribers = json['totalSubscribers'];
//     _isSubscribed = json['isSubscribed'];
//     _channelName = json['channelName'];
//     _channelImage = json['channelImage'];
//     if (json['detailsOfShorts'] != null) {
//       _detailsOfShorts = [];
//       json['detailsOfShorts'].forEach((v) {
//         _detailsOfShorts?.add(DetailsOfShorts.fromJson(v));
//       });
//     }
//   }
//   bool? _status;
//   String? _message;
//   int? _totalShortsOfChannel;
//   int? _totalSubscribers;
//   bool? _isSubscribed;
//   String? _channelName;
//   String? _channelImage;
//   List<DetailsOfShorts>? _detailsOfShorts;
//   GetShortsChannelDetailsModel copyWith({
//     bool? status,
//     String? message,
//     int? totalShortsOfChannel,
//     int? totalSubscribers,
//     bool? isSubscribed,
//     String? channelName,
//     String? channelImage,
//     List<DetailsOfShorts>? detailsOfShorts,
//   }) =>
//       GetShortsChannelDetailsModel(
//         status: status ?? _status,
//         message: message ?? _message,
//         totalShortsOfChannel: totalShortsOfChannel ?? _totalShortsOfChannel,
//         totalSubscribers: totalSubscribers ?? _totalSubscribers,
//         isSubscribed: isSubscribed ?? _isSubscribed,
//         channelName: channelName ?? _channelName,
//         channelImage: channelImage ?? _channelImage,
//         detailsOfShorts: detailsOfShorts ?? _detailsOfShorts,
//       );
//   bool? get status => _status;
//   String? get message => _message;
//   int? get totalShortsOfChannel => _totalShortsOfChannel;
//   int? get totalSubscribers => _totalSubscribers;
//   bool? get isSubscribed => _isSubscribed;
//   String? get channelName => _channelName;
//   String? get channelImage => _channelImage;
//   List<DetailsOfShorts>? get detailsOfShorts => _detailsOfShorts;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['status'] = _status;
//     map['message'] = _message;
//     map['totalShortsOfChannel'] = _totalShortsOfChannel;
//     map['totalSubscribers'] = _totalSubscribers;
//     map['isSubscribed'] = _isSubscribed;
//     map['channelName'] = _channelName;
//     map['channelImage'] = _channelImage;
//     if (_detailsOfShorts != null) {
//       map['detailsOfShorts'] = _detailsOfShorts?.map((v) => v.toJson()).toList();
//     }
//     return map;
//   }
// }
//
// DetailsOfShorts detailsOfShortsFromJson(String str) => DetailsOfShorts.fromJson(json.decode(str));
// String detailsOfShortsToJson(DetailsOfShorts data) => json.encode(data.toJson());
//
// class DetailsOfShorts {
//   DetailsOfShorts({
//     String? id,
//     String? title,
//     int? videoType,
//     int? videoTime,
//     String? videoUrl,
//     String? videoImage,
//     String? channelId,
//     String? createdAt,
//     int? views,
//   }) {
//     _id = id;
//     _title = title;
//     _videoType = videoType;
//     _videoTime = videoTime;
//     _videoUrl = videoUrl;
//     _videoImage = videoImage;
//     _channelId = channelId;
//     _createdAt = createdAt;
//     _views = views;
//   }
//
//   DetailsOfShorts.fromJson(dynamic json) {
//     _id = json['_id'];
//     _title = json['title'];
//     _videoType = json['videoType'];
//     _videoTime = json['videoTime'];
//     _videoUrl = json['videoUrl'];
//     _videoImage = json['videoImage'];
//     _channelId = json['channelId'];
//     _createdAt = json['createdAt'];
//     _views = json['views'];
//   }
//   String? _id;
//   String? _title;
//   int? _videoType;
//   int? _videoTime;
//   String? _videoUrl;
//   String? _videoImage;
//   String? _channelId;
//   String? _createdAt;
//   int? _views;
//   DetailsOfShorts copyWith({
//     String? id,
//     String? title,
//     int? videoType,
//     int? videoTime,
//     String? videoUrl,
//     String? videoImage,
//     String? channelId,
//     String? createdAt,
//     int? views,
//   }) =>
//       DetailsOfShorts(
//         id: id ?? _id,
//         title: title ?? _title,
//         videoType: videoType ?? _videoType,
//         videoTime: videoTime ?? _videoTime,
//         videoUrl: videoUrl ?? _videoUrl,
//         videoImage: videoImage ?? _videoImage,
//         channelId: channelId ?? _channelId,
//         createdAt: createdAt ?? _createdAt,
//         views: views ?? _views,
//       );
//   String? get id => _id;
//   String? get title => _title;
//   int? get videoType => _videoType;
//   int? get videoTime => _videoTime;
//   String? get videoUrl => _videoUrl;
//   String? get videoImage => _videoImage;
//   String? get channelId => _channelId;
//   String? get createdAt => _createdAt;
//   int? get views => _views;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = _id;
//     map['title'] = _title;
//     map['videoType'] = _videoType;
//     map['videoTime'] = _videoTime;
//     map['videoUrl'] = _videoUrl;
//     map['videoImage'] = _videoImage;
//     map['channelId'] = _channelId;
//     map['createdAt'] = _createdAt;
//     map['views'] = _views;
//     return map;
//   }
// }
