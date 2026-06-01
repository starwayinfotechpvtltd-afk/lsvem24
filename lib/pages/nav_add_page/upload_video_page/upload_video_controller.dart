import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:metube/custom/custom_method/custom_check_internet.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/notification/local_notification_services.dart';
import 'package:metube/pages/custom_pages/file_upload_page/convert_video_api.dart';
import 'package:metube/pages/custom_pages/file_upload_page/convert_video_image_api.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/pages/admin_settings/admin_settings_api.dart';
import 'package:metube/pages/nav_add_page/upload_video_page/upload_video_api.dart';
import 'package:metube/pages/nav_library_page/main_page/nav_library_controller.dart';
import 'package:metube/pages/main_home_page/main_home_view.dart';
import 'package:metube/pages/nav_library_page/your_video_page/your_video_page.dart';
import 'package:metube/pages/profile_page/your_channel_page/channel_video_page/get_channel_video_api.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:path_provider/path_provider.dart'; 
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:metube/utils/compressor/video_compressor.dart';
import 'package:metube/utils/compressor/image_compressor.dart';
import 'package:metube/utils/helpers/media_path_helper.dart';

class UploadVideoController extends GetxController {
  final libraryController = Get.put(NavLibraryPageController());
  
  TextEditingController videoTitleController = TextEditingController();
  TextEditingController videoDescriptionController = TextEditingController();
  TextEditingController videoHashtagController = TextEditingController();

  TextEditingController channelName =
      TextEditingController(); // This is Use to Create Channel...
  TextEditingController channelDescription =
      TextEditingController(); // This is Use to Create Channel...

  RxList hashTagCollection = [].obs;

  RxInt selectVisibility = 0.obs;

  RxInt selectAudience = 0.obs;

  RxInt videoChargeType = 1.obs;

  RxString selectDate = AppStrings.now.tr.obs;

  RxInt scheduleType = 2.obs; // [1 - Selected Data  2 - Now]

  RxInt selectComments = 0.obs;

  RxString thumbnail = "".obs;

  Future<void> onGetThumbnail(String videoPath) async {
    thumbnail.value = "";
    if (!localFileExists(videoPath)) return;

    final normalizedVideo = localFilePath(videoPath);
    final appDir = await getApplicationDocumentsDirectory();
    final thumbDir = Directory('${appDir.path}/thumbnails');
    if (!thumbDir.existsSync()) await thumbDir.create(recursive: true);

    for (final timeMs in [1000, 0, 3000]) {
      try {
        final videoThumbnail = await VideoThumbnail.thumbnailFile(
          video: normalizedVideo,
          thumbnailPath: thumbDir.path,
          imageFormat: ImageFormat.JPEG,
          timeMs: timeMs,
          maxHeight: 720,
          quality: 85,
        );
        if (videoThumbnail != null && localFileExists(videoThumbnail)) {
          thumbnail.value = localFilePath(videoThumbnail);
          return;
        }
      } catch (e) {
        debugPrint("Get Thumbnail ($timeMs ms) => $e");
      }
    }
  }

