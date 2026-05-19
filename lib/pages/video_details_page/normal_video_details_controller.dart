// import 'dart:developer';
//
// import 'package:chewie/chewie.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:metube/database/database.dart';
// import 'package:metube/database/watch_history_database.dart';
// import 'package:metube/pages/nav_home_page/controller/nav_home_controller.dart';
// import 'package:metube/pages/nav_library_page/history_page/create_watch_history_api.dart';
// import 'package:metube/pages/profile_page/content_engagement_page/video_engagement_reward_api.dart';
// import 'package:metube/pages/profile_page/your_channel_page/main_page/your_channel_controller.dart';
// import 'package:metube/pages/video_details_page/get_related_video_api.dart';
// import 'package:metube/pages/video_details_page/get_related_video_model.dart';
// import 'package:metube/pages/video_details_page/video_details_api.dart';
// import 'package:metube/pages/video_details_page/video_details_model.dart';
// import 'package:metube/utils/services/convert_to_network.dart';
// import 'package:metube/utils/settings/app_settings.dart';
// import 'package:video_player/video_player.dart';
//
// class NormalVideoDetailsController extends GetxController {
//   final yourChannelController = Get.find<YourChannelController>();
//
//   TextEditingController commentController = TextEditingController();
//
//   ScrollController scrollController = ScrollController();
//
//   GetRelatedVideoModel? _getRelatedVideoModel;
//   VideoDetailsModel? videoDetailsModel;
//
//   VideoPlayerController? videoPlayerController;
//   ChewieController? chewieController;
//
//   List<Data>? mainRelatedVideos;
//
//   int selectedWatchedVideo = 0;
//   List<WatchedVideoModel> mainWatchedVideos = [];
//
//   String videoId = "";
//
//   RxBool isLike = false.obs;
//   RxBool isDisLike = false.obs;
//   RxBool isSubscribe = false.obs;
//   RxBool isSave = false.obs;
//   RxMap customChanges = {"like": 0, "disLike": 0, "comment": 0, "share": 0}.obs;
//
//   RxBool isDisableNext = false.obs;
//   RxBool isDisablePrevious = false.obs;
//
//   bool isVideoLoading = false;
//   bool isShowVideoControls = false;
//   RxBool isVideoDetailsLoading = true.obs;
//
//   RxBool isDownloading = false.obs;
//
//   RxBool isLoop = false.obs;
//   RxBool isSpeaker = true.obs;
//   RxInt currentSpeedIndex = 2.obs;
//   final List<double> speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
//
//   // Video Engagement Reward...
//
//   bool isVideoSkip = false;
//   bool isGetVideoRewardCoin = false;
//
//   @override
//   void onInit() {
//     // TODO: implement onInit
//
//     ///
//     adCompleted = false;
//
//     super.onInit();
//   }
//
//   Future<void> init(String videoId, String videoUrl) async {
//     this.videoId = videoId;
//     onGetRelatedVideos(videoId);
//     onGetVideoDetails(videoId);
//
//     await initializeVideoPlayer(videoId, videoUrl);
//   }
//
//   void onGetPlayListVideos() {
//     if (yourChannelController.selectedPlayList != null) {
//       AppSettings.showLog("Selected PlayList => ${yourChannelController.selectedPlayList}");
//       for (int i = 0; i < yourChannelController.channelPlayList![yourChannelController.selectedPlayList!].videos!.length; i++) {
//         if (yourChannelController.selectedPlayListVideo < i) {
//           final index = yourChannelController.channelPlayList![yourChannelController.selectedPlayList!].videos![i];
//           mainWatchedVideos.add(WatchedVideoModel(videoId: index.videoId!, videoUrl: index.videoUrl!));
//         }
//       }
//     }
//   }
//
//   Future<void> onGetRelatedVideos(String videoId) async {
//     mainRelatedVideos = null;
//     _getRelatedVideoModel = await GetRelatedVideoApi.callApi(loginUserId: Database.loginUserId!, videoId: videoId);
//
//     if (_getRelatedVideoModel != null) {
//       mainRelatedVideos = _getRelatedVideoModel?.data ?? [];
//     }
//     AppSettings.showLog("Playing Related Video Length => ${mainRelatedVideos?.length}");
//
//     mainRelatedVideos?.shuffle();
//
//     update(["onGetRelatedVideos"]);
//
//     if (mainRelatedVideos?.isEmpty ?? true && mainWatchedVideos.length == 1) {
//       isDisableNext(true);
//     }
//
//     try {
//       scrollController.animateTo(0, duration: const Duration(milliseconds: 10), curve: Curves.ease);
//     } catch (e) {
//       log("Scrolling Failed");
//     }
//   }
//
//   Future<void> onGetVideoDetails(String videoId) async {
//     isVideoDetailsLoading.value = true;
//
//     // >>>>>>>>>>>> This is Used to Clear Previous Data <<<<<<<<<<<<
//     videoDetailsModel = null;
//
//     videoDetailsModel = await VideoDetailsApi.callApi(Database.loginUserId!, videoId, 1);
//     if (videoDetailsModel != null) {
//       isLike.value = videoDetailsModel?.detailsOfVideo?.isLike ?? false;
//       isDisLike.value = videoDetailsModel?.detailsOfVideo?.isDislike ?? false;
//       isSubscribe.value = videoDetailsModel?.detailsOfVideo?.isSubscribed ?? false;
//       isSave.value = videoDetailsModel?.detailsOfVideo?.isSaveToWatchLater ?? false;
//
//       customChanges["like"] = videoDetailsModel!.detailsOfVideo!.like!;
//       customChanges["disLike"] = videoDetailsModel!.detailsOfVideo!.dislike!;
//       customChanges["comment"] = videoDetailsModel!.detailsOfVideo!.totalComments!;
//       customChanges["subscribe"] = videoDetailsModel!.detailsOfVideo!.totalSubscribers!;
//
//       isVideoDetailsLoading.value = false;
//
//       createWatchHistory();
//
//       // >>>>>>>>>>>> This is Used to Increase Views <<<<<<<<<<<<
//     }
//   }
//
//   Future<void> onCreateHistory() async {
//     if (Database.channelId != null && videoPlayerController != null && videoDetailsModel?.detailsOfVideo != null) {
//       final watchTime = videoPlayerController!.value.position.inSeconds / 60;
//       AppSettings.showLog("Video Watch Time => $watchTime");
//
//       if (isVideoSkip == false) {
//         await CreateWatchHistoryApi.callApi(
//           loginUserId: Database.loginUserId!,
//           videoId: videoDetailsModel!.detailsOfVideo!.id!,
//           videoChannelId: videoDetailsModel!.detailsOfVideo!.channelId!,
//           videoUserId: videoDetailsModel!.detailsOfVideo!.userId!,
//           watchTimeInMinute: watchTime,
//         );
//       }
//     }
//   }
//
//   void onToggleVolume() {
//     if (isSpeaker.value) {
//       isSpeaker.value = false;
//       videoPlayerController?.setVolume(0);
//     } else {
//       videoPlayerController?.setVolume(100);
//       isSpeaker.value = true;
//     }
//   }
//
//   // Future<void> initializeVideoPlayer(String videoId, String videoUrl) async {
//   //   try {
//   //     isVideoSkip = false;
//   //     isGetVideoRewardCoin = false;
//   //
//   //     // String videoPath = Database.onGetVideoUrl(videoId) ?? await ConvertToNetwork.normalVideo(videoUrl);
//   //     String videoPath = Database.onGetVideoUrl(videoId) ?? await ConvertToNetwork.convert(videoUrl);
//   //
//   //     videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoPath));
//   //
//   //     await videoPlayerController?.initialize();
//   //
//   //     if (videoPlayerController != null && (videoPlayerController?.value.isInitialized ?? false)) {
//   //       if (Database.onGetVideoUrl(videoId) == null) {
//   //         Database.onSetVideoUrl(videoId, videoPath);
//   //       }
//   //       // chewieController = (orientation == Orientation.portrait)
//   //       //     ? ChewieController(
//   //       //         videoPlayerController: videoPlayerController!,
//   //       //         aspectRatio: Get.width / (Get.height / 3.5),
//   //       //         autoPlay: true,
//   //       //         looping: isLoop.value,
//   //       //         allowedScreenSleep: false,
//   //       //         allowMuting: false,
//   //       //         showControlsOnInitialize: false,
//   //       //         showControls: false,
//   //       //       )
//   //       //     :
//   //       chewieController = ChewieController(
//   //         videoPlayerController: videoPlayerController!,
//   //         // aspectRatio: Get.width / Get.height,
//   //         autoPlay: false,
//   //         looping: isLoop.value,
//   //         allowedScreenSleep: false,
//   //         allowMuting: false,
//   //         showControlsOnInitialize: false,
//   //         showControls: false,
//   //       );
//   //
//   //       videoPlayerController?.addListener(
//   //         () async {
//   //           //  >>>>>>>>>>>>>>>>>>>>>>>> Use To Close Page After Stop Video <<<<<<<<<<<<<<<<<<<<<<<<<
//   //
//   //           if (Get.currentRoute != "/NormalVideoDetailsView") {
//   //             videoPlayerController?.pause();
//   //             AppSettings.showLog("Video Playing Routes Changes...");
//   //           }
//   //
//   //           if ((videoPlayerController?.value.isInitialized ?? false)) {
//   //             if (videoPlayerController!.value.isBuffering) {
//   //               if (isVideoLoading == false) {
//   //                 isVideoLoading = true;
//   //                 update(["onLoading"]);
//   //               }
//   //             } else {
//   //               if (isVideoLoading == true) {
//   //                 isVideoLoading = false;
//   //                 update(["onLoading"]);
//   //               }
//   //             }
//   //             update(["onProgressLine", "onVideoTime", "onVideoPlayPause"]);
//   //
//   //             //  >>>>>>>>>>>>>>>>>>>>>>>> Use To Finish Video After Condition <<<<<<<<<<<<<<<<<<<<<<<<<
//   //
//   //             if (videoPlayerController!.value.position >= videoPlayerController!.value.duration) {
//   //               AppSettings.showLog("Playing Video Complete...");
//   //
//   //               AppSettings.showLog("Video Engagement Reward Method Calling...");
//   //
//   //               if (isGetVideoRewardCoin == false && isVideoSkip == false) {
//   //                 isGetVideoRewardCoin = true;
//   //                 VideoEngagementRewardApi.callApi(
//   //                     loginUserId: Database.loginUserId ?? "",
//   //                     videoId: videoId,
//   //                     totalWatchTime: videoPlayerController!.value.duration.inSeconds.toString());
//   //               }
//   //
//   //               onCreateHistory();
//   //               if (AppSettings.isAutoPlayVideo.value) {
//   //                 if ((mainRelatedVideos?.isNotEmpty ?? false) && mainWatchedVideos.length != 1) {
//   //                   isDisablePrevious(false);
//   //                 }
//   //
//   //                 selectedWatchedVideo++;
//   //
//   //                 if (selectedWatchedVideo < mainWatchedVideos.length) {
//   //                   onDisposeVideoPlayer();
//   //                   init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
//   //                 } else if (mainRelatedVideos?.isNotEmpty ?? false) {
//   //                   onCreateHistory();
//   //                   onDisposeVideoPlayer();
//   //                   isDisablePrevious(false);
//   //                   mainWatchedVideos.insert(
//   //                       selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
//   //                   init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
//   //                   mainRelatedVideos = null;
//   //                   update(["onGetRelatedVideos"]);
//   //                 } else {
//   //                   isDisableNext(true);
//   //                 }
//   //                 // if (selectedWatchedVideo == (mainWatchedVideos.length - 1)) {
//   //                 //   isDisableNext(true);
//   //                 // }
//   //               }
//   //             }
//   //           }
//   //         },
//   //       );
//   //
//   //       if (isSpeaker.value == false) {
//   //         videoPlayerController?.setVolume(0);
//   //       }
//   //     }
//   //
//   //     update(["onVideoInitialize"]);
//   //   } catch (e) {
//   //     AppSettings.showLog("Normal Video Initialization Failed => $e");
//   //     onDisposeVideoPlayer();
//   //   }
//   // }
//
//   ///
//
//   Future<void> initializeVideoPlayer(String videoId, String videoUrl) async {
//     try {
//       isVideoSkip = false;
//       isGetVideoRewardCoin = false;
//
//       String videoPath = Database.onGetVideoUrl(videoId) ?? await ConvertToNetwork.convert(videoUrl);
//
//       videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoPath));
//
//       await videoPlayerController?.initialize();
//
//       if (videoPlayerController != null && (videoPlayerController?.value.isInitialized ?? false)) {
//         if (Database.onGetVideoUrl(videoId) == null) {
//           Database.onSetVideoUrl(videoId, videoPath);
//         }
//
//         chewieController = ChewieController(
//           videoPlayerController: videoPlayerController!,
//           autoPlay: true, // Don't auto-play, we'll control this manually
//           looping: isLoop.value,
//           allowedScreenSleep: false,
//           allowMuting: false,
//           showControlsOnInitialize: false,
//           showControls: false,
//         );
//
//         videoPlayerController?.addListener(
//           () async {
//             if (Get.currentRoute != "/NormalVideoDetailsView") {
//               videoPlayerController?.pause();
//               AppSettings.showLog("Video Playing Routes Changes...");
//             }
//
//             if ((videoPlayerController?.value.isInitialized ?? false)) {
//               if (videoPlayerController!.value.isBuffering) {
//                 if (isVideoLoading == false) {
//                   isVideoLoading = true;
//                   update(["onLoading"]);
//                 }
//               } else {
//                 if (isVideoLoading == true) {
//                   isVideoLoading = false;
//                   update(["onLoading"]);
//                 }
//               }
//               update(["onProgressLine", "onVideoTime", "onVideoPlayPause"]);
//
//               if (videoPlayerController!.value.position >= videoPlayerController!.value.duration) {
//                 AppSettings.showLog("Playing Video Complete...");
//
//                 if (isGetVideoRewardCoin == false && isVideoSkip == false) {
//                   isGetVideoRewardCoin = true;
//                   VideoEngagementRewardApi.callApi(
//                       loginUserId: Database.loginUserId ?? "",
//                       videoId: videoId,
//                       totalWatchTime: videoPlayerController!.value.duration.inSeconds.toString());
//                 }
//
//                 onCreateHistory();
//                 if (AppSettings.isAutoPlayVideo.value) {
//                   if ((mainRelatedVideos?.isNotEmpty ?? false) && mainWatchedVideos.length != 1) {
//                     isDisablePrevious(false);
//                   }
//
//                   selectedWatchedVideo++;
//
//                   if (selectedWatchedVideo < mainWatchedVideos.length) {
//                     onDisposeVideoPlayer();
//                     init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
//                   } else if (mainRelatedVideos?.isNotEmpty ?? false) {
//                     onCreateHistory();
//                     onDisposeVideoPlayer();
//                     isDisablePrevious(false);
//                     mainWatchedVideos.insert(
//                         selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
//                     init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
//                     mainRelatedVideos = null;
//                     update(["onGetRelatedVideos"]);
//                   } else {
//                     isDisableNext(true);
//                   }
//                 }
//               }
//             }
//           },
//         );
//
//         if (isSpeaker.value == false) {
//           videoPlayerController?.setVolume(0);
//         }
//       }
//
//       update(["onVideoInitialize"]);
//     } catch (e) {
//       AppSettings.showLog("Normal Video Initialization Failed => $e");
//       onDisposeVideoPlayer();
//     }
//   }
//
//   void onChangeVideoLoading() {
//     isVideoLoading = !isVideoLoading;
//     update(["onChangeVideoLoading"]);
//   }
//
//   void onDisposeVideoPlayer() {
//     videoPlayerController?.dispose();
//     chewieController?.dispose();
//     chewieController = null;
//     update(["onVideoInitialize"]);
//   }
//
//   void onNextVideo() {
//     isDisablePrevious(false);
//
//     selectedWatchedVideo++;
//
//     if (selectedWatchedVideo != mainWatchedVideos.length) {
//       onDisposeVideoPlayer();
//       onCreateHistory();
//       init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
//     } else if (mainRelatedVideos?.isNotEmpty ?? false) {
//       onCreateHistory();
//       onDisposeVideoPlayer();
//       isDisablePrevious(false);
//       mainWatchedVideos.insert(
//           selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
//       init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
//       mainRelatedVideos = null;
//       update(["onGetRelatedVideos"]);
//     } else {
//       isDisableNext(true);
//     }
//     // if (selectedWatchedVideo == (mainWatchedVideos.length - 1)) {
//     //   isDisableNext(true);
//     // }
//   }
//
//   void onPreviousVideo() async {
//     isDisableNext(false);
//
//     selectedWatchedVideo--;
//     if (selectedWatchedVideo >= 0) {
//       onDisposeVideoPlayer();
//       init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
//     }
//     if (selectedWatchedVideo == 0) {
//       isDisablePrevious(true);
//     }
//   }
//
//   // Future<void> onRotate(double aspectRatio) async {
//   // if (videoPlayerController != null) {
//   //   chewieController = null;
//   //
//   //   chewieController = ChewieController(
//   //     videoPlayerController: videoPlayerController!,
//   //     aspectRatio: aspectRatio,
//   //     looping: isLoop.value,
//   //     allowedScreenSleep: false,
//   //     allowMuting: false,
//   //     showControlsOnInitialize: false,
//   //     showControls: false,
//   //   );
//   //   update(["onVideoInitialize"]);
//   // }
//   // }
//
//   Future<void> onChangeLoop() async {
//     if (videoPlayerController != null) {
//       chewieController = null;
//
//       chewieController = ChewieController(
//         videoPlayerController: videoPlayerController!,
//         looping: isLoop.value,
//         allowedScreenSleep: false,
//         allowMuting: false,
//         showControlsOnInitialize: false,
//         showControls: false,
//       );
//       update(["onVideoInitialize"]);
//     }
//   }
//
//   void createWatchHistory() async {
//     if (AppSettings.isCreateHistory.value) {
//       AppSettings.showLog("Create Watch History Method Called");
//       bool isAvailable = false;
//       for (int index = 0; index < WatchHistory.mainWatchHistory.length; index++) {
//         if (WatchHistory.mainWatchHistory[index]["videoId"] == videoDetailsModel!.detailsOfVideo!.id) {
//           AppSettings.showLog("Replace Watch History");
//           WatchHistory.mainWatchHistory.insert(0, WatchHistory.mainWatchHistory.removeAt(index));
//           isAvailable = true;
//           break;
//         } else {
//           AppSettings.showLog("Not Match");
//         }
//       }
//       if (isAvailable == false) {
//         AppSettings.showLog("Create New Watch History");
//         WatchHistory.mainWatchHistory.insert(
//           0,
//           {
//             "id": DateTime.now().millisecondsSinceEpoch,
//             "videoId": videoDetailsModel!.detailsOfVideo!.id,
//             "videoTitle": videoDetailsModel!.detailsOfVideo!.title,
//             "videoType": videoDetailsModel!.detailsOfVideo!.videoType,
//             "videoTime": videoDetailsModel!.detailsOfVideo!.videoTime,
//             "videoUrl": videoDetailsModel!.detailsOfVideo!.videoUrl,
//             "videoImage": videoDetailsModel!.detailsOfVideo!.videoImage,
//             "views": videoDetailsModel!.detailsOfVideo!.views,
//             "channelName": videoDetailsModel!.detailsOfVideo!.channelName,
//           },
//         );
//       }
//       WatchHistory.onSet();
//     }
//   }
//
//   void showVideoControls() {
//     isShowVideoControls = !isShowVideoControls;
//     update(["onShowControls"]);
//   }
//
//   Future<void> forwardSkipVideo() async {
//     await videoPlayerController?.seekTo((await videoPlayerController?.position)! + const Duration(seconds: 10));
//     isVideoSkip = true;
//   }
//
//   Future<void> backwardSkipVideo() async {
//     await videoPlayerController?.seekTo((await videoPlayerController?.position)! - const Duration(seconds: 10));
//   }
//
//   ///
//
//   bool adCompleted = false;
//   @override
//   void onClose() {
//     videoPlayerController?.dispose();
//     chewieController?.dispose();
//     super.onClose();
//   }
//
//   void onAdCompleted() {
//     debugPrint('Ad completed, starting video playback');
//     adCompleted = true;
//
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
//         videoPlayerController?.play();
//       }
//       update(["onVideoInitialize", "onAdCompleted"]);
//     });
//   }
//
//   RxBool isLoadingAds = true.obs;
// }
//
// class WatchedVideoModel {
//   final String videoId;
//   final String videoUrl;
//   WatchedVideoModel({required this.videoId, required this.videoUrl});
// }

