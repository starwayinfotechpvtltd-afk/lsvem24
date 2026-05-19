import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class GetRazorpayConfigApi {
  static String? keyId;
  static String currency = 'INR';
  static bool enabled = false;

  static Future<bool> callApi({bool forceRefresh = false}) async {
    if (!forceRefresh && keyId != null && keyId!.isNotEmpty) {
      return true;
    }

    final uri = Uri.parse('${Constant.baseURL}${Constant.getRazorpayConfig}');
    final headers = {'key': Constant.secretKey};

    try {
      AppSettings.showLog('Get Razorpay Config Api Calling...');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode != 200) {
        AppSettings.showLog(
            'Get Razorpay Config failed: ${response.statusCode}');
        return false;
      }

      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      if (jsonResponse['status'] != true) {
        AppSettings.showLog(
            'Get Razorpay Config: ${jsonResponse['message']}');
        return false;
      }

      keyId = jsonResponse['keyId']?.toString();
      currency = jsonResponse['currency']?.toString() ?? 'INR';
      enabled = jsonResponse['enabled'] == true;

      AppSettings.showLog(
          'Razorpay config loaded — keyId: ${keyId != null ? '${keyId!.substring(0, 8)}...' : 'null'}, currency: $currency');

      return keyId != null && keyId!.isNotEmpty;
    } catch (e) {
      AppSettings.showLog('Get Razorpay Config Error => $e');
      return false;
    }
  }

  static void clearCache() {
    keyId = null;
    currency = 'INR';
    enabled = false;
  }
}
