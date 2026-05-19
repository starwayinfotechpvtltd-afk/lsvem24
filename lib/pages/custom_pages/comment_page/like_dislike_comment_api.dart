import 'package:http/http.dart' as http;
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

// ******************* Edit Complete *************************

class LikeDisLikeCommentApi {
  static Future<void> callApi(String userId, String commentId, bool isLike) async {
    AppSettings.showLog("Like DisLike Comment Api Calling...");

    final uri = Uri.parse("${Constant.baseURL + Constant.likeDislikeComment}?userId=$userId&videoCommentId=$commentId&likeOrDislike=${isLike ? "like" : "dislike"}");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        AppSettings.showLog("Like DisLike Comment Api Response => ${response.body}");
      } else {
        AppSettings.showLog("Like DisLike Comment Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Like DisLike Comment Api Error => $error");
    }
  }
}
