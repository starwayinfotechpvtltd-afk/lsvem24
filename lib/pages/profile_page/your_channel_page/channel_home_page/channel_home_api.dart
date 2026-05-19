import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/pages/profile_page/your_channel_page/channel_home_page/channel_home_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class ChannelHomeApi {
  static int startPagination = 0;
  static int limitPagination = 20;

  static Future<ChannelHomeModel?> callApi(String userId, String channelId) async {
    AppSettings.showLog("Channel Home Api Calling...$userId **** $channelId");

    startPagination += 1;
    AppSettings.showLog("Pagination Page Index => $startPagination");

    final uri = Uri.parse("${Constant.baseURL + Constant.channelHome}?channelId=$channelId&userId=$userId&start=$startPagination&limit=$limitPagination");

    AppSettings.showLog("Channel Home Api => $uri");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        AppSettings.showLog("Channel Home Api Response => ${response.body}");

        return ChannelHomeModel.fromJson(jsonResponse);
      } else {
        AppSettings.showLog("Channel Home Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Channel Home Api Error => $error");
    }
    return null;
  }
}
