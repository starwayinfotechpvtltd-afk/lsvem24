import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:metube/utils/constant/app_constant.dart';

class AddViewApi {
  static Future<int?> callApi(
    String videoId,
    String userId,
  ) async {
    try {
      print("Add View Called for video: $videoId");
      final uri = Uri.parse(
        "${Constant.baseURL}${Constant.addView}"
        "?videoId=$videoId&userId=$userId",
      );

      final headers = {'key': Constant.secretKey};
      final response = await http.post(uri, headers: headers);

      print("Add View Status => ${response.statusCode}");
      print("Add View Response => ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json["status"] == true || json["success"] == true) {
          if (json.containsKey("views")) {
            return json["views"] is int ? json["views"] : int.tryParse(json["views"].toString());
          } else if (json.containsKey("totalViews")) {
            return json["totalViews"] is int ? json["totalViews"] : int.tryParse(json["totalViews"].toString());
          }
        }
      }
      return null;
    } catch (e) {
      print("Add View Error => $e");
      return null;
    }
  }
}