import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/long_video_ads/get_long_video_ads_api.dart';
import 'package:metube/pages/long_video_ads/long_video_ad_model.dart';
import 'package:metube/database/watch_history_database.dart';
import 'package:metube/pages/nav_library_page/history_page/create_watch_history_api.dart';
import 'package:metube/pages/profile_page/content_engagement_page/video_engagement_reward_api.dart';
import 'package:metube/pages/profile_page/your_channel_page/main_page/your_channel_controller.dart';
import 'package:metube/pages/video_details_page/get_related_video_api.dart';
import 'package:metube/pages/video_details_page/get_related_video_model.dart';
import 'package:metube/pages/video_details_page/video_details_api.dart';
import 'package:metube/pages/video_details_page/video_details_model.dart';
import 'package:metube/utils/services/convert_to_network.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/utils.dart';
import 'package:video_player/video_player.dart';

//
// class NormalVideoDetailsController extends GetxController {
//   final yourChannelController = Get.find<YourChannelController>();
//
//   TextEditingController commentController = TextEditingController();
//
//   ScrollController scrollController = ScrollController();
//
//   GetRelatedVideoModel? _getRelatedVideoModel;
//   VideoDetailsModel? videoDetailsModel;
//
//   VideoPlayerController? videoPlayerController;
//   ChewieController? chewieController;
//
//   List<Data>? mainRelatedVideos;
//
//   int selectedWatchedVideo = 0;
//   List<WatchedVideoModel> mainWatchedVideos = [];
//
//   String videoId = "";
//
//   RxBool isLike = false.obs;
//   RxBool isDisLike = false.obs;
//   RxBool isSubscribe = false.obs;
//   RxBool isSave = false.obs;
//   RxMap customChanges = {"like": 0, "disLike": 0, "comment": 0, "share": 0}.obs;
//
//   RxBool isDisableNext = false.obs;
//   RxBool isDisablePrevious = false.obs;
//
//   bool isVideoLoading = false;
//   bool isShowVideoControls = false;
//   RxBool isVideoDetailsLoading = true.obs;
//
//   RxBool isDownloading = false.obs;
//
//   RxBool isLoop = false.obs;
//   RxBool isSpeaker = true.obs;
//   RxInt currentSpeedIndex = 2.obs;
//   final List<double> speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
//
//   // Video Engagement Reward...
//
//   bool isVideoSkip = false;
//   bool isGetVideoRewardCoin = false;
//
//   @override
//   void onInit() {
//     // TODO: implement onInit
//
//     ///
//     _preloadVideo();
//     adCompleted = false;
//
//     super.onInit();
//   }
//
//   Future<void> init(String videoId, String videoUrl) async {
//     this.videoId = videoId;
//     onGetRelatedVideos(videoId);
//     onGetVideoDetails(videoId);
//
//     await initializeVideoPlayer(videoId, videoUrl);
//   }
//
//   void onGetPlayListVideos() {
//     if (yourChannelController.selectedPlayList != null) {
//       AppSettings.showLog("Selected PlayList => ${yourChannelController.selectedPlayList}");
//       for (int i = 0; i < yourChannelController.channelPlayList![yourChannelController.selectedPlayList!].videos!.length; i++) {
//         if (yourChannelController.selectedPlayListVideo < i) {
//           final index = yourChannelController.channelPlayList![yourChannelController.selectedPlayList!].videos![i];
//           mainWatchedVideos.add(WatchedVideoModel(videoId: index.videoId!, videoUrl: index.videoUrl!));
//         }
//       }
//     }
//   }
//
//   Future<void> onGetRelatedVideos(String videoId) async {
//     mainRelatedVideos = null;
//     _getRelatedVideoModel = await GetRelatedVideoApi.callApi(loginUserId: Database.loginUserId!, videoId: videoId);
//
//     if (_getRelatedVideoModel != null) {
//       mainRelatedVideos = _getRelatedVideoModel?.data ?? [];
//     }
//     AppSettings.showLog("Playing Related Video Length => ${mainRelatedVideos?.length}");
//
//     mainRelatedVideos?.shuffle();
//
//     update(["onGetRelatedVideos"]);
//
//     if (mainRelatedVideos?.isEmpty ?? true && mainWatchedVideos.length == 1) {
//       isDisableNext(true);
//     }
//
//     try {
//       scrollController.animateTo(0, duration: const Duration(milliseconds: 10), curve: Curves.ease);
//     } catch (e) {
//       log("Scrolling Failed");
//     }
//   }
//
//   Future<void> onGetVideoDetails(String videoId) async {
//     isVideoDetailsLoading.value = true;
//
//     // >>>>>>>>>>>> This is Used to Clear Previous Data <<<<<<<<<<<<
//     videoDetailsModel = null;
//
//     videoDetailsModel = await VideoDetailsApi.callApi(Database.loginUserId!, videoId, 1);
//     if (videoDetailsModel != null) {
//       isLike.value = videoDetailsModel?.detailsOfVideo?.isLike ?? false;
//       isDisLike.value = videoDetailsModel?.detailsOfVideo?.isDislike ?? false;
//       isSubscribe.value = videoDetailsModel?.detailsOfVideo?.isSubscribed ?? false;
//       isSave.value = videoDetailsModel?.detailsOfVideo?.isSaveToWatchLater ?? false;
//
//       customChanges["like"] = videoDetailsModel!.detailsOfVideo!.like!;
//       customChanges["disLike"] = videoDetailsModel!.detailsOfVideo!.dislike!;
//       customChanges["comment"] = videoDetailsModel!.detailsOfVideo!.totalComments!;
//       customChanges["subscribe"] = videoDetailsModel!.detailsOfVideo!.totalSubscribers!;
//
//       isVideoDetailsLoading.value = false;
//
//       createWatchHistory();
//
//       // >>>>>>>>>>>> This is Used to Increase Views <<<<<<<<<<<<
//     }
//   }
//
//   Future<void> onCreateHistory() async {
//     if (Database.channelId != null && videoPlayerController != null && videoDetailsModel?.detailsOfVideo != null) {
//       final watchTime = videoPlayerController!.value.position.inSeconds / 60;
//       AppSettings.showLog("Video Watch Time => $watchTime");
//
//       if (isVideoSkip == false) {
//         await CreateWatchHistoryApi.callApi(
//           loginUserId: Database.loginUserId!,
//           videoId: videoDetailsModel!.detailsOfVideo!.id!,
//           videoChannelId: videoDetailsModel!.detailsOfVideo!.channelId!,
//           videoUserId: videoDetailsModel!.detailsOfVideo!.userId!,
//           watchTimeInMinute: watchTime,
//         );
//       }
//     }
//   }
//
//   void onToggleVolume() {
//     if (isSpeaker.value) {
//       isSpeaker.value = false;
//       videoPlayerController?.setVolume(0);
//     } else {
//       videoPlayerController?.setVolume(100);
//       isSpeaker.value = true;
//     }
//   }
//
//   ///
//
//   Future<void> initializeVideoPlayer(String videoId, String videoUrl) async {
//     try {
//       isVideoSkip = false;
//       isGetVideoRewardCoin = false;
//
//       String videoPath = Database.onGetVideoUrl(videoId) ?? await ConvertToNetwork.convert(videoUrl);
//
//       videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoPath));
//
//       await videoPlayerController?.initialize();
//
//       if (videoPlayerController != null && (videoPlayerController?.value.isInitialized ?? false)) {
//         if (Database.onGetVideoUrl(videoId) == null) {
//           Database.onSetVideoUrl(videoId, videoPath);
//         }
//
//         chewieController = ChewieController(
//           videoPlayerController: videoPlayerController!,
//           autoPlay: true, // Don't auto-play, we'll control this manually
//           looping: isLoop.value,
//           allowedScreenSleep: false,
//           allowMuting: false,
//           showControlsOnInitialize: false,
//           showControls: false,
//         );
//
//         videoPlayerController?.addListener(
//           () async {
//             if (Get.currentRoute != "/NormalVideoDetailsView") {
//               videoPlayerController?.pause();
//               AppSettings.showLog("Video Playing Routes Changes...");
//             }
//
//             if ((videoPlayerController?.value.isInitialized ?? false)) {
//               if (videoPlayerController!.value.isBuffering) {
//                 if (isVideoLoading == false) {
//                   isVideoLoading = true;
//                   update(["onLoading"]);
//                 }
//               } else {
//                 if (isVideoLoading == true) {
//                   isVideoLoading = false;
//                   update(["onLoading"]);
//                 }
//               }
//               update(["onProgressLine", "onVideoTime", "onVideoPlayPause"]);
//
//               if (videoPlayerController!.value.position >= videoPlayerController!.value.duration) {
//                 AppSettings.showLog("Playing Video Complete...");
//
//                 if (isGetVideoRewardCoin == false && isVideoSkip == false) {
//                   isGetVideoRewardCoin = true;
//                   VideoEngagementRewardApi.callApi(
//                       loginUserId: Database.loginUserId ?? "",
//                       videoId: videoId,
//                       totalWatchTime: videoPlayerController!.value.duration.inSeconds.toString());
//                 }
//
//                 onCreateHistory();
//                 if (AppSettings.isAutoPlayVideo.value) {
//                   if ((mainRelatedVideos?.isNotEmpty ?? false) && mainWatchedVideos.length != 1) {
//                     isDisablePrevious(false);
//                   }
//
//                   selectedWatchedVideo++;
//
//                   if (selectedWatchedVideo < mainWatchedVideos.length) {
//                     onDisposeVideoPlayer();
//                     init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
//                   } else if (mainRelatedVideos?.isNotEmpty ?? false) {
//                     onCreateHistory();
//                     onDisposeVideoPlayer();
//                     isDisablePrevious(false);
//                     mainWatchedVideos.insert(
//                         selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
//                     init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
//                     mainRelatedVideos = null;
//                     update(["onGetRelatedVideos"]);
//                   } else {
//                     isDisableNext(true);
//                   }
//                 }
//               }
//             }
//           },
//         );
//
//         if (isSpeaker.value == false) {
//           videoPlayerController?.setVolume(0);
//         }
//       }
//
//       update(["onVideoInitialize"]);
//     } catch (e) {
//       AppSettings.showLog("Normal Video Initialization Failed => $e");
//       onDisposeVideoPlayer();
//     }
//   }
//
//   void onChangeVideoLoading() {
//     isVideoLoading = !isVideoLoading;
//     update(["onChangeVideoLoading"]);
//   }
//
//   void onDisposeVideoPlayer() {
//     videoPlayerController?.dispose();
//     chewieController?.dispose();
//     chewieController = null;
//     update(["onVideoInitialize"]);
//   }
//
//   void onNextVideo() {
//     isDisablePrevious(false);
//
//     selectedWatchedVideo++;
//
//     if (selectedWatchedVideo != mainWatchedVideos.length) {
//       onDisposeVideoPlayer();
//       onCreateHistory();
//       init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
//     } else if (mainRelatedVideos?.isNotEmpty ?? false) {
//       onCreateHistory();
//       onDisposeVideoPlayer();
//       isDisablePrevious(false);
//       mainWatchedVideos.insert(
//           selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
//       init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
//       mainRelatedVideos = null;
//       update(["onGetRelatedVideos"]);
//     } else {
//       isDisableNext(true);
//     }
//     // if (selectedWatchedVideo == (mainWatchedVideos.length - 1)) {
//     //   isDisableNext(true);
//     // }
//   }
//
//   void onPreviousVideo() async {
//     isDisableNext(false);
//
//     selectedWatchedVideo--;
//     if (selectedWatchedVideo >= 0) {
//       onDisposeVideoPlayer();
//       init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
//     }
//     if (selectedWatchedVideo == 0) {
//       isDisablePrevious(true);
//     }
//   }
//
//   // Future<void> onRotate(double aspectRatio) async {
//   // if (videoPlayerController != null) {
//   //   chewieController = null;
//   //
//   //   chewieController = ChewieController(
//   //     videoPlayerController: videoPlayerController!,
//   //     aspectRatio: aspectRatio,
//   //     looping: isLoop.value,
//   //     allowedScreenSleep: false,
//   //     allowMuting: false,
//   //     showControlsOnInitialize: false,
//   //     showControls: false,
//   //   );
//   //   update(["onVideoInitialize"]);
//   // }
//   // }
//
//   Future<void> onChangeLoop() async {
//     if (videoPlayerController != null) {
//       chewieController = null;
//
//       chewieController = ChewieController(
//         videoPlayerController: videoPlayerController!,
//         looping: isLoop.value,
//         allowedScreenSleep: false,
//         allowMuting: false,
//         showControlsOnInitialize: false,
//         showControls: false,
//       );
//       update(["onVideoInitialize"]);
//     }
//   }
//
//   void createWatchHistory() async {
//     if (AppSettings.isCreateHistory.value) {
//       AppSettings.showLog("Create Watch History Method Called");
//       bool isAvailable = false;
//       for (int index = 0; index < WatchHistory.mainWatchHistory.length; index++) {
//         if (WatchHistory.mainWatchHistory[index]["videoId"] == videoDetailsModel!.detailsOfVideo!.id) {
//           AppSettings.showLog("Replace Watch History");
//           WatchHistory.mainWatchHistory.insert(0, WatchHistory.mainWatchHistory.removeAt(index));
//           isAvailable = true;
//           break;
//         } else {
//           AppSettings.showLog("Not Match");
//         }
//       }
//       if (isAvailable == false) {
//         AppSettings.showLog("Create New Watch History");
//         WatchHistory.mainWatchHistory.insert(
//           0,
//           {
//             "id": DateTime.now().millisecondsSinceEpoch,
//             "videoId": videoDetailsModel!.detailsOfVideo!.id,
//             "videoTitle": videoDetailsModel!.detailsOfVideo!.title,
//             "videoType": videoDetailsModel!.detailsOfVideo!.videoType,
//             "videoTime": videoDetailsModel!.detailsOfVideo!.videoTime,
//             "videoUrl": videoDetailsModel!.detailsOfVideo!.videoUrl,
//             "videoImage": videoDetailsModel!.detailsOfVideo!.videoImage,
//             "views": videoDetailsModel!.detailsOfVideo!.views,
//             "channelName": videoDetailsModel!.detailsOfVideo!.channelName,
//           },
//         );
//       }
//       WatchHistory.onSet();
//     }
//   }
//
//   void showVideoControls() {
//     isShowVideoControls = !isShowVideoControls;
//     update(["onShowControls"]);
//   }
//
//   Future<void> forwardSkipVideo() async {
//     await videoPlayerController?.seekTo((await videoPlayerController?.position)! + const Duration(seconds: 10));
//     isVideoSkip = true;
//   }
//
//   Future<void> backwardSkipVideo() async {
//     await videoPlayerController?.seekTo((await videoPlayerController?.position)! - const Duration(seconds: 10));
//   }
//
//   ///
//
//   bool adCompleted = false;
//
//   void onAdCompleted() {
//     debugPrint('Ad completed, starting video playback');
//     adCompleted = true;
//
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
//         videoPlayerController?.play();
//       }
//       update(["onVideoInitialize", "onAdCompleted"]);
//     });
//   }
//
//   RxBool isLoadingAds = true.obs;
//
//   ///
//
//   bool showAd = true;
//   bool isVideoReady = false;
//
//   void _preloadVideo() {
//     videoPlayerController = VideoPlayerController.network('${videoPlayerController}');
//
//     videoPlayerController!.initialize().then((_) {
//       // Create chewie controller but with autoPlay: false
//       chewieController = ChewieController(
//         videoPlayerController: videoPlayerController!,
//         autoPlay: true, // Don't auto-play
//         looping: false,
//       );
//
//       isVideoReady = true;
//       update();
//
//       log('Video preloaded but not started');
//     });
//   }
//
//   void onAdCompleted1() {
//     log('Ad completed, starting main video...');
//
//     showAd = false;
//     videoPlayerController!.play();
//     update(['adComplete']);
//
//     // // Start video playback after ad completes
//     // Future.delayed(const Duration(milliseconds: 300), () {
//     //   if (isVideoReady && videoPlayerController != null) {
//     //     videoPlayerController!.play();
//     //     log('Video playback started');
//     //   }
//     // });
//   }
//
//   @override
//   void onClose() {
//     videoPlayerController?.dispose();
//     chewieController?.dispose();
//     VideoAdServices.dispose();
//     super.onClose();
//   }
//
//   ///
// }
//
// class WatchedVideoModel {
//   final String videoId;
//   final String videoUrl;
//   WatchedVideoModel({required this.videoId, required this.videoUrl});
// }

