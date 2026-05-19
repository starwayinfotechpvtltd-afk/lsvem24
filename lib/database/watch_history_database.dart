import 'dart:convert';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchHistory {
  static RxList<Map<String, dynamic>> mainWatchHistory =
      <Map<String, dynamic>>[].obs;

  static Future<void> onGet() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final jsonData = preferences.getString("watchHistory");

    if (jsonData != null) {
      List<dynamic> jsonDecodeData = json.decode(jsonData);
      mainWatchHistory.value = List<Map<String, dynamic>>.from(    
        jsonDecodeData.map((item) {
          final m = Map<String, dynamic>.from(item);
          return {
            "id": m["id"] ?? DateTime.now().millisecondsSinceEpoch,
            "videoId": m["videoId"]?.toString() ?? "",
            "videoTitle": m["videoTitle"]?.toString() ?? "",
            "videoType": m["videoType"] ?? 1,
            "videoTime": m["videoTime"] ?? 0,
            "videoUrl": m["videoUrl"]?.toString() ?? "",
            "videoImage": m["videoImage"]?.toString() ?? "",
            "views": m["views"] ?? 0,
            "channelName": m["channelName"]?.toString() ?? "",
          };
        }),
      );
    } else {
      mainWatchHistory.value = [];
    }
  }

  static Future<void> onSet() async {
    // This Method Call Video Watch Time...

    final SharedPreferences preferences = await SharedPreferences.getInstance();

    String jsonData = json.encode(mainWatchHistory);

    final isSuccess = await preferences.setString("watchHistory", jsonData);
    isSuccess
        ? AppSettings.showLog(
            "Watch History Database OnSet Method Called Success")
        : AppSettings.showLog(
            "Watch History Database OnSet Method Called Error");
  }
}
