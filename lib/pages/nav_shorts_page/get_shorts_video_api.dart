import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/pages/nav_shorts_page/get_shorts_video_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class GetShortsVideoApi {
  static GetShortsVideoModel? getShortsVideoModel;
  static int startPagination = 0;
  static int limitPagination = 30;

  static Future<GetShortsVideoModel?> callApi(String loginUserId) async {
    AppSettings.showLog("Get Shorts Video Api Calling... ");

    final nextPage = startPagination + 1;

    AppSettings.showLog("Get Shorts Pagination Page => $startPagination");

    final uri = Uri.parse("${Constant.baseURL + Constant.getShortsVideo}?start=$nextPage&limit=$limitPagination");

    try {
    final response = await http
        .get(
          uri,
          headers: {
            "key": Constant.secretKey,
          },
        )
        .timeout(
          const Duration(seconds: 20),
        );

    if (response.statusCode == 200) {
      startPagination = nextPage;

      return GetShortsVideoModel.fromJson(
        jsonDecode(response.body),
      );
    }
  } catch (e) {
    AppSettings.showLog(
      "Shorts Error => $e",
    );
  }
    return null;
  }
}
