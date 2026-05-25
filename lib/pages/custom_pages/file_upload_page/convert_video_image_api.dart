import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:metube/pages/custom_pages/file_upload_page/file_upload_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class ConvertVideoImageApi {
  static FileUploadModel? _fileUploadModel;

  static Future<String?> callApi(String thumbnailPath, bool isNormalVideo) async {
    AppSettings.showLog("Convert Video Image Api Calling...");

    if (thumbnailPath.isEmpty || !File(thumbnailPath).existsSync()) {
      AppSettings.showLog("Convert Video Image: invalid thumbnail path");
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
                'folderStructure': Constant.normalVideoImage,
                'keyName': '${DateTime.now().millisecondsSinceEpoch}.jpg',
              }
            : {
                'folderStructure': Constant.shortsVideoImage,
                'keyName': '${DateTime.now().millisecondsSinceEpoch}.jpg',
              },
      );

      request.files.add(
        await http.MultipartFile.fromPath('content', thumbnailPath),
      );
      request.headers.addAll(headers);

      final response = await request.send().timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          throw Exception('Thumbnail upload timed out');
        },
      );

      final responseBody = await response.stream.bytesToString();

      AppSettings.showLog(
        "THUMB STATUS => ${response.statusCode}"
        );

        AppSettings.showLog(
        "THUMB RESPONSE => $responseBody"
        );

        if (response.statusCode != 200) {
          throw Exception(
              "Thumbnail upload HTTP ${response.statusCode}");
        }

      final jsonResult = jsonDecode(responseBody) as Map<String, dynamic>;
      _fileUploadModel = FileUploadModel.fromJson(jsonResult);
      AppSettings.showLog(
        "status=${_fileUploadModel?.status}"
        );

        AppSettings.showLog(
        "url=${_fileUploadModel?.url}"
        );

        AppSettings.showLog(
        "message=${_fileUploadModel?.message}"
        );

      if (_fileUploadModel?.status == true &&
          (_fileUploadModel?.url?.isNotEmpty ?? false)) {
        AppSettings.showLog(
          "Convert Video Image Api Response => ${_fileUploadModel?.url}",
        );
        return _fileUploadModel!.url;
      }

      AppSettings.showLog(
        "Convert Video Image failed: ${_fileUploadModel?.message}",
      );
    } catch (e) {
      AppSettings.showLog("Convert Video Image Api Error !! => $e");
    }
    return null;
  }
}
