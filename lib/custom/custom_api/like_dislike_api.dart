import 'package:http/http.dart' as http;
import 'package:metube/database/database.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class LikeDisLikeVideoApi {
  static Future<void> callApi(String videoId, bool isLike) async {
    AppSettings.showLog("Like DisLike Video Api Calling...");

    final uri = Uri.parse("${Constant.baseURL + Constant.likeDislikeVideo}?userId=${Database.loginUserId!}&videoId=$videoId&likeOrDislike=${isLike ? "like" : "dislike"}");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        AppSettings.showLog("Like DisLike Video Api Response => ${response.body}");
      } else {
        AppSettings.showLog("Like DisLike Video Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Like DisLike Video Api Error => $error");
    }
  }
}
