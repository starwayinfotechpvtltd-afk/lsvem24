import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/pages/long_video_ads/long_video_ad_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class GetLongVideoAdsApi {
  static Future<List<LongVideoAd>> callApi({String? placement}) async {
    AppSettings.showLog("Get Long Video Ads Api Calling...");

    final query = placement != null ? '?placement=$placement' : '';
    final uri =
        Uri.parse('${Constant.baseURL}${Constant.getLongVideoAds}$query');
    final headers = {'key': Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        if (jsonResponse['status'] != true) return [];

        final raw = jsonResponse['ads'];
        if (raw is! List) return [];

        return raw
            .whereType<Map>()
            .map((e) => LongVideoAd.fromJson(Map<String, dynamic>.from(e)))
            .where((ad) => ad.hasVideo || ad.hasImage)
            .toList();
      }
      AppSettings.showLog(
          'Get Long Video Ads status => ${response.statusCode}');
    } catch (e) {
      AppSettings.showLog('Get Long Video Ads Error => $e');
    }
    return [];
  }
}
