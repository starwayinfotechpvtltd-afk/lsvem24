import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/database/database.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/utils/ads/ad_budget_calculator.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class AdBudgetResult {
  final bool status;
  final int budget;
  final int currentCoin;
  final int totalPurchasedCoin;
  final bool canUpload;
  final String? message;
  final bool fromLocalFallback;

  const AdBudgetResult({
    required this.status,
    required this.budget,
    required this.currentCoin,
    required this.totalPurchasedCoin,
    required this.canUpload,
    this.message,
    this.fromLocalFallback = false,
  });

  factory AdBudgetResult.fromJson(
    Map<String, dynamic> json, {
    int fallbackCoin = 0,
    int fallbackPurchasedCoin = 0,
  }) {
    final coin = (json['availableCoin'] as num?)?.toInt() ?? fallbackCoin;
    final purchased =
        (json['totalPurchasedCoin'] as num?)?.toInt() ?? fallbackPurchasedCoin;
    final budget = (json['budget'] as num?)?.toInt() ?? 0;
    return AdBudgetResult(
      status: json['status'] == true,
      budget: budget,
      currentCoin: coin,
      totalPurchasedCoin: purchased,
      canUpload: json['canUpload'] == true || coin >= budget,
      message: json['message']?.toString(),
    );
  }

  static AdBudgetResult local({
    required int budget,
    required int currentCoin,
    required int totalPurchasedCoin,
  }) {
    return AdBudgetResult(
      status: true,
      budget: budget,
      currentCoin: currentCoin,
      totalPurchasedCoin: totalPurchasedCoin,
      canUpload: currentCoin >= budget,
      fromLocalFallback: true,
    );
  }
}

class CalculateBudgetApi {
  static int _currentCoin() {
    return GetProfileApi.profileModel?.user?.currentCoin ?? 0;
  }

  static int _purchasedCoin() {
    return GetProfileApi.profileModel?.user?.totalPurchasedCoin ?? 0;
  }

  static Future<AdBudgetResult> callApi({
    required double fileSizeMB,
    required int durationSeconds,
    required String type,
    required String placement,
    required String mediaType,
  }) async {
    final currentCoin = _currentCoin();
    final purchasedCoin = _purchasedCoin();

    final userId = Database.loginUserId?.toString().trim();
    if (userId == null || userId.isEmpty || userId == 'null') {
      return AdBudgetResult.local(
        budget: AdBudgetCalculator.calculate(
          fileSizeMB: fileSizeMB,
          durationSeconds: durationSeconds,
          adType: type,
          placement: placement,
          mediaType: mediaType,
        ).budget,
        currentCoin: currentCoin,
         totalPurchasedCoin: purchasedCoin,
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse('${Constant.baseURL}${Constant.calculateBudget}'),
            headers: {
              'key': Constant.secretKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'userId': userId,
              'fileSizeMB': fileSizeMB,
              'durationSeconds': durationSeconds,
              'durationMs': durationSeconds * 1000,
              'type': type,
              'placement': placement,
              'mediaType': mediaType,
            }),
          )
          .timeout(const Duration(seconds: 45));

      AppSettings.showLog('Calculate Budget => ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['status'] == true) {
          return AdBudgetResult.fromJson(
            json,
            fallbackCoin: currentCoin,
            fallbackPurchasedCoin: purchasedCoin,
          );
        }
      }
    } catch (e) {
      AppSettings.showLog('Calculate Budget Api Error => $e');
    }

    final breakdown = AdBudgetCalculator.calculate(
      fileSizeMB: fileSizeMB,
      durationSeconds: durationSeconds,
      adType: type,
      placement: placement,
      mediaType: mediaType,
    );

    return AdBudgetResult.local(
      budget: breakdown.budget,
      currentCoin: currentCoin,
      totalPurchasedCoin: purchasedCoin,
    );
  }
}
