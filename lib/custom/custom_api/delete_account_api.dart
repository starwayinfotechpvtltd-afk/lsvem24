import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class DeleteUserApi {
  static Future<bool> sendDeleteOtp({required String email}) async {
    AppSettings.showLog("Delete User Send OTP Api Calling... ");

    print("Deleting account => ${Constant.baseURL + Constant.deleteaccountotp}");
    final uri = Uri.parse(Constant.baseURL + Constant.deleteaccountotp);
    final headers = {"key": Constant.secretKey, 'Content-Type': 'application/json'};
    final body = json.encode({'email': email});

    try {
      var response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        AppSettings.showLog("Delete User Send OTP Response => ${response.body}");

        if (jsonResponse["message"] != null) {
          CustomToast.show(jsonResponse["message"]);
        }
        return jsonResponse["status"] ?? false;
      } else {
        AppSettings.showLog("Delete User Send OTP StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Delete User Send OTP Error => $error");
    }
    return false;
  }

  static Future<bool> callApi({
    required String loginUserId,
    required String email,
    required String otp,
  }) async {
    AppSettings.showLog("Delete User Api Calling... ");

    final uri = Uri.parse(
        "${Constant.baseURL + Constant.deleteAccount}?userId=$loginUserId&email=${Uri.encodeComponent(email)}&otp=$otp");

    final headers = {"key": Constant.secretKey};

    try {
      var response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        AppSettings.showLog("Delete User Api Response => ${response.body}");

        if (jsonResponse["status"] != true && jsonResponse["message"] != null) {
          CustomToast.show(jsonResponse["message"]);
        }
        return jsonResponse["status"] ?? false;
      } else {
        AppSettings.showLog("Delete User Api StateCode Error");
      }
    } catch (error) {
      AppSettings.showLog("Delete User Api Error => $error");
    }
    return false;
  }
}

