import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/pages/nav_add_page/create_short_page/get_sound_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class GetSoundApi {
  static GetSoundModel? _getSoundModel;

  static Future<List<SoundList>?> callApi() async {
    AppSettings.showLog("Get Sound Api Calling...");

    final uri = Uri.parse(Constant.baseURL + Constant.getSoundList);

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        _getSoundModel = GetSoundModel.fromJson(jsonResponse);

        AppSettings.showLog("Get Sound Api Response => ${response.body}");

        return _getSoundModel?.soundList;
      } else {
        AppSettings.showLog("Get Sound Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Get Sound Api Error => $error");
    }
    return null;
  }
}
