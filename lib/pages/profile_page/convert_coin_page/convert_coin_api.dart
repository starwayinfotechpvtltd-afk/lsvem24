import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:metube/pages/profile_page/convert_coin_page/convert_coin_model.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/constant/app_constant.dart';

class ConvertCoinApi {
  static Future<ConvertCoinModel?> callApi({required String loginUserId, required int coin}) async {
    AppSettings.showLog("Convert Coin Api Calling...");

    final uri = Uri.parse("${Constant.baseURL}${Constant.convertCoin}?userId=$loginUserId&coin=$coin");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        AppSettings.showLog("Convert Coin Api Response => ${response.body}");

        return ConvertCoinModel.fromJson(jsonResponse);
      } else {
        AppSettings.showLog("Convert Coin Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Convert Coin Api Error => $error");
    }
    return null;
  }
}
