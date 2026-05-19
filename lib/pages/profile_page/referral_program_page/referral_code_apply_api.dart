import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:metube/pages/profile_page/referral_program_page/referral_code_apply_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class ReferralCodeApplyApi {
  static ReferralCodeApplyModel? referralCodeApplyModel;
  static Future<void> callApi({required String loginUserId, required String referralCode}) async {
    AppSettings.showLog("Referral Code Apply Api Calling...");

    try {
      final headers = {"key": Constant.secretKey, "Content-Type": 'application/json'};

      final uri = Uri.parse('${Constant.baseURL + Constant.referralCodeApply}?userId=$loginUserId&referralCode=$referralCode');

      AppSettings.showLog("Referral Code Apply Api Uri => $uri");

      final response = await http.patch(uri, headers: headers);

      final jsonResponse = jsonDecode(response.body);

      AppSettings.showLog("Referral Code Apply Api Response => $jsonResponse");

      referralCodeApplyModel = ReferralCodeApplyModel.fromJson(jsonResponse);
    } catch (e) {
      AppSettings.showLog("Referral Code Apply Api Error => $e");
    }
  }
}
