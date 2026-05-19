// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
// import 'package:metube/database/database.dart';
// import 'package:metube/pages/nav_library_page/history_page/get_watch_history_model.dart';
// import 'package:metube/utils/constant/app_constant.dart';
// import 'package:metube/utils/settings/app_settings.dart';
//
// class GetWatchHistoryApiClass {
//   static GetWatchHistoryModel? _getWatchHistoryModel;
//
//   static Future<List<WatchHistory>?> callApi() async {
//     AppSettings.showLog("Get Watch History Video Api Calling...");
//
//     final uri = Uri.parse("${Constant.baseURL + Constant.watchHistory}?userId=${Database.loginUserId}");
//
//     final headers = {"key": Constant.secretKey};
//
//     try {
//       final response = await http.get(uri, headers: headers);
//
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//
//         _getWatchHistoryModel = GetWatchHistoryModel.fromJson(jsonResponse);
//
//         AppSettings.showLog("Get Watch History Video Api Response => ${response.body}");
//
//         return _getWatchHistoryModel?.watchHistory;
//       } else {
//         AppSettings.showLog("Get Watch History Video Api StateCode Error");
//       }
//     } catch (error) {
//       AppSettings.showLog("Get Watch History Video Api Error => $error");
//     }
//     return null;
//   }
// }
