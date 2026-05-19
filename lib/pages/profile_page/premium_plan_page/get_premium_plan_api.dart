import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/pages/profile_page/premium_plan_page/get_premium_plan_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class GetPremiumPlanApi {
  static GetPremiumPlanModel? _getPremiumPlanModel;

  static Future<List<PremiumPlan>?> callApi() async {
    AppSettings.showLog("Get Premium Plan Api Calling...");

    final uri = Uri.parse(Constant.baseURL + Constant.premiumPlan);

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        _getPremiumPlanModel = GetPremiumPlanModel.fromJson(jsonResponse);

        AppSettings.showLog("Get Premium Plan Api Response => ${response.body}");

        return _getPremiumPlanModel?.premiumPlan;
      } else {
        AppSettings.showLog("Get Premium Plan Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Get Premium Plan Api Video Error => $error");
    }
    return null;
  }
}
