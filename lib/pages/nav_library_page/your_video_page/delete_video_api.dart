import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class DeleteVideoApi {
  static Future<bool> callApi({required String videoId}) async {
    AppSettings.showLog("Delete Video Api Calling... ");

    final uri = Uri.parse("${Constant.baseURL + Constant.deleteVideo}?videoId=$videoId");

    final headers = {"key": Constant.secretKey};

    try {
      var response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        AppSettings.showLog("Delete Video Api Response => ${response.body}");

        return jsonResponse["status"];
      } else {
        AppSettings.showLog("Delete Video Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Delete Video Api Error => $error");
    }
    return false;
  }
}
