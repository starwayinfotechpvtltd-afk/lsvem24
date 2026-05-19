import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/pages/custom_pages/comment_page/get_all_reply_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class GetAllReplyApi {
  static Future<GetAllReplyModel> callApi(String loginUserId, String videoId, String commentId) async {
    AppSettings.showLog("Get All Reply Api Calling...");

    final uri = Uri.parse("${Constant.baseURL + Constant.getAllReply}?userId=$loginUserId&videoId=$videoId&recursiveCommentId=$commentId");

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        AppSettings.showLog("Get All Reply Response => ${response.body}");
        return GetAllReplyModel.fromJson(jsonResponse);
      } else {
        AppSettings.showLog("Get All Reply StateCode Error");
        throw ">>> Error <<<";
      }
    } catch (error) {
      AppSettings.showLog("Get All Reply Error => $error");
      throw ">>> Error <<<";
    }
  }
}
