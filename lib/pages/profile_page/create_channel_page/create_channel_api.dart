import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/database/database.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class CreateChannelApi {
  static bool? status;
  static String? message;

  static Future<void> callApi() async {
    message = "";
    AppSettings.showLog("Create Channel Api Calling...");

    final uri = Uri.parse(
        '${Constant.baseURL + Constant.createChannel}?userId=${Database.loginUserId}&isChannel=false');

    final headers = {
      "key": Constant.secretKey,
      "Content-Type": 'application/json'
    };

    final body = json.encode({
      "fullName": AppSettings.nameController.text,
      "channelType": AppSettings.channelType.value.toString(),
      "descriptionOfChannel": AppSettings.channelDescriptionController.text,
      "instagramLink": AppSettings.instagramController.text.trim(),
      "facebookLink": AppSettings.facebookController.text.trim(),
      "twitterLink": AppSettings.twitterController.text.trim(),
      "websiteLink": AppSettings.websiteController.text.trim(),
    });

    print("****** ${body}");

    final response = await http.patch(uri, headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      status = jsonResponse["status"];
      message = jsonResponse["message"];

      AppSettings.showLog("Create Channel Api Response => ${response.body}");
    } else {
      AppSettings.showLog(
          "Create Channel Api Error => ${response.reasonPhrase.toString()}");
    }
  }
}
