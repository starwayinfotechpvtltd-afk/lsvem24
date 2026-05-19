import 'package:http/http.dart' as http;
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class TrackShortsFeedAdApi {
  static Future<void> trackView(String adId) async {
    if (adId.isEmpty) return;
    try {
      final uri = Uri.parse(
          "${Constant.baseURL}client/videoad/track/$adId/view");
      await http.patch(uri, headers: {"key": Constant.secretKey});
    } catch (e) {
      AppSettings.showLog("Track ad view error => $e");
    }
  }

  static Future<void> trackClick(String adId) async {
    if (adId.isEmpty) return;
    try {
      final uri = Uri.parse(
          "${Constant.baseURL}client/videoad/track/$adId/click");
      await http.patch(uri, headers: {"key": Constant.secretKey});
    } catch (e) {
      AppSettings.showLog("Track ad click error => $e");
    }
  }
}
