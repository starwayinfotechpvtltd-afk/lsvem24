import 'package:http/http.dart' as http;
import 'package:metube/utils/constant/app_constant.dart';

class AddViewApi {
  static Future<bool> callApi(
    String videoId,
    String userId,
  ) async {
    try {
      print("Add View Called");
      final uri = Uri.parse(
        "${Constant.baseURL}${Constant.addView}"
        "?videoId=$videoId&userId=$userId",
      );

      final headers = {'key': Constant.secretKey};
      final response = await http.post(uri, headers: headers);

      print("Add View Status => ${response.statusCode}");
      print("Add View Response => ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("Add View Error => $e");
      return false;
    }
  }
}