///

/*class NormalVideoDetailsController extends GetxController {
  final yourChannelController = Get.find<YourChannelController>();

  TextEditingController commentController = TextEditingController();
  ScrollController scrollController = ScrollController();

  GetRelatedVideoModel? _getRelatedVideoModel;
  VideoDetailsModel? videoDetailsModel;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  List<Data>? mainRelatedVideos;

  int selectedWatchedVideo = 0;
  List<WatchedVideoModel> mainWatchedVideos = [];

  String videoId = "";

  RxBool isLike = false.obs;
  RxBool isDisLike = false.obs;
  RxBool isSubscribe = false.obs;
  RxBool isSave = false.obs;
  RxMap customChanges = {"like": 0, "disLike": 0, "comment": 0, "share": 0}.obs;

  RxBool isDisableNext = false.obs;
  RxBool isDisablePrevious = false.obs;

  bool isVideoLoading = false;
  bool isShowVideoControls = false;
  RxBool isVideoDetailsLoading = true.obs;

  RxBool isDownloading = false.obs;

  RxBool isLoop = false.obs;
  RxBool isSpeaker = true.obs;
  RxInt currentSpeedIndex = 2.obs;
  final List<double> speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  // Video Engagement Reward...
  bool isVideoSkip = false;
  bool isGetVideoRewardCoin = false;

  // Mid-roll ad variables - Updated for 30 second timing
  bool showAd = false;
  bool isAdLoading = false; // Add this for ad loading state
  bool isVideoReady = false;
  bool hasShownMidrollAd = false;
  Duration pausedPosition = Duration.zero;
  bool wasPlayingBeforeAd = false;
  int adShowCount = 0; // Track how many ads have been shown
  List<int> adTimings = [30, 60, 90, 120]; // Show ads at 30s, 60s, 90s, 120s etc.
  List<int> dotTiming = [35, 65, 95, 125]; // Show ads at 30s, 60s, 90s, 120s etc.

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> init(String videoId, String videoUrl) async {
    this.videoId = videoId;
    onGetRelatedVideos(videoId);
    onGetVideoDetails(videoId);

    await initializeVideoPlayer(videoId, videoUrl);
  }

  void onGetPlayListVideos() {
    if (yourChannelController.selectedPlayList != null) {
      AppSettings.showLog("Selected PlayList => ${yourChannelController.selectedPlayList}");
      for (int i = 0; i < yourChannelController.channelPlayList![yourChannelController.selectedPlayList!].videos!.length; i++) {
        if (yourChannelController.selectedPlayListVideo < i) {
          final index = yourChannelController.channelPlayList![yourChannelController.selectedPlayList!].videos![i];
          mainWatchedVideos.add(WatchedVideoModel(videoId: index.videoId!, videoUrl: index.videoUrl!));
        }
      }
    }
  }

  Future<void> onGetRelatedVideos(String videoId) async {
    mainRelatedVideos = null;
    _getRelatedVideoModel = await GetRelatedVideoApi.callApi(loginUserId: Database.loginUserId!, videoId: videoId);

    if (_getRelatedVideoModel != null) {
      mainRelatedVideos = _getRelatedVideoModel?.data ?? [];
    }
    AppSettings.showLog("Playing Related Video Length => ${mainRelatedVideos?.length}");

    mainRelatedVideos?.shuffle();

    update(["onGetRelatedVideos"]);

    if (mainRelatedVideos?.isEmpty ?? true && mainWatchedVideos.length == 1) {
      isDisableNext(true);
    }

    try {
      scrollController.animateTo(0, duration: const Duration(milliseconds: 10), curve: Curves.ease);
    } catch (e) {
      log("Scrolling Failed");
    }
  }

  Future<void> onGetVideoDetails(String videoId) async {
    isVideoDetailsLoading.value = true;

    videoDetailsModel = null;

    videoDetailsModel = await VideoDetailsApi.callApi(Database.loginUserId!, videoId, 1);
    if (videoDetailsModel != null) {
      isLike.value = videoDetailsModel?.detailsOfVideo?.isLike ?? false;
      isDisLike.value = videoDetailsModel?.detailsOfVideo?.isDislike ?? false;
      isSubscribe.value = videoDetailsModel?.detailsOfVideo?.isSubscribed ?? false;
      isSave.value = videoDetailsModel?.detailsOfVideo?.isSaveToWatchLater ?? false;

      customChanges["like"] = videoDetailsModel!.detailsOfVideo!.like!;
      customChanges["disLike"] = videoDetailsModel!.detailsOfVideo!.dislike!;
      customChanges["comment"] = videoDetailsModel!.detailsOfVideo!.totalComments!;
      customChanges["subscribe"] = videoDetailsModel!.detailsOfVideo!.totalSubscribers!;

      isVideoDetailsLoading.value = false;

      createWatchHistory();
    }
  }

  Future<void> onCreateHistory() async {
    if (Database.channelId != null && videoPlayerController != null && videoDetailsModel?.detailsOfVideo != null) {
      final watchTime = videoPlayerController!.value.position.inSeconds / 60;
      AppSettings.showLog("Video Watch Time => $watchTime");

      if (isVideoSkip == false) {
        await CreateWatchHistoryApi.callApi(
          loginUserId: Database.loginUserId!,
          videoId: videoDetailsModel!.detailsOfVideo!.id!,
          videoChannelId: videoDetailsModel!.detailsOfVideo!.channelId!,
          videoUserId: videoDetailsModel!.detailsOfVideo!.userId!,
          watchTimeInMinute: watchTime,
        );
      }
    }
  }

  void onToggleVolume() {
    if (isSpeaker.value) {
      isSpeaker.value = false;
      videoPlayerController?.setVolume(0);
    } else {
      videoPlayerController?.setVolume(100);
      isSpeaker.value = true;
    }
  }

  Future<void> initializeVideoPlayer(String videoId, String videoUrl) async {
    try {
      isVideoSkip = false;
      isGetVideoRewardCoin = false;
      hasShownMidrollAd = false;
      showAd = false;
      isAdLoading = false; // Reset ad loading state
      wasPlayingBeforeAd = false;
      adShowCount = 0; // Reset ad count for new video

      String videoPath = Database.onGetVideoUrl(videoId) ?? await ConvertToNetwork.convert(videoUrl);

      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoPath));

      await videoPlayerController?.initialize();

      if (videoPlayerController != null && (videoPlayerController?.value.isInitialized ?? false)) {
        if (Database.onGetVideoUrl(videoId) == null) {
          Database.onSetVideoUrl(videoId, videoPath);
        }

        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          autoPlay: true,
          looping: isLoop.value,
          allowedScreenSleep: false,
          allowMuting: false,
          showControlsOnInitialize: false,
          showControls: false,
        );

        videoPlayerController?.addListener(() async {
          if (Get.currentRoute != "/NormalVideoDetailsView") {
            videoPlayerController?.pause();
            AppSettings.showLog("Video Playing Routes Changes...");
          }

          if ((videoPlayerController?.value.isInitialized ?? false)) {
            if (videoPlayerController!.value.isBuffering) {
              if (isVideoLoading == false) {
                isVideoLoading = true;
                update(["onLoading"]);
              }
            } else {
              if (isVideoLoading == true) {
                isVideoLoading = false;
                update(["onLoading"]);
              }
            }
            update(["onProgressLine", "onVideoTime", "onVideoPlayPause"]);

            // Check for mid-roll ad timing (30 seconds intervals)
            _checkMidrollAdTiming();

            if (videoPlayerController!.value.position >= videoPlayerController!.value.duration) {
              AppSettings.showLog("Playing Video Complete...");

              if (isGetVideoRewardCoin == false && isVideoSkip == false) {
                isGetVideoRewardCoin = true;
                VideoEngagementRewardApi.callApi(
                    loginUserId: Database.loginUserId ?? "",
                    videoId: videoId,
                    totalWatchTime: videoPlayerController!.value.duration.inSeconds.toString());
              }

              onCreateHistory();
              if (AppSettings.isAutoPlayVideo.value) {
                if ((mainRelatedVideos?.isNotEmpty ?? false) && mainWatchedVideos.length != 1) {
                  isDisablePrevious(false);
                }

                selectedWatchedVideo++;

                if (selectedWatchedVideo < mainWatchedVideos.length) {
                  onDisposeVideoPlayer();
                  init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
                } else if (mainRelatedVideos?.isNotEmpty ?? false) {
                  onCreateHistory();
                  onDisposeVideoPlayer();
                  isDisablePrevious(false);
                  mainWatchedVideos.insert(
                      selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
                  init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
                  mainRelatedVideos = null;
                  update(["onGetRelatedVideos"]);
                } else {
                  isDisableNext(true);
                }
              }
            }
          }
        });

        if (isSpeaker.value == false) {
          videoPlayerController?.setVolume(0);
        }

        isVideoReady = true;
      }

      update(["onVideoInitialize"]);
    } catch (e) {
      AppSettings.showLog("Normal Video Initialization Failed => $e");
      onDisposeVideoPlayer();
    }
  }

  void _checkMidrollAdTiming() {
    // Check if we should show an ad at 30-second intervals
    if (!showAd && videoPlayerController != null && videoPlayerController!.value.isPlaying && adShowCount < adTimings.length) {
      int currentSeconds = videoPlayerController!.value.position.inSeconds;
      int targetTime = adTimings[adShowCount];

      // Show ad when video reaches the target time (30s, 60s, 90s, etc.)
      if (currentSeconds >= targetTime) {
        _showMidrollAd();
      }
    }
  }

// બેહતર approach - ad service ના callbacks વાપરો:

  void _showMidrollAd() {
    if (showAd) return;

    AppSettings.showLog("Showing mid-roll ad at ${videoPlayerController!.value.position.inSeconds} seconds");

    // Store current state
    wasPlayingBeforeAd = videoPlayerController?.value.isPlaying ?? false;
    pausedPosition = videoPlayerController!.value.position;

    // Pause the video
    videoPlayerController?.pause();

    // Show loading state first
    isAdLoading = true;
    showAd = true;
    adShowCount++; // Increment ad count

    update([
      "adComplete",
      "onVideoPlayPause",
      "onShowControls",
      "onProgressLine",
    ]);
  }

// Ad started callback - આ method call કરો જ્યારે ad actually start થાય
  void onAdStarted() {
    isAdLoading = false;
    AppSettings.showLog("Ad started playing, hiding loader");

    update(['adComplete']);
  }

// Ad failed callback - આ method call કરો જ્યારે ad load fail થાય
  void onAdFailed() {
    AppSettings.showLog("Ad failed to load, resuming video");
    showAd = false;
    isAdLoading = false;
    adShowCount--; // Decrement ad count as ad failed

    // Resume video
    if (videoPlayerController != null) {
      videoPlayerController!.seekTo(pausedPosition);
      if (wasPlayingBeforeAd) {
        Future.delayed(const Duration(milliseconds: 300), () {
          videoPlayerController?.play();
        });
      }
    }

    update(['adComplete', 'onVideoPlayPause']);
  }

  void onAdCompleted1() {
    log('Mid-roll ad completed, resuming video...');

    showAd = false;
    isAdLoading = false; // Reset loading state

    // Resume video from where it was paused if it was playing before ad
    if (videoPlayerController != null) {
      videoPlayerController!.seekTo(pausedPosition);

      // Only resume if video was playing before ad
      if (wasPlayingBeforeAd) {
        Future.delayed(const Duration(milliseconds: 300), () {
          videoPlayerController?.play();
        });
      }
    }

    update(['adComplete', 'onVideoPlayPause']);
  }

  void onChangeVideoLoading() {
    isVideoLoading = !isVideoLoading;
    update(["onChangeVideoLoading"]);
  }

  void onDisposeVideoPlayer() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    chewieController = null;
    showAd = false;
    isAdLoading = false; // Reset loading state
    hasShownMidrollAd = false;
    wasPlayingBeforeAd = false;
    adShowCount = 0; // Reset ad count
    update(["onVideoInitialize"]);
  }

  void onNextVideo() {
    isDisablePrevious(false);

    selectedWatchedVideo++;

    if (selectedWatchedVideo != mainWatchedVideos.length) {
      onDisposeVideoPlayer();
      onCreateHistory();
      init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
    } else if (mainRelatedVideos?.isNotEmpty ?? false) {
      onCreateHistory();
      onDisposeVideoPlayer();
      isDisablePrevious(false);
      mainWatchedVideos.insert(
          selectedWatchedVideo, WatchedVideoModel(videoId: mainRelatedVideos![0].id!, videoUrl: mainRelatedVideos![0].videoUrl!));
      init(mainRelatedVideos![0].id!, mainRelatedVideos![0].videoUrl!);
      mainRelatedVideos = null;
      update(["onGetRelatedVideos"]);
    } else {
      isDisableNext(true);
    }
  }

  void onPreviousVideo() async {
    isDisableNext(false);

    selectedWatchedVideo--;
    if (selectedWatchedVideo >= 0) {
      onDisposeVideoPlayer();
      init(mainWatchedVideos[selectedWatchedVideo].videoId, mainWatchedVideos[selectedWatchedVideo].videoUrl);
    }
    if (selectedWatchedVideo == 0) {
      isDisablePrevious(true);
    }
  }

  Future<void> onChangeLoop() async {
    if (videoPlayerController != null) {
      chewieController = null;

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        looping: isLoop.value,
        allowedScreenSleep: false,
        allowMuting: false,
        showControlsOnInitialize: false,
        showControls: false,
      );
      update(["onVideoInitialize"]);
    }
  }

  void createWatchHistory() async {
    if (AppSettings.isCreateHistory.value) {
      AppSettings.showLog("Create Watch History Method Called");
      bool isAvailable = false;
      for (int index = 0; index < WatchHistory.mainWatchHistory.length; index++) {
        if (WatchHistory.mainWatchHistory[index]["videoId"] == videoDetailsModel!.detailsOfVideo!.id) {
          AppSettings.showLog("Replace Watch History");
          WatchHistory.mainWatchHistory.insert(0, WatchHistory.mainWatchHistory.removeAt(index));
          isAvailable = true;
          break;
        } else {
          AppSettings.showLog("Not Match");
        }
      }
      if (isAvailable == false) {
        AppSettings.showLog("Create New Watch History");
        WatchHistory.mainWatchHistory.insert(
          0,
          {
            "id": DateTime.now().millisecondsSinceEpoch,
            "videoId": videoDetailsModel!.detailsOfVideo!.id,
            "videoTitle": videoDetailsModel!.detailsOfVideo!.title,
            "videoType": videoDetailsModel!.detailsOfVideo!.videoType,
            "videoTime": videoDetailsModel!.detailsOfVideo!.videoTime,
            "videoUrl": videoDetailsModel!.detailsOfVideo!.videoUrl,
            "videoImage": videoDetailsModel!.detailsOfVideo!.videoImage,
            "views": videoDetailsModel!.detailsOfVideo!.views,
            "channelName": videoDetailsModel!.detailsOfVideo!.channelName,
          },
        );
      }
      WatchHistory.onSet();
    }
  }

  void showVideoControls() {
    // Don't show controls during ad
    if (showAd) return;

    isShowVideoControls = !isShowVideoControls;
    update(["onShowControls"]);
  }

  Future<void> forwardSkipVideo() async {
    // Don't allow skip during ad
    if (showAd) return;

    await videoPlayerController?.seekTo((await videoPlayerController?.position)! + const Duration(seconds: 10));
    isVideoSkip = true;
  }

  Future<void> backwardSkipVideo() async {
    // Don't allow skip during ad
    if (showAd) return;

    await videoPlayerController?.seekTo((await videoPlayerController?.position)! - const Duration(seconds: 10));
  }

  @override
  void onClose() {
    videoPlayerController?.dispose();
    chewieController?.dispose();
    VideoAdServices.dispose();
    super.onClose();
  }
}

class WatchedVideoModel {
  final String videoId;
  final String videoUrl;
  WatchedVideoModel({required this.videoId, required this.videoUrl});
}*/
import 'package:metube/utils/constant/app_constant.dart';

