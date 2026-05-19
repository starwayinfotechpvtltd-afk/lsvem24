import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

import 'get_premium_plan_purchase_history_model.dart';

class GetPremiumPlanHistoryApi {
  static GetPremiumPlanPurchaseHistoryModel? historyModel;

  static Future<void> callApi(String loginUserId) async {
    AppSettings.showLog("Get Premium Plan Purchase History Api Calling...");

    final uri = Uri.parse("${Constant.baseURL + Constant.premiumPlanPurchaseHistory}?userId=$loginUserId");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        historyModel = GetPremiumPlanPurchaseHistoryModel.fromJson(jsonResponse);

        AppSettings.showLog("Get Premium Plan Purchase History Api Response => ${response.body}");
      } else {
        AppSettings.showLog("Get Premium Plan Purchase History Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Get Premium Plan Purchase History Api Error => $error");
    }
  }
}
