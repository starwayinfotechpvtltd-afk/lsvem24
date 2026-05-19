import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class CreateReplyApi {
  static Future<void> callApi(String loginUserId, String videoId, String commentId, String commentText) async {
    AppSettings.showLog("Create Reply Api Calling...");

    final uri = Uri.parse(Constant.baseURL + Constant.createReply);

    final headers = {"key": Constant.secretKey, 'Content-Type': 'application/json'};

    final body = json.encode({"userId": loginUserId, "videoId": videoId, "videoCommentId": commentId, "commentText": commentText});
    try {
      final response = await http.post(uri, body: body, headers: headers);

      if (response.statusCode == 200) {
        AppSettings.showLog("Create Reply Api Response => ${response.body}");
      } else {
        AppSettings.showLog("Create Reply StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Create Reply Api Error => $error");
    }
  }
}
