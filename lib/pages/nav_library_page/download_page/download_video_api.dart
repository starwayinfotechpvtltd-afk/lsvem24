// import 'package:http/http.dart' as http;
// import 'package:metube/utils/constant/app_constant.dart';
// import 'package:metube/utils/settings/app_settings.dart';
//
// class DownloadVideoApi {
//   static Future<void> callApi(String loginUserId, String videoId) async {
//     AppSettings.showLog("Download Video Api Calling...");
//
//     final uri = Uri.parse("${Constant.baseURL + Constant.downloadVideo}?userId=$loginUserId&videoId=$videoId");
//
//     final headers = {"key": Constant.secretKey};
//
//     try {
//       final response = await http.post(uri, headers: headers);
//
//       if (response.statusCode == 200) {
//         AppSettings.showLog("Download Video Api Response => ${response.body}");
//       } else {
//         AppSettings.showLog("Download Video Api StateCode Error");
//       }
//     } catch (error) {
//       AppSettings.showLog("Download Video Api Error => $error");
//     }
//   }
// }
