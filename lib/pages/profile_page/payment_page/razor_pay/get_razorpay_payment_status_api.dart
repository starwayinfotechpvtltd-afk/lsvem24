import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class GetRazorpayPaymentStatusApi {
  static Future<RazorpayPaymentStatusResult?> callApi({
    required String userId,
    required String orderId,
  }) async {
    final uri = Uri.parse(
      '${Constant.baseURL}${Constant.razorpayPaymentStatus}',
    ).replace(queryParameters: {
      'userId': userId,
      'orderId': orderId,
    });

    final headers = {'key': Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) return null;

      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      if (jsonResponse['status'] != true) {
        AppSettings.showLog(
          'Razorpay status: ${jsonResponse['message']}',
        );
        return null;
      }

      final payment = jsonResponse['payment'] as Map<String, dynamic>?;
      return RazorpayPaymentStatusResult(
        status: payment?['status']?.toString() ?? '',
        purpose: payment?['purpose']?.toString(),
      );
    } catch (e) {
      AppSettings.showLog('Get Razorpay Payment Status Error => $e');
      return null;
    }
  }

  /// Poll until webhook/verify marks payment fulfilled (or failed).
  static Future<bool> waitUntilFulfilled({
    required String userId,
    required String orderId,
    int maxAttempts = 15,
    Duration interval = const Duration(seconds: 2),
  }) async {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final result = await callApi(userId: userId, orderId: orderId);
      final status = result?.status ?? '';

      AppSettings.showLog(
        'Razorpay poll [$attempt/$maxAttempts] order=$orderId status=$status',
      );

      if (status == 'fulfilled') return true;
      if (status == 'failed') return false;

      if (attempt < maxAttempts - 1) {
        await Future.delayed(interval);
      }
    }
    return false;
  }
}

class RazorpayPaymentStatusResult {
  RazorpayPaymentStatusResult({
    required this.status,
    this.purpose,
  });

  final String status;
  final String? purpose;
}
