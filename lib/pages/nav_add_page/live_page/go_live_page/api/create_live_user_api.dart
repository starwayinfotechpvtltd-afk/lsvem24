import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/pages/nav_add_page/live_page/go_live_page/model/create_live_user_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class CreateLiveUserApi {
  static CreateLiveUserModel? _createLiveUserModel;

  static Future<String?> callApi({
    required String loginUserId,
    required int liveType,
    required String thumbnail,
    required String title,
  }) async {
    AppSettings.showLog("Create Live User Api Calling...");

    final uri = Uri.parse("${Constant.baseURL + Constant.createLiveUser}?userId=$loginUserId&liveType=$liveType");

    final headers = {"key": Constant.secretKey, "Content-Type": "application/json"};

    final body = json.encode({"thumbnail": thumbnail, "title": title});

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        AppSettings.showLog("Create Live User Api Response => ${response.body}");
        final jsonResponse = json.decode(response.body);

        _createLiveUserModel = CreateLiveUserModel.fromJson(jsonResponse);

        return _createLiveUserModel?.liveUser?.liveHistoryId;
      } else {
        AppSettings.showLog("Create Live User Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Create Live User Api Error => $error");
    }
    return null;
  }
}
