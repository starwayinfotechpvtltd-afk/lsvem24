import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:metube/database/database.dart';
import 'package:metube/pages/custom_pages/file_upload_page/convert_video_api.dart';
import 'package:metube/pages/custom_pages/file_upload_page/file_upload_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class CreateAdsApi {
  static bool? status;
  static String? message;
  static String uploadStatus = '';
  static final uploadStatusRx = ''.obs;

  static Future<bool> callApi({
    String? title,
    String? description,
    String? country,
    String? state,
    String? type,
    String? category,
    String? adRuns,
    String? city,
    String? budget,
    String? placement,
    int? durationSeconds,
    double? fileSizeMB,
    File? image,
    File? video,
    void Function(double progress)? onProgress,
  }) async {
    status = null;
    message = '';
    uploadStatus = '';
    uploadStatusRx.value = '';

    final userId = Database.loginUserId?.toString().trim();
    if (userId == null || userId.isEmpty || userId == 'null') {
      message = 'Please login first';
      return false;
    }

    if (image == null && video == null) {
      message = 'Please select an image or video for the ad';
      return false;
    }

    try {
      String? imageUrl;
      String? videoUrl;
      final isShortAd = adRuns == 'short videos';

      if (image != null) {
        imageUrl = await _compressAndUploadImage(image, onProgress: onProgress);
        if (imageUrl == null) {
          message = 'Image upload failed';
          return false;
        }
      }

      if (video != null) {
        videoUrl = await _compressAndUploadVideo(
          video,
          isShort: isShortAd,
          onProgress: onProgress,
        );
        if (videoUrl == null) {
          message = 'Video upload failed';
          return false;
        }
      }

      final uri = Uri.parse(
        '${Constant.baseURL}${Constant.createAds}?userId=$userId',
      );

      final response = await http
          .post(
            uri,
            headers: {
              'key': Constant.secretKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'title': title ?? '',
              'description': description ?? '',
              'country': country ?? '',
              'state': state ?? '',
              'city': city ?? '',
              'type': type ?? '',
              'category': category ?? '',
              'budget': budget ?? '',
              'adRuns': adRuns ?? '',
              'placement': placement ?? 'pre-roll',
              'durationSeconds': durationSeconds ?? 0,
              'durationMs': (durationSeconds ?? 0) * 1000,
              'fileSizeMB': fileSizeMB ?? 0,
              'mediaType': video != null ? 'video' : 'image',
              'image': imageUrl ?? '',
              'video': videoUrl ?? '',
            }),
          )
          .timeout(const Duration(seconds: 60));

      AppSettings.showLog('Create Ads response => ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        status = jsonResponse['status'] == true;
        message = jsonResponse['message']?.toString() ?? '';
        return status == true;
      }

      message = 'Create ad failed (${response.statusCode})';
    } catch (e) {
      message = e.toString().replaceFirst('Exception: ', '');
      AppSettings.showLog('Create Ads Error => $e');
    }

    return false;
  }

  static Future<String?> _compressAndUploadImage(
    File image, {
    void Function(double progress)? onProgress,
  }) async {
    if (!image.existsSync()) return null;

    return _uploadFile(
      file: image,
      folderStructure: '${Constant.folderStructurePath}/adsImage',
      extension: 'jpg',
      onProgress: onProgress,
    );
  }

  static Future<String?> _compressAndUploadVideo(
    File video, {
    required bool isShort,
    void Function(double progress)? onProgress,
  }) async {
    if (!video.existsSync()) return null;

    return _uploadFile(
      file: video,
      folderStructure: '${Constant.folderStructurePath}/adsVideo',
      extension: 'mp4',
      timeoutMinutes: 15,
      onProgress: onProgress,
    );
  }

  static Future<String?> _uploadFile({
    required File file,
    required String folderStructure,
    required String extension,
    int timeoutMinutes = 5,
    void Function(double progress)? onProgress,
  }) async {
    if (!file.existsSync()) {
      AppSettings.showLog('_uploadFile: file missing');
      return null;
    }

    try {
      final request = ProgressMultipartRequest(
        'PUT',
        Uri.parse('${Constant.baseURL}${Constant.fileUpload}'),
        onProgress: (bytes, total) {
          if (onProgress != null && total > 0) {
            onProgress(bytes / total);
          }
        },
      );

      request.headers['key'] = Constant.secretKey;
      request.fields.addAll({
        'folderStructure': folderStructure,
        'keyName': '${DateTime.now().millisecondsSinceEpoch}.$extension',
      });
      request.files.add(
        await http.MultipartFile.fromPath('content', file.path),
      );

      final response = await request.send().timeout(
        Duration(minutes: timeoutMinutes),
        onTimeout: () => throw Exception('Upload timed out'),
      );

      final body = await response.stream.bytesToString();
      AppSettings.showLog('Ad file upload status=${response.statusCode}');

      if (response.statusCode != 200) return null;

      final model = FileUploadModel.fromJson(
        jsonDecode(body) as Map<String, dynamic>,
      );

      if (model.status == true && (model.url?.isNotEmpty ?? false)) {
        return model.url;
      }

      AppSettings.showLog('Ad file upload failed: ${model.message}');
    } catch (e) {
      AppSettings.showLog('_uploadFile Error => $e');
    }

    return null;
  }
}
