import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class UpdateRazorpayPaymentFailedApi {
  static Future<void> callApi({
    required String userId,
    required String razorpayOrderId,
    String? reason,
  }) async {
    final uri = Uri.parse(
      '${Constant.baseURL}${Constant.razorpayPaymentFailed}',
    );
    final headers = {
      'key': Constant.secretKey,
      'Content-Type': 'application/json',
    };

    try {
      await http.post(
        uri,
        headers: headers,
        body: json.encode({
          'userId': userId,
          'razorpayOrderId': razorpayOrderId,
          if (reason != null) 'reason': reason,
        }),
      );
    } catch (e) {
      AppSettings.showLog('Update Razorpay Payment Failed Error => $e');
    }
  }
}
