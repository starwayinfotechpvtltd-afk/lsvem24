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

  void onGetThumbnail(String videoPath) async {
    thumbnail.value = "";
    final appDir = await getApplicationDocumentsDirectory();
    final thumbDir = Directory('${appDir.path}/thumbnails');
    if (!thumbDir.existsSync()) await thumbDir.create(recursive: true);
    try {
      final videoThumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        timeMs: -1,
        maxHeight: 400,
        quality: 100,
      );
      if (videoThumbnail != null) {
        thumbnail.value = videoThumbnail;
      }
    } catch (e) {
      debugPrint("Get Thumbnail Error !! => $e");
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
    videoPlayerController = VideoPlayerController.file(File(videoUrl));
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

  void onUploadVideoProcess(String videoPath, int videoType, String loginUserId,
      String loginUserChannelId) async {
    if (CustomCheckInternet.isConnect.value) {
      Get.back();
      onStopVideoPlay();

      AppSettings.isUploading.value = true;
      CustomToast.show(AppStrings.videoUploading.tr);

      // ✅ Allow upload without channel — auto-fill channel name if missing
      final effectiveChannelId =
          loginUserChannelId.isNotEmpty ? loginUserChannelId : "";

      if (channelName.text.trim().isEmpty &&
          (Database.channelId == null || Database.channelId!.isEmpty)) {
        channelName.text =
            "channel_${Database.loginUserId ?? DateTime.now().millisecondsSinceEpoch}";
        AppSettings.showLog(
            "⚠️ No channel found — auto channel name set: ${channelName.text}");
      }

      // ✅ Copy video to safe path
      String safeVideoPath = videoPath;
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final uploadDir = Directory('${appDir.path}/pending_uploads');
        if (!uploadDir.existsSync()) await uploadDir.create(recursive: true);
        final fileName = 'upload_${DateTime.now().millisecondsSinceEpoch}.mp4';
        safeVideoPath = '${uploadDir.path}/$fileName';
        await File(videoPath).copy(safeVideoPath);
        AppSettings.showLog("✅ Video safe path: $safeVideoPath");
      } catch (e) {
        AppSettings.showLog("⚠️ Copy failed, using original: $e");
        safeVideoPath = videoPath;
      }

      AppSettings.showLog("Video Path => $safeVideoPath");

      if (thumbnail.value != "") {
        final videoThumbnail = await ConvertVideoImageApi.callApi(
            thumbnail.value, videoType == 1 ? true : false);

        if (videoThumbnail != null) {
          final videoUrl = await ConvertVideoApi.callApi(
              safeVideoPath, videoType == 1 ? true : false);

          if (videoUrl != null) {
            final isSuccess = await UploadVideoApi.callApi(
              title: videoTitleController.text.trim().isEmpty
                  ? "${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}"
                  : videoTitleController.text.trim(),
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
              loginUserId: loginUserId,
              loginChannelId: effectiveChannelId, // ✅ safe even if empty
              videoUrl: videoUrl,
              videoImage: videoThumbnail,
              channelDescription: channelDescription.text,
              channelName: channelName.text, // ✅ auto-filled if no channel
              videoPrivacyType: videoChargeType.value,
            );

            AppSettings.isUploading.value = false;
            if (isSuccess) {
              sendNotification("Upload Success", videoTitleController.text);
              // ✅ Always refresh profile — picks up newly created channel too
              await GetProfileApi.callApi(Database.loginUserId ?? "");
              AppSettings.showLog("✅ Profile refreshed after upload");
            } else {
              sendNotification("Upload Failed !!", videoTitleController.text);
            }
            onDeleteDirectory();
          } else {
            AppSettings.showLog("Get Video Url Failed !!!");
            CustomToast.show(AppStrings.someThingWentWrong.tr);
            AppSettings.isUploading.value = false;
          }
        } else {
          AppSettings.showLog("Get Video Thumbnail Failed !!!");
          CustomToast.show(AppStrings.someThingWentWrong.tr);
          AppSettings.isUploading.value = false;
          sendNotification("Upload Failed !!", videoTitleController.text);
        }
      } else {
        AppSettings.showLog("Thumbnail empty!");
        CustomToast.show(AppStrings.someThingWentWrong.tr);
        AppSettings.isUploading.value = false;
        sendNotification("Upload Failed !!", videoTitleController.text);
      }
    } else {
      CustomToast.show(AppStrings.connectionIssue.tr);
      AppSettings.showLog("Internet Connection Failed !!!");
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
              name.startsWith('upload_')) {
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
