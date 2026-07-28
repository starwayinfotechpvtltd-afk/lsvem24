import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:metube/pages/custom_pages/file_upload_page/convert_video_api.dart';
import 'package:metube/pages/custom_pages/file_upload_page/file_upload_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/helpers/media_path_helper.dart';
import 'package:metube/utils/services/convert_to_network.dart';

class ConvertVideoImageApi {
  static FileUploadModel? _fileUploadModel;

  static Future<String?> callApi(
    String thumbnailPath,
    bool isNormalVideo, {
    void Function(double progress)? onProgress,
  }) async {
    final path = localFilePath(thumbnailPath);
    if (path.isEmpty || !File(path).existsSync()) {
      debugPrint('❌ ConvertVideoImage: invalid path => $thumbnailPath');
      return null;
    }

    debugPrint('📤 ConvertVideoImage: ${await File(path).length()} bytes');

    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        final url = await _uploadOnce(path, isNormalVideo, onProgress: onProgress);
        if (url != null && url.isNotEmpty) {
          debugPrint('✅ ConvertVideoImage: $url');
          return url;
        }
      } catch (e) {
        debugPrint('❌ ConvertVideoImage attempt $attempt: $e');
        if (attempt < 2) {
          await Future.delayed(const Duration(seconds: 2));
        } else {
          rethrow;
        }
      }
    }
    return null;
  }

  static Future<String?> _uploadOnce(
    String path,
    bool isNormalVideo, {
    void Function(double progress)? onProgress,
  }) async {
    final request = ProgressMultipartRequest(
      'PUT',
      Uri.parse(Constant.baseURL + Constant.fileUpload),
      onProgress: (bytes, total) {
        if (onProgress != null && total > 0) {
          onProgress(bytes / total);
        }
      },
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

    request.files.add(await http.MultipartFile.fromPath('content', path));
    request.headers.addAll({'key': Constant.secretKey});

    final response = await request.send().timeout(
      const Duration(minutes: 5),
      onTimeout: () => throw Exception('Thumbnail upload timed out'),
    );

    final responseBody = await response.stream.bytesToString();
    debugPrint('📤 ConvertVideoImage HTTP ${response.statusCode}: $responseBody');

    if (response.statusCode != 200) {
      throw Exception('Thumbnail upload HTTP ${response.statusCode}');
    }

    final jsonResult = jsonDecode(responseBody) as Map<String, dynamic>;
    _fileUploadModel = FileUploadModel.fromJson(jsonResult);

    if (_fileUploadModel?.status == true &&
        (_fileUploadModel?.url?.isNotEmpty ?? false)) {
      return ConvertToNetwork.resolve(_fileUploadModel!.url!);
    }

    throw Exception(
      _fileUploadModel?.message?.toString() ?? 'Thumbnail upload rejected',
    );
  }
}
