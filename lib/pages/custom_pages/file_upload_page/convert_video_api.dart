import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:metube/pages/custom_pages/file_upload_page/file_upload_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class ConvertVideoApi {
  static FileUploadModel? _fileUploadModel;

  static Future<String?> callApi(String videoPath, bool isNormalVideo) async {
    AppSettings.showLog("Convert Video Api Calling...");

    if (!File(videoPath).existsSync()) {
      AppSettings.showLog("Convert Video: file not found => $videoPath");
      return null;
    }

    try {
      final headers = {'key': Constant.secretKey};

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(Constant.baseURL + Constant.fileUpload),
      );

      request.fields.addAll(
        isNormalVideo
            ? {
                'folderStructure': Constant.normalVideo,
                'keyName': '${DateTime.now().millisecondsSinceEpoch}.mp4',
              }
            : {
                'folderStructure': Constant.shortsVideo,
                'keyName': '${DateTime.now().millisecondsSinceEpoch}.mp4',
              },
      );

      request.files.add(
        await http.MultipartFile.fromPath('content', videoPath),
      );
      request.headers.addAll(headers);

      final response = await request.send().timeout(
        const Duration(minutes: 15),
        onTimeout: () {
          throw Exception('Video upload timed out');
        },
      );

      final responseBody = await response.stream.bytesToString();
      AppSettings.showLog(
        "Convert Video status=${response.statusCode} body=$responseBody",
      );

      if (response.statusCode != 200) return null;

      final jsonResult = jsonDecode(responseBody) as Map<String, dynamic>;
      _fileUploadModel = FileUploadModel.fromJson(jsonResult);

      if (_fileUploadModel?.status == true &&
          (_fileUploadModel?.url?.isNotEmpty ?? false)) {
        return _fileUploadModel!.url!;
      }

      AppSettings.showLog(
        "Convert Video failed: ${_fileUploadModel?.message}",
      );
      return null;
    } catch (e) {
      AppSettings.showLog("Convert Video Api Error => $e");
      return null;
    }
  }
}
