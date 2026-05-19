import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class VerifyRazorpayPaymentApi {
  static Future<VerifyRazorpayPaymentResult?> callApi({
    required String userId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final uri = Uri.parse('${Constant.baseURL}client/payment/razorpay/verify');
    final headers = {
      'key': Constant.secretKey,
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'userId': userId,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
    });

    try {
      AppSettings.showLog('Verify Razorpay Payment Api Calling...');
      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      );

      AppSettings.showLog('Verify Razorpay response: ${response.body}');

      if (response.statusCode != 200) return null;

      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      return VerifyRazorpayPaymentResult(
        status: jsonResponse['status'] == true,
        message: jsonResponse['message']?.toString() ?? '',
        paymentStatus: jsonResponse['paymentStatus']?.toString(),
        purpose: jsonResponse['purpose']?.toString(),
      );
    } catch (e) {
      AppSettings.showLog('Verify Razorpay Payment Error => $e');
      return null;
    }
  }
}

class VerifyRazorpayPaymentResult {
  VerifyRazorpayPaymentResult({
    required this.status,
    required this.message,
    this.paymentStatus,
    this.purpose,
  });

  final bool status;
  final String message;
  final String? paymentStatus;
  final String? purpose;
}
