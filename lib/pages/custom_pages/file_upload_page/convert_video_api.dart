import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:metube/pages/custom_pages/file_upload_page/file_upload_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/helpers/media_path_helper.dart';
import 'package:metube/utils/services/convert_to_network.dart';
import 'package:metube/utils/settings/app_settings.dart';

class ConvertVideoApi {
  static FileUploadModel? _fileUploadModel;

  static Future<String?> callApi(String videoPath, bool isNormalVideo) async {
    final path = localFilePath(videoPath);
    if (!File(path).existsSync()) {
      debugPrint('❌ ConvertVideo: file not found => $videoPath');
      return null;
    }

    final sizeMb = (await File(path).length()) / (1024 * 1024);
    debugPrint('📤 ConvertVideo: uploading ${sizeMb.toStringAsFixed(2)} MB');

    Object? lastError;
    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        final url = await _uploadOnce(path, isNormalVideo);
        if (url != null && url.isNotEmpty) {
          debugPrint('✅ ConvertVideo: $url');
          return url;
        }
      } catch (e) {
        lastError = e;
        debugPrint('❌ ConvertVideo attempt $attempt: $e');
        if (attempt < 2) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }

    if (lastError != null) {
      throw Exception(lastError.toString().replaceFirst('Exception: ', ''));
    }
    return null;
  }

  static Future<String?> _uploadOnce(String path, bool isNormalVideo) async {
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

    request.files.add(await http.MultipartFile.fromPath('content', path));
    request.headers.addAll({'key': Constant.secretKey});

    final response = await request.send().timeout(
      const Duration(minutes: 20),
      onTimeout: () => throw Exception('Video upload timed out'),
    );

    final responseBody = await response.stream.bytesToString();
    debugPrint('📤 ConvertVideo HTTP ${response.statusCode}: $responseBody');

    if (response.statusCode != 200) {
      throw Exception('Video upload HTTP ${response.statusCode}');
    }

    final jsonResult = jsonDecode(responseBody) as Map<String, dynamic>;
    _fileUploadModel = FileUploadModel.fromJson(jsonResult);

    if (_fileUploadModel?.status == true &&
        (_fileUploadModel?.url?.isNotEmpty ?? false)) {
      return ConvertToNetwork.resolve(_fileUploadModel!.url!);
    }

    throw Exception(
      _fileUploadModel?.message?.toString() ?? 'Video upload rejected',
    );
  }
}
