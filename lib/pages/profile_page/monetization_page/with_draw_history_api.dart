// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
// import 'package:metube/pages/profile_page/monetization_page/with_draw_history_model.dart';
// import 'package:metube/utils/constant/app_constant.dart';
// import 'package:metube/utils/settings/app_settings.dart';
//
// class WithDrawHistoryApi {
//   static Future<WithDrawHistoryModel?> callApi({required String loginUserId, required String startDate, required String endDate}) async {
//     AppSettings.showLog("Get With Draw History Api Calling...");
//
//     final uri = Uri.parse("${Constant.baseURL + Constant.withDrawRequestHistory}?userId=$loginUserId&startDate=$startDate&endDate=$endDate");
//
//     final headers = {"key": Constant.secretKey};
//
//     try {
//       final response = await http.get(uri, headers: headers);
//
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//
//         AppSettings.showLog("Get With Draw History Api Response => ${response.body}");
//         return WithDrawHistoryModel.fromJson(jsonResponse);
//       } else {
//         AppSettings.showLog("Get With Draw History Api StateCode Error");
//       }
//     } catch (error) {
//       AppSettings.showLog("Get With Draw History Api Error => $error");
//     }
//     return null;
//   }
// }