class NormalVideoDetailsController extends GetxController {
  final yourChannelController = Get.find<YourChannelController>();

  TextEditingController commentController = TextEditingController();
  ScrollController scrollController = ScrollController();

  GetRelatedVideoModel? _getRelatedVideoModel;
  VideoDetailsModel? videoDetailsModel;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  List<Data>? mainRelatedVideos;

  int selectedWatchedVideo = 0;
  List<WatchedVideoModel> mainWatchedVideos = [];

  String videoId = "";

  RxBool isLike = false.obs;
  RxBool isDisLike = false.obs;
  RxBool isSubscribe = false.obs;
  RxBool isSave = false.obs;
  RxMap customChanges =
      {"like": 0, "disLike": 0, "comment": 0, "share": 0, "subscribe": 0}.obs;

  RxBool isDisableNext = false.obs;
  RxBool isDisablePrevious = false.obs;

  bool isVideoLoading = false;
  bool isShowVideoControls = false;
  bool isFullscreen = false;
  bool isFullscreenTransitioning = false;
  RxBool isVideoDetailsLoading = true.obs;

  RxBool isDownloading = false.obs;

  RxBool isLoop = false.obs;
  RxBool isSpeaker = true.obs;
  RxInt currentSpeedIndex = 2.obs;
  final List<double> speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  bool isVideoSkip = false;
  bool isGetVideoRewardCoin = false;

