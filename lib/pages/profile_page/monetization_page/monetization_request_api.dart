import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/pages/profile_page/monetization_page/monetization_request_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class MonetizationRequestApi {
  static Future<MonetizationRequestModel?> callApi(String loginUserId) async {
    AppSettings.showLog("Monetization Request Api Calling...");

    final uri = Uri.parse("${Constant.baseURL + Constant.monetizationRequest}?userId=$loginUserId");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        AppSettings.showLog("Monetization Request Api Response => ${response.body}");
        return MonetizationRequestModel.fromJson(jsonResponse);
      } else {
        AppSettings.showLog("Monetization Request Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Monetization Request Api Error => $error");
    }
    return null;
  }
}
