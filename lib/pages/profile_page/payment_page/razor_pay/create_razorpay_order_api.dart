import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class CreateRazorpayOrderApi {
  static Future<RazorpayOrderResult?> callApi({
    required String userId,
    required String purpose,
    String? premiumPlanId,
    String? coinPlanId,
  }) async {
    final uri = Uri.parse('${Constant.baseURL}client/payment/razorpay/create-order');
    final headers = {
      'key': Constant.secretKey,
      'Content-Type': 'application/json',
    };

    final body = <String, dynamic>{
      'userId': userId,
      'purpose': purpose,
    };
    if (premiumPlanId != null) body['premiumPlanId'] = premiumPlanId;
    if (coinPlanId != null) body['coinPlanId'] = coinPlanId;

    try {
      AppSettings.showLog('Create Razorpay Order Api Calling...');
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode != 200) return null;

      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      if (jsonResponse['status'] != true) {
        AppSettings.showLog(
            'Create Razorpay Order failed: ${jsonResponse['message']}');
        return null;
      }

      return RazorpayOrderResult(
        orderId: jsonResponse['orderId']?.toString() ?? '',
        amount: jsonResponse['amount'] is int
            ? jsonResponse['amount'] as int
            : int.tryParse(jsonResponse['amount']?.toString() ?? '') ?? 0,
        currency: jsonResponse['currency']?.toString() ?? 'INR',
        keyId: jsonResponse['keyId']?.toString(),
        purpose: jsonResponse['purpose']?.toString() ?? purpose,
      );
    } catch (e) {
      AppSettings.showLog('Create Razorpay Order Error => $e');
      return null;
    }
  }
}

class RazorpayOrderResult {
  RazorpayOrderResult({
    required this.orderId,
    required this.amount,
    required this.currency,
    this.keyId,
    required this.purpose,
  });

  final String orderId;
  final int amount;
  final String currency;
  final String? keyId;
  final String purpose;
}
