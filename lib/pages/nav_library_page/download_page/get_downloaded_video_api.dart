// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
// import 'package:metube/database/database.dart';
// import 'package:metube/pages/nav_library_page/download_page/get_downloaded_video_model.dart';
// import 'package:metube/utils/constant/app_constant.dart';
// import 'package:metube/utils/settings/app_settings.dart';
//
// class GetDownloadedVideoApiClass {
//   static GetDownloadedVideoModel? _getDownloadedVideoModel;
//
//   static Future<List<GetdownloadVideoHistory>?> callApi() async {
//     AppSettings.showLog("Get Downloaded Video Api Calling...");
//
//     final uri = Uri.parse("${Constant.baseURL + Constant.downloadedVideo}?userId=${Database.loginUserId}");
//
//     final headers = {"key": Constant.secretKey};
//
//     try {
//       final response = await http.get(uri, headers: headers);
//
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//
//         _getDownloadedVideoModel = GetDownloadedVideoModel.fromJson(jsonResponse);
//
//         AppSettings.showLog("Get Downloaded Video Api Response => ${response.body}");
//
//         return _getDownloadedVideoModel?.getdownloadVideoHistory;
//       } else {
//         AppSettings.showLog("Get Downloaded Video Api StateCode Error");
//       }
//     } catch (error) {
//       AppSettings.showLog("Get Downloaded Video Api Error => $error");
//     }
//     return null;
//   }
// }
