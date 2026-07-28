import 'package:http/http.dart' as http;
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class RemoveWatchLaterApi {
  static Future<bool> callApi(String loginUserId, String videoId) async {
    AppSettings.showLog("Remove Watch Later Api Calling...");

    final uri = Uri.parse("${Constant.baseURL + Constant.removeWatchLater}?userId=$loginUserId&videoId=$videoId");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.post(uri, headers: headers);
      if (response.statusCode == 200) {
        AppSettings.showLog("Remove Watch Later Api Response => ${response.body}");
        return true;
      } else {
        AppSettings.showLog("Remove Watch Later Api StatusCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Remove Watch Later Api Error => $error");
    }
    return false;
  }
}
