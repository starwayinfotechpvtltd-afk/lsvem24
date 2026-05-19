import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/pages/nav_home_page/controller/nav_home_controller.dart';
import 'package:metube/pages/splash_screen_page/view/splash_screen_view.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/pages/main_home_page/main_home_view.dart';

class CreatePremiumPlanApi {
  static final homeController = Get.find<NavHomeController>();
  static Future<void> callApi(String loginUserId, String premiumPlanId, String paymentType) async {
    AppSettings.showLog("Create PremiumPlan Api Calling...");

    final uri = Uri.parse(Constant.baseURL + Constant.purchasePremiumPlan);

    final headers = {"key": Constant.secretKey, "Content-Type": "application/json"};
    AppSettings.showLog(" Create Premium Plan Api uri ::$uri");
    final body = json.encode({
      "userId": loginUserId,
      "premiumPlanId": premiumPlanId,
      "paymentGateway": paymentType,
    });
    AppSettings.showLog(" Create Premium Plan Api body ::$body");
    try {
      final response = await http.post(uri, headers: headers, body: body);
      AppSettings.showLog(" Create Premium Plan Api response status code ::${response.statusCode}");
      if (response.statusCode == 200) {
        AppSettings.showLog("Create PremiumPlan Api Response => ${response.body}");

        final jsonResponse = jsonDecode(response.body);
    
        if (jsonResponse["status"] == true) {
          CustomToast.show("Payment Success");

          await GetProfileApi.callApi(Database.loginUserId!);
          Get.offAll(const MainHomePageView());
        }
      } else {
        AppSettings.showLog("Create PremiumPlan Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Create PremiumPlan Api Error => $error");
    }
  }
}
