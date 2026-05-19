import 'dart:async';  // ✅ Add this import for TimeoutException
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:metube/pages/login_related_page/login_page/login_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class LoginApi {
  static Future<LoginModel?> callApi(String email, String password, int loginType) async {
    AppSettings.showLog("===== LOGIN API CALLING =====");
    
    try {
      final uri = Uri.parse(Constant.baseURL + Constant.checkUser);
      AppSettings.showLog("📍 Request URL: $uri");
      
      final headers = {
        "key": Constant.secretKey,
        "Content-Type": "application/json; charset=UTF-8"
      };
      
      // ✅ Trim whitespace from email and password
      final body = json.encode({
        'email': email.trim(),
        'loginType': loginType,
        'password': password.trim()
      });
      
      AppSettings.showLog("📤 Request Body: $body");
      
      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout - Server not reachable');  // ✅ Use TimeoutException
        },
      );
      
      AppSettings.showLog("📥 Response Status: ${response.statusCode}");
      AppSettings.showLog("📥 Response Body: ${response.body}");
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final loginModel = LoginModel.fromJson(jsonResponse);
        
        // ✅ Add parsed response logging
        AppSettings.showLog("✅ Parsed LoginModel:");
        AppSettings.showLog("  - status: ${loginModel.status}");
        AppSettings.showLog("  - isLogin: ${loginModel.isLogin}");
        AppSettings.showLog("  - message: ${loginModel.message}");
        
        return loginModel;
      } else {
        AppSettings.showLog("❌ Error Status Code: ${response.statusCode}");
        AppSettings.showLog("❌ Error Response: ${response.body}");
        return null;
      }
    } on SocketException catch (e) {
      AppSettings.showLog("❌ Network Error: Cannot reach server");
      AppSettings.showLog("❌ Details: $e");
      AppSettings.showLog("💡 Check: Is your backend running on ${Constant.baseURL}?");
      return null;
    } on TimeoutException catch (e) {  // ✅ Fix: This was catching generic Exception
      AppSettings.showLog("❌ Timeout Error: Server took too long to respond");
      AppSettings.showLog("❌ Details: $e");
      return null;
    } on FormatException catch (e) {
      AppSettings.showLog("❌ JSON Parse Error: Invalid response format");
      AppSettings.showLog("❌ Details: $e");
      return null;
    } catch (error) {
      AppSettings.showLog("❌ Unexpected Error: $error");
      AppSettings.showLog("❌ Error Type: ${error.runtimeType}");
      return null;
    }
  }
}
