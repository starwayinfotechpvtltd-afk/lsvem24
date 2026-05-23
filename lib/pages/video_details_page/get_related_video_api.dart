import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:metube/database/database.dart';
import 'package:metube/pages/video_details_page/get_related_video_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class GetRelatedVideoApi {
  static Future<GetRelatedVideoModel?> callApi({
    required String videoId,
  }) async {
    AppSettings.showLog('Get Related Video Api Calling...');

    final userId = Database.loginUserId?.toString().trim();
    final hasUser =
        userId != null && userId.isNotEmpty && userId.toLowerCase() != 'null';

    final query = <String, String>{'videoId': videoId};
    if (hasUser) {
      query['userId'] = userId;
    }

    final uri = Uri.parse(
      '${Constant.baseURL}${Constant.getRelatedVideo}',
    ).replace(queryParameters: query);

    AppSettings.showLog('Get Related Video Api => $uri');

    final headers = {'key': Constant.secretKey};

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode != 200) {
        AppSettings.showLog(
          'Get Related Video Api status error => ${response.statusCode}',
        );
        return null;
      }

      final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
      AppSettings.showLog(
        'Get Related Video Api Response status => ${jsonResponse['status']}',
      );

      final model = GetRelatedVideoModel.fromJson(jsonResponse);
      if (model.status == true) {
        return model;
      }

      AppSettings.showLog(
        'Get Related Video failed => ${model.message}',
      );
      return null;
    } catch (error) {
      AppSettings.showLog('Get Related Video Api Error => $error');
      return null;
    }
  }
}
