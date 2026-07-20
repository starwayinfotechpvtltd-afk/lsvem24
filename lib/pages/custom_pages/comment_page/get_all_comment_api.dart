import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/database/database.dart';
import 'package:metube/pages/custom_pages/comment_page/get_all_comment_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class GetAllCommentApi {
  static GetAllCommentModel? getAllCommentModel;
  static const List commentType = ["top", "newest", "mostLiked"];
  static Future<List<VideoComment>?> callApi(
      String videoId, int commentTypeIndex, String? loginUserId) async {
    AppSettings.showLog("Get All Comment Api Calling...");

    String url = "${Constant.baseURL + Constant.getAllComment}"
        "?videoId=$videoId"
        "&commentType=${commentType[commentTypeIndex]}";

    if (loginUserId != null && loginUserId.isNotEmpty) {
      url += "&userId=$loginUserId";
    }

    final uri = Uri.parse(url);

    final headers = {"key": Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        getAllCommentModel = GetAllCommentModel.fromJson(jsonResponse);
        AppSettings.showLog(
            "Get All Comment Response => ${getAllCommentModel?.videoComment?.length}");
        return getAllCommentModel?.videoComment ?? <VideoComment>[];
      } else {
        AppSettings.showLog("Get All Comment StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Get All Comment Error => $error");
    }
    return null;
  }
}
