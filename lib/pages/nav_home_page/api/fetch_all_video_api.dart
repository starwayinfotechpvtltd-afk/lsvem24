import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/pages/nav_home_page/model/fetch_all_video_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class FetchAllVideoApi {
  static int startPagination = 0;
  static int limitPagination = 20;

  static Future<FetchAllVideoModel?> callApi(String loginUserId) async {
    AppSettings.showLog("Fetch All Video Api Calling...");

    startPagination += 1;

    final uri = Uri.parse("${Constant.baseURL + Constant.homeVideo}?start=$startPagination&type=all&limit=$limitPagination");

    AppSettings.showLog("Uri => $uri");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        AppSettings.showLog("Fetch All Video Api Response => ${response.body}");
        return FetchAllVideoModel.fromJson(jsonResponse);
      } else {
        AppSettings.showLog("Fetch All Video Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Fetch All Video Api Error => $error");
    }
    return null;
  }
}