  Future<void> pickImage() async {
    try {
      Get.dialog(const LoaderUi(color: AppColor.white),
          barrierDismissible: false);
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        AppSettings.showLog("Pick Image Path => ${image.path}");
        thumbnail.value = image.path;
        Get.back();
      } else {
        Get.back();
      }
    } catch (e) {
      Get.back();
      AppSettings.showLog("Image Picker Error => $e");
    }
  }

  RxString selectCounty = "".obs;
  double latitude = 0.0;
  double longitude = 0.0;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  RxInt videoTime = 0.obs;
  RxBool isPlaying = false.obs;

  Future<void> initializeVideoPlayer(String videoUrl) async {
    if (!localFileExists(videoUrl)) {
      CustomToast.show(AppStrings.someThingWentWrong.tr);
      return;
    }
    videoPlayerController =
        VideoPlayerController.file(File(localFilePath(videoUrl)));
    try {
      await videoPlayerController?.initialize();

      if (videoPlayerController?.value.isInitialized ?? false) {
        videoTime.value = videoPlayerController!.value.duration.inMilliseconds;

        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          autoPlay: false,
          looping: false,
          allowedScreenSleep: false,
          allowMuting: false,
          showControlsOnInitialize: false,
          showControls: false,
        );

        update(["initializeVideoPlayer"]);

        if (videoPlayerController!.value.isInitialized) {
          update(["onProgressLine", "onVideoTime"]);
        }

        videoPlayerController?.addListener(() {
          if (videoPlayerController!.value.position >=
              videoPlayerController!.value.duration) {
            isPlaying.value = false;
          }
          if (videoPlayerController!.value.isInitialized) {
            update(["onProgressLine", "onVideoTime"]);
          }
        });
      }
    } catch (e) {
      chewieController?.dispose();
      chewieController = null;
      videoPlayerController?.dispose();
      update(["initializeVideoPlayer"]);
      Get.back();
      CustomToast.show(AppStrings.someThingWentWrong.tr);
      AppSettings.showLog("Video Loading Failed => $e");
    }
  }

  void onStopVideoPlay() {
    if (isPlaying.value) {
      isPlaying.value = false;
      videoPlayerController?.pause();
    }
  }

  void _setUploadStatus(String message) {
    AppSettings.uploadStatusMessage.value = message;
    debugPrint('📤 UPLOAD: $message');
  }

  Future<void> _ensureVideoDuration(String videoPath) async {
    if (videoTime.value > 0) return;
    if (videoPlayerController?.value.isInitialized ?? false) {
      videoTime.value = videoPlayerController!.value.duration.inMilliseconds;
      if (videoTime.value > 0) return;
    }
    try {
      final controller = VideoPlayerController.file(File(localFilePath(videoPath)));
      await controller.initialize();
      videoTime.value = controller.value.duration.inMilliseconds;
      await controller.dispose();
    } catch (e) {
      AppSettings.showLog('Video duration read failed: $e');
    }
  }

  void _showUploadLoader() {
    if (Get.isDialogOpen ?? false) return;
    Get.dialog(
      PopScope(
        canPop: false,
        child: Obx(
          () => LoaderUi(
            color: AppColor.white,
            message: AppSettings.uploadStatusMessage.value,
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _hideUploadLoader() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  Future<void> onUploadVideoProcess(
    String videoPath,
    int videoType,
    String loginUserId,
    String loginUserChannelId,
  ) async {
    try {
      if (!CustomCheckInternet.isConnect.value) {
        CustomToast.show(AppStrings.connectionIssue.tr);
        return;
      }

      if (!localFileExists(videoPath)) {
        throw Exception('Video file not found. Please select the video again.');
      }

      onStopVideoPlay();

      AppSettings.isUploading.value = true;
      _showUploadLoader();
      // _setUploadStatus('Preparing video...');

      final effectiveChannelId =
          loginUserChannelId.isNotEmpty ? loginUserChannelId : '';
          print("channelId=$effectiveChannelId");

      if (channelName.text.trim().isEmpty &&
          (Database.channelId == null || Database.channelId!.isEmpty)) {
        channelName.text =
            'channel_${DateTime.now().millisecondsSinceEpoch}';
      }

      String safeVideoPath = localFilePath(videoPath);
      print(
  "Using original file:"
);

print(
  safeVideoPath
);

      // try {
      //   final appDir = await getApplicationDocumentsDirectory();
      //   final uploadDir = Directory('${appDir.path}/pending_uploads');
      //   if (!uploadDir.existsSync()) {
      //     await uploadDir.create(recursive: true);
      //   }
      //   final copiedFile = File(
      //     '${uploadDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4',
      //   );
      //   await File(safeVideoPath).copy(copiedFile.path);
      //   safeVideoPath = copiedFile.path;
      // } catch (e) {
      //   AppSettings.showLog('Video copy skipped, using original path: $e');
      // }

      await _ensureVideoDuration(safeVideoPath);

      String finalVideo = safeVideoPath;

      // Optional light compression (skipped for large files; server optimizes too).
      final sizeMb =
(await File(safeVideoPath).length()) /
1024 /
1024;

if (sizeMb > 300) {
  // _setUploadStatus(
  //   "Large video detected. Optimizing..."
  // );
}

      // _setUploadStatus("Optimizing video...");

try {

  final compressed =
      await VideoCompressor.compress(
        input: safeVideoPath,
        isShort: videoType == 2,
      );

  if (
      compressed != null &&
      localFileExists(compressed)) {

    finalVideo =
        localFilePath(compressed);

    final mb =
        await File(finalVideo)
            .length() /
        1024 /
        1024;

    print(
      "Final compressed size: "
      "${mb.toStringAsFixed(2)} MB",
    );
  }

} catch (e) {
  debugPrint(
    "Compression skipped: $e",
  );
}

      // _setUploadStatus('Preparing thumbnail...');
      if (!localFileExists(thumbnail.value)) {
        await onGetThumbnail(finalVideo);
      }

      String finalThumb = thumbnail.value.isNotEmpty
          ? localFilePath(thumbnail.value)
          : '';

      // Use thumbnail as-is (VideoThumbnail already outputs JPEG).
      // ImageCompressor can fail on some Android devices (ImageDecoder errors).

      if (!localFileExists(finalThumb)) {
        throw Exception('Thumbnail could not be generated');
      }

      // _setUploadStatus('Uploading thumbnail...');
      AppSettings.showLog('Thumb size => ${await File(finalThumb).length()}');

      final compressedThumb =
        await ImageCompressor.compress(
        finalThumb,
        );

        if (compressedThumb != null) {
        finalThumb = compressedThumb;
        }

      final uploadedThumbnail = await ConvertVideoImageApi.callApi(
        finalThumb,
        videoType == 1,
      );

      if (uploadedThumbnail == null || uploadedThumbnail.isEmpty) {
        throw Exception('Thumbnail upload failed');
      }

      // _setUploadStatus('Uploading video...');

      if (!localFileExists(finalVideo)) {
        throw Exception('Video file is missing after processing');
      }

      final size = await File(finalVideo).length();
      AppSettings.showLog(
        'Upload size => ${(size / 1024 / 1024).toStringAsFixed(2)} MB',
      );

      if (size < 1024) {
        throw Exception('Video file is too small or corrupted');
      }
      final uploadedVideo = await ConvertVideoApi.callApi(
        finalVideo,
        videoType == 1,
      );

      if (uploadedVideo == null || uploadedVideo.isEmpty) {
        throw Exception('Video upload failed');
      }

      if (videoTime.value <= 0) {
        videoTime.value = 1000;
      }

      if (videoType == 2) {
        final maxMs =
            AdminSettingsApi.adminSettingsModel?.setting?.durationOfShorts ??
                60000;
        if (maxMs > 0 && videoTime.value > maxMs) {
          throw Exception(
            'Shorts must be ${maxMs ~/ 1000} seconds or less',
          );
        }
      }

      // _setUploadStatus('Saving video details...');
      AppSettings.showLog('Uploaded video => $uploadedVideo');
      AppSettings.showLog('Uploaded thumbnail => $uploadedThumbnail');

print("uploadedVideo = $uploadedVideo");
print("uploadedThumbnail = $uploadedThumbnail");
print("loginUserId=[$loginUserId]");
print("channelId=[$effectiveChannelId]");
      final uploadResult = await UploadVideoApi.callApi(

title:
videoTitleController
.text
.trim()
.isEmpty

?

"${DateTime.now().day.toString().padLeft(2,'0')}-"
"${DateTime.now().month.toString().padLeft(2,'0')}-"
"${DateTime.now().year}"

:

videoTitleController.text,

description:
videoDescriptionController.text,

hashTag:
hashTagCollection,

videoType:
videoType,

videoTime:
videoTime.value,

visibilityType:
selectVisibility.value,

audienceType:
selectAudience.value,

commentType:
selectComments.value,

scheduleType:
scheduleType.value,

scheduleTime:
selectDate.value,

location:
selectCounty.value,

latitude:
latitude.toString(),

longitude:
longitude.toString(),

loginUserId:
loginUserId.isNotEmpty
    ? loginUserId
    : (Database.loginUserId ?? ''),

loginChannelId:
effectiveChannelId,

videoUrl:
uploadedVideo,

videoImage:
uploadedThumbnail,

channelDescription:
channelDescription.text,

channelName:
channelName.text,

videoPrivacyType:
videoChargeType.value,

      );

      AppSettings.isUploading.value = false;
      _hideUploadLoader();

      if (uploadResult.success) {
        sendNotification('Upload Success', videoTitleController.text);
        await GetProfileApi.callApi(Database.loginUserId ?? '');
        CustomToast.show('Upload completed');
        Get.offAll(() => const MainHomePageView());
      } else {
        sendNotification('Upload Failed', videoTitleController.text);
        throw Exception(uploadResult.message ?? 'Upload failed');
      }

      await onDeleteDirectory();
    } catch (e) {
      AppSettings.isUploading.value = false;
      _hideUploadLoader();

      sendNotification('Upload Failed', videoTitleController.text);

      final message = e.toString().replaceFirst('Exception: ', '');
      CustomToast.show(message.isNotEmpty ? message : 'Upload failed');

      debugPrint('❌ UPLOAD ERROR: $e');
      AppSettings.showLog('Upload Error => $e');

      await onDeleteDirectory();
    }
  }

  void sendNotification(String title, String body) {
    LocalNotificationServices.onSendNotification(
      title,
      body,
      () {
        GetChannelVideoApiClass.startPagination[0] = 0;
        GetChannelVideoApiClass.startPagination[1] = 0;
        libraryController.mainChannelVideos[0] = null;
        libraryController.mainChannelVideos[1] = null;
        libraryController.typeWiseGetChannelVideo(0);
        Get.to(() => const YourVideoPageView());
      },
    );
  }

  Future<void> onDeleteDirectory() async {
    try {
      // Delete pending uploads folder
      final appDir = await getApplicationDocumentsDirectory();
      final uploadDir = Directory('${appDir.path}/pending_uploads');
      if (uploadDir.existsSync()) {
        await uploadDir.delete(recursive: true);
        debugPrint('✅ pending_uploads removed');
      }

      // Delete thumbnails folder
      final thumbDir = Directory('${appDir.path}/thumbnails');
      if (thumbDir.existsSync()) {
        await thumbDir.delete(recursive: true);
        debugPrint('✅ thumbnails removed');
      }

      // Delete only YOUR temp files (RM_ and FV_ prefixes from FFmpeg)
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        final files = tempDir.listSync();
        for (final file in files) {
          final name = file.path.split('/').last;
          if (name.startsWith('RM_') ||
              name.startsWith('FV_') ||
              name.startsWith('upload_') ||
              name.startsWith('c_')
              ) {
            try {
              await file.delete(recursive: true);
            } catch (_) {}
          }
        }
        debugPrint('✅ Selective temp cleanup done');
      }
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }
}

// This is Upload Variable

// String upTitle = "";
// String upDescription = "";
// String upCountry = "";
// List upHashTag = [];
// int upVisibilityType = 0;
// int upAudienceType = 0;
// int upCommentType = 0;
// int upScheduleType = 0;
// int upVideoTime = 0;

// upVideoTime = videoTime.value;
// upTitle = videoTitleController.text;
// upDescription = videoDescriptionController.text;
// upHashTag = hashTagCollection;
// upVisibilityType = selectVisibility.value;
// upAudienceType = selectAudience.value;
// upCommentType = selectComments.value;
// upScheduleType = scheduleType.value;
// upCountry = selectCounty.value;

// final videoTime = await CustomVideoTime.onGet(videoPath);

// final videoSize = await CustomVideoSize.onGet(videoPath);

//
// if (videoTime != null && videoSize != null) {
//   final videoThumbnail = await CustomGetThumbnail.onGet(videoPath, videoType);

// Compress Video
// if ((videoTime <= 180000 && videoSize >= 10) || videoType == 2) {
//   final compressVideoPath = await CustomVideoCompress.onCompress(videoPath);
//   if (compressVideoPath != null) {
//     final videoSize = await CustomVideoSize.onGet(compressVideoPath);
//     AppSettings.showLog("Final Upload Video Size => $videoSize");
//     final videoUrl = await ConvertVideoApi.callApi(compressVideoPath, videoType == 1 ? true : false);
//     if (videoUrl != null) {
//       await onCallUploadApi(
//           videoUrl: videoUrl, videoThumbnail: videoThumbnail, videoTime: videoTime, videoType: videoType, loginUserId: loginUserId, loginUserChannelId: loginUserChannelId);
//     } else {
//       AppSettings.showLog("Convert Video Failed !!!");
//       CustomToast.show("Some Thing Went Wrong Please Try Again");
//     }
//   } else {
//     AppSettings.showLog("Compress Video Failed !!!");
//     CustomToast.show("Some Thing Went Wrong Please Try Again");
//   }
// }
// WithOut Compress Video
// else {
// AppSettings.showLog("Selected Video Not Compress");
// final videoSize = await CustomVideoSize.onGet(videoPath);
// AppSettings.showLog("Final Upload Video Size => $videoSize");

//
// chewieController?.dispose();
// chewieController = null;
// videoPlayerController.dispose();

// else {
//   AppSettings.showLog("Get Video Time Failed !!!");
//   CustomToast.show(AppStrings.someThingWentWrong.tr);
// }

// AppSettings.isUploading.value = false;

// void onCloseEvent() {
//   onStopVideoPlay();
//   chewieController?.dispose();
//   chewieController = null;
//   update(["initializeVideoPlayer"]);
//
//   videoTitleController.clear();
//   videoDescriptionController.clear();
//   hashTagCollection.clear();
//   selectCounty.value = "";
// }

// int? convertedVideoTime;
// String? convertedVideoUrl;
// String? convertedVideoImage;

// RxInt selectAgeRestriction = 0.obs;
// final List ageRestrictionCollection = [
//   "Yes, restrict my video to viewers over 18",
//   "No, don’t restrict my video to viewers over 18",
// ];
