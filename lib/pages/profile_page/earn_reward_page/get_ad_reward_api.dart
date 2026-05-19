import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/pages/profile_page/earn_reward_page/get_ad_reward_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class GetAdRewardApi {
  static Future<GetAdRewardModel?> callApi({required String userId}) async {
    AppSettings.showLog("Get Ad Reward Api Calling...");

    final uri = Uri.parse("${Constant.baseURL}${Constant.adRewardCoin}?userId=$userId");

    AppSettings.showLog("Get Ad Reward Api Url => $uri");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        AppSettings.showLog("Get Ad Reward Api Response => ${response.body}");

        return GetAdRewardModel.fromJson(jsonResponse);
      } else {
        AppSettings.showLog("Get Ad Reward Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Get Ad Reward Api Error => $error");
    }
    return null;
  }
}