  bool showAd = false;
  bool isAdLoading = false;
  bool isVideoReady = false;
  bool hasShownMidrollAd = false;
  bool isPreRollAdPhase = false;
  bool mainVideoPlaybackStarted = false;
  Duration pausedPosition = Duration.zero;
  bool wasPlayingBeforeAd = false;
  int adShowCount = 0;

  List<int> adTimings = [];
  int totalAdsToShow = 2;
  int minAdInterval = 30;

  List<LongVideoAd> _preRollAds = [];
  List<LongVideoAd> _midRollAds = [];
  LongVideoAd? currentLongVideoAd;
  LongVideoAd? activeBannerAd;
  LongVideoAd? activeOverlayAd;
  final Random _adRandom = Random();

  bool get isShowingInterruptAd =>
      showAd && (currentLongVideoAd?.isInterruptType ?? false);

  LongVideoAd? _pickPreRollAd() {
    if (_preRollAds.isEmpty) return null;
    return _preRollAds[_adRandom.nextInt(_preRollAds.length)];
  }

  LongVideoAd? _pickMidRollAd() {
    if (_midRollAds.isEmpty) return null;
    return _midRollAds[_adRandom.nextInt(_midRollAds.length)];
  }

  Future<void> _loadLongVideoAds() async {
    final ads = await GetLongVideoAdsApi.callApi();
    _preRollAds = ads.where((a) => a.supportsPreRoll).toList();
    _midRollAds = ads.where((a) => a.supportsMidRoll).toList();
    AppSettings.showLog(
        'Long video ads loaded — pre-roll: ${_preRollAds.length}, mid-roll: ${_midRollAds.length}');
  }

