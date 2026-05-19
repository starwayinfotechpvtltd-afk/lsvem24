import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/pages/profile_page/monetization_page/monetization_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class MonetizationApi {
  static Future<MonetizationModel?> callApi(String loginUserId) async {
    AppSettings.showLog("Get Monetization Api Calling...");

    final uri = Uri.parse("${Constant.baseURL + Constant.monetization}?userId=$loginUserId");

    final headers = {"key": Constant.secretKey};

    AppSettings.showLog("Get Monetization Api Url => $uri");

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        AppSettings.showLog("Get Monetization Response => ${response.body}");
        return MonetizationModel.fromJson(jsonResponse);
      } else {
        AppSettings.showLog("Get Monetization StateCode Error $response");
      }
    } catch (error) {
      AppSettings.showLog("Get Monetization Error => $error");
    }
    return null;
  }
}
