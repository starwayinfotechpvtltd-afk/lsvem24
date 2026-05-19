import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';

class AddIntoPlayListApi {
  static Future<void> callApi(String loginUserId, String loginUserChannelId, String playListId, String videoId) async {
    AppSettings.showLog("Add Into PlayList Api Calling...");

    final headers = {"key": Constant.secretKey, "Content-Type": 'application/json'};

    final uri = Uri.parse(Constant.baseURL + Constant.updatePlayList);

    final body = json.encode({
      "userId": loginUserId,
      "channelId": loginUserChannelId,
      "playListId": playListId,
      "videoId": videoId,
    });
    // "playListName": optional,
    // "playListType": optional       // >>> Note :- Private = 1 , Public = 2
    final response = await http.patch(uri, body: body, headers: headers);

    if (response.statusCode == 200) {
      AppSettings.showLog("Add Into PlayList Api Response => ${response.body}");

      Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse["message"] == "The video already exists in the playlist.") {
        CustomToast.show(AppStrings.videoAlreadyAdded.tr);
      } else {
        CustomToast.show(AppStrings.videoAddedSuccess.tr);
      }
    } else {
      CustomToast.show(AppStrings.someThingWentWrong.tr);
      AppSettings.showLog("Add Into PlayList Api Error => ${response.reasonPhrase.toString()}");
    }
  }
}