  @override
  void onInit() {
    super.onInit();
  }

  bool get shouldSuppressMiniPlayer =>
      isFullscreen || isFullscreenTransitioning;

  Future<void> enterFullscreen() async {
    if (isFullscreenTransitioning || isFullscreen) return;

    isFullscreenTransitioning = true;
    isFullscreen = true;
    update(["onFullscreenMode"]);

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Color(0x00000000),
        systemNavigationBarColor: Color(0xFF000000),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    Future.delayed(const Duration(milliseconds: 700), () {
      isFullscreenTransitioning = false;
      update(["onFullscreenMode"]);
    });
  }

  Future<void> exitFullscreen() async {
    if (isFullscreenTransitioning) return;

    isFullscreenTransitioning = true;
    update(["onFullscreenMode"]);

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Future.delayed(const Duration(milliseconds: 700), () {
      isFullscreen = false;
      isFullscreenTransitioning = false;
      update(["onFullscreenMode"]);
    });
  }

  Future<void> restorePortraitMode() async {
    isFullscreen = false;
    isFullscreenTransitioning = false;
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  Future<void> init(String videoId, String videoUrl) async {
    this.videoId = videoId;
    AppSettings.showLog(
        "🎬 init() called — videoId: $videoId, videoUrl: $videoUrl");

    onGetRelatedVideos(videoId);
    onGetVideoDetails(videoId);
    await _loadLongVideoAds();

    await initializeVideoPlayer(videoId, videoUrl);
  }

  void _calculateAdTimings() {
    if (videoPlayerController == null ||
        !videoPlayerController!.value.isInitialized) {
      adTimings = [];
      return;
    }

    int totalVideoSeconds = videoPlayerController!.value.duration.inSeconds;
    adTimings.clear();

    AppSettings.showLog("Video total duration: $totalVideoSeconds seconds");

    if (totalVideoSeconds < 60) {
      adTimings = [];
      AppSettings.showLog("Video too short - No ads");
    } else {
      int firstAd = totalVideoSeconds ~/ 3;
      int secondAd = (totalVideoSeconds * 2) ~/ 3;

      if (firstAd < minAdInterval) firstAd = minAdInterval;
      if (secondAd - firstAd < minAdInterval)
        secondAd = firstAd + minAdInterval;

      if (totalVideoSeconds - secondAd < 30) {
        secondAd = totalVideoSeconds - 30;
        if (secondAd <= firstAd) {
          adTimings = [firstAd];
          AppSettings.showLog("Only 1 ad possible at: $adTimings");
        } else {
          adTimings = [firstAd, secondAd];
          AppSettings.showLog("2 ads scheduled at: $adTimings");
        }
      } else {
        adTimings = [firstAd, secondAd];
        AppSettings.showLog("2 ads scheduled at: $adTimings");
      }
    }

    adShowCount = 0;
    totalAdsToShow = adTimings.length;
  }

  bool shouldShowAdCountdown() {
    if (showAd ||
        videoPlayerController == null ||
        adShowCount >= adTimings.length) return false;

    int currentSeconds = videoPlayerController!.value.position.inSeconds;
    int nextAdTime = adTimings[adShowCount];

    return currentSeconds >= (nextAdTime - 10) && currentSeconds < nextAdTime;
  }

  int getSecondsUntilNextAd() {
    if (videoPlayerController == null || adShowCount >= adTimings.length)
      return 0;

    int currentSeconds = videoPlayerController!.value.position.inSeconds;
    int nextAdTime = adTimings[adShowCount];

    return nextAdTime - currentSeconds;
  }

  void onGetPlayListVideos() {
    if (yourChannelController.selectedPlayList != null) {
      for (int i = 0;
          i <
              yourChannelController
                  .channelPlayList![yourChannelController.selectedPlayList!]
                  .videos!
                  .length;
          i++) {
        if (yourChannelController.selectedPlayListVideo < i) {
          final index = yourChannelController
              .channelPlayList![yourChannelController.selectedPlayList!]
              .videos![i];
          mainWatchedVideos.add(WatchedVideoModel(
              videoId: index.videoId!, videoUrl: index.videoUrl!));
        }
      }
    }
  }

  Future<void> onGetRelatedVideos(String videoId) async {
    mainRelatedVideos = null;
    _getRelatedVideoModel = await GetRelatedVideoApi.callApi(
        loginUserId: Database.loginUserId ?? "", videoId: videoId);

    if (_getRelatedVideoModel != null) {
      mainRelatedVideos = _getRelatedVideoModel?.data ?? [];
    }
    AppSettings.showLog(
        "Playing Related Video Length => ${mainRelatedVideos?.length}");

    mainRelatedVideos?.shuffle();
    update(["onGetRelatedVideos"]);

    if (mainRelatedVideos?.isEmpty ?? true && mainWatchedVideos.length == 1) {
      isDisableNext(true);
    }

    try {
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 10), curve: Curves.ease);
    } catch (e) {
      log("Scrolling Failed");
    }
  }

  Future<void> onGetVideoDetails(String videoId) async {
    isVideoDetailsLoading.value = true;
    videoDetailsModel = null;

    try {
      videoDetailsModel =
          await VideoDetailsApi.callApi(Database.loginUserId ?? "", videoId, 1);

      if (videoDetailsModel != null) {
        final details = videoDetailsModel?.detailsOfVideo;
        isLike.value = videoDetailsModel?.detailsOfVideo?.isLike ?? false;
        isDisLike.value = videoDetailsModel?.detailsOfVideo?.isDislike ?? false;
        isSubscribe.value =
            videoDetailsModel?.detailsOfVideo?.isSubscribed ?? false;
        isSave.value =
            videoDetailsModel?.detailsOfVideo?.isSaveToWatchLater ?? false;

        customChanges["like"] = details?.like ?? 0;
        customChanges["disLike"] = details?.dislike ?? 0;
        customChanges["comment"] = details?.totalComments ?? 0;
        customChanges["subscribe"] = details?.totalSubscribers ?? 0;

        createWatchHistory();
      }
    } catch (e) {
      AppSettings.showLog("❌ onGetVideoDetails failed: $e");
    } finally {
      // ✅ FIX: Always set to false so UI never stays as infinite loader
      isVideoDetailsLoading.value = false;
      update(["onVideoInitialize"]);
    }
  }

  Future<void> onCreateHistory() async {
    if (Database.channelId != null &&
        videoPlayerController != null &&
        videoDetailsModel?.detailsOfVideo != null) {
      final details = videoDetailsModel?.detailsOfVideo;
      final watchTime = videoPlayerController!.value.position.inSeconds / 60;
      AppSettings.showLog("Video Watch Time => $watchTime");

      if (isVideoSkip == false) {
        await CreateWatchHistoryApi.callApi(
          loginUserId: Database.loginUserId ?? "",
          videoId: details?.id ?? "",
          videoChannelId: details?.channelId ?? "",
          videoUserId: details?.userId ?? "",
          watchTimeInMinute: watchTime,
        );
      }
    }
  }

  void onToggleVolume() {
    if (isSpeaker.value) {
      isSpeaker.value = false;
      videoPlayerController?.setVolume(0);
    } else {
      videoPlayerController?.setVolume(100);
      isSpeaker.value = true;
    }
  }

  Future<void> initializeVideoPlayer(String videoId, String videoUrl) async {
    try {
      isVideoSkip = false;
      isGetVideoRewardCoin = false;
      hasShownMidrollAd = false;
      showAd = false;
      isAdLoading = false;
      isPreRollAdPhase = false;
      mainVideoPlaybackStarted = false;
      currentLongVideoAd = null;
      activeBannerAd = null;
      activeOverlayAd = null;
      wasPlayingBeforeAd = false;
      adShowCount = 0;

      AppSettings.showLog("========================================");
      AppSettings.showLog("📌 RAW videoUrl received: $videoUrl");
      AppSettings.showLog("📌 Constant.mediaBaseURL: ${Constant.mediaBaseURL}");
      AppSettings.showLog("📌 Constant.baseURL: ${Constant.baseURL}");
      AppSettings.showLog("========================================");

      // ✅ FIX: Convert relative URL to full URL
      String videoPath = _resolveVideoUrl(videoId, videoUrl);
      AppSettings.showLog("🔗 Final video path: $videoPath");

      if (videoPath.isEmpty) {
        AppSettings.showLog("❌ Video path is empty — cannot play");
        update(["onVideoInitialize"]);
        return;
      }

      // dispose old controllers
      videoPlayerController?.removeListener(_videoListener);
      await videoPlayerController?.dispose();
      videoPlayerController = null;
      chewieController?.dispose();
      chewieController = null;

      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoPath));

      await videoPlayerController!.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Video initialization timed out");
        },
      );

      if (videoPlayerController!.value.isInitialized) {
        AppSettings.showLog("✅ Video initialized successfully");

        Database.onSetVideoUrl(videoId, videoPath);
        _calculateAdTimings();

        final hasBlockingPreRoll =
            _preRollAds.any((ad) => ad.isInterruptType);
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          autoPlay: !hasBlockingPreRoll,
          looping: isLoop.value,
          allowedScreenSleep: false,
          allowMuting: false,
          showControlsOnInitialize: false,
          showControls: false,
        );

        videoPlayerController!.addListener(_videoListener);

        if (!isSpeaker.value) {
          videoPlayerController?.setVolume(0);
        }

        isVideoReady = true;

        if (_preRollAds.isNotEmpty) {
          if (hasBlockingPreRoll) {
            await videoPlayerController!.pause();
          }
          _showPreRollAd();
        } else {
          mainVideoPlaybackStarted = true;
        }
      }

      update(["onVideoInitialize"]);
    } catch (e) {
      AppSettings.showLog("❌ initializeVideoPlayer Exception: $e");
      videoPlayerController?.dispose();
      videoPlayerController = null;
      chewieController?.dispose();
      chewieController = null;
      isVideoReady = false;
      update(["onVideoInitialize"]);
    }
  }

