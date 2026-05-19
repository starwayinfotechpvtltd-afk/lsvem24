// import 'dart:convert';
//
// WithDrawHistoryModel withDrawHistoryModelFromJson(String str) => WithDrawHistoryModel.fromJson(json.decode(str));
// String withDrawHistoryModelToJson(WithDrawHistoryModel data) => json.encode(data.toJson());
//
// class WithDrawHistoryModel {
//   WithDrawHistoryModel({
//     bool? status,
//     String? message,
//     List<WithDrawRequests>? withDrawRequests,
//   }) {
//     _status = status;
//     _message = message;
//     _withDrawRequests = withDrawRequests;
//   }
//
//   WithDrawHistoryModel.fromJson(dynamic json) {
//     _status = json['status'];
//     _message = json['message'];
//     if (json['WithDrawRequests'] != null) {
//       _withDrawRequests = [];
//       json['WithDrawRequests'].forEach((v) {
//         _withDrawRequests?.add(WithDrawRequests.fromJson(v));
//       });
//     }
//   }
//   bool? _status;
//   String? _message;
//   List<WithDrawRequests>? _withDrawRequests;
//   WithDrawHistoryModel copyWith({
//     bool? status,
//     String? message,
//     List<WithDrawRequests>? withDrawRequests,
//   }) =>
//       WithDrawHistoryModel(
//         status: status ?? _status,
//         message: message ?? _message,
//         withDrawRequests: withDrawRequests ?? _withDrawRequests,
//       );
//   bool? get status => _status;
//   String? get message => _message;
//   List<WithDrawRequests>? get withDrawRequests => _withDrawRequests;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['status'] = _status;
//     map['message'] = _message;
//     if (_withDrawRequests != null) {
//       map['WithDrawRequests'] = _withDrawRequests?.map((v) => v.toJson()).toList();
//     }
//     return map;
//   }
// }
//
// WithDrawRequests withDrawRequestsFromJson(String str) => WithDrawRequests.fromJson(json.decode(str));
// String withDrawRequestsToJson(WithDrawRequests data) => json.encode(data.toJson());
//
// class WithDrawRequests {
//   WithDrawRequests({
//     String? id,
//     String? userId,
//     String? channelId,
//     String? channelName,
//     int? requestAmount,
//     int? totalWatchTime,
//     int? status,
//     String? paymentGateway,
//     List<String>? paymentDetails,
//     String? uniqueId,
//     String? requestDate,
//     String? paymentDate,
//     String? reason,
//     String? createdAt,
//     String? updatedAt,
//   }) {
//     _id = id;
//     _userId = userId;
//     _channelId = channelId;
//     _channelName = channelName;
//     _requestAmount = requestAmount;
//     _totalWatchTime = totalWatchTime;
//     _status = status;
//     _paymentGateway = paymentGateway;
//     _paymentDetails = paymentDetails;
//     _uniqueId = uniqueId;
//     _requestDate = requestDate;
//     _paymentDate = paymentDate;
//     _reason = reason;
//     _createdAt = createdAt;
//     _updatedAt = updatedAt;
//   }
//
//   WithDrawRequests.fromJson(dynamic json) {
//     _id = json['_id'];
//     _userId = json['userId'];
//     _channelId = json['channelId'];
//     _channelName = json['channelName'];
//     _requestAmount = json['requestAmount'];
//     _totalWatchTime = json['totalWatchTime'];
//     _status = json['status'];
//     _paymentGateway = json['paymentGateway'];
//     _paymentDetails = json['paymentDetails'] != null ? json['paymentDetails'].cast<String>() : [];
//     _uniqueId = json['uniqueId'];
//     _requestDate = json['requestDate'];
//     _paymentDate = json['paymentDate'];
//     _reason = json['reason'];
//     _createdAt = json['createdAt'];
//     _updatedAt = json['updatedAt'];
//   }
//   String? _id;
//   String? _userId;
//   String? _channelId;
//   String? _channelName;
//   int? _requestAmount;
//   int? _totalWatchTime;
//   int? _status;
//   String? _paymentGateway;
//   List<String>? _paymentDetails;
//   String? _uniqueId;
//   String? _requestDate;
//   String? _paymentDate;
//   String? _reason;
//   String? _createdAt;
//   String? _updatedAt;
//   WithDrawRequests copyWith({
//     String? id,
//     String? userId,
//     String? channelId,
//     String? channelName,
//     int? requestAmount,
//     int? totalWatchTime,
//     int? status,
//     String? paymentGateway,
//     List<String>? paymentDetails,
//     String? uniqueId,
//     String? requestDate,
//     String? paymentDate,
//     String? reason,
//     String? createdAt,
//     String? updatedAt,
//   }) =>
//       WithDrawRequests(
//         id: id ?? _id,
//         userId: userId ?? _userId,
//         channelId: channelId ?? _channelId,
//         channelName: channelName ?? _channelName,
//         requestAmount: requestAmount ?? _requestAmount,
//         totalWatchTime: totalWatchTime ?? _totalWatchTime,
//         status: status ?? _status,
//         paymentGateway: paymentGateway ?? _paymentGateway,
//         paymentDetails: paymentDetails ?? _paymentDetails,
//         uniqueId: uniqueId ?? _uniqueId,
//         requestDate: requestDate ?? _requestDate,
//         paymentDate: paymentDate ?? _paymentDate,
//         reason: reason ?? _reason,
//         createdAt: createdAt ?? _createdAt,
//         updatedAt: updatedAt ?? _updatedAt,
//       );
//   String? get id => _id;
//   String? get userId => _userId;
//   String? get channelId => _channelId;
//   String? get channelName => _channelName;
//   int? get requestAmount => _requestAmount;
//   int? get totalWatchTime => _totalWatchTime;
//   int? get status => _status;
//   String? get paymentGateway => _paymentGateway;
//   List<String>? get paymentDetails => _paymentDetails;
//   String? get uniqueId => _uniqueId;
//   String? get requestDate => _requestDate;
//   String? get paymentDate => _paymentDate;
//   String? get reason => _reason;
//   String? get createdAt => _createdAt;
//   String? get updatedAt => _updatedAt;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['_id'] = _id;
//     map['userId'] = _userId;
//     map['channelId'] = _channelId;
//     map['channelName'] = _channelName;
//     map['requestAmount'] = _requestAmount;
//     map['totalWatchTime'] = _totalWatchTime;
//     map['status'] = _status;
//     map['paymentGateway'] = _paymentGateway;
//     map['paymentDetails'] = _paymentDetails;
//     map['uniqueId'] = _uniqueId;
//     map['requestDate'] = _requestDate;
//     map['paymentDate'] = _paymentDate;
//     map['reason'] = _reason;
//     map['createdAt'] = _createdAt;
//     map['updatedAt'] = _updatedAt;
//     return map;
//   }
// }
