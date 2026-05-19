import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/pages/shorts_ads/shorts_feed_ad_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class GetShortsFeedAdsApi {
  static Future<List<ShortsFeedAd>> callApi() async {
    AppSettings.showLog("Get Shorts Feed Ads Api Calling...");

    final uri = Uri.parse("${Constant.baseURL}${Constant.getShortsFeedAds}");
    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        if (jsonResponse['status'] != true) return [];

        final raw = jsonResponse['ads'];
        if (raw is! List) return [];

        return raw
            .whereType<Map>()
            .map((e) => ShortsFeedAd.fromJson(Map<String, dynamic>.from(e)))
            .where((ad) => ad.hasVideo || ad.hasImage)
            .toList();
      }
      AppSettings.showLog("Get Shorts Feed Ads status => ${response.statusCode}");
    } catch (e) {
      AppSettings.showLog("Get Shorts Feed Ads Error => $e");
    }
    return [];
  }
}