// static String resolveAssetUrl(String path) {
//   if (path.isEmpty) return '';
//   if (path.startsWith('http://') || path.startsWith('https://')) return path;
//   String base = Constant.baseURL.endsWith('/')
//       ? Constant.baseURL.substring(0, Constant.baseURL.length - 1)
//       : Constant.baseURL;
//   String p = path.startsWith('/') ? path : '/$path';
//   return '$base$p';
// }

// ✅ NEW METHOD: Properly resolves relative or absolute video URLs
  String _resolveVideoUrl(String videoId, String videoUrl) {
    // Check cache
    String? cachedUrl = Database.onGetVideoUrl(videoId);
    if (cachedUrl != null &&
        cachedUrl.isNotEmpty &&
        cachedUrl.startsWith('http')) {
      AppSettings.showLog("✅ Using cached URL: $cachedUrl");
      return cachedUrl;
    }

    // Already full URL
    if (videoUrl.startsWith('http://') || videoUrl.startsWith('https://')) {
      return videoUrl;
    }

    // ✅ Use mediaBaseURL (no /api/) to build media file URL
    String path = videoUrl.startsWith('/') ? videoUrl : '/$videoUrl';
    String fullUrl = '${Constant.mediaBaseURL}$path';
    AppSettings.showLog("✅ Resolved URL: $fullUrl");
    return fullUrl;
  }

