import 'package:http/http.dart' as http;
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class CreateWatchLater {
  static Future<void> callApi(String loginUserId, String videoId) async {
    AppSettings.showLog("Create Watch Later Api Calling...");

    final uri = Uri.parse("${Constant.baseURL + Constant.createWatchLater}?userId=$loginUserId&videoId=$videoId");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.post(uri, headers: headers);
      if (response.statusCode == 200) {
        AppSettings.showLog("Create Watch Later Api Response => ${response.body}");
      } else {
        AppSettings.showLog("Create Watch Later Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Create Watch Later Api Error => $error");
    }
  }
}
