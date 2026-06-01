import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/pages/nav_add_page/upload_video_page/upload_video_model.dart';
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';

class UploadResult {
  final bool success;
  final String? message;
  const UploadResult({required this.success, this.message});
}

class UploadVideoApi {
  static UploadVideoModel? _uploadVideoModel;
  static Future<UploadResult> callApi({
    required String title,
    required String description,
    required List hashTag,
    required int videoType,
    required int videoTime,
    required int visibilityType,
    required int audienceType,
    required int commentType,
    required int scheduleType,
    required String scheduleTime,
    required String location,
    required String latitude,
    required String longitude,
    required String loginUserId,
    required String loginChannelId,
    required String videoUrl,
    required String videoImage,
    required String channelName,
    required String channelDescription,
    required int videoPrivacyType,
  }) async {
    AppSettings.showLog("Upload Video Api Calling...$scheduleType");

    try {
      final uri = Uri.parse(Constant.baseURL + Constant.uploadVideo);
      print('Upload video API URI: ${Constant.baseURL + Constant.uploadVideo}');

      var headers = {
 'key': Constant.secretKey,
 'Content-Type': 'application/json'
};


      final body = json.encode(scheduleType == 1 // SCHEDULED
          ? {
              "title": title,
              "description": description,
              "hashTag": hashTag,
              "videoType": videoType,
              "videoTime": videoTime,
              "visibilityType": visibilityType + 1,
              "audienceType": audienceType + 1,
              "commentType": commentType + 1,
              "scheduleType": scheduleType,
              "scheduleTime": scheduleTime,
              "location": location,
              "latitude": latitude,
              "longitude": longitude,
              "userId": loginUserId,
              "channelId": loginChannelId,
              "fullName": channelName,
              "descriptionOfChannel": channelDescription,
              "videoUrl": videoUrl,
              "videoImage": videoImage,
              "videoPrivacyType": videoPrivacyType,
              "channelType": AppSettings.channelType.value.toString(),
            }
          : {
              "title": title,
              "description": description,
              "hashTag": hashTag,
              "videoType": videoType,
              "videoTime": videoTime,
              "visibilityType": visibilityType + 1,
              "audienceType": audienceType + 1,
              "commentType": commentType + 1,
              "scheduleType": scheduleType,
              "location": location,
              "latitude": latitude,
              "longitude": longitude,
              "userId": loginUserId,
              "channelId": loginChannelId,
              "fullName": channelName,
              "descriptionOfChannel": channelDescription,
              "videoUrl": videoUrl,
              "videoImage": videoImage,
              "videoPrivacyType": videoPrivacyType,
              "channelType": AppSettings.channelType.value.toString(),
            });

print("REQUEST BODY:");
print(body);
      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      );
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("HEADERS: ${response.headers}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        AppSettings.showLog("Upload Video Api Response => $jsonResponse");
        _uploadVideoModel = UploadVideoModel.fromJson(jsonResponse);

        if (_uploadVideoModel?.status ?? false) {
          CustomToast.show(AppStrings.videoUploadSuccessfully.tr);
          return const UploadResult(success: true);
        }
        final msg = _uploadVideoModel?.message?.toString() ?? 'Upload failed';
        AppSettings.showLog('Upload Video Api failed => $msg');
        return UploadResult(success: false, message: msg);
      } else {
        AppSettings.showLog(
          'Upload Video Api Status Code Error => ${response.statusCode}',
        );
        return UploadResult(
          success: false,
          message: 'Server error (${response.statusCode})',
        );
      }
    } catch (e) {
      AppSettings.showLog('Upload Video Api Error => $e');
      return UploadResult(success: false, message: e.toString());
    }
  }
}