// ✅ Static helper for images too
  static String resolveAssetUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    String p = path.startsWith('/') ? path : '/$path';
    return '${Constant.mediaBaseURL}$p';
  }

  // ✅ FIX: Extracted listener into named method so it can be properly removed
  void _videoListener() async {
    if (videoPlayerController == null) return;

    if (Get.currentRoute != "/NormalVideoDetailsView") {
      videoPlayerController?.pause();
      AppSettings.showLog("Video Playing Routes Changes...");
    }

    if (videoPlayerController!.value.isInitialized) {
      if (videoPlayerController!.value.isBuffering) {
        if (isVideoLoading == false) {
          isVideoLoading = true;
          update(["onLoading"]);
        }
      } else {
        if (isVideoLoading == true) {
          isVideoLoading = false;
          update(["onLoading"]);
        }
      }

      update(
          ["onProgressLine", "onVideoTime", "onVideoPlayPause", "adComplete"]);

      _checkMidrollAdTiming();

      if (videoPlayerController!.value.position >=
              videoPlayerController!.value.duration &&
          videoPlayerController!.value.duration > Duration.zero) {
        AppSettings.showLog("Playing Video Complete...");

        if (isGetVideoRewardCoin == false && isVideoSkip == false) {
          isGetVideoRewardCoin = true;
          VideoEngagementRewardApi.callApi(
            loginUserId: Database.loginUserId ?? "",
            videoId: videoId,
            totalWatchTime:
                videoPlayerController!.value.duration.inSeconds.toString(),
          );
        }

        onCreateHistory();

        if (AppSettings.isAutoPlayVideo.value) {
          if ((mainRelatedVideos?.isNotEmpty ?? false) &&
              mainWatchedVideos.length != 1) {
            isDisablePrevious(false);
          }

          selectedWatchedVideo++;

          if (selectedWatchedVideo < mainWatchedVideos.length) {
            onDisposeVideoPlayer();
            init(mainWatchedVideos[selectedWatchedVideo].videoId,
                mainWatchedVideos[selectedWatchedVideo].videoUrl);
          } else if (mainRelatedVideos?.isNotEmpty ?? false) {
            onCreateHistory();
            onDisposeVideoPlayer();
            isDisablePrevious(false);
            mainWatchedVideos.insert(
                selectedWatchedVideo,
                WatchedVideoModel(
                    videoId: mainRelatedVideos![0].id ?? "",
                    videoUrl: mainRelatedVideos![0].videoUrl ?? ""));
            init(mainRelatedVideos![0].id ?? "",
                mainRelatedVideos![0].videoUrl ?? "");
            mainRelatedVideos = null;
            update(["onGetRelatedVideos"]);
          } else {
            isDisableNext(true);
          }
        }
      }
    }
  }

  void _checkMidrollAdTiming() {
    if (!mainVideoPlaybackStarted ||
        isShowingInterruptAd ||
        videoPlayerController == null ||
        !videoPlayerController!.value.isPlaying ||
        adShowCount >= adTimings.length) {
      return;
    }

    final currentSeconds = videoPlayerController!.value.position.inSeconds;
    final targetTime = adTimings[adShowCount];

    if (currentSeconds < targetTime) return;

    if (_midRollAds.isEmpty) {
      adShowCount++;
      return;
    }

    _showMidrollAd();
  }

  void _showPreRollAd() {
    if (isShowingInterruptAd) return;

    final ad = _pickPreRollAd();
    if (ad == null) {
      _startMainVideoAfterAd();
      return;
    }

    AppSettings.showLog('Pre-roll ad: ${ad.id} (${ad.type})');
    if (ad.isBanner) {
      _showBannerAd(ad, isPreRoll: true);
      return;
    }
    if (ad.isOverlay) {
      activeOverlayAd = ad;
      // Start long video under the corner overlay; user can close overlay anytime.
      Future.microtask(_startMainVideoAfterAd);
      return;
    }

    _showInterruptAd(ad, isPreRoll: true);
  }

  void _showMidrollAd() {
    if (isShowingInterruptAd) return;

    final ad = _pickMidRollAd();
    if (ad == null) {
      adShowCount++;
      return;
    }

    adShowCount++;
    AppSettings.showLog(
        'Mid-roll ad $adShowCount/${adTimings.length}: ${ad.id} (${ad.type})');

    if (ad.isBanner) {
      _showBannerAd(ad, isPreRoll: false);
      return;
    }
    if (ad.isOverlay) {
      activeOverlayAd = ad;
      update(['adComplete', 'onProgressLine']);
      return;
    }

    _showInterruptAd(ad, isPreRoll: false);
  }

  void _showBannerAd(LongVideoAd ad, {required bool isPreRoll}) {
    activeBannerAd = ad;
    if (isPreRoll) {
      _startMainVideoAfterAd();
    } else {
      update(['adComplete', 'onProgressLine']);
    }
  }

  void _showInterruptAd(LongVideoAd ad, {required bool isPreRoll}) {
    currentLongVideoAd = ad;
    isPreRollAdPhase = isPreRoll;
    wasPlayingBeforeAd =
        !isPreRoll && (videoPlayerController?.value.isPlaying ?? false);
    pausedPosition = isPreRoll
        ? Duration.zero
        : (videoPlayerController?.value.position ?? Duration.zero);

    videoPlayerController?.pause();
    isAdLoading = true;
    showAd = true;

    update(
        ['adComplete', 'onVideoPlayPause', 'onShowControls', 'onProgressLine']);
  }

  void dismissOverlayAd() {
    activeOverlayAd = null;
    if (!mainVideoPlaybackStarted) {
      _startMainVideoAfterAd();
    } else {
      _ensureMainVideoPlaying();
    }
    update(['adComplete', 'onVideoPlayPause']);
  }

  void _ensureMainVideoPlaying() {
    mainVideoPlaybackStarted = true;
    final player = videoPlayerController;
    if (player == null || !player.value.isInitialized) return;

    if (!player.value.isPlaying) {
      player.play();
    }
  }

  void dismissBannerAd() {
    activeBannerAd = null;
    update(['adComplete', 'onProgressLine']);
  }

  void _startMainVideoAfterAd() {
    isPreRollAdPhase = false;
    currentLongVideoAd = null;
    showAd = false;
    isAdLoading = false;
    mainVideoPlaybackStarted = true;

    final player = videoPlayerController;
    if (player != null && player.value.isInitialized) {
      player.seekTo(Duration.zero);
      player.play();
    }

    update(['adComplete', 'onVideoPlayPause', 'onProgressLine']);
  }

  void _resumeMainVideoAfterMidRoll() {
    showAd = false;
    isAdLoading = false;
    currentLongVideoAd = null;

    final player = videoPlayerController;
    if (player != null && player.value.isInitialized) {
      player.seekTo(pausedPosition);
      player.play();
    }

    update(['adComplete', 'onVideoPlayPause', 'onProgressLine']);
  }

  void _resumeMainVideoAfterInterruptAd({required bool wasPreRoll}) {
    showAd = false;
    isAdLoading = false;
    currentLongVideoAd = null;

    if (wasPreRoll) {
      _startMainVideoAfterAd();
    } else {
      _resumeMainVideoAfterMidRoll();
    }
  }

  void onAdStarted() {
    isAdLoading = false;
    AppSettings.showLog("Ad started playing");
    update(['adComplete', 'onVideoPlayPause']);
  }

  void onAdFailed() {
    AppSettings.showLog('Sponsored ad failed, resuming content');
    final wasPreRoll = isPreRollAdPhase;

    if (!wasPreRoll) {
      adShowCount--;
    }

    _resumeMainVideoAfterInterruptAd(wasPreRoll: wasPreRoll);
  }

  void onAdCompleted1() {
    AppSettings.showLog('Interrupt ad completed — resuming long video');
    _resumeMainVideoAfterInterruptAd(wasPreRoll: isPreRollAdPhase);
  }

  void onChangeVideoLoading() {
    isVideoLoading = !isVideoLoading;
    update(["onChangeVideoLoading"]);
  }

  void onDisposeVideoPlayer() {
    videoPlayerController?.removeListener(_videoListener);
    videoPlayerController?.dispose();
    videoPlayerController = null;
    chewieController?.dispose();
    chewieController = null;
    showAd = false;
    isAdLoading = false;
    hasShownMidrollAd = false;
    isPreRollAdPhase = false;
    mainVideoPlaybackStarted = false;
    currentLongVideoAd = null;
    activeBannerAd = null;
    activeOverlayAd = null;
    wasPlayingBeforeAd = false;
    adShowCount = 0;
    adTimings.clear();
    isVideoReady = false;
    update(["onVideoInitialize", "adComplete"]);
  }

  void onNextVideo() {
    isDisablePrevious(false);
    selectedWatchedVideo++;

    if (selectedWatchedVideo != mainWatchedVideos.length) {
      onDisposeVideoPlayer();
      onCreateHistory();
      init(mainWatchedVideos[selectedWatchedVideo].videoId,
          mainWatchedVideos[selectedWatchedVideo].videoUrl);
    } else if (mainRelatedVideos?.isNotEmpty ?? false) {
      onCreateHistory();
      onDisposeVideoPlayer();
      isDisablePrevious(false);
      mainWatchedVideos.insert(
          selectedWatchedVideo,
          WatchedVideoModel(
              videoId: mainRelatedVideos![0].id ?? "",
              videoUrl: mainRelatedVideos![0].videoUrl ?? ""));
      init(
          mainRelatedVideos![0].id ?? "", mainRelatedVideos![0].videoUrl ?? "");
      mainRelatedVideos = null;
      update(["onGetRelatedVideos"]);
    } else {
      isDisableNext(true);
    }
  }

  void onPreviousVideo() async {
    isDisableNext(false);
    selectedWatchedVideo--;

    if (selectedWatchedVideo >= 0) {
      onDisposeVideoPlayer();
      init(mainWatchedVideos[selectedWatchedVideo].videoId,
          mainWatchedVideos[selectedWatchedVideo].videoUrl);
    }
    if (selectedWatchedVideo == 0) {
      isDisablePrevious(true);
    }
  }

  Future<void> onChangeLoop() async {
    if (videoPlayerController != null) {
      chewieController?.dispose();
      chewieController = null;

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        looping: isLoop.value,
        allowedScreenSleep: false,
        allowMuting: false,
        showControlsOnInitialize: false,
        showControls: false,
      );
      update(["onVideoInitialize"]);
    }
  }

  void createWatchHistory() async {
    if (AppSettings.isCreateHistory.value) {
      final details = videoDetailsModel?.detailsOfVideo;
      if (details == null) return;

      AppSettings.showLog("Create Watch History Method Called");

      bool isAvailable = false;
      for (int index = 0;
          index < WatchHistory.mainWatchHistory.length;
          index++) {
        if (WatchHistory.mainWatchHistory[index]["videoId"] == details.id) {
          WatchHistory.mainWatchHistory
              .insert(0, WatchHistory.mainWatchHistory.removeAt(index));
          isAvailable = true;
          break;
        }
      }

      if (isAvailable == false) {
        WatchHistory.mainWatchHistory.insert(0, {
          "id": DateTime.now().millisecondsSinceEpoch,
          "videoId": details.id ?? "",
          "videoTitle": details.title ?? "",
          "videoType": details.videoType ?? 1,
          "videoTime": details.videoTime ?? 0,
          "videoUrl": details.videoUrl ?? "",
          "videoImage": details.videoImage ?? "",
          "views": details.views ?? 0,
          "channelName": details.channelName ?? "",
        });
      }

      WatchHistory.onSet();
    }
  }

  void showVideoControls() {
    if (isShowingInterruptAd) return;
    isShowVideoControls = !isShowVideoControls;
    update(["onShowControls"]);
  }

  Future<void> forwardSkipVideo() async {
    if (isShowingInterruptAd) return;
    final pos = await videoPlayerController?.position;
    if (pos != null) {
      await videoPlayerController?.seekTo(pos + const Duration(seconds: 10));
      isVideoSkip = true;
    }
  }

  Future<void> backwardSkipVideo() async {
    if (isShowingInterruptAd) return;
    final pos = await videoPlayerController?.position;
    if (pos != null) {
      await videoPlayerController?.seekTo(pos - const Duration(seconds: 10));
    }
  }

  @override
  void onClose() {
    videoPlayerController?.removeListener(_videoListener);
    videoPlayerController?.dispose();
    chewieController?.dispose();
    super.onClose();
  }
}

class WatchedVideoModel {
  final String videoId;
  final String videoUrl;
  WatchedVideoModel({required this.videoId, required this.videoUrl});
}
