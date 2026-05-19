import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:metube/pages/search_page/search_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class SearchApi {
  static Future<SearchModel?> callApi(String userId, String searchString, String type) async {
    AppSettings.showLog("Search Api Calling...");

    final uri = Uri.parse("${Constant.baseURL + Constant.search}?userId=$userId&searchString=$searchString&type=$type");
    AppSettings.showLog("Search Api Calling => $uri");
    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        AppSettings.showLog("Search Api Response => ${response.body}");

        final jsonResponse = json.decode(response.body);

        return SearchModel.fromJson(jsonResponse);
      } else {
        AppSettings.showLog("Search Api StateCode Error => ${response.body}");
        return null;
      }
    } catch (error) {
      AppSettings.showLog("Search Api Error => $error");
      return null;
    }
  }
}
