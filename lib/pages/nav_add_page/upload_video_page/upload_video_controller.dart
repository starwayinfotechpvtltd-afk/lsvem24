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
import 'package:metube/pages/nav_library_page/your_video_page/your_video_page.dart';
import 'package:metube/pages/profile_page/your_channel_page/channel_video_page/get_channel_video_api.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:metube/utils/helpers/media_path_helper.dart';
import 'package:metube/utils/navigation/navigation_observer.dart';

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
        if (!NavigationObserver.isNavigating &&
    (Get.isDialogOpen ?? false || Get.key.currentState?.canPop() == true)) {
  Get.back();
}
      } else {
        if (!NavigationObserver.isNavigating &&
    (Get.isDialogOpen ?? false || Get.key.currentState?.canPop() == true)) {
  Get.back();
}
      }
    } catch (e) {
      if (!NavigationObserver.isNavigating &&
    (Get.isDialogOpen ?? false || Get.key.currentState?.canPop() == true)) {
  Get.back();
}
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
      if (!NavigationObserver.isNavigating &&
    (Get.isDialogOpen ?? false || Get.key.currentState?.canPop() == true)) {
  Get.back();
}
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

  Future<void> _ensureVideoDuration(String videoPath) async {
    if (videoTime.value > 0) return;
    if (videoPlayerController?.value.isInitialized ?? false) {
      videoTime.value = videoPlayerController!.value.duration.inMilliseconds;
      if (videoTime.value > 0) return;
    }
    try {
      final controller =
          VideoPlayerController.file(File(localFilePath(videoPath)));
      await controller.initialize();
      videoTime.value = controller.value.duration.inMilliseconds;
      await controller.dispose();
    } catch (e) {
      AppSettings.showLog('Video duration read failed: $e');
    }
  }

  Future<void> onUploadVideoProcess(
    String videoPath,
    int videoType,
    String loginUserId,
    String loginUserChannelId,
  ) async {
    final uploadNotificationId = DateTime.now().millisecondsSinceEpoch % 100000;
    final videoTypeName = videoType == 1 ? "Long Video" : "Short Video";
    final displayTitle = videoTitleController.text.trim().isNotEmpty
        ? videoTitleController.text.trim()
        : videoTypeName;

    try {
      if (!CustomCheckInternet.isConnect.value) {
        CustomToast.show(AppStrings.connectionIssue.tr);
        return;
      }

      if (!localFileExists(videoPath)) {
        throw Exception('Video file not found. Please select the video again.');
      }

      onStopVideoPlay();

      LocalNotificationServices.showUploadProgressNotification(
        id: uploadNotificationId,
        title: "Uploading $videoTypeName",
        body: "Preparing video...",
        progress: 5,
      );

      final effectiveChannelId =
          loginUserChannelId.isNotEmpty ? loginUserChannelId : '';
      print("channelId=$effectiveChannelId");

      if (channelName.text.trim().isEmpty &&
          (Database.channelId == null || Database.channelId!.isEmpty)) {
        channelName.text = 'channel_${DateTime.now().millisecondsSinceEpoch}';
      }

      String safeVideoPath = localFilePath(videoPath);
      print("Using original file:");
      print(safeVideoPath);

      await _ensureVideoDuration(safeVideoPath);

      String finalVideo = safeVideoPath;

      if (!localFileExists(thumbnail.value)) {
        await onGetThumbnail(finalVideo);
      }

      String finalThumb =
          thumbnail.value.isNotEmpty ? localFilePath(thumbnail.value) : '';

      if (!localFileExists(finalThumb)) {
        throw Exception('Thumbnail could not be generated');
      }

      AppSettings.showLog('Thumb size => ${await File(finalThumb).length()}');

      LocalNotificationServices.showUploadProgressNotification(
        id: uploadNotificationId,
        title: "Uploading $videoTypeName",
        body: "Uploading thumbnail...",
        progress: 15,
      );

      final uploadedThumbnail = await ConvertVideoImageApi.callApi(
        finalThumb,
        videoType == 1,
        onProgress: (p) {
          final currentProgress = 15 + (p * 15).toInt();
          LocalNotificationServices.showUploadProgressNotification(
            id: uploadNotificationId,
            title: "Uploading $videoTypeName",
            body: "Uploading thumbnail (${(p * 100).toInt()}%)...",
            progress: currentProgress,
          );
        },
      );

      if (uploadedThumbnail == null || uploadedThumbnail.isEmpty) {
        throw Exception('Thumbnail upload failed');
      }

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

      LocalNotificationServices.showUploadProgressNotification(
        id: uploadNotificationId,
        title: "Uploading $videoTypeName",
        body: "Uploading video...",
        progress: 30,
      );

      final uploadedVideo = await ConvertVideoApi.callApi(
        finalVideo,
        videoType == 1,
        onProgress: (p) {
          final currentProgress = 30 + (p * 60).toInt();
          LocalNotificationServices.showUploadProgressNotification(
            id: uploadNotificationId,
            title: "Uploading $videoTypeName",
            body: "Uploading video (${(p * 100).toInt()}%)...",
            progress: currentProgress,
          );
        },
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

      LocalNotificationServices.showUploadProgressNotification(
        id: uploadNotificationId,
        title: "Uploading $videoTypeName",
        body: "Saving video details...",
        progress: 95,
      );

      AppSettings.showLog('Uploaded video => $uploadedVideo');
      AppSettings.showLog('Uploaded thumbnail => $uploadedThumbnail');

      print("uploadedVideo = $uploadedVideo");
      print("uploadedThumbnail = $uploadedThumbnail");
      print("loginUserId=[$loginUserId]");
      print("channelId=[$effectiveChannelId]");

      final uploadResult = await UploadVideoApi.callApi(
        title: videoTitleController.text.trim().isEmpty
            ? "${DateTime.now().day.toString().padLeft(2, '0')}-"
                "${DateTime.now().month.toString().padLeft(2, '0')}-"
                "${DateTime.now().year}"
            : videoTitleController.text,
        description: videoDescriptionController.text,
        hashTag: hashTagCollection,
        videoType: videoType,
        videoTime: videoTime.value,
        visibilityType: selectVisibility.value,
        audienceType: selectAudience.value,
        commentType: selectComments.value,
        scheduleType: scheduleType.value,
        scheduleTime: selectDate.value,
        location: selectCounty.value,
        latitude: latitude.toString(),
        longitude: longitude.toString(),
        loginUserId:
            loginUserId.isNotEmpty ? loginUserId : (Database.loginUserId ?? ''),
        loginChannelId: effectiveChannelId,
        videoUrl: uploadedVideo,
        videoImage: uploadedThumbnail,
        channelDescription: channelDescription.text,
        channelName: channelName.text,
        videoPrivacyType: videoChargeType.value,
      );

      if (uploadResult.success) {
        LocalNotificationServices.showUploadSuccessNotification(
          id: uploadNotificationId,
          title: '$videoTypeName Upload Complete',
          body: displayTitle,
          function: () {
            GetChannelVideoApiClass.startPagination[0] = 0;
            GetChannelVideoApiClass.startPagination[1] = 0;
            libraryController.mainChannelVideos[0] = null;
            libraryController.mainChannelVideos[1] = null;
            libraryController.typeWiseGetChannelVideo(0);
            _openYourVideos();
          },
        );
        await GetProfileApi.callApi(Database.loginUserId ?? '');
        CustomToast.show('Upload completed');
      } else {
        LocalNotificationServices.showUploadFailedNotification(
          id: uploadNotificationId,
          title: '$videoTypeName Upload Failed',
          body: uploadResult.message ?? 'Upload failed',
        );
        throw Exception(uploadResult.message ?? 'Upload failed');
      }

      await onDeleteDirectory();
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      LocalNotificationServices.showUploadFailedNotification(
        id: uploadNotificationId,
        title: '$videoTypeName Upload Failed',
        body: message.isNotEmpty ? message : 'Upload failed',
      );

      CustomToast.show(message.isNotEmpty ? message : 'Upload failed');
      debugPrint('❌ UPLOAD ERROR: $e');
      AppSettings.showLog('Upload Error => $e');

      await onDeleteDirectory();
    }
  }

  void _openYourVideos() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Get.context == null) return;

      await Future.delayed(const Duration(milliseconds: 200));

      if (Get.currentRoute != "/YourVideoPageView") {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future.delayed(const Duration(milliseconds: 250));

          if (Get.context == null) return;

          if (!NavigationObserver.isNavigating) {
            Get.to(() => const YourVideoPageView());
          }
        });
      }
    });
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
        _openYourVideos();
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
              name.startsWith('c_')) {
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
