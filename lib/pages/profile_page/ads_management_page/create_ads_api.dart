import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:metube/database/database.dart';
import 'package:metube/pages/custom_pages/file_upload_page/file_upload_model.dart';
import 'package:metube/utils/compressor/image_compressor.dart';
import 'package:metube/utils/compressor/video_compressor.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';

class CreateAdsApi {
  static bool? status;
  static String? message;
  static String uploadStatus = '';
  static final uploadStatusRx = ''.obs;

  static void _setStatus(String value) {
    uploadStatus = value;
    uploadStatusRx.value = value;
    AppSettings.showLog(value);
  }

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
    File? image,
    File? video,
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
        _setStatus('Optimizing ad image...');
        imageUrl = await _compressAndUploadImage(image);
        if (imageUrl == null) {
          message = 'Image upload failed';
          return false;
        }
      }

      if (video != null) {
        _setStatus('Optimizing ad video...');
        videoUrl = await _compressAndUploadVideo(
          video,
          isShort: isShortAd,
        );
        if (videoUrl == null) {
          message = 'Video upload failed';
          return false;
        }
      }

      _setStatus('Saving ad...');

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

  static Future<String?> _compressAndUploadImage(File image) async {
    if (!image.existsSync()) return null;

    File uploadFile = image;
    try {
      final compressed = await ImageCompressor.compress(image.path);
      if (compressed != null && File(compressed).existsSync()) {
        uploadFile = File(compressed);
      }
    } catch (e) {
      AppSettings.showLog('Ads image compression skipped => $e');
    }

    _setStatus('Uploading ad image...');
    return _uploadFile(
      file: uploadFile,
      folderStructure: '${Constant.folderStructurePath}/adsImage',
      extension: 'jpg',
    );
  }

  static Future<String?> _compressAndUploadVideo(
    File video, {
    required bool isShort,
  }) async {
    if (!video.existsSync()) return null;

    File uploadFile = video;
    try {
      final compressed = await VideoCompressor.compress(
        input: video.path,
        isShort: isShort,
      );
      if (compressed != null && File(compressed).existsSync()) {
        final size = await File(compressed).length();
        if (size > 10000) {
          uploadFile = File(compressed);
          AppSettings.showLog(
            'Ad video size => ${(size / 1024 / 1024).toStringAsFixed(2)} MB',
          );
        }
      }
    } catch (e) {
      AppSettings.showLog('Ads video compression skipped => $e');
    }

    _setStatus('Uploading ad video...');
    return _uploadFile(
      file: uploadFile,
      folderStructure: '${Constant.folderStructurePath}/adsVideo',
      extension: 'mp4',
      timeoutMinutes: 15,
    );
  }

  static Future<String?> _uploadFile({
    required File file,
    required String folderStructure,
    required String extension,
    int timeoutMinutes = 5,
  }) async {
    if (!file.existsSync()) {
      AppSettings.showLog('_uploadFile: file missing');
      return null;
    }

    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${Constant.baseURL}${Constant.fileUpload}'),
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
