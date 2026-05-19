import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

import 'admin_settings_model.dart';

class AdminSettingsApi {
  static AdminSettingsModel? adminSettingsModel;
  
  static Future<bool> callApi() async {
    try {
      AppSettings.showLog("📤 Get Admin Settings Api Calling...");

      final uri = Uri.parse(Constant.baseURL + Constant.adminSetting);
      AppSettings.showLog("📍 Get Admin Settings Api Url => $uri");

      final headers = {"key": Constant.secretKey};

      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      AppSettings.showLog("📥 Response Status: ${response.statusCode}");
      AppSettings.showLog("📥 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // ✅ Save to static variable
        adminSettingsModel = AdminSettingsModel.fromJson(jsonResponse);

        AppSettings.showLog("✅ Admin Settings loaded successfully");
        AppSettings.showLog("  - Setting exists: ${adminSettingsModel?.setting != null}");
        AppSettings.showLog(
            "  - Payment switches: razor=${adminSettingsModel?.setting?.razorPaySwitch}, "
            "google=${adminSettingsModel?.setting?.googlePlaySwitch}, "
            "stripe=${adminSettingsModel?.setting?.stripeSwitch}, "
            "flutter=${adminSettingsModel?.setting?.flutterWaveSwitch}");

        return adminSettingsModel?.setting != null;
      } else {
        AppSettings.showLog("❌ Get Admin Settings Api StateCode Error: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      AppSettings.showLog("❌ Get Admin Settings Api Error => $error");
      return false;
    }
  }
}
