// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:chewie/chewie.dart';
// import 'package:floating/floating.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:get/get.dart';
// import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:interactive_media_ads/interactive_media_ads.dart';
// import 'package:metube/ads/google_ads/google_large_native_ad.dart';
// import 'package:metube/custom/custom_api/like_dislike_api.dart';
// import 'package:metube/custom/custom_method/custom_download.dart';
// import 'package:metube/custom/custom_method/custom_format_number.dart';
// import 'package:metube/custom/custom_method/custom_format_timer.dart';
// import 'package:metube/custom/custom_method/custom_share.dart';
// import 'package:metube/custom/custom_method/custom_toast.dart';
// import 'package:metube/custom/custom_ui/data_not_found_ui.dart';
// import 'package:metube/custom/custom_ui/loader_ui.dart';
// import 'package:metube/custom/custom_ui/normal_video_ui.dart';
// import 'package:metube/custom/custom_ui/premium_plan_dialog.dart';
// import 'package:metube/custom/shimmer/normal_video_shimmer_ui.dart';
// import 'package:metube/custom/shimmer/video_details_shimmer_ui.dart';
// import 'package:metube/database/database.dart';
// import 'package:metube/database/download_history_database.dart';
// import 'package:metube/main.dart';
// import 'package:metube/notification/local_notification_services.dart';
// import 'package:metube/pages/custom_pages/comment_page/comment_bottom_sheet.dart';
// import 'package:metube/pages/custom_pages/comment_page/create_comment_api.dart';
// import 'package:metube/pages/custom_pages/report_page/custom_report_view.dart';
// import 'package:metube/pages/custom_pages/share_count_page/share_count_api.dart';
// import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
// import 'package:metube/pages/nav_home_page/controller/nav_home_controller.dart';
// import 'package:metube/pages/nav_library_page/download_page/download_view.dart';
// import 'package:metube/pages/nav_library_page/watch_later_page/create_watch_later_api.dart';
// import 'package:metube/pages/nav_subscription_page/subscribe_channel_api.dart';
// import 'package:metube/pages/profile_page/your_channel_page/main_page/your_channel_view.dart';
// import 'package:metube/pages/splash_screen_page/api/unlock_private_video_api.dart';
// import 'package:metube/pages/video_details_page/normal_video_details_controller.dart';
// import 'package:metube/pages/video_details_page/video_description_bottom_sheet.dart';
// import 'package:metube/utils/colors/app_color.dart';
// import 'package:metube/utils/config/size_config.dart';
// import 'package:metube/utils/icons/app_icons.dart';
// import 'package:metube/utils/services/convert_to_network.dart';
// import 'package:metube/utils/services/preview_image.dart';
// import 'package:metube/utils/settings/app_settings.dart';
// import 'package:metube/utils/string/app_string.dart';
// import 'package:metube/utils/style/app_style.dart';
// import 'package:metube/utils/utils.dart';
// import 'package:metube/widget/subscribe_premium_channel_bottom_sheet.dart';
// import 'package:metube/widget/subscribed_success_dialog.dart';
// import 'package:metube/widget/unlock_premium_video_bottom_sheet.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_thumbnail/video_thumbnail.dart';
// import 'package:video_player/video_player.dart';
//
// class NormalVideoDetailsView extends StatefulWidget {
//   const NormalVideoDetailsView(
//       {super.key,
//       required this.videoId,
//       required this.videoUrl,
//       this.isPlayList});
//
//   final String videoId;
//   final String videoUrl;
//   final bool? isPlayList;
//
//   @override
//   State<NormalVideoDetailsView> createState() => _NormalVideoDetailsViewState();
// }
//
// class _NormalVideoDetailsViewState extends State<NormalVideoDetailsView> {
//   final navHomeController = Get.find<NavHomeController>();
//
//   final _controller = Get.put(NormalVideoDetailsController());
//
//   @override
//   void initState() {
//     _controller.mainRelatedVideos = null;
//     _controller.mainWatchedVideos.clear();
//
//     _controller.init(widget.videoId, widget.videoUrl);
//
//     _controller.selectedWatchedVideo = 0;
//     _controller.mainWatchedVideos.add(
//         WatchedVideoModel(videoId: widget.videoId, videoUrl: widget.videoUrl));
//
//     _controller.isDisablePrevious(true);
//
//     if (widget.isPlayList ?? false) {
//       _controller.isDisableNext(false);
//       _controller.onGetPlayListVideos();
//     } else {}
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _controller.onCreateHistory();
//     _controller.onDisposeVideoPlayer();
//     super.dispose();
//   }
//
//   void onSubscribePrivateChannel({required int index}) {
//     SubscribePremiumChannelBottomSheet.onShow(
//       coin: (_controller.mainRelatedVideos?[index].user?.subscriptionCost ?? 0)
//           .toString(),
//       callback: () async {
//         Get.dialog(const LoaderUi(), barrierDismissible: false);
//         final bool isSuccess = await SubscribeChannelApiClass.callApi(
//             _controller.mainRelatedVideos?[index].channelId ?? "");
//
//         Get.close(2);
//
//         if (isSuccess) {
//           _controller.mainRelatedVideos =
//               _controller.mainRelatedVideos?.map((e) {
//             if (e.id == _controller.mainRelatedVideos?[index].id) {
//               e.videoPrivacyType = 1;
//             }
//             return e;
//           }).toList();
//
//           _controller.update(["onGetRelatedVideos"]);
//           SubscribedSuccessDialog.show(context);
//         }
//       },
//     );
//   }
//
//   void onUnlockPrivateVideo({required int index}) {
//     UnlockPremiumVideoBottomSheet.onShow(
//       coin: (_controller.mainRelatedVideos?[index].user?.videoUnlockCost ?? 0)
//           .toString(),
//       callback: () async {
//         Get.dialog(const LoaderUi(), barrierDismissible: false);
//         await UnlockPrivateVideoApi.callApi(
//             loginUserId: Database.loginUserId ?? "",
//             videoId: _controller.mainRelatedVideos?[index].id ?? "");
//
//         if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
//           _controller.mainRelatedVideos =
//               _controller.mainRelatedVideos?.map((e) {
//             if (e.id == _controller.mainRelatedVideos?[index].id) {
//               e.videoPrivacyType = 1;
//             }
//             return e;
//           }).toList();
//         }
//
//         Get.close(2);
//         _controller.update(["onGetRelatedVideos"]);
//         SubscribedSuccessDialog.show(context);
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Timer(const Duration(milliseconds: 300), () {
//       SystemChrome.setSystemUIOverlayStyle(
//         const SystemUiOverlayStyle(
//           statusBarIconBrightness: Brightness.light,
//           statusBarColor: Colors.transparent,
//         ),
//       );
//     });
//     return PopScope(
//       onPopInvoked: (didPop) {
//         SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//             overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
//         SystemChrome.setPreferredOrientations(
//             [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
//         _controller.onDisposeVideoPlayer();
//       },
//       child: PiPSwitcher(
//         childWhenEnabled: GetBuilder<NormalVideoDetailsController>(
//           id: "onVideoInitialize",
//           builder: (controller) => (_controller.chewieController != null &&
//                   (_controller.videoPlayerController?.value.isInitialized ??
//                       false))
//               ? SizedBox.expand(
//                   child: FittedBox(
//                     fit: BoxFit.cover,
//                     child: SizedBox(
//                       width:
//                           _controller.videoPlayerController?.value.size.width ??
//                               0,
//                       height: _controller
//                               .videoPlayerController?.value.size.height ??
//                           0,
//                       child: Chewie(controller: _controller.chewieController!),
//                     ),
//                   ),
//                 )
//               : const Offstage(),
//         ),
//         childWhenDisabled: Scaffold(
//           body: OrientationBuilder(builder: (context, orientation) {
//             AppSettings.showLog("Current Orientation => $orientation");
//             return Column(
//               children: [
//                 PreviewVideoUi(orientation: orientation),
//                 orientation == Orientation.landscape
//                     ? const Offstage()
//                     : Expanded(
//                         child: SingleChildScrollView(
//                           controller: _controller.scrollController,
//                           child: Column(
//                             children: [
//                               const VideoDetailsUi(),
//                               GetBuilder<NormalVideoDetailsController>(
//                                 id: "onGetRelatedVideos",
//                                 builder: (controller) => controller
//                                             .mainRelatedVideos ==
//                                         null
//                                     ? const NormalVideoShimmerUi()
//                                         .paddingOnly(top: 10)
//                                     : controller.mainRelatedVideos!.isEmpty
//                                         ? const DataNotFoundUi()
//                                             .paddingSymmetric(vertical: 50)
//                                         : ListView.builder(
//                                             shrinkWrap: true,
//                                             physics:
//                                                 const NeverScrollableScrollPhysics(),
//                                             itemCount: controller
//                                                     .mainRelatedVideos
//                                                     ?.length ??
//                                                 0,
//                                             itemBuilder: (context, index) {
//                                               final indexData = controller
//                                                   .mainRelatedVideos![index];
//
//                                               return ((indexData.videoPrivacyType ==
//                                                               2 &&
//                                                           indexData.user
//                                                                   ?.channelType ==
//                                                               1) ||
//                                                       (indexData.videoPrivacyType ==
//                                                               2 &&
//                                                           indexData.user
//                                                                   ?.channelType ==
//                                                               2 &&
//                                                           indexData
//                                                                   .isSubscribedChannel ==
//                                                               false))
//                                                   ? PrivateContentNormalVideoUi(
//                                                       videoId:
//                                                           indexData.id ?? "",
//                                                       title:
//                                                           indexData.title ?? "",
//                                                       videoImage: indexData
//                                                               .videoImage ??
//                                                           "",
//                                                       videoUrl:
//                                                           indexData.videoUrl ??
//                                                               "",
//                                                       videoTime:
//                                                           indexData.videoTime ??
//                                                               0,
//                                                       channelId:
//                                                           indexData.channelId ??
//                                                               "",
//                                                       channelImage: indexData
//                                                               .user?.image ??
//                                                           "",
//                                                       channelName: indexData
//                                                               .user?.fullName ??
//                                                           "",
//                                                       views: indexData
//                                                               .totalViews ??
//                                                           0,
//                                                       uploadTime:
//                                                           indexData.time ?? "",
//                                                       isSave: controller
//                                                               .mainRelatedVideos?[
//                                                                   index]
//                                                               .isSavedToWatchLater ??
//                                                           false,
//                                                       subscribeCallback: () =>
//                                                           onSubscribePrivateChannel(
//                                                               index: index),
//                                                       videoCallback: () =>
//                                                           onUnlockPrivateVideo(
//                                                               index: index),
//                                                       videoCost: indexData.user
//                                                               ?.videoUnlockCost ??
//                                                           0,
//                                                       subscribeCost: indexData
//                                                               .user
//                                                               ?.subscriptionCost ??
//                                                           0,
//                                                       channelType: indexData
//                                                               .user
//                                                               ?.channelType ??
//                                                           1,
//                                                     )
//                                                   : GestureDetector(
//                                                       onTap: () {
//                                                         controller
//                                                             .onCreateHistory();
//                                                         controller
//                                                             .onDisposeVideoPlayer();
//                                                         controller
//                                                             .isDisablePrevious(
//                                                                 false);
//                                                         controller
//                                                             .selectedWatchedVideo++;
//                                                         controller
//                                                             .mainWatchedVideos
//                                                             .insert(
//                                                           controller
//                                                               .selectedWatchedVideo,
//                                                           WatchedVideoModel(
//                                                               videoId: controller
//                                                                   .mainRelatedVideos![
//                                                                       index]
//                                                                   .id!,
//                                                               videoUrl: controller
//                                                                   .mainRelatedVideos![
//                                                                       index]
//                                                                   .videoUrl!),
//                                                         );
//                                                         controller.init(
//                                                             controller
//                                                                 .mainRelatedVideos![
//                                                                     index]
//                                                                 .id!,
//                                                             controller
//                                                                 .mainRelatedVideos![
//                                                                     index]
//                                                                 .videoUrl!);
//                                                         controller
//                                                                 .mainRelatedVideos =
//                                                             null;
//                                                         controller.update([
//                                                           "onGetRelatedVideos"
//                                                         ]);
//                                                       },
//                                                       child: Column(
//                                                         children: [
//                                                           NormalVideoUi(
//                                                             videoId: controller
//                                                                 .mainRelatedVideos![
//                                                                     index]
//                                                                 .id!,
//                                                             title: controller
//                                                                 .mainRelatedVideos![
//                                                                     index]
//                                                                 .title!,
//                                                             videoImage: controller
//                                                                 .mainRelatedVideos![
//                                                                     index]
//                                                                 .videoImage!,
//                                                             videoUrl: controller
//                                                                 .mainRelatedVideos![
//                                                                     index]
//                                                                 .videoUrl!,
//                                                             videoTime: controller
//                                                                 .mainRelatedVideos![
//                                                                     index]
//                                                                 .videoTime!,
//                                                             channelId: controller
//                                                                 .mainRelatedVideos![
//                                                                     index]
//                                                                 .channelId!,
//                                                             channelImage: controller
//                                                                 .mainRelatedVideos![
//                                                                     index]
//                                                                 .user!
//                                                                 .image!,
//                                                             channelName: controller
//                                                                 .mainRelatedVideos![
//                                                                     index]
//                                                                 .user!
//                                                                 .fullName!,
//                                                             views: controller
//                                                                 .mainRelatedVideos![
//                                                                     index]
//                                                                 .totalViews!,
//                                                             isSave: controller
//                                                                 .mainRelatedVideos![
//                                                                     index]
//                                                                 .isSavedToWatchLater!,
//                                                           ),
//                                                           index != 0 &&
//                                                                   index %
//                                                                           AppSettings
//                                                                               .showAdsIndex ==
//                                                                       0
//                                                               ? const GoogleLargeNativeAd()
//                                                               : const Offstage()
//                                                         ],
//                                                       ),
//                                                     );
//                                             },
//                                           ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }
//
// class PreviewVideoUi extends StatelessWidget {
//   const PreviewVideoUi({super.key, required this.orientation});
//
//   final Orientation orientation;
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<NormalVideoDetailsController>(
//       id: "onVideoInitialize",
//       builder: (controller) => Database.channelId !=
//                   controller.videoDetailsModel?.detailsOfVideo?.channelId &&
//               ((controller.videoDetailsModel?.detailsOfVideo
//                               ?.videoPrivacyType ==
//                           2 &&
//                       controller
//                               .videoDetailsModel?.detailsOfVideo?.channelType ==
//                           1) ||
//                   (controller.videoDetailsModel?.detailsOfVideo
//                               ?.videoPrivacyType ==
//                           2 &&
//                       controller
//                               .videoDetailsModel?.detailsOfVideo?.channelType ==
//                           2 &&
//                       controller.isSubscribe.value == false))
//           ? Container(
//               height: orientation == Orientation.landscape
//                   ? Get.height
//                   : Get.height / 3.5,
//               width: Get.width,
//               color: AppColor.black,
//             )
//           : (controller.chewieController != null &&
//                   (controller.videoPlayerController?.value.isInitialized ??
//                       false))
//               ? GestureDetector(
//                   onTap: () => controller.showVideoControls(),
//                   child: Container(
//                     height: orientation == Orientation.landscape
//                         ? Get.height
//                         : Get.height / 3.5,
//                     width: Get.width,
//                     clipBehavior: Clip.antiAlias,
//                     decoration: const BoxDecoration(color: AppColor.black),
//                     child: Stack(
//                       clipBehavior: Clip.antiAlias,
//                       children: [
//                         ///ad show
//                         GetBuilder<NormalVideoDetailsController>(
//                           id: "onVideoInitialize",
//                           builder: (controller) {
//                             log("!controller.adCompleted${!controller.adCompleted}");
//                             return
//                                 // (!controller.adCompleted)
//                                 //   ? GoogleVideoAd(
//                                 //       isLoadingAds: controller.isLoadingAds,
//                                 //       onAdCompleted: () {
//                                 //         controller.onAdCompleted();
//                                 //       },
//                                 //     )
//                                 //   :
//                                 SizedBox(
//                               height: orientation == Orientation.landscape
//                                   ? Get.height
//                                   : Get.height / 3.5,
//                               width: Get.width,
//                               child: Container(
//                                   color: Colors.black,
//                                   child: SizedBox.expand(
//                                     child: FittedBox(
//                                       fit: BoxFit.cover,
//                                       child: SizedBox(
//                                         width: controller.videoPlayerController
//                                                 ?.value.size.width ??
//                                             0,
//                                         height: controller.videoPlayerController
//                                                 ?.value.size.height ??
//                                             0,
//                                         child: Chewie(
//                                             controller:
//                                                 controller.chewieController!),
//                                       ),
//                                     ),
//                                   )),
//                             );
//                           },
//                         ),
//                         Positioned(
//                           // Logo Water Mark Code
//                           top: MediaQuery.of(context).viewPadding.top + 40,
//                           left: 20,
//                           child: Visibility(
//                               visible: AppStrings.isShowWaterMark,
//                               child: CachedNetworkImage(
//                                 imageUrl: AppStrings.waterMarkIcon,
//                                 fit: BoxFit.contain,
//                                 imageBuilder: (context, imageProvider) => Image(
//                                   image: ResizeImage(imageProvider,
//                                       width: AppStrings.waterMarkSize,
//                                       height: AppStrings.waterMarkSize),
//                                   fit: BoxFit.contain,
//                                 ),
//                                 placeholder: (context, url) => const Offstage(),
//                                 errorWidget: (context, url, error) =>
//                                     const Offstage(),
//                               )),
//                         ),
//                         GetBuilder<NormalVideoDetailsController>(
//                           id: "onShowControls",
//                           builder: (controller) => Visibility(
//                             visible: controller.isShowVideoControls,
//                             child: Stack(
//                               alignment: Alignment.center,
//                               children: [
//                                 Align(
//                                   alignment: Alignment.center,
//                                   child:
//                                       GetBuilder<NormalVideoDetailsController>(
//                                     id: "onLoading",
//                                     builder: (controller) =>
//                                         controller.isVideoLoading
//                                             ? const SpinKitCircle(
//                                                 color: AppColor.primaryColor,
//                                                 size: 60)
//                                             : const Offstage(),
//                                   ),
//                                 ),
//                                 Positioned(
//                                   top: Platform.isAndroid ? 30 : 40,
//                                   child: SizedBox(
//                                     width: Get.width,
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             orientation == Orientation.portrait
//                                                 ? IconButton(
//                                                     icon: const ImageIcon(
//                                                         AssetImage(
//                                                             AppIcons.arrowBack),
//                                                         size: 18,
//                                                         color: AppColor.white),
//                                                     onPressed: () async {
//                                                       controller
//                                                           .videoPlayerController
//                                                           ?.pause();
//                                                       Get.back();
//                                                     },
//                                                   ).paddingOnly(left: 10)
//                                                 : const Offstage(),
//                                             orientation == Orientation.landscape
//                                                 ? IconButton(
//                                                     icon: const ImageIcon(
//                                                         AssetImage(
//                                                             AppIcons.arrowBack),
//                                                         size: 18,
//                                                         color: AppColor.white),
//                                                     onPressed: () async {
//                                                       SystemChrome
//                                                           .setEnabledSystemUIMode(
//                                                               SystemUiMode
//                                                                   .manual,
//                                                               overlays: [
//                                                             SystemUiOverlay.top,
//                                                             SystemUiOverlay
//                                                                 .bottom
//                                                           ]);
//                                                       await SystemChrome
//                                                           .setPreferredOrientations([
//                                                         DeviceOrientation
//                                                             .portraitUp,
//                                                         DeviceOrientation
//                                                             .portraitDown,
//                                                       ]);
//                                                     },
//                                                   )
//                                                 : const Offstage(),
//                                             orientation == Orientation.landscape
//                                                 ? SizedBox(
//                                                     width: Get.width / 2,
//                                                     child: Obx(
//                                                       () => Text(
//                                                         controller
//                                                                 .isVideoDetailsLoading
//                                                                 .value
//                                                             ? ""
//                                                             : controller
//                                                                     .videoDetailsModel
//                                                                     ?.detailsOfVideo
//                                                                     ?.title ??
//                                                                 "",
//                                                         style: GoogleFonts
//                                                             .urbanist(
//                                                                 fontSize: 18,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold,
//                                                                 color: AppColor
//                                                                     .white),
//                                                         overflow: TextOverflow
//                                                             .ellipsis,
//                                                         maxLines: 1,
//                                                       ),
//                                                     ),
//                                                   )
//                                                 : const Offstage(),
//                                           ],
//                                         ),
//                                         Row(
//                                           children: [
//                                             orientation == Orientation.landscape
//                                                 ? IconButton(
//                                                     icon: const ImageIcon(
//                                                       AssetImage(
//                                                           AppIcons.share),
//                                                       size: 22,
//                                                       color: AppColor.white,
//                                                     ),
//                                                     onPressed: () async {
//                                                       CustomShare.share(
//                                                         name: controller
//                                                             .videoDetailsModel!
//                                                             .detailsOfVideo!
//                                                             .title!,
//                                                         url: controller
//                                                             .videoDetailsModel!
//                                                             .detailsOfVideo!
//                                                             .videoUrl!,
//                                                         channelId: controller
//                                                             .videoDetailsModel!
//                                                             .detailsOfVideo!
//                                                             .channelId!,
//                                                         videoId: controller
//                                                             .videoDetailsModel!
//                                                             .detailsOfVideo!
//                                                             .id!,
//                                                         image: controller
//                                                             .videoDetailsModel!
//                                                             .detailsOfVideo!
//                                                             .videoImage!,
//                                                         pageRoutes:
//                                                             "NormalVideo",
//                                                       );
//
//                                                       await ShareCountApiClass
//                                                           .callApi(
//                                                               Database
//                                                                   .loginUserId!,
//                                                               controller
//                                                                   .videoId);
//                                                     },
//                                                   )
//                                                 : const Offstage(),
//                                             Obx(
//                                               () => IconButton(
//                                                 onPressed: () =>
//                                                     controller.onToggleVolume(),
//                                                 icon: Icon(
//                                                   controller.isSpeaker.value
//                                                       ? Icons.volume_up_rounded
//                                                       : Icons
//                                                           .volume_off_rounded,
//                                                   color: AppColor.white,
//                                                 ),
//                                               ),
//                                             ),
//                                             IconButton(
//                                               icon: const Icon(
//                                                 Icons.more_vert,
//                                                 color: AppColor.white,
//                                                 size: 25,
//                                               ),
//                                               onPressed: () {
//                                                 orientation ==
//                                                         Orientation.portrait
//                                                     ? Get.bottomSheet(
//                                                         backgroundColor: isDarkMode
//                                                                 .value
//                                                             ? AppColor
//                                                                 .secondDarkMode
//                                                             : AppColor.white,
//                                                         isScrollControlled:
//                                                             true,
//                                                         shape:
//                                                             const RoundedRectangleBorder(
//                                                           borderRadius:
//                                                               BorderRadius.only(
//                                                             topLeft:
//                                                                 Radius.circular(
//                                                                     25),
//                                                             topRight:
//                                                                 Radius.circular(
//                                                                     25),
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                           height: 200,
//                                                           child:
//                                                               SingleChildScrollView(
//                                                             child: Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .symmetric(
//                                                                       horizontal:
//                                                                           15),
//                                                               child: Column(
//                                                                 crossAxisAlignment:
//                                                                     CrossAxisAlignment
//                                                                         .start,
//                                                                 children: [
//                                                                   const SizedBox(
//                                                                       height:
//                                                                           8),
//                                                                   Center(
//                                                                     child:
//                                                                         Container(
//                                                                       width: 30,
//                                                                       height: 3,
//                                                                       decoration:
//                                                                           BoxDecoration(
//                                                                         borderRadius:
//                                                                             BorderRadius.circular(60),
//                                                                         color: AppColor
//                                                                             .grey_300,
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                   const SizedBox(
//                                                                       height:
//                                                                           4),
//                                                                   Center(
//                                                                     child: Text(
//                                                                       AppStrings
//                                                                           .moreOption
//                                                                           .tr,
//                                                                       style: GoogleFonts
//                                                                           .urbanist(
//                                                                         textStyle:
//                                                                             const TextStyle(
//                                                                           fontWeight:
//                                                                               FontWeight.bold,
//                                                                           fontSize:
//                                                                               20,
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                   Divider(
//                                                                       indent:
//                                                                           20,
//                                                                       endIndent:
//                                                                           20,
//                                                                       color: AppColor
//                                                                           .grey_200),
//                                                                   const SizedBox(
//                                                                       height:
//                                                                           5),
//                                                                   Row(
//                                                                       children: [
//                                                                         const ImageIcon(
//                                                                             AssetImage(AppIcons.loopVideo)),
//                                                                         const SizedBox(
//                                                                             width:
//                                                                                 10),
//                                                                         Text(
//                                                                           AppStrings
//                                                                               .loopVideo
//                                                                               .tr,
//                                                                           style:
//                                                                               GoogleFonts.urbanist(
//                                                                             textStyle:
//                                                                                 const TextStyle(
//                                                                               fontWeight: FontWeight.bold,
//                                                                               fontSize: 15,
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                         const Spacer(),
//                                                                         SizedBox(
//                                                                           height:
//                                                                               20,
//                                                                           width:
//                                                                               25,
//                                                                           child:
//                                                                               Transform.scale(
//                                                                             scale:
//                                                                                 0.7,
//                                                                             child:
//                                                                                 Obx(
//                                                                               () => CupertinoSwitch(
//                                                                                 activeColor: AppColor.primaryColor,
//                                                                                 value: controller.isLoop.value,
//                                                                                 onChanged: (value) {
//                                                                                   controller.isLoop.value = value;
//
//                                                                                   controller.onChangeLoop();
//                                                                                 },
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ).paddingOnly(
//                                                                             right:
//                                                                                 10),
//                                                                       ]),
//                                                                   const SizedBox(
//                                                                       height:
//                                                                           20),
//                                                                   GestureDetector(
//                                                                     onTap: () {
//                                                                       Get.back();
//                                                                       Get.bottomSheet(
//                                                                         backgroundColor: isDarkMode.value
//                                                                             ? AppColor.secondDarkMode
//                                                                             : AppColor.white,
//                                                                         isScrollControlled:
//                                                                             true,
//                                                                         shape:
//                                                                             const RoundedRectangleBorder(
//                                                                           borderRadius:
//                                                                               BorderRadius.only(
//                                                                             topLeft:
//                                                                                 Radius.circular(25),
//                                                                             topRight:
//                                                                                 Radius.circular(25),
//                                                                           ),
//                                                                         ),
//                                                                         SizedBox(
//                                                                           height:
//                                                                               250,
//                                                                           child:
//                                                                               SingleChildScrollView(
//                                                                             child:
//                                                                                 Column(
//                                                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                                                               mainAxisAlignment: MainAxisAlignment.start,
//                                                                               children: [
//                                                                                 const SizedBox(height: 10),
//                                                                                 Center(
//                                                                                   child: Container(
//                                                                                     width: SizeConfig.blockSizeHorizontal * 12,
//                                                                                     height: 3,
//                                                                                     decoration: BoxDecoration(
//                                                                                       borderRadius: BorderRadius.circular(60),
//                                                                                       color: AppColor.grey_300,
//                                                                                     ),
//                                                                                   ),
//                                                                                 ),
//                                                                                 const SizedBox(height: 10),
//                                                                                 Center(
//                                                                                   child: Text(
//                                                                                     AppStrings.playbackSpeed.tr,
//                                                                                     style: GoogleFonts.urbanist(
//                                                                                       textStyle: const TextStyle(
//                                                                                         fontWeight: FontWeight.bold,
//                                                                                         fontSize: 15,
//                                                                                       ),
//                                                                                     ),
//                                                                                   ),
//                                                                                 ),
//                                                                                 const SizedBox(height: 5),
//                                                                                 const Divider(),
//                                                                                 for (int i = 0; i < controller.speedOptions.length; i++)
//                                                                                   Padding(
//                                                                                     padding: const EdgeInsets.only(left: 20, bottom: 8),
//                                                                                     child: GestureDetector(
//                                                                                       onTap: () {
//                                                                                         controller.currentSpeedIndex.value = i;
//                                                                                         controller.videoPlayerController?.setPlaybackSpeed(controller.speedOptions[controller.currentSpeedIndex.value]);
//                                                                                       },
//                                                                                       child: Obx(
//                                                                                         () => Row(
//                                                                                           children: [
//                                                                                             controller.currentSpeedIndex.value == i ? Image.asset(AppIcons.done, height: 15, width: 15) : const SizedBox(width: 15),
//                                                                                             const SizedBox(width: 10),
//                                                                                             Text(
//                                                                                               "${controller.speedOptions[i]}x",
//                                                                                               style: GoogleFonts.urbanist(
//                                                                                                 textStyle: const TextStyle(
//                                                                                                   fontWeight: FontWeight.bold,
//                                                                                                   fontSize: 15,
//                                                                                                 ),
//                                                                                               ),
//                                                                                             ),
//                                                                                           ],
//                                                                                         ),
//                                                                                       ),
//                                                                                     ),
//                                                                                   ),
//                                                                               ],
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                       );
//                                                                     },
//                                                                     child: Row(
//                                                                       children: [
//                                                                         const ImageIcon(
//                                                                           AssetImage(
//                                                                               AppIcons.playSpeed),
//                                                                           size:
//                                                                               22,
//                                                                         ),
//                                                                         const SizedBox(
//                                                                             width:
//                                                                                 10),
//                                                                         Text(
//                                                                           AppStrings
//                                                                               .playbackSpeed
//                                                                               .tr,
//                                                                           style:
//                                                                               GoogleFonts.urbanist(
//                                                                             textStyle:
//                                                                                 const TextStyle(
//                                                                               fontWeight: FontWeight.bold,
//                                                                               fontSize: 15,
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                         const Spacer(),
//                                                                         Obx(
//                                                                           () =>
//                                                                               Text(
//                                                                             controller.currentSpeedIndex.value == 2
//                                                                                 ? AppStrings.normal.tr
//                                                                                 : "${controller.speedOptions[controller.currentSpeedIndex.value]}x",
//                                                                             style:
//                                                                                 GoogleFonts.urbanist(
//                                                                               textStyle: const TextStyle(
//                                                                                 fontWeight: FontWeight.bold,
//                                                                                 fontSize: 15,
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                         const SizedBox(
//                                                                             width:
//                                                                                 3),
//                                                                         const ImageIcon(
//                                                                           AssetImage(
//                                                                               AppIcons.arrowDown),
//                                                                           size:
//                                                                               18,
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                   const SizedBox(
//                                                                       height:
//                                                                           20),
//                                                                   GestureDetector(
//                                                                     onTap: () {
//                                                                       Get.back();
//                                                                       CustomReportView.show(
//                                                                           controller
//                                                                               .videoId);
//                                                                     },
//                                                                     child: Row(
//                                                                       children: [
//                                                                         const ImageIcon(
//                                                                             AssetImage(AppIcons.report)),
//                                                                         const SizedBox(
//                                                                             width:
//                                                                                 10),
//                                                                         Text(
//                                                                           "${AppStrings.report.tr}-${AppStrings.block.tr}",
//                                                                           style:
//                                                                               GoogleFonts.urbanist(textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                   const SizedBox(
//                                                                       height:
//                                                                           20),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       )
//                                                     : Get.defaultDialog(
//                                                         title: AppStrings
//                                                             .moreOption.tr,
//                                                         titlePadding:
//                                                             const EdgeInsets
//                                                                 .only(top: 10),
//                                                         titleStyle: GoogleFonts
//                                                             .urbanist(
//                                                           textStyle:
//                                                               const TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize: 20,
//                                                           ),
//                                                         ),
//                                                         backgroundColor: isDarkMode
//                                                                 .value
//                                                             ? AppColor
//                                                                 .secondDarkMode
//                                                             : AppColor.white,
//                                                         contentPadding:
//                                                             const EdgeInsets
//                                                                 .symmetric(
//                                                                 horizontal: 10),
//                                                         content: Container(
//                                                           height: 130,
//                                                           padding:
//                                                               EdgeInsets.only(
//                                                             left: SizeConfig
//                                                                     .blockSizeHorizontal *
//                                                                 2,
//                                                             right: SizeConfig
//                                                                     .blockSizeHorizontal *
//                                                                 2,
//                                                           ),
//                                                           decoration:
//                                                               BoxDecoration(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         20),
//                                                             color: Colors
//                                                                 .transparent,
//                                                           ),
//                                                           child:
//                                                               SingleChildScrollView(
//                                                             child: Column(
//                                                               crossAxisAlignment:
//                                                                   CrossAxisAlignment
//                                                                       .start,
//                                                               children: [
//                                                                 Divider(
//                                                                     indent: 25,
//                                                                     endIndent:
//                                                                         25,
//                                                                     color: AppColor
//                                                                         .grey_300),
//                                                                 const SizedBox(
//                                                                     height: 5),
//                                                                 Row(children: [
//                                                                   const ImageIcon(
//                                                                       AssetImage(
//                                                                           AppIcons
//                                                                               .loopVideo)),
//                                                                   const SizedBox(
//                                                                       width:
//                                                                           10),
//                                                                   Text(
//                                                                     AppStrings
//                                                                         .loopVideo
//                                                                         .tr,
//                                                                     style: GoogleFonts.urbanist(
//                                                                         textStyle: const TextStyle(
//                                                                             fontWeight:
//                                                                                 FontWeight.bold,
//                                                                             fontSize: 15)),
//                                                                   ),
//                                                                   const Spacer(),
//                                                                   SizedBox(
//                                                                     height: 20,
//                                                                     width: 25,
//                                                                     child: Transform
//                                                                         .scale(
//                                                                       scale:
//                                                                           0.7,
//                                                                       child:
//                                                                           Obx(
//                                                                         () =>
//                                                                             CupertinoSwitch(
//                                                                           activeColor:
//                                                                               AppColor.primaryColor,
//                                                                           value: controller
//                                                                               .isLoop
//                                                                               .value,
//                                                                           onChanged:
//                                                                               (value) {
//                                                                             controller.isLoop.value =
//                                                                                 value;
//
//                                                                             controller.onChangeLoop();
//                                                                           },
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                   ).paddingOnly(
//                                                                       right:
//                                                                           10),
//                                                                 ]),
//                                                                 const SizedBox(
//                                                                     height: 15),
//                                                                 GestureDetector(
//                                                                   onTap: () {
//                                                                     Get.back();
//                                                                     Get.defaultDialog(
//                                                                       title: AppStrings
//                                                                           .playbackSpeed
//                                                                           .tr,
//                                                                       titlePadding: const EdgeInsets
//                                                                           .only(
//                                                                           top:
//                                                                               20),
//                                                                       titleStyle:
//                                                                           GoogleFonts
//                                                                               .urbanist(
//                                                                         textStyle: const TextStyle(
//                                                                             fontWeight:
//                                                                                 FontWeight.bold,
//                                                                             fontSize: 16),
//                                                                       ),
//                                                                       backgroundColor: isDarkMode.value
//                                                                           ? AppColor
//                                                                               .secondDarkMode
//                                                                           : AppColor
//                                                                               .white,
//                                                                       content:
//                                                                           Container(
//                                                                         height:
//                                                                             170,
//                                                                         padding:
//                                                                             EdgeInsets.only(
//                                                                           left: SizeConfig.blockSizeHorizontal *
//                                                                               2,
//                                                                           right:
//                                                                               SizeConfig.blockSizeHorizontal * 2,
//                                                                         ),
//                                                                         decoration:
//                                                                             BoxDecoration(
//                                                                           borderRadius:
//                                                                               BorderRadius.circular(20),
//                                                                           color:
//                                                                               AppColor.transparent,
//                                                                         ),
//                                                                         child:
//                                                                             Column(
//                                                                           children: [
//                                                                             const Divider(),
//                                                                             Expanded(
//                                                                               child: SingleChildScrollView(
//                                                                                 child: Column(
//                                                                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                                                                   mainAxisAlignment: MainAxisAlignment.start,
//                                                                                   children: [
//                                                                                     for (int i = 0; i < controller.speedOptions.length; i++)
//                                                                                       Padding(
//                                                                                         padding: const EdgeInsets.only(left: 10, top: 10),
//                                                                                         child: GestureDetector(
//                                                                                           onTap: () {
//                                                                                             controller.currentSpeedIndex.value = i;
//                                                                                             controller.videoPlayerController?.setPlaybackSpeed(controller.speedOptions[controller.currentSpeedIndex.value]);
//                                                                                           },
//                                                                                           child: Obx(
//                                                                                             () => Row(
//                                                                                               children: [
//                                                                                                 controller.currentSpeedIndex.value == i ? Image.asset(AppIcons.done, height: 15, width: 15) : const SizedBox(width: 15),
//                                                                                                 const SizedBox(width: 10),
//                                                                                                 Text("${controller.speedOptions[i]}x"),
//                                                                                               ],
//                                                                                             ),
//                                                                                           ),
//                                                                                         ),
//                                                                                       ),
//                                                                                   ],
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           ],
//                                                                         ),
//                                                                       ),
//                                                                     );
//                                                                   },
//                                                                   child: Row(
//                                                                     children: [
//                                                                       const ImageIcon(
//                                                                           AssetImage(
//                                                                               AppIcons.playSpeed)),
//                                                                       const SizedBox(
//                                                                           width:
//                                                                               10),
//                                                                       Text(
//                                                                           AppStrings
//                                                                               .playbackSpeed
//                                                                               .tr,
//                                                                           style:
//                                                                               GoogleFonts.urbanist(textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
//                                                                       const Spacer(),
//                                                                       Obx(
//                                                                         () =>
//                                                                             Text(
//                                                                           controller.currentSpeedIndex.value == 2
//                                                                               ? AppStrings.normal.tr
//                                                                               : "${controller.speedOptions[controller.currentSpeedIndex.value]}x",
//                                                                           style:
//                                                                               GoogleFonts.urbanist(
//                                                                             textStyle:
//                                                                                 const TextStyle(
//                                                                               fontWeight: FontWeight.bold,
//                                                                               fontSize: 15,
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                       const SizedBox(
//                                                                           width:
//                                                                               3),
//                                                                       const ImageIcon(
//                                                                         AssetImage(
//                                                                             AppIcons.arrowDown),
//                                                                         size:
//                                                                             18,
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                                 const SizedBox(
//                                                                     height: 15),
//                                                                 GestureDetector(
//                                                                   onTap: () {
//                                                                     Get.back();
//                                                                     CustomReportView.show(
//                                                                         controller
//                                                                             .videoId);
//                                                                   },
//                                                                   child: Row(
//                                                                     children: [
//                                                                       const ImageIcon(
//                                                                           AssetImage(
//                                                                               AppIcons.report)),
//                                                                       const SizedBox(
//                                                                           width:
//                                                                               10),
//                                                                       Text(
//                                                                         "${AppStrings.report.tr}-${AppStrings.block.tr}",
//                                                                         style: GoogleFonts.urbanist(
//                                                                             textStyle:
//                                                                                 const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                                 const SizedBox(
//                                                                     height: 10),
//                                                               ],
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       );
//                                               },
//                                             ),
//                                             const SizedBox(width: 10),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//
//                                 // >>>>> Both Mode Progress Line <<<<<<<
//                                 Positioned(
//                                   bottom: orientation == Orientation.portrait
//                                       ? 25
//                                       : 50,
//                                   child:
//                                       GetBuilder<NormalVideoDetailsController>(
//                                     id: "onProgressLine",
//                                     builder: (controller) => SizedBox(
//                                       width: Get.width,
//                                       child: Padding(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 20),
//                                         child: Row(
//                                           children: [
//                                             orientation == Orientation.landscape
//                                                 ? GetBuilder<
//                                                     NormalVideoDetailsController>(
//                                                     id: "onVideoTime",
//                                                     builder: (controller) =>
//                                                         Text(
//                                                       CustomFormatTime.convert(
//                                                           controller
//                                                                   .videoPlayerController
//                                                                   ?.value
//                                                                   .position
//                                                                   .inMilliseconds ??
//                                                               0),
//                                                       style: const TextStyle(
//                                                           color: AppColor.white,
//                                                           fontSize: 12),
//                                                     ),
//                                                   )
//                                                 : const Offstage(),
//                                             Expanded(
//                                               child: SliderTheme(
//                                                 data: SliderTheme.of(context)
//                                                     .copyWith(
//                                                   trackHeight: 6,
//                                                   trackShape:
//                                                       const RoundedRectSliderTrackShape(),
//                                                   inactiveTrackColor:
//                                                       Colors.white60,
//                                                   thumbColor: AppColor.white,
//                                                   activeTrackColor:
//                                                       AppColor.primaryColor,
//                                                   thumbShape:
//                                                       const RoundSliderThumbShape(
//                                                           enabledThumbRadius:
//                                                               12.0),
//                                                   overlayShape:
//                                                       const RoundSliderOverlayShape(
//                                                           overlayRadius: 24.0),
//                                                 ),
//                                                 child: Slider(
//                                                   value: controller
//                                                           .videoPlayerController
//                                                           ?.value
//                                                           .position
//                                                           .inMilliseconds
//                                                           .toDouble() ??
//                                                       0,
//                                                   onChanged: (double value) {
//                                                     Duration? currentPosition =
//                                                         controller
//                                                             .videoPlayerController
//                                                             ?.value
//                                                             .position;
//
//                                                     Duration newPosition =
//                                                         Duration(
//                                                             milliseconds:
//                                                                 value.toInt());
//
//                                                     if (currentPosition !=
//                                                         null) {
//                                                       if (currentPosition <
//                                                           newPosition) {
//                                                         controller.isVideoSkip =
//                                                             true;
//                                                         print("9999999999");
//                                                       }
//                                                     }
//
//                                                     controller
//                                                         .videoPlayerController
//                                                         ?.seekTo(newPosition);
//                                                   },
//                                                   min: 0.0,
//                                                   max: controller
//                                                           .videoPlayerController
//                                                           ?.value
//                                                           .duration
//                                                           .inMilliseconds
//                                                           .toDouble() ??
//                                                       0,
//                                                 ),
//                                               ),
//                                             ),
//                                             orientation == Orientation.landscape
//                                                 ? Text(
//                                                     CustomFormatTime.convert(
//                                                         controller
//                                                                 .videoPlayerController
//                                                                 ?.value
//                                                                 .duration
//                                                                 .inMilliseconds ??
//                                                             0),
//                                                     style: const TextStyle(
//                                                         color: AppColor.white,
//                                                         fontSize: 12),
//                                                   )
//                                                 : const Offstage(),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 orientation == Orientation.portrait
//                                     ? Positioned(
//                                         bottom: 0,
//                                         child: SizedBox(
//                                           width: Get.width,
//                                           child: Row(
//                                             children: [
//                                               const SizedBox(width: 10),
//                                               GetBuilder<
//                                                   NormalVideoDetailsController>(
//                                                 id: "onVideoTime",
//                                                 builder: (controller) => Text(
//                                                   CustomFormatTime.convert(
//                                                       controller
//                                                               .videoPlayerController
//                                                               ?.value
//                                                               .position
//                                                               .inMilliseconds ??
//                                                           0),
//                                                   style: const TextStyle(
//                                                       color: AppColor.white,
//                                                       fontSize: 12),
//                                                 ),
//                                               ),
//                                               Text(
//                                                 " / ${CustomFormatTime.convert(controller.videoPlayerController?.value.duration.inMilliseconds ?? 0)}",
//                                                 style: const TextStyle(
//                                                     color: AppColor.white,
//                                                     fontSize: 12),
//                                               ),
//                                               const Spacer(),
//                                               IconButton(
//                                                 icon: const ImageIcon(
//                                                   AssetImage(AppIcons.expand),
//                                                   size: 20,
//                                                   color: AppColor.white,
//                                                 ),
//                                                 onPressed: () async {
//                                                   SystemChrome
//                                                       .setEnabledSystemUIMode(
//                                                           SystemUiMode.manual,
//                                                           overlays: [
//                                                         SystemUiOverlay.top
//                                                       ]);
//                                                   Timer(
//                                                       const Duration(
//                                                           milliseconds: 300),
//                                                       () {
//                                                     SystemChrome
//                                                         .setSystemUIOverlayStyle(
//                                                       const SystemUiOverlayStyle(
//                                                         statusBarIconBrightness:
//                                                             Brightness.light,
//                                                         statusBarColor:
//                                                             Colors.transparent,
//                                                       ),
//                                                     );
//                                                   });
//
//                                                   await SystemChrome
//                                                       .setPreferredOrientations([
//                                                     DeviceOrientation
//                                                         .landscapeLeft,
//                                                     DeviceOrientation
//                                                         .landscapeRight,
//                                                   ]);
//                                                 },
//                                               ),
//                                               const SizedBox(width: 10),
//                                             ],
//                                           ),
//                                         ),
//                                       )
//                                     : const Offstage(),
//                                 orientation == Orientation.portrait
//                                     ? Align(
//                                         alignment: Alignment.center,
//                                         child: SizedBox(
//                                           width: Get.width,
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceAround,
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               IconButton(
//                                                 icon: const ImageIcon(
//                                                     AssetImage(
//                                                         AppIcons.backward10s),
//                                                     size: 20,
//                                                     color: AppColor.white),
//                                                 onPressed: () async =>
//                                                     await controller
//                                                         .backwardSkipVideo(),
//                                               ),
//                                               Obx(
//                                                 () => IconButton(
//                                                   icon: ImageIcon(
//                                                       const AssetImage(
//                                                           AppIcons.previous),
//                                                       size: 25,
//                                                       color: controller
//                                                               .isDisablePrevious
//                                                               .value
//                                                           ? AppColor.white
//                                                               .withOpacity(0.6)
//                                                           : AppColor.white),
//                                                   onPressed: controller
//                                                           .isDisablePrevious
//                                                           .value
//                                                       ? () {}
//                                                       : () {
//                                                           AppSettings.showLog(
//                                                               "Previous Video Playing....");
//                                                           controller
//                                                               .onPreviousVideo();
//                                                         },
//                                                 ),
//                                               ),
//                                               GetBuilder<
//                                                   NormalVideoDetailsController>(
//                                                 id: "onVideoPlayPause",
//                                                 builder: (controller) =>
//                                                     IconButton(
//                                                   icon: ImageIcon(
//                                                     AssetImage(
//                                                       (controller
//                                                                   .videoPlayerController
//                                                                   ?.value
//                                                                   .isPlaying ??
//                                                               false)
//                                                           ? AppIcons.pause
//                                                           : AppIcons.videoPlay,
//                                                     ),
//                                                     size: 28,
//                                                     color: AppColor.white,
//                                                   ),
//                                                   onPressed: () {
//                                                     if (controller
//                                                             .videoPlayerController
//                                                             ?.value
//                                                             .isPlaying ??
//                                                         false) {
//                                                       controller
//                                                           .videoPlayerController
//                                                           ?.pause();
//                                                     } else {
//                                                       controller
//                                                           .videoPlayerController
//                                                           ?.play();
//                                                     }
//                                                   },
//                                                 ),
//                                               ),
//                                               Obx(
//                                                 () => IconButton(
//                                                   icon: ImageIcon(
//                                                       const AssetImage(
//                                                           AppIcons.next),
//                                                       size: 25,
//                                                       color: controller
//                                                               .isDisableNext
//                                                               .value
//                                                           ? AppColor.white
//                                                               .withOpacity(0.6)
//                                                           : AppColor.white),
//                                                   onPressed: controller
//                                                           .isDisableNext.value
//                                                       ? () {}
//                                                       : () {
//                                                           AppSettings.showLog(
//                                                               "Next Video Playing....");
//                                                           controller
//                                                               .onNextVideo();
//                                                         },
//                                                 ),
//                                               ),
//                                               IconButton(
//                                                 icon: const ImageIcon(
//                                                   AssetImage(
//                                                       AppIcons.forward10s),
//                                                   size: 20,
//                                                   color: AppColor.white,
//                                                 ),
//                                                 onPressed: () async =>
//                                                     await controller
//                                                         .forwardSkipVideo(),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       )
//                                     : const Offstage(),
//                                 orientation == Orientation.landscape
//                                     ? Positioned(
//                                         bottom: 5,
//                                         child: SizedBox(
//                                           width: Get.width,
//                                           child: Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Row(
//                                                 children: [
//                                                   Obx(
//                                                     () => IconButton(
//                                                       onPressed: () async {
//                                                         if (!controller
//                                                             .isLike.value) {
//                                                           if (controller
//                                                               .isDisLike
//                                                               .value) {
//                                                             controller.isDisLike
//                                                                 .value = false;
//                                                             controller
//                                                                     .customChanges[
//                                                                 "disLike"]--;
//                                                           }
//                                                           controller.isLike
//                                                               .value = true;
//                                                           controller
//                                                                   .customChanges[
//                                                               "like"]++;
//                                                           await LikeDisLikeVideoApi
//                                                               .callApi(
//                                                                   controller
//                                                                       .videoId,
//                                                                   true);
//                                                         }
//                                                       },
//                                                       icon: ImageIcon(
//                                                         AssetImage(controller
//                                                                 .isLike.value
//                                                             ? AppIcons.likeBold
//                                                             : AppIcons.like),
//                                                         size: 25,
//                                                         color: AppColor.white,
//                                                       ).paddingOnly(bottom: 2),
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 10),
//                                                   Obx(
//                                                     () => IconButton(
//                                                       onPressed: () async {
//                                                         if (!controller
//                                                             .isDisLike.value) {
//                                                           if (controller
//                                                               .isLike.value) {
//                                                             controller.isLike
//                                                                 .value = false;
//                                                             controller
//                                                                     .customChanges[
//                                                                 "like"]--;
//                                                           }
//                                                           controller.isDisLike
//                                                               .value = true;
//                                                           controller
//                                                                   .customChanges[
//                                                               "disLike"]++;
//                                                           await LikeDisLikeVideoApi
//                                                               .callApi(
//                                                                   controller
//                                                                       .videoId,
//                                                                   false);
//                                                         }
//                                                       },
//                                                       icon: ImageIcon(
//                                                               AssetImage(controller
//                                                                       .isDisLike
//                                                                       .value
//                                                                   ? AppIcons
//                                                                       .disLikeBold
//                                                                   : AppIcons
//                                                                       .disLike),
//                                                               size: 25,
//                                                               color: AppColor
//                                                                   .white)
//                                                           .paddingOnly(top: 2),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Row(
//                                                 children: [
//                                                   IconButton(
//                                                     icon: const ImageIcon(
//                                                         AssetImage(AppIcons
//                                                             .backward10s),
//                                                         size: 28,
//                                                         color: AppColor.white),
//                                                     onPressed: () async =>
//                                                         await controller
//                                                             .backwardSkipVideo(),
//                                                   ),
//                                                   const SizedBox(width: 10),
//                                                   Obx(
//                                                     () => IconButton(
//                                                       icon: ImageIcon(
//                                                           const AssetImage(
//                                                               AppIcons
//                                                                   .previous),
//                                                           size: 28,
//                                                           color: controller
//                                                                   .isDisablePrevious
//                                                                   .value
//                                                               ? AppColor.white
//                                                                   .withOpacity(
//                                                                       0.6)
//                                                               : AppColor.white),
//                                                       onPressed: controller
//                                                               .isDisablePrevious
//                                                               .value
//                                                           ? () {}
//                                                           : () {
//                                                               AppSettings.showLog(
//                                                                   "Previous Video Playing....");
//                                                               controller
//                                                                   .onPreviousVideo();
//                                                             },
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 10),
//                                                   GetBuilder<
//                                                       NormalVideoDetailsController>(
//                                                     id: "onVideoPlayPause",
//                                                     builder: (controller) =>
//                                                         IconButton(
//                                                       icon: ImageIcon(
//                                                           AssetImage(
//                                                             (controller
//                                                                         .videoPlayerController
//                                                                         ?.value
//                                                                         .isPlaying ??
//                                                                     false)
//                                                                 ? AppIcons.pause
//                                                                 : AppIcons
//                                                                     .videoPlay,
//                                                           ),
//                                                           size: 35,
//                                                           color:
//                                                               AppColor.white),
//                                                       onPressed: () {
//                                                         if (controller
//                                                                 .videoPlayerController
//                                                                 ?.value
//                                                                 .isPlaying ??
//                                                             false) {
//                                                           controller
//                                                               .videoPlayerController
//                                                               ?.pause();
//                                                         } else {
//                                                           controller
//                                                               .videoPlayerController
//                                                               ?.play();
//                                                         }
//                                                       },
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 10),
//                                                   Obx(
//                                                     () => IconButton(
//                                                       icon: ImageIcon(
//                                                           const AssetImage(
//                                                               AppIcons.next),
//                                                           size: 28,
//                                                           color: controller
//                                                                   .isDisableNext
//                                                                   .value
//                                                               ? AppColor.white
//                                                                   .withOpacity(
//                                                                       0.6)
//                                                               : AppColor.white),
//                                                       onPressed: controller
//                                                               .isDisableNext
//                                                               .value
//                                                           ? () {}
//                                                           : () {
//                                                               AppSettings.showLog(
//                                                                   "Next Video Playing....");
//                                                               controller
//                                                                   .onNextVideo();
//                                                             },
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 10),
//                                                   IconButton(
//                                                     icon: const ImageIcon(
//                                                         AssetImage(AppIcons
//                                                             .forward10s),
//                                                         size: 28,
//                                                         color: AppColor.white),
//                                                     onPressed: () async =>
//                                                         await controller
//                                                             .forwardSkipVideo(),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Row(
//                                                 children: [
//                                                   IconButton(
//                                                     onPressed: () {
//                                                       if (controller
//                                                               .isSave.value ==
//                                                           false) {
//                                                         controller.isSave
//                                                             .value = true;
//                                                         CustomToast.show(
//                                                             AppStrings
//                                                                 .addToWatchLater
//                                                                 .tr);
//                                                         CreateWatchLater.callApi(
//                                                             Database
//                                                                 .loginUserId!,
//                                                             controller.videoId);
//                                                       }
//                                                     },
//                                                     icon: Obx(
//                                                       () => ImageIcon(
//                                                           AssetImage(controller
//                                                                   .isSave.value
//                                                               ? AppIcons
//                                                                   .saveDone1
//                                                               : AppIcons
//                                                                   .addToSave),
//                                                           size: 22,
//                                                           color:
//                                                               AppColor.white),
//                                                     ),
//                                                   ),
//                                                   const SizedBox(width: 10),
//                                                   IconButton(
//                                                     icon: const ImageIcon(
//                                                         AssetImage(
//                                                             AppIcons.collapse),
//                                                         size: 25,
//                                                         color: AppColor.white),
//                                                     onPressed: () async {
//                                                       SystemChrome
//                                                           .setEnabledSystemUIMode(
//                                                               SystemUiMode
//                                                                   .manual,
//                                                               overlays: [
//                                                             SystemUiOverlay.top,
//                                                             SystemUiOverlay
//                                                                 .bottom
//                                                           ]);
//                                                       await SystemChrome
//                                                           .setPreferredOrientations([
//                                                         DeviceOrientation
//                                                             .portraitUp,
//                                                         DeviceOrientation
//                                                             .portraitDown,
//                                                       ]);
//                                                     },
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ).paddingSymmetric(horizontal: 10),
//                                         ))
//                                     : const Offstage(),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               : Container(
//                   height: orientation == Orientation.landscape
//                       ? Get.height
//                       : Get.height / 3.5,
//                   width: Get.width,
//                   color: AppColor.black,
//                   child: Stack(
//                     children: [
//                       Positioned(
//                         top: 30,
//                         child: SizedBox(
//                           width: Get.width,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               IconButton(
//                                 icon: const ImageIcon(
//                                     AssetImage(AppIcons.arrowBack),
//                                     size: 18,
//                                     color: AppColor.white),
//                                 onPressed: () async {
//                                   try {
//                                     controller.videoPlayerController?.pause();
//                                     Get.back();
//                                   } catch (e) {
//                                     log("Back Error");
//                                   }
//                                 },
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                       const Center(
//                           child: SpinKitCircle(
//                               color: AppColor.primaryColor, size: 60)),
//                     ],
//                   ),
//                 ),
//     );
//   }
// }
//
// class VideoDetailsUi extends GetView<NormalVideoDetailsController> {
//   const VideoDetailsUi({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => controller.isVideoDetailsLoading.value
//           ? const VideoDetailsShimmerUi()
//           : Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 8),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           controller.videoDetailsModel!.detailsOfVideo!.title!,
//                           style: profileTitleStyle,
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 2,
//                         ),
//                       ),
//                       IconButton(
//                         padding: const EdgeInsets.only(left: 8),
//                         onPressed: () {
//                           controller.chewieController?.pause();
//                           DescriptionBottomSheet.show(
//                               controller.videoDetailsModel!.detailsOfVideo!
//                                   .channelId!,
//                               controller
//                                   .videoDetailsModel!.detailsOfVideo!.title!,
//                               controller.videoDetailsModel!.detailsOfVideo!
//                                   .channelImage!,
//                               controller.videoDetailsModel!.detailsOfVideo!
//                                   .channelName!,
//                               controller
//                                   .videoDetailsModel!.detailsOfVideo!.like!,
//                               controller
//                                   .videoDetailsModel!.detailsOfVideo!.dislike!,
//                               controller
//                                   .videoDetailsModel!.detailsOfVideo!.views!,
//                               controller.videoDetailsModel!.detailsOfVideo!
//                                   .createdAt!,
//                               controller
//                                   .videoDetailsModel!.detailsOfVideo!.hashTag!
//                                   .join(','),
//                               controller.videoDetailsModel!.detailsOfVideo!
//                                   .description!);
//                         },
//                         icon: const ImageIcon(AssetImage(AppIcons.arrowDown),
//                             size: 20),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   child: Text(
//                       "${CustomFormatNumber.convert(controller.videoDetailsModel!.detailsOfVideo!.views!)} ${AppStrings.views.tr} - ${controller.videoDetailsModel!.detailsOfVideo!.time!}",
//                       style: fillYourProfileStyle),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 15),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       NormalVideoDetailsIconUi(
//                         title: CustomFormatNumber.convert(
//                             controller.customChanges["like"]),
//                         icon: controller.isLike.value
//                             ? AppIcons.likeBold
//                             : AppIcons.like,
//                         callback: () async {
//                           if (!controller.isLike.value) {
//                             if (controller.isDisLike.value) {
//                               controller.isDisLike.value = false;
//                               controller.customChanges["disLike"]--;
//                             }
//                             controller.isLike.value = true;
//                             controller.customChanges["like"]++;
//                             await LikeDisLikeVideoApi.callApi(
//                                 controller.videoId, true);
//                           }
//                         },
//                       ).paddingOnly(bottom: 2),
//                       NormalVideoDetailsIconUi(
//                         title: CustomFormatNumber.convert(
//                             controller.customChanges["disLike"]),
//                         icon: controller.isDisLike.value
//                             ? AppIcons.disLikeBold
//                             : AppIcons.disLike,
//                         callback: () async {
//                           if (!controller.isDisLike.value) {
//                             if (controller.isLike.value) {
//                               controller.isLike.value = false;
//                               controller.customChanges["like"]--;
//                             }
//                             controller.isDisLike.value = true;
//                             controller.customChanges["disLike"]++;
//                             await LikeDisLikeVideoApi.callApi(
//                                 controller.videoId, false);
//                           }
//                         },
//                       ).paddingOnly(top: 2),
//                       NormalVideoDetailsIconUi(
//                         title: AppStrings.comments.tr,
//                         icon: AppIcons.boldChat,
//                         callback: () async {
//                           controller.chewieController?.pause();
//                           controller.customChanges["comment"] =
//                               await CommentBottomSheet.show(
//                             context,
//                             controller.videoId,
//                             controller
//                                 .videoDetailsModel!.detailsOfVideo!.channelId!,
//                             controller.customChanges["comment"],
//                           );
//                         },
//                       ),
//                       NormalVideoDetailsIconUi(
//                         title: AppStrings.share.tr,
//                         icon: AppIcons.share,
//                         callback: () async {
//                           controller.chewieController?.pause();
//
//                           CustomShare.share(
//                             name: controller
//                                 .videoDetailsModel!.detailsOfVideo!.title!,
//                             url: controller
//                                 .videoDetailsModel!.detailsOfVideo!.videoUrl!,
//                             channelId: controller
//                                 .videoDetailsModel!.detailsOfVideo!.channelId!,
//                             videoId: controller
//                                 .videoDetailsModel!.detailsOfVideo!.id!,
//                             image: controller
//                                 .videoDetailsModel!.detailsOfVideo!.videoImage!,
//                             pageRoutes: "NormalVideo",
//                           );
//
//                           await ShareCountApiClass.callApi(
//                               Database.loginUserId!, controller.videoId);
//                         },
//                       ),
//                       Obx(() => controller.isDownloading.value
//                           ? Center(
//                               child: SpinKitCircle(
//                                   color: isDarkMode.value
//                                       ? AppColor.white
//                                       : (AppColor.primaryColor),
//                                   size: 40))
//                           : NormalVideoDetailsIconUi(
//                               title: AppStrings.download.tr,
//                               icon: DownloadHistory.mainDownloadHistory.any(
//                                       (map) =>
//                                           map['videoId'] == controller.videoId)
//                                   ? AppIcons.accept
//                                   : AppIcons.videoDownload,
//                               callback: () async {
//                                 if (DownloadHistory.mainDownloadHistory.any(
//                                     (map) =>
//                                         map['videoId'] == controller.videoId)) {
//                                   CustomToast.show("Video Already Downloaded");
//                                 } else if ((GetProfileApi
//                                         .profileModel?.user?.isPremiumPlan ??
//                                     false)) {
//                                   CustomToast.show("Downloading....");
//                                   controller.isDownloading.value = true;
//                                   AppSettings.isDownloading.value = true;
//                                   final downloadPath =
//                                       await CustomDownload.download(
//                                           Database.onGetVideoUrl(controller
//                                                   .videoDetailsModel!
//                                                   .detailsOfVideo!
//                                                   .id!) ??
//                                               await ConvertToNetwork.convert(
//                                                   controller
//                                                       .videoDetailsModel!
//                                                       .detailsOfVideo!
//                                                       .videoUrl!),
//                                           controller.videoDetailsModel!
//                                               .detailsOfVideo!.id!);
//
//                                   if (downloadPath != null) {
//                                     final downloadThumbnail =
//                                         await VideoThumbnail.thumbnailFile(
//                                       video: downloadPath,
//                                       thumbnailPath:
//                                           (await getTemporaryDirectory()).path,
//                                       imageFormat: ImageFormat.JPEG,
//                                       maxHeight: 400,
//                                       quality: 100,
//                                     );
//                                     if (downloadThumbnail != null) {
//                                       DateTime now = DateTime.now();
//                                       String formattedDate = now.toString();
//
//                                       DownloadHistory.mainDownloadHistory
//                                           .insert(
//                                         0,
//                                         {
//                                           "videoId": controller
//                                               .videoDetailsModel!
//                                               .detailsOfVideo!
//                                               .id!,
//                                           "videoTitle": controller
//                                               .videoDetailsModel!
//                                               .detailsOfVideo!
//                                               .title!,
//                                           "videoType": controller
//                                               .videoDetailsModel!
//                                               .detailsOfVideo!
//                                               .videoType!,
//                                           "videoTime": controller
//                                               .videoDetailsModel!
//                                               .detailsOfVideo!
//                                               .videoTime!,
//                                           "videoUrl": downloadPath,
//                                           "videoImage": downloadThumbnail,
//                                           "views": controller.videoDetailsModel!
//                                               .detailsOfVideo!.views!,
//                                           "channelId": controller
//                                               .videoDetailsModel!
//                                               .detailsOfVideo!
//                                               .channelId!,
//                                           "channelName": controller
//                                               .videoDetailsModel!
//                                               .detailsOfVideo!
//                                               .channelName!,
//                                           "time": formattedDate
//                                         },
//                                       );
//                                       DownloadHistory.onSet();
//                                     }
//                                     LocalNotificationServices
//                                         .onSendNotification(
//                                       "Download Complete",
//                                       controller.videoDetailsModel!
//                                           .detailsOfVideo!.title!,
//                                       () {
//                                         AppSettings.showLog(
//                                             "Go To Download Routes");
//                                         if (DownloadHistory
//                                             .mainDownloadHistory.isEmpty) {
//                                           DownloadHistory.onGet();
//                                         }
//                                         Get.to(() => const DownloadView());
//                                       },
//                                     );
//                                     CustomToast.show("Video download complete");
//                                     controller.isDownloading.value = false;
//                                     AppSettings.isDownloading.value = false;
//                                   } else {
//                                     controller.isDownloading.value = false;
//                                     AppSettings.isDownloading.value = false;
//                                   }
//                                 } else {
//                                   PremiumPlanDialog().show(context);
//                                 }
//                               },
//                             )),
//                       Obx(
//                         () => NormalVideoDetailsIconUi(
//                           title: controller.isSave.value
//                               ? AppStrings.saved.tr
//                               : AppStrings.save.tr,
//                           icon: controller.isSave.value
//                               ? AppIcons.saveDone1
//                               : AppIcons.addToSave,
//                           callback: () {
//                             if (controller.isSave.value == false) {
//                               controller.isSave.value = true;
//                               CustomToast.show(AppStrings.addToWatchLater.tr);
//                               CreateWatchLater.callApi(
//                                   Database.loginUserId!, controller.videoId);
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: SizeConfig.blockSizeVertical * 1),
//                 const Divider(indent: 5, endIndent: 5, height: 5),
//                 GestureDetector(
//                   onTap: () => Get.to(
//                     () => YourChannelView(
//                       loginUserId: Database.loginUserId!,
//                       channelId: controller
//                           .videoDetailsModel!.detailsOfVideo!.channelId!,
//                     ),
//                   ),
//                   child: ListTile(
//                     contentPadding:
//                         const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
//                     dense: true,
//                     leading: PreviewProfileImage(
//                       size: 45,
//                       id: controller
//                               .videoDetailsModel?.detailsOfVideo?.channelId ??
//                           "",
//                       image: controller.videoDetailsModel?.detailsOfVideo
//                               ?.channelImage ??
//                           "",
//                       fit: BoxFit.cover,
//                     ),
//                     title: Text(
//                       controller
//                           .videoDetailsModel!.detailsOfVideo!.channelName!,
//                       style: GoogleFonts.urbanist(
//                           fontWeight: FontWeight.bold, fontSize: 16),
//                     ),
//                     subtitle: Obx(
//                       () => Text(
//                         "${CustomFormatNumber.convert(controller.customChanges["subscribe"])} ${AppStrings.subscribes.tr}",
//                         style: GoogleFonts.urbanist(),
//                       ),
//                     ),
//                     trailing: Visibility(
//                       visible: Database.channelId !=
//                           controller
//                               .videoDetailsModel?.detailsOfVideo?.channelId,
//                       child: controller.videoDetailsModel?.detailsOfVideo
//                                   ?.channelType ==
//                               2
//                           ? GestureDetector(
//                               onTap: () async {
//                                 if (controller.isSubscribe.value == false) {
//                                   SubscribePremiumChannelBottomSheet.onShow(
//                                     coin: (controller
//                                                 .videoDetailsModel
//                                                 ?.detailsOfVideo
//                                                 ?.subscriptionCost ??
//                                             0)
//                                         .toString(),
//                                     callback: () async {
//                                       Get.dialog(const LoaderUi(),
//                                           barrierDismissible: false);
//                                       final bool isSuccess =
//                                           await SubscribeChannelApiClass
//                                               .callApi(controller
//                                                       .videoDetailsModel
//                                                       ?.detailsOfVideo
//                                                       ?.channelId ??
//                                                   "");
//
//                                       Get.close(2);
//
//                                       if (isSuccess) {
//                                         if (controller.isSubscribe.value) {
//                                           controller.isSubscribe.value = false;
//                                           controller
//                                               .customChanges["subscribe"]--;
//                                         } else {
//                                           controller.isSubscribe.value = true;
//                                           controller
//                                               .customChanges["subscribe"]++;
//                                         }
//                                       }
//                                     },
//                                   );
//                                 } else {
//                                   if (controller.isSubscribe.value) {
//                                     controller.isSubscribe.value = false;
//                                     controller.customChanges["subscribe"]--;
//                                   } else {
//                                     controller.isSubscribe.value = true;
//                                     controller.customChanges["subscribe"]++;
//                                   }
//                                   await SubscribeChannelApiClass.callApi(
//                                       controller.videoDetailsModel!
//                                           .detailsOfVideo!.channelId!);
//                                 }
//                               },
//                               child: Obx(
//                                 () => Container(
//                                   height: 40,
//                                   width:
//                                       controller.isSubscribe.value ? 100 : 150,
//                                   alignment: Alignment.center,
//                                   decoration: BoxDecoration(
//                                     color: controller.isSubscribe.value
//                                         ? Colors.transparent
//                                         : AppColor.primaryColor,
//                                     border: controller.isSubscribe.value
//                                         ? Border.all(
//                                             color: AppColor.primaryColor,
//                                             width: 1.5)
//                                         : null,
//                                     borderRadius: BorderRadius.circular(100),
//                                   ),
//                                   child: controller.isSubscribe.value
//                                       ? Text(
//                                           "Subscribed",
//                                           textAlign: TextAlign.center,
//                                           style: GoogleFonts.urbanist(
//                                             fontWeight: FontWeight.w600,
//                                             fontSize: 14,
//                                             color: AppColor.primaryColor,
//                                           ),
//                                         )
//                                       : Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             Text(
//                                               "Subscribe",
//                                               textAlign: TextAlign.center,
//                                               style: GoogleFonts.urbanist(
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: 14,
//                                                 color: AppColor.white,
//                                               ),
//                                             ),
//                                             8.width,
//                                             Image.asset(AppIcons.coin,
//                                                 width: 15),
//                                             Text(
//                                               " ${CustomFormatNumber.convert(0)}/m",
//                                               textAlign: TextAlign.center,
//                                               style: GoogleFonts.urbanist(
//                                                 fontWeight: FontWeight.w600,
//                                                 fontSize: 14,
//                                                 color: AppColor.white,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                 ),
//                               ),
//                             )
//                           : GestureDetector(
//                               onTap: () async {
//                                 if (controller.isSubscribe.value) {
//                                   controller.isSubscribe.value = false;
//                                   controller.customChanges["subscribe"]--;
//                                 } else {
//                                   controller.isSubscribe.value = true;
//                                   controller.customChanges["subscribe"]++;
//                                 }
//                                 await SubscribeChannelApiClass.callApi(
//                                     controller.videoDetailsModel!
//                                         .detailsOfVideo!.channelId!);
//                               },
//                               child: Obx(
//                                 () => Container(
//                                   height: 40,
//                                   width: SizeConfig.screenWidth / 3.8,
//                                   alignment: Alignment.center,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(25),
//                                     border: Border.all(
//                                         color: AppColor.primaryColor, width: 2),
//                                     color: controller.isSubscribe.value
//                                         ? Colors.transparent
//                                         : AppColor.primaryColor,
//                                   ),
//                                   child: Text(
//                                     controller.isSubscribe.value
//                                         ? AppStrings.subscribed.tr
//                                         : AppStrings.subscribe.tr,
//                                     style: GoogleFonts.urbanist(
//                                       fontSize: 13,
//                                       fontWeight: FontWeight.bold,
//                                       color: controller.isSubscribe.value
//                                           ? AppColor.primaryColor
//                                           : AppColor.white,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//                 const Divider(indent: 5, endIndent: 5, height: 5),
//                 Padding(
//                   padding: const EdgeInsets.only(left: 8),
//                   child: GestureDetector(
//                     onTap: () async {
//                       controller.chewieController?.pause();
//                       controller.customChanges["comment"] =
//                           await CommentBottomSheet.show(
//                         context,
//                         controller.videoId,
//                         controller
//                             .videoDetailsModel!.detailsOfVideo!.channelId!,
//                         controller.customChanges["comment"],
//                       );
//                     },
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text.rich(
//                           TextSpan(
//                             children: [
//                               TextSpan(
//                                 text: "${AppStrings.comments.tr} ",
//                                 style: GoogleFonts.urbanist(
//                                     fontSize: 15, fontWeight: FontWeight.w500),
//                               ),
//                               TextSpan(
//                                 text: CustomFormatNumber.convert(
//                                     controller.customChanges["comment"]),
//                                 style: GoogleFonts.urbanist(
//                                     fontSize: 15, fontWeight: FontWeight.w500),
//                               ),
//                             ],
//                           ),
//                         ),
//                         IconButton(
//                           padding: const EdgeInsets.symmetric(horizontal: 0),
//                           onPressed: () async {
//                             controller.chewieController?.pause();
//                             controller.customChanges["comment"] =
//                                 await CommentBottomSheet.show(
//                               context,
//                               controller.videoId,
//                               controller.videoDetailsModel!.detailsOfVideo!
//                                   .channelId!,
//                               controller.customChanges["comment"],
//                             );
//                           },
//                           icon: const ImageIcon(AssetImage(AppIcons.swap),
//                               size: 20),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       GestureDetector(
//                         child: Obx(
//                           () => PreviewProfileImage(
//                             size: 40,
//                             id: Database.channelId ?? "",
//                             image: AppSettings.profileImage.value,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: TextFormField(
//                           controller: controller.commentController,
//                           keyboardType: TextInputType.multiline,
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: isDarkMode.value
//                                 ? AppColor.secondDarkMode
//                                 : AppColor.grey_200,
//                             contentPadding: const EdgeInsets.only(left: 10),
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide.none),
//                             hintText: AppStrings.addComments.tr,
//                             hintStyle: GoogleFonts.urbanist(
//                                 color: Colors.grey, fontSize: 14),
//                             suffixIcon: IconButton(
//                               onPressed: () async {
//                                 if (controller
//                                     .commentController.text.isNotEmpty) {
//                                   final commentText =
//                                       controller.commentController.text;
//                                   controller.commentController.clear();
//                                   controller.customChanges["comment"]++;
//                                   FocusScope.of(context)
//                                       .requestFocus(FocusNode());
//                                   await CreateCommentApiClass.callApi(
//                                       controller.videoId, commentText);
//                                 }
//                               },
//                               icon: const Icon(Icons.send_rounded,
//                                   color: Colors.grey),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: SizeConfig.blockSizeVertical * 1),
//               ],
//             ),
//     );
//   }
// }
//
// class NormalVideoDetailsIconUi extends StatelessWidget {
//   const NormalVideoDetailsIconUi(
//       {super.key,
//       required this.title,
//       required this.icon,
//       required this.callback});
//
//   final String title;
//   final String icon;
//   final Callback callback;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         InkWell(
//           onTap: callback,
//           child: Container(
//             height: 35,
//             width: 35,
//             color: AppColor.transparent,
//             child: Center(
//               child: Image(
//                 image: AssetImage(icon),
//                 height: 22,
//                 width: 22,
//                 color:
//                     isDarkMode.value ? AppColor.white : const Color(0xFF424242),
//               ),
//             ),
//           ),
//         ),
//         Text(
//           title,
//           style: GoogleFonts.urbanist(
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//             color: isDarkMode.value ? AppColor.white : const Color(0xFF424242),
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:floating/floating.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/ads/google_ads/google_large_native_ad.dart';
import 'package:metube/pages/long_video_ads/long_video_ad_banner.dart';
import 'package:metube/pages/long_video_ads/long_video_ad_corner_overlay.dart';
import 'package:metube/pages/long_video_ads/long_video_ad_overlay.dart';
import 'package:metube/custom/custom_api/like_dislike_api.dart';
import 'package:metube/custom/custom_method/custom_download.dart';
import 'package:metube/custom/custom_method/custom_format_number.dart';
import 'package:metube/custom/custom_method/custom_format_timer.dart';
import 'package:metube/custom/custom_method/custom_share.dart';
import 'package:metube/custom/custom_method/custom_toast.dart';
import 'package:metube/custom/custom_ui/data_not_found_ui.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/custom/custom_ui/normal_video_ui.dart';
import 'package:metube/custom/custom_ui/premium_plan_dialog.dart';
import 'package:metube/custom/shimmer/normal_video_shimmer_ui.dart';
import 'package:metube/custom/shimmer/video_details_shimmer_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/database/download_history_database.dart';
import 'package:metube/main.dart';
import 'package:metube/notification/local_notification_services.dart';
import 'package:metube/pages/custom_pages/comment_page/comment_bottom_sheet.dart';
import 'package:metube/pages/custom_pages/comment_page/create_comment_api.dart';
import 'package:metube/pages/custom_pages/report_page/custom_report_view.dart';
import 'package:metube/pages/custom_pages/share_count_page/share_count_api.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:metube/pages/nav_home_page/controller/nav_home_controller.dart';
import 'package:metube/pages/nav_library_page/download_page/download_view.dart';
import 'package:metube/pages/nav_library_page/watch_later_page/create_watch_later_api.dart';
import 'package:metube/pages/nav_subscription_page/subscribe_channel_api.dart';
import 'package:metube/pages/profile_page/your_channel_page/main_page/your_channel_view.dart';
import 'package:metube/pages/splash_screen_page/api/unlock_private_video_api.dart';
import 'package:metube/pages/video_details_page/normal_video_details_controller.dart';
import 'package:metube/pages/video_details_page/video_description_bottom_sheet.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/convert_to_network.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:metube/utils/utils.dart';
import 'package:metube/widget/subscribe_premium_channel_bottom_sheet.dart';
import 'package:metube/widget/subscribed_success_dialog.dart';
import 'package:metube/widget/unlock_premium_video_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class NormalVideoDetailsView extends StatefulWidget {
  const NormalVideoDetailsView(
      {super.key,
      required this.videoId,
      required this.videoUrl,
      this.isPlayList});

  final String videoId;
  final String videoUrl;
  final bool? isPlayList;

  @override
  State<NormalVideoDetailsView> createState() => _NormalVideoDetailsViewState();
}

class _NormalVideoDetailsViewState extends State<NormalVideoDetailsView> {
  final navHomeController = Get.find<NavHomeController>();

  final _controller = Get.put(NormalVideoDetailsController());

  @override
  void initState() {
    _controller.mainRelatedVideos = null;
    _controller.mainWatchedVideos.clear();

    _controller.init(widget.videoId, widget.videoUrl);

    _controller.selectedWatchedVideo = 0;
    _controller.mainWatchedVideos.add(
        WatchedVideoModel(videoId: widget.videoId, videoUrl: widget.videoUrl));

    _controller.isDisablePrevious(true);

    if (widget.isPlayList ?? false) {
      _controller.isDisableNext(false);
      _controller.onGetPlayListVideos();
    } else {}
    super.initState();
  }

  @override
  void dispose() {
    _controller.onCreateHistory();
    _controller.restorePortraitMode();
    _controller.onDisposeVideoPlayer();
    super.dispose();
  }

  void onSubscribePrivateChannel({required int index}) {
    SubscribePremiumChannelBottomSheet.onShow(
      coin: (_controller.mainRelatedVideos?[index].user?.subscriptionCost ?? 0)
          .toString(),
      callback: () async {
        Get.dialog(const LoaderUi(), barrierDismissible: false);
        final bool isSuccess = await SubscribeChannelApiClass.callApi(
            _controller.mainRelatedVideos?[index].channelId ?? "");

        Get.close(2);

        if (isSuccess) {
          _controller.mainRelatedVideos =
              _controller.mainRelatedVideos?.map((e) {
            if (e.id == _controller.mainRelatedVideos?[index].id) {
              e.videoPrivacyType = 1;
            }
            return e;
          }).toList();

          _controller.update(["onGetRelatedVideos"]);
          SubscribedSuccessDialog.show(context);
        }
      },
    );
  }

  void onUnlockPrivateVideo({required int index}) {
    UnlockPremiumVideoBottomSheet.onShow(
      coin: (_controller.mainRelatedVideos?[index].user?.videoUnlockCost ?? 0)
          .toString(),
      callback: () async {
        Get.dialog(const LoaderUi(), barrierDismissible: false);
        await UnlockPrivateVideoApi.callApi(
            loginUserId: Database.loginUserId ?? "",
            videoId: _controller.mainRelatedVideos?[index].id ?? "");

        if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
          _controller.mainRelatedVideos =
              _controller.mainRelatedVideos?.map((e) {
            if (e.id == _controller.mainRelatedVideos?[index].id) {
              e.videoPrivacyType = 1;
            }
            return e;
          }).toList();
        }

        Get.close(2);
        _controller.update(["onGetRelatedVideos"]);
        SubscribedSuccessDialog.show(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 300), () {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
        ),
      );
    });
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop &&
            MediaQuery.of(context).orientation == Orientation.landscape) {
          await _controller.exitFullscreen();
          return;
        }

        if (didPop) {
          await _controller.restorePortraitMode();
        }
      },
      canPop: MediaQuery.of(context).orientation != Orientation.landscape,
      child: PiPSwitcher(
        childWhenEnabled: GetBuilder<NormalVideoDetailsController>(
          id: "onVideoInitialize",
          builder: (controller) => (_controller.chewieController != null &&
                  (_controller.videoPlayerController?.value.isInitialized ??
                      false))
              ? SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width:
                          _controller.videoPlayerController?.value.size.width ??
                              0,
                      height: _controller
                              .videoPlayerController?.value.size.height ??
                          0,
                      child: Chewie(controller: _controller.chewieController!),
                    ),
                  ),
                )
              : const Offstage(),
        ),
        childWhenDisabled: Scaffold(
          body: OrientationBuilder(builder: (context, orientation) {
            AppSettings.showLog("Current Orientation => $orientation");
            return Column(
              children: [
                PreviewVideoUi(orientation: orientation),
                orientation == Orientation.landscape
                    ? const Offstage()
                    : Expanded(
                        child: SingleChildScrollView(
                          controller: _controller.scrollController,
                          child: Column(
                            children: [
                              const VideoDetailsUi(),
                              GetBuilder<NormalVideoDetailsController>(
                                id: "onGetRelatedVideos",
                                builder: (controller) => controller
                                            .mainRelatedVideos ==
                                        null
                                    ? const NormalVideoShimmerUi()
                                        .paddingOnly(top: 10)
                                    : controller.mainRelatedVideos!.isEmpty
                                        ? const DataNotFoundUi()
                                            .paddingSymmetric(vertical: 50)
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: controller
                                                    .mainRelatedVideos
                                                    ?.length ??
                                                0,
                                            itemBuilder: (context, index) {
                                              final indexData = controller
                                                  .mainRelatedVideos![index];

                                              return ((indexData.videoPrivacyType ==
                                                              2 &&
                                                          indexData.user
                                                                  ?.channelType ==
                                                              1) ||
                                                      (indexData.videoPrivacyType ==
                                                              2 &&
                                                          indexData.user
                                                                  ?.channelType ==
                                                              2 &&
                                                          indexData
                                                                  .isSubscribedChannel ==
                                                              false))
                                                  ? PrivateContentNormalVideoUi(
                                                      videoId:
                                                          indexData.id ?? "",
                                                      title:
                                                          indexData.title ?? "",
                                                      videoImage: ConvertToNetwork
                                                          .resolve(indexData
                                                                  .videoImage ??
                                                              ''),
                                                      videoUrl:
                                                          indexData.videoUrl ??
                                                              "",
                                                      videoTime:
                                                          indexData.videoTime ??
                                                              0,
                                                      channelId:
                                                          indexData.channelId ??
                                                              "",
                                                      channelImage:
                                                          ConvertToNetwork
                                                              .resolve(indexData
                                                                      .user
                                                                      ?.image ??
                                                                  ''),
                                                      channelName: indexData
                                                              .user?.fullName ??
                                                          "",
                                                      views: indexData
                                                              .totalViews ??
                                                          0,
                                                      uploadTime:
                                                          indexData.time ?? "",
                                                      isSave: controller
                                                              .mainRelatedVideos?[
                                                                  index]
                                                              .isSavedToWatchLater ??
                                                          false,
                                                      subscribeCallback: () =>
                                                          onSubscribePrivateChannel(
                                                              index: index),
                                                      videoCallback: () =>
                                                          onUnlockPrivateVideo(
                                                              index: index),
                                                      videoCost: indexData.user
                                                              ?.videoUnlockCost ??
                                                          0,
                                                      subscribeCost: indexData
                                                              .user
                                                              ?.subscriptionCost ??
                                                          0,
                                                      channelType: indexData
                                                              .user
                                                              ?.channelType ??
                                                          1,
                                                    )
                                                  : GestureDetector(
                                                      onTap: () {
                                                        controller
                                                            .onCreateHistory();
                                                        controller
                                                            .onDisposeVideoPlayer();
                                                        controller
                                                            .isDisablePrevious(
                                                                false);
                                                        controller
                                                            .selectedWatchedVideo++;
                                                        controller
                                                            .mainWatchedVideos
                                                            .insert(
                                                          controller
                                                              .selectedWatchedVideo,
                                                          WatchedVideoModel(
                                                              videoId: controller
                                                                  .mainRelatedVideos![
                                                                      index]
                                                                  .id!,
                                                              videoUrl: controller
                                                                  .mainRelatedVideos![
                                                                      index]
                                                                  .videoUrl!),
                                                        );
                                                        controller.init(
                                                            controller
                                                                .mainRelatedVideos![
                                                                    index]
                                                                .id!,
                                                            controller
                                                                .mainRelatedVideos![
                                                                    index]
                                                                .videoUrl!);
                                                        controller
                                                                .mainRelatedVideos =
                                                            null;
                                                        controller.update([
                                                          "onGetRelatedVideos"
                                                        ]);
                                                      },
                                                      child: Column(
                                                        children: [
                                                          NormalVideoUi(
                                                            videoId: controller
                                                                .mainRelatedVideos![
                                                                    index]
                                                                .id!,
                                                            title: controller
                                                                .mainRelatedVideos![
                                                                    index]
                                                                .title!,
                                                            videoImage: ConvertToNetwork
                                                                .resolve(controller
                                                                    .mainRelatedVideos![
                                                                        index]
                                                                    .videoImage!),
                                                            videoUrl: controller
                                                                .mainRelatedVideos![
                                                                    index]
                                                                .videoUrl!,
                                                            videoTime: controller
                                                                .mainRelatedVideos![
                                                                    index]
                                                                .videoTime!,
                                                            channelId: controller
                                                                .mainRelatedVideos![
                                                                    index]
                                                                .channelId!,
                                                            channelImage: ConvertToNetwork
                                                                .resolve(controller
                                                                    .mainRelatedVideos![
                                                                        index]
                                                                    .user!
                                                                    .image!),
                                                            channelName: controller
                                                                .mainRelatedVideos![
                                                                    index]
                                                                .user!
                                                                .fullName!,
                                                            views: controller
                                                                .mainRelatedVideos![
                                                                    index]
                                                                .totalViews!,
                                                            isSave: controller
                                                                .mainRelatedVideos![
                                                                    index]
                                                                .isSavedToWatchLater!,
                                                          ),
                                                          index != 0 &&
                                                                  index %
                                                                          AppSettings
                                                                              .showAdsIndex ==
                                                                      0
                                                              ? const GoogleLargeNativeAd()
                                                              : const Offstage()
                                                        ],
                                                      ),
                                                    );
                                            },
                                          ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class PreviewVideoUi extends StatelessWidget {
  const PreviewVideoUi({super.key, required this.orientation});

  final Orientation orientation;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NormalVideoDetailsController>(
      id: "onVideoInitialize",
      builder: (controller) => Database.channelId !=
                  controller.videoDetailsModel?.detailsOfVideo?.channelId &&
              ((controller.videoDetailsModel?.detailsOfVideo
                              ?.videoPrivacyType ==
                          2 &&
                      controller
                              .videoDetailsModel?.detailsOfVideo?.channelType ==
                          1) ||
                  (controller.videoDetailsModel?.detailsOfVideo
                              ?.videoPrivacyType ==
                          2 &&
                      controller
                              .videoDetailsModel?.detailsOfVideo?.channelType ==
                          2 &&
                      controller.isSubscribe.value == false))
          ? Container(
              height: orientation == Orientation.landscape
                  ? Get.height
                  : Get.height / 3.5,
              width: Get.width,
              color: AppColor.black,
            )
          : (controller.chewieController != null &&
                  (controller.videoPlayerController?.value.isInitialized ??
                      false))
              ? GestureDetector(
                  onTap: () => controller.showVideoControls(),
                  child: GetBuilder<NormalVideoDetailsController>(
                    id: 'adComplete',
                    builder: (controller) {
                      final playerHeight = orientation ==
                              Orientation.landscape
                          ? Get.height
                          : Get.height / 3.5;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: playerHeight,
                            width: Get.width,
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(
                                  color: AppColor.black),
                              child: Stack(
                                clipBehavior: Clip.antiAlias,
                                children: [
                                  SizedBox(
                                    height: playerHeight,
                                    width: Get.width,
                                    child: Container(
                                      color: Colors.black,
                                      child: SizedBox.expand(
                                        child: FittedBox(
                                          fit: BoxFit.cover,
                                          child: Visibility(
                                            visible: !controller
                                                .isShowingInterruptAd,
                                            child: SizedBox(
                                              width: controller
                                                      .videoPlayerController
                                                      ?.value
                                                      .size
                                                      .width ??
                                                  0,
                                              height: controller
                                                      .videoPlayerController
                                                      ?.value
                                                      .size
                                                      .height ??
                                                  0,
                                              child: controller
                                                          .chewieController !=
                                                      null
                                                  ? Chewie(
                                                      controller: controller
                                                          .chewieController!)
                                                  : const CircularProgressIndicator(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (controller.activeOverlayAd != null)
                                    LongVideoAdCornerOverlay(
                                      ad: controller.activeOverlayAd!,
                                      onClose: controller.dismissOverlayAd,
                                    ),
                                  if (controller.isShowingInterruptAd &&
                                      controller.currentLongVideoAd != null)
                                    Positioned.fill(
                                      child: Stack(
                                        children: [
                                          LongVideoAdOverlay(
                                            ad: controller.currentLongVideoAd!,
                                            onStarted: controller.onAdStarted,
                                            onCompleted:
                                                controller.onAdCompleted1,
                                            onFailed: controller.onAdFailed,
                                          ),
                                          if (controller.isAdLoading)
                                            const Center(
                                              child: SpinKitCircle(
                                                color: AppColor.primaryColor,
                                                size: 60,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  Positioned(
                                    top: MediaQuery.of(context)
                                            .viewPadding
                                            .top +
                                        40,
                                    left: 20,
                                    child: Visibility(
                                      visible: AppStrings.isShowWaterMark,
                                      child: CachedNetworkImage(
                                        imageUrl: AppStrings.waterMarkIcon,
                                        fit: BoxFit.contain,
                                        imageBuilder:
                                            (context, imageProvider) => Image(
                                          image: ResizeImage(
                                            imageProvider,
                                            width: AppStrings.waterMarkSize,
                                            height: AppStrings.waterMarkSize,
                                          ),
                                          fit: BoxFit.contain,
                                        ),
                                        placeholder: (context, url) =>
                                            const Offstage(),
                                        errorWidget: (context, url, error) =>
                                            const Offstage(),
                                      ),
                                    ),
                                  ),
                                  GetBuilder<NormalVideoDetailsController>(
                                    id: 'onShowControls',
                                    builder: (controller) => Visibility(
                                      visible: controller.isShowVideoControls &&
                                          !controller.isShowingInterruptAd,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child:
                                      GetBuilder<NormalVideoDetailsController>(
                                    id: "onLoading",
                                    builder: (controller) =>
                                        controller.isVideoLoading
                                            ? const SpinKitCircle(
                                                color: AppColor.transparent,
                                                size: 60)
                                            : const Offstage(),
                                  ),
                                ),
                                Positioned(
                                  top: Platform.isAndroid ? 30 : 40,
                                  child: SizedBox(
                                    width: Get.width,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            orientation == Orientation.portrait
                                                ? IconButton(
                                                    icon: const ImageIcon(
                                                        AssetImage(
                                                            AppIcons.arrowBack),
                                                        size: 18,
                                                        color: AppColor.white),
                                                    onPressed: () async {
                                                      controller
                                                          .videoPlayerController
                                                          ?.pause();
                                                      Get.back();
                                                    },
                                                  ).paddingOnly(left: 10)
                                                : const Offstage(),
                                            orientation == Orientation.landscape
                                                ? IconButton(
                                                    icon: const ImageIcon(
                                                        AssetImage(
                                                            AppIcons.arrowBack),
                                                        size: 18,
                                                        color: AppColor.white),
                                                    onPressed: () async {
                                                      await controller
                                                          .exitFullscreen();
                                                    },
                                                  )
                                                : const Offstage(),
                                            orientation == Orientation.landscape
                                                ? SizedBox(
                                                    width: Get.width / 2,
                                                    child: Obx(
                                                      () => Text(
                                                        controller
                                                                .isVideoDetailsLoading
                                                                .value
                                                            ? ""
                                                            : controller
                                                                    .videoDetailsModel
                                                                    ?.detailsOfVideo
                                                                    ?.title ??
                                                                "",
                                                        style: GoogleFonts
                                                            .urbanist(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: AppColor
                                                                    .white),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  )
                                                : const Offstage(),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            orientation == Orientation.landscape
                                                ? IconButton(
                                                    icon: const ImageIcon(
                                                      AssetImage(
                                                          AppIcons.share),
                                                      size: 22,
                                                      color: AppColor.white,
                                                    ),
                                                    onPressed: () async {
                                                      final details = controller
                                                          .videoDetailsModel
                                                          ?.detailsOfVideo;
                                                      await CustomShare.share(
                                                        name: details?.title ??
                                                            "",
                                                        url: (details?.videoUrl
                                                                    ?.isNotEmpty ??
                                                                false)
                                                            ? details!.videoUrl!
                                                            : controller
                                                                    .mainWatchedVideos
                                                                    .isNotEmpty
                                                                ? controller
                                                                    .mainWatchedVideos[
                                                                        controller
                                                                            .selectedWatchedVideo]
                                                                    .videoUrl
                                                                : "",
                                                        channelId: details
                                                                ?.channelId ??
                                                            "",
                                                        videoId:
                                                            details?.id ?? "",
                                                        image: details
                                                                ?.videoImage ??
                                                            "",
                                                        pageRoutes:
                                                            "NormalVideo",
                                                      );

                                                      await ShareCountApiClass
                                                          .callApi(
                                                              Database.loginUserId ??
                                                                  "",
                                                              controller
                                                                  .videoId);
                                                    },
                                                  )
                                                : const Offstage(),
                                            Obx(
                                              () => IconButton(
                                                onPressed: () =>
                                                    controller.onToggleVolume(),
                                                icon: Icon(
                                                  controller.isSpeaker.value
                                                      ? Icons.volume_up_rounded
                                                      : Icons
                                                          .volume_off_rounded,
                                                  color: AppColor.white,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.more_vert,
                                                color: AppColor.white,
                                                size: 25,
                                              ),
                                              onPressed: () {
                                                orientation ==
                                                        Orientation.portrait
                                                    ? Get.bottomSheet(
                                                        backgroundColor: isDarkMode
                                                                .value
                                                            ? AppColor
                                                                .secondDarkMode
                                                            : AppColor.white,
                                                        isScrollControlled:
                                                            true,
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    25),
                                                            topRight:
                                                                Radius.circular(
                                                                    25),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 200,
                                                          child:
                                                              SingleChildScrollView(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          15),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const SizedBox(
                                                                      height:
                                                                          8),
                                                                  Center(
                                                                    child:
                                                                        Container(
                                                                      width: 30,
                                                                      height: 3,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(60),
                                                                        color: AppColor
                                                                            .grey_300,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          4),
                                                                  Center(
                                                                    child: Text(
                                                                      AppStrings
                                                                          .moreOption
                                                                          .tr,
                                                                      style: GoogleFonts
                                                                          .urbanist(
                                                                        textStyle:
                                                                            const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              20,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Divider(
                                                                      indent:
                                                                          20,
                                                                      endIndent:
                                                                          20,
                                                                      color: AppColor
                                                                          .grey_200),
                                                                  const SizedBox(
                                                                      height:
                                                                          5),
                                                                  Row(
                                                                      children: [
                                                                        const ImageIcon(
                                                                            AssetImage(AppIcons.loopVideo)),
                                                                        const SizedBox(
                                                                            width:
                                                                                10),
                                                                        Text(
                                                                          AppStrings
                                                                              .loopVideo
                                                                              .tr,
                                                                          style:
                                                                              GoogleFonts.urbanist(
                                                                            textStyle:
                                                                                const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 15,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const Spacer(),
                                                                        SizedBox(
                                                                          height:
                                                                              20,
                                                                          width:
                                                                              25,
                                                                          child:
                                                                              Transform.scale(
                                                                            scale:
                                                                                0.7,
                                                                            child:
                                                                                Obx(
                                                                              () => CupertinoSwitch(
                                                                                activeColor: AppColor.primaryColor,
                                                                                value: controller.isLoop.value,
                                                                                onChanged: (value) {
                                                                                  controller.isLoop.value = value;

                                                                                  controller.onChangeLoop();
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ).paddingOnly(
                                                                            right:
                                                                                10),
                                                                      ]),
                                                                  const SizedBox(
                                                                      height:
                                                                          20),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Get.back();
                                                                      Get.bottomSheet(
                                                                        backgroundColor: isDarkMode.value
                                                                            ? AppColor.secondDarkMode
                                                                            : AppColor.white,
                                                                        isScrollControlled:
                                                                            true,
                                                                        shape:
                                                                            const RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.only(
                                                                            topLeft:
                                                                                Radius.circular(25),
                                                                            topRight:
                                                                                Radius.circular(25),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              250,
                                                                          child:
                                                                              SingleChildScrollView(
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                const SizedBox(height: 10),
                                                                                Center(
                                                                                  child: Container(
                                                                                    width: SizeConfig.blockSizeHorizontal * 12,
                                                                                    height: 3,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.circular(60),
                                                                                      color: AppColor.grey_300,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 10),
                                                                                Center(
                                                                                  child: Text(
                                                                                    AppStrings.playbackSpeed.tr,
                                                                                    style: GoogleFonts.urbanist(
                                                                                      textStyle: const TextStyle(
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontSize: 15,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(height: 5),
                                                                                const Divider(),
                                                                                for (int i = 0; i < controller.speedOptions.length; i++)
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(left: 20, bottom: 8),
                                                                                    child: GestureDetector(
                                                                                      onTap: () {
                                                                                        controller.currentSpeedIndex.value = i;
                                                                                        controller.videoPlayerController?.setPlaybackSpeed(controller.speedOptions[controller.currentSpeedIndex.value]);
                                                                                      },
                                                                                      child: Obx(
                                                                                        () => Row(
                                                                                          children: [
                                                                                            controller.currentSpeedIndex.value == i ? Image.asset(AppIcons.done, height: 15, width: 15) : const SizedBox(width: 15),
                                                                                            const SizedBox(width: 10),
                                                                                            Text(
                                                                                              "${controller.speedOptions[i]}x",
                                                                                              style: GoogleFonts.urbanist(
                                                                                                textStyle: const TextStyle(
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                  fontSize: 15,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                    child: Row(
                                                                      children: [
                                                                        const ImageIcon(
                                                                          AssetImage(
                                                                              AppIcons.playSpeed),
                                                                          size:
                                                                              22,
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                10),
                                                                        Text(
                                                                          AppStrings
                                                                              .playbackSpeed
                                                                              .tr,
                                                                          style:
                                                                              GoogleFonts.urbanist(
                                                                            textStyle:
                                                                                const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 15,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const Spacer(),
                                                                        Obx(
                                                                          () =>
                                                                              Text(
                                                                            controller.currentSpeedIndex.value == 2
                                                                                ? AppStrings.normal.tr
                                                                                : "${controller.speedOptions[controller.currentSpeedIndex.value]}x",
                                                                            style:
                                                                                GoogleFonts.urbanist(
                                                                              textStyle: const TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 15,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                3),
                                                                        const ImageIcon(
                                                                          AssetImage(
                                                                              AppIcons.arrowDown),
                                                                          size:
                                                                              18,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          20),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      Get.back();
                                                                      CustomReportView.show(
                                                                          controller
                                                                              .videoId);
                                                                    },
                                                                    child: Row(
                                                                      children: [
                                                                        const ImageIcon(
                                                                            AssetImage(AppIcons.report)),
                                                                        const SizedBox(
                                                                            width:
                                                                                10),
                                                                        Text(
                                                                          "${AppStrings.report.tr}-${AppStrings.block.tr}",
                                                                          style:
                                                                              GoogleFonts.urbanist(textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          20),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Get.defaultDialog(
                                                        title: AppStrings
                                                            .moreOption.tr,
                                                        titlePadding:
                                                            const EdgeInsets
                                                                .only(top: 10),
                                                        titleStyle: GoogleFonts
                                                            .urbanist(
                                                          textStyle:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                        backgroundColor: isDarkMode
                                                                .value
                                                            ? AppColor
                                                                .secondDarkMode
                                                            : AppColor.white,
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10),
                                                        content: Container(
                                                          height: 130,
                                                          padding:
                                                              EdgeInsets.only(
                                                            left: SizeConfig
                                                                    .blockSizeHorizontal *
                                                                2,
                                                            right: SizeConfig
                                                                    .blockSizeHorizontal *
                                                                2,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            color: Colors
                                                                .transparent,
                                                          ),
                                                          child:
                                                              SingleChildScrollView(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Divider(
                                                                    indent: 25,
                                                                    endIndent:
                                                                        25,
                                                                    color: AppColor
                                                                        .grey_300),
                                                                const SizedBox(
                                                                    height: 5),
                                                                Row(children: [
                                                                  const ImageIcon(
                                                                      AssetImage(
                                                                          AppIcons
                                                                              .loopVideo)),
                                                                  const SizedBox(
                                                                      width:
                                                                          10),
                                                                  Text(
                                                                    AppStrings
                                                                        .loopVideo
                                                                        .tr,
                                                                    style: GoogleFonts.urbanist(
                                                                        textStyle: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 15)),
                                                                  ),
                                                                  const Spacer(),
                                                                  SizedBox(
                                                                    height: 20,
                                                                    width: 25,
                                                                    child: Transform
                                                                        .scale(
                                                                      scale:
                                                                          0.7,
                                                                      child:
                                                                          Obx(
                                                                        () =>
                                                                            CupertinoSwitch(
                                                                          activeColor:
                                                                              AppColor.primaryColor,
                                                                          value: controller
                                                                              .isLoop
                                                                              .value,
                                                                          onChanged:
                                                                              (value) {
                                                                            controller.isLoop.value =
                                                                                value;

                                                                            controller.onChangeLoop();
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ).paddingOnly(
                                                                      right:
                                                                          10),
                                                                ]),
                                                                const SizedBox(
                                                                    height: 15),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Get.back();
                                                                    Get.defaultDialog(
                                                                      title: AppStrings
                                                                          .playbackSpeed
                                                                          .tr,
                                                                      titlePadding: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              20),
                                                                      titleStyle:
                                                                          GoogleFonts
                                                                              .urbanist(
                                                                        textStyle: const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize: 16),
                                                                      ),
                                                                      backgroundColor: isDarkMode.value
                                                                          ? AppColor
                                                                              .secondDarkMode
                                                                          : AppColor
                                                                              .white,
                                                                      content:
                                                                          Container(
                                                                        height:
                                                                            170,
                                                                        padding:
                                                                            EdgeInsets.only(
                                                                          left: SizeConfig.blockSizeHorizontal *
                                                                              2,
                                                                          right:
                                                                              SizeConfig.blockSizeHorizontal * 2,
                                                                        ),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(20),
                                                                          color:
                                                                              AppColor.transparent,
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            const Divider(),
                                                                            Expanded(
                                                                              child: SingleChildScrollView(
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    for (int i = 0; i < controller.speedOptions.length; i++)
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.only(left: 10, top: 10),
                                                                                        child: GestureDetector(
                                                                                          onTap: () {
                                                                                            controller.currentSpeedIndex.value = i;
                                                                                            controller.videoPlayerController?.setPlaybackSpeed(controller.speedOptions[controller.currentSpeedIndex.value]);
                                                                                          },
                                                                                          child: Obx(
                                                                                            () => Row(
                                                                                              children: [
                                                                                                controller.currentSpeedIndex.value == i ? Image.asset(AppIcons.done, height: 15, width: 15) : const SizedBox(width: 15),
                                                                                                const SizedBox(width: 10),
                                                                                                Text("${controller.speedOptions[i]}x"),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      const ImageIcon(
                                                                          AssetImage(
                                                                              AppIcons.playSpeed)),
                                                                      const SizedBox(
                                                                          width:
                                                                              10),
                                                                      Text(
                                                                          AppStrings
                                                                              .playbackSpeed
                                                                              .tr,
                                                                          style:
                                                                              GoogleFonts.urbanist(textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                                                                      const Spacer(),
                                                                      Obx(
                                                                        () =>
                                                                            Text(
                                                                          controller.currentSpeedIndex.value == 2
                                                                              ? AppStrings.normal.tr
                                                                              : "${controller.speedOptions[controller.currentSpeedIndex.value]}x",
                                                                          style:
                                                                              GoogleFonts.urbanist(
                                                                            textStyle:
                                                                                const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 15,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          width:
                                                                              3),
                                                                      const ImageIcon(
                                                                        AssetImage(
                                                                            AppIcons.arrowDown),
                                                                        size:
                                                                            18,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 15),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Get.back();
                                                                    CustomReportView.show(
                                                                        controller
                                                                            .videoId);
                                                                  },
                                                                  child: Row(
                                                                    children: [
                                                                      const ImageIcon(
                                                                          AssetImage(
                                                                              AppIcons.report)),
                                                                      const SizedBox(
                                                                          width:
                                                                              10),
                                                                      Text(
                                                                        "${AppStrings.report.tr}-${AppStrings.block.tr}",
                                                                        style: GoogleFonts.urbanist(
                                                                            textStyle:
                                                                                const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 10),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                              },
                                            ),
                                            const SizedBox(width: 10),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // >>>>> Both Mode Progress Line <<<<<<<
                                Positioned(
                                  bottom: orientation == Orientation.portrait
                                      ? 25
                                      : 50,
                                  child:
                                      GetBuilder<NormalVideoDetailsController>(
                                    id: "onProgressLine",
                                    builder: (controller) => SizedBox(
                                      width: Get.width,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          children: [
                                            orientation == Orientation.landscape
                                                ? GetBuilder<
                                                    NormalVideoDetailsController>(
                                                    id: "onVideoTime",
                                                    builder: (controller) =>
                                                        Text(
                                                      CustomFormatTime.convert(
                                                          controller
                                                                  .videoPlayerController
                                                                  ?.value
                                                                  .position
                                                                  .inMilliseconds ??
                                                              0),
                                                      style: const TextStyle(
                                                          color: AppColor.white,
                                                          fontSize: 12),
                                                    ),
                                                  )
                                                : const Offstage(),
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  // Ad markers overlay
                                                  Positioned.fill(
                                                    child: CustomPaint(
                                                      painter: AdMarkersPainter(
                                                        adTimings: controller
                                                            .adTimings,
                                                        videoDuration: controller
                                                                .videoPlayerController
                                                                ?.value
                                                                .duration ??
                                                            Duration.zero,
                                                        adShowCount: controller
                                                            .adShowCount,
                                                        currentPosition: controller
                                                                    .videoPlayerController !=
                                                                null
                                                            ? controller
                                                                .videoPlayerController!
                                                                .value
                                                                .position
                                                            : Duration.zero,
                                                      ),
                                                    ),
                                                  ),
                                                  // Main Slider
                                                  SliderTheme(
                                                    data:
                                                        SliderTheme.of(context)
                                                            .copyWith(
                                                      trackHeight: 5,
                                                      trackShape:
                                                          const RoundedRectSliderTrackShape(),
                                                      inactiveTrackColor:
                                                          Colors.white60,
                                                      thumbColor:
                                                          AppColor.white,
                                                      activeTrackColor:
                                                          AppColor.primaryColor,
                                                      thumbShape:
                                                          const RoundSliderThumbShape(
                                                              enabledThumbRadius:
                                                                  12.0),
                                                      overlayShape:
                                                          const RoundSliderOverlayShape(
                                                              overlayRadius:
                                                                  24.0),
                                                    ),
                                                    child: Slider(
                                                      value: controller
                                                              .videoPlayerController
                                                              ?.value
                                                              .position
                                                              .inMilliseconds
                                                              .toDouble() ??
                                                          0,
                                                      onChanged:
                                                          (double value) {
                                                        // Don't allow seeking during ad
                                                        if (controller
                                                            .isShowingInterruptAd)
                                                          return;

                                                        Duration?
                                                            currentPosition =
                                                            controller
                                                                .videoPlayerController
                                                                ?.value
                                                                .position;
                                                        Duration newPosition =
                                                            Duration(
                                                                milliseconds:
                                                                    value
                                                                        .toInt());

                                                        if (currentPosition !=
                                                            null) {
                                                          if (currentPosition <
                                                              newPosition) {
                                                            controller
                                                                    .isVideoSkip =
                                                                true;
                                                          }
                                                        }
                                                        controller
                                                            .videoPlayerController
                                                            ?.seekTo(
                                                                newPosition);
                                                      },
                                                      min: 0.0,
                                                      max: controller
                                                              .videoPlayerController
                                                              ?.value
                                                              .duration
                                                              .inMilliseconds
                                                              .toDouble() ??
                                                          0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            orientation == Orientation.landscape
                                                ? Text(
                                                    CustomFormatTime.convert(
                                                        controller
                                                                .videoPlayerController
                                                                ?.value
                                                                .duration
                                                                .inMilliseconds ??
                                                            0),
                                                    style: const TextStyle(
                                                        color: AppColor.white,
                                                        fontSize: 12),
                                                  )
                                                : const Offstage(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                orientation == Orientation.portrait
                                    ? Positioned(
                                        bottom: 0,
                                        child: SizedBox(
                                          width: Get.width,
                                          child: Row(
                                            children: [
                                              const SizedBox(width: 10),
                                              GetBuilder<
                                                  NormalVideoDetailsController>(
                                                id: "onVideoTime",
                                                builder: (controller) => Text(
                                                  CustomFormatTime.convert(
                                                      controller
                                                              .videoPlayerController
                                                              ?.value
                                                              .position
                                                              .inMilliseconds ??
                                                          0),
                                                  style: const TextStyle(
                                                      color: AppColor.white,
                                                      fontSize: 12),
                                                ),
                                              ),
                                              Text(
                                                " / ${CustomFormatTime.convert(controller.videoPlayerController?.value.duration.inMilliseconds ?? 0)}",
                                                style: const TextStyle(
                                                    color: AppColor.white,
                                                    fontSize: 12),
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                icon: const ImageIcon(
                                                  AssetImage(AppIcons.expand),
                                                  size: 20,
                                                  color: AppColor.white,
                                                ),
                                                onPressed: () async {
                                                  await controller
                                                      .enterFullscreen();
                                                },
                                              ),
                                              const SizedBox(width: 10),
                                            ],
                                          ),
                                        ),
                                      )
                                    : const Offstage(),
                                orientation == Orientation.portrait
                                    ? Align(
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          width: Get.width,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const ImageIcon(
                                                    AssetImage(
                                                        AppIcons.backward10s),
                                                    size: 20,
                                                    color: AppColor.white),
                                                onPressed: () async =>
                                                    await controller
                                                        .backwardSkipVideo(),
                                              ),
                                              Obx(
                                                () => IconButton(
                                                  icon: ImageIcon(
                                                      const AssetImage(
                                                          AppIcons.previous),
                                                      size: 25,
                                                      color: controller
                                                              .isDisablePrevious
                                                              .value
                                                          ? AppColor.white
                                                              .withOpacity(0.6)
                                                          : AppColor.white),
                                                  onPressed: controller
                                                          .isDisablePrevious
                                                          .value
                                                      ? () {}
                                                      : () {
                                                          AppSettings.showLog(
                                                              "Previous Video Playing....");
                                                          controller
                                                              .onPreviousVideo();
                                                        },
                                                ),
                                              ),
                                              GetBuilder<
                                                  NormalVideoDetailsController>(
                                                id: "onVideoPlayPause",
                                                builder: (controller) =>
                                                    IconButton(
                                                  icon: ImageIcon(
                                                    AssetImage(
                                                      (controller
                                                                  .videoPlayerController
                                                                  ?.value
                                                                  .isPlaying ??
                                                              false)
                                                          ? AppIcons.pause
                                                          : AppIcons.videoPlay,
                                                    ),
                                                    size: 28,
                                                    color: AppColor.white,
                                                  ),
                                                  onPressed: () {
                                                    if (controller
                                                            .videoPlayerController
                                                            ?.value
                                                            .isPlaying ??
                                                        false) {
                                                      controller
                                                          .videoPlayerController
                                                          ?.pause();
                                                    } else {
                                                      controller
                                                          .videoPlayerController
                                                          ?.play();
                                                    }
                                                  },
                                                ),
                                              ),
                                              Obx(
                                                () => IconButton(
                                                  icon: ImageIcon(
                                                      const AssetImage(
                                                          AppIcons.next),
                                                      size: 25,
                                                      color: controller
                                                              .isDisableNext
                                                              .value
                                                          ? AppColor.white
                                                              .withOpacity(0.6)
                                                          : AppColor.white),
                                                  onPressed: controller
                                                          .isDisableNext.value
                                                      ? () {}
                                                      : () {
                                                          AppSettings.showLog(
                                                              "Next Video Playing....");
                                                          controller
                                                              .onNextVideo();
                                                        },
                                                ),
                                              ),
                                              IconButton(
                                                icon: const ImageIcon(
                                                  AssetImage(
                                                      AppIcons.forward10s),
                                                  size: 20,
                                                  color: AppColor.white,
                                                ),
                                                onPressed: () async =>
                                                    await controller
                                                        .forwardSkipVideo(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : const Offstage(),
                                orientation == Orientation.landscape
                                    ? Positioned(
                                        bottom: 5,
                                        child: SizedBox(
                                          width: Get.width,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Obx(
                                                    () => IconButton(
                                                      onPressed: () async {
                                                        if (!controller
                                                            .isLike.value) {
                                                          if (controller
                                                              .isDisLike
                                                              .value) {
                                                            controller.isDisLike
                                                                .value = false;
                                                            controller
                                                                    .customChanges[
                                                                "disLike"]--;
                                                          }
                                                          controller.isLike
                                                              .value = true;
                                                          controller
                                                                  .customChanges[
                                                              "like"]++;
                                                          await LikeDisLikeVideoApi
                                                              .callApi(
                                                                  controller
                                                                      .videoId,
                                                                  true);
                                                        }
                                                      },
                                                      icon: ImageIcon(
                                                        AssetImage(controller
                                                                .isLike.value
                                                            ? AppIcons.likeBold
                                                            : AppIcons.like),
                                                        size: 25,
                                                        color: AppColor.white,
                                                      ).paddingOnly(bottom: 2),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Obx(
                                                    () => IconButton(
                                                      onPressed: () async {
                                                        if (!controller
                                                            .isDisLike.value) {
                                                          if (controller
                                                              .isLike.value) {
                                                            controller.isLike
                                                                .value = false;
                                                            controller
                                                                    .customChanges[
                                                                "like"]--;
                                                          }
                                                          controller.isDisLike
                                                              .value = true;
                                                          controller
                                                                  .customChanges[
                                                              "disLike"]++;
                                                          await LikeDisLikeVideoApi
                                                              .callApi(
                                                                  controller
                                                                      .videoId,
                                                                  false);
                                                        }
                                                      },
                                                      icon: ImageIcon(
                                                              AssetImage(controller
                                                                      .isDisLike
                                                                      .value
                                                                  ? AppIcons
                                                                      .disLikeBold
                                                                  : AppIcons
                                                                      .disLike),
                                                              size: 25,
                                                              color: AppColor
                                                                  .white)
                                                          .paddingOnly(top: 2),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const ImageIcon(
                                                        AssetImage(AppIcons
                                                            .backward10s),
                                                        size: 28,
                                                        color: AppColor.white),
                                                    onPressed: () async =>
                                                        await controller
                                                            .backwardSkipVideo(),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Obx(
                                                    () => IconButton(
                                                      icon: ImageIcon(
                                                          const AssetImage(
                                                              AppIcons
                                                                  .previous),
                                                          size: 28,
                                                          color: controller
                                                                  .isDisablePrevious
                                                                  .value
                                                              ? AppColor.white
                                                                  .withOpacity(
                                                                      0.6)
                                                              : AppColor.white),
                                                      onPressed: controller
                                                              .isDisablePrevious
                                                              .value
                                                          ? () {}
                                                          : () {
                                                              AppSettings.showLog(
                                                                  "Previous Video Playing....");
                                                              controller
                                                                  .onPreviousVideo();
                                                            },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  GetBuilder<
                                                      NormalVideoDetailsController>(
                                                    id: "onVideoPlayPause",
                                                    builder: (controller) =>
                                                        IconButton(
                                                      icon: ImageIcon(
                                                          AssetImage(
                                                            (controller
                                                                        .videoPlayerController
                                                                        ?.value
                                                                        .isPlaying ??
                                                                    false)
                                                                ? AppIcons.pause
                                                                : AppIcons
                                                                    .videoPlay,
                                                          ),
                                                          size: 35,
                                                          color:
                                                              AppColor.white),
                                                      onPressed: () {
                                                        if (controller
                                                                .videoPlayerController
                                                                ?.value
                                                                .isPlaying ??
                                                            false) {
                                                          controller
                                                              .videoPlayerController
                                                              ?.pause();
                                                        } else {
                                                          controller
                                                              .videoPlayerController
                                                              ?.play();
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Obx(
                                                    () => IconButton(
                                                      icon: ImageIcon(
                                                          const AssetImage(
                                                              AppIcons.next),
                                                          size: 28,
                                                          color: controller
                                                                  .isDisableNext
                                                                  .value
                                                              ? AppColor.white
                                                                  .withOpacity(
                                                                      0.6)
                                                              : AppColor.white),
                                                      onPressed: controller
                                                              .isDisableNext
                                                              .value
                                                          ? () {}
                                                          : () {
                                                              AppSettings.showLog(
                                                                  "Next Video Playing....");
                                                              controller
                                                                  .onNextVideo();
                                                            },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  IconButton(
                                                    icon: const ImageIcon(
                                                        AssetImage(AppIcons
                                                            .forward10s),
                                                        size: 28,
                                                        color: AppColor.white),
                                                    onPressed: () async =>
                                                        await controller
                                                            .forwardSkipVideo(),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      if (controller
                                                              .isSave.value ==
                                                          false) {
                                                        controller.isSave
                                                            .value = true;
                                                        CustomToast.show(
                                                            AppStrings
                                                                .addToWatchLater
                                                                .tr);
                                                        CreateWatchLater.callApi(
                                                            Database.loginUserId ??
                                                                "",
                                                            controller.videoId);
                                                      }
                                                    },
                                                    icon: Obx(
                                                      () => ImageIcon(
                                                          AssetImage(controller
                                                                  .isSave.value
                                                              ? AppIcons
                                                                  .saveDone1
                                                              : AppIcons
                                                                  .addToSave),
                                                          size: 22,
                                                          color:
                                                              AppColor.white),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  IconButton(
                                                    icon: const ImageIcon(
                                                        AssetImage(
                                                            AppIcons.collapse),
                                                        size: 25,
                                                        color: AppColor.white),
                                                    onPressed: () async {
                                                      await controller
                                                          .exitFullscreen();
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ).paddingSymmetric(horizontal: 10),
                                        ))
                                    : const Offstage(),
                              ],
                            ),
                          ),
                        ),
                                ],
                              ),
                            ),
                          ),
                          if (controller.activeBannerAd != null)
                            LongVideoAdBanner(
                              ad: controller.activeBannerAd!,
                              onDismissed: controller.dismissBannerAd,
                            ),
                        ],
                      );
                    },
                  ),
                )
              : Container(
                  height: orientation == Orientation.landscape
                      ? Get.height
                      : Get.height / 3.5,
                  width: Get.width,
                  color: AppColor.black,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if ((controller.videoDetailsModel?.detailsOfVideo
                                  ?.videoImage ??
                              '')
                          .isNotEmpty)
                        PreviewVideoImage(
                          videoId: controller.videoId,
                          videoImage: controller
                                  .videoDetailsModel!.detailsOfVideo!.videoImage ??
                              '',
                          fit: BoxFit.cover,
                        ),
                      Positioned(
                        top: 30,
                        child: SizedBox(
                          width: Get.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: const ImageIcon(
                                    AssetImage(AppIcons.arrowBack),
                                    size: 18,
                                    color: AppColor.white),
                                onPressed: () async {
                                  try {
                                    controller.videoPlayerController?.pause();
                                    Get.back();
                                  } catch (e) {
                                    log("Back Error");
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                      const Center(
                          child: SpinKitCircle(
                              color: AppColor.primaryColor, size: 60)),
                    ],
                  ),
                ),
    );
  }
}

class AdMarkersPainter extends CustomPainter {
  final List<int> adTimings;
  final Duration videoDuration;
  final int adShowCount;
  final Duration currentPosition;

  AdMarkersPainter({
    required this.adTimings,
    required this.videoDuration,
    required this.adShowCount,
    required this.currentPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (videoDuration.inSeconds == 0 || adTimings.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;

    // Draw ad markers on progress bar
    for (int i = 0; i < adTimings.length; i++) {
      final adTime = adTimings[i];

      // Skip if ad time is beyond video duration
      if (adTime > videoDuration.inSeconds) continue;

      // Calculate position on slider
      final position = (adTime / videoDuration.inSeconds) * size.width;

      // Choose color based on ad status
      Color dotColor;
      if (i < adShowCount) {
        // Ad already shown - green color
        dotColor = Colors.green;
      } else if (currentPosition.inSeconds >= adTime - 10 &&
          currentPosition.inSeconds < adTime) {
        // Ad coming soon (within 10 seconds) - yellow color
        dotColor = Colors.yellow;
      } else {
        // Future ad - red color
        dotColor = Colors.yellow;
      }

      paint.color = dotColor;

      // Draw ad marker dot
      canvas.drawCircle(
        Offset(position, size.height / 2),
        2.5, // Dot radius
        paint,
      );

      // Draw white border around dot for better visibility
      final borderPaint = Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawCircle(
        Offset(position, size.height / 2),
        2.5,
        borderPaint,
      );

      // Add ad number text above dot (optional)
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.transparent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(position - textPainter.width / 2, -textPainter.height - 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is AdMarkersPainter) {
      return oldDelegate.adTimings != adTimings ||
          oldDelegate.videoDuration != videoDuration ||
          oldDelegate.adShowCount != adShowCount ||
          oldDelegate.currentPosition != currentPosition;
    }
    return true;
  }
}

class VideoDetailsUi extends GetView<NormalVideoDetailsController> {
  const VideoDetailsUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.isVideoDetailsLoading.value) {
          return const VideoDetailsShimmerUi();
        }
        final details = controller.videoDetailsModel?.detailsOfVideo;
        return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          details?.title ?? "",
                          style: profileTitleStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      IconButton(
                        padding: const EdgeInsets.only(left: 8),
                        onPressed: () {
                          controller.chewieController?.pause();
                          DescriptionBottomSheet.show(
                              details?.channelId ?? "",
                              details?.title ?? "",
                              details?.channelImage ?? "",
                              details?.channelName ?? "",
                              details?.like ?? 0,
                              details?.dislike ?? 0,
                              details?.views ?? 0,
                              details?.createdAt ?? "",
                              details?.hashTag?.join(',') ?? "",
                              details?.description ?? "");
                        },
                        icon: const ImageIcon(AssetImage(AppIcons.arrowDown),
                            size: 20),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                      "${CustomFormatNumber.convert(details?.views ?? 0)} ${AppStrings.views.tr} - ${details?.time ?? ""}",
                      style: fillYourProfileStyle),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NormalVideoDetailsIconUi(
                        title: CustomFormatNumber.convert(
                            controller.customChanges["like"]),
                        icon: controller.isLike.value
                            ? AppIcons.likeBold
                            : AppIcons.like,
                        callback: () async {
                          if (!controller.isLike.value) {
                            if (controller.isDisLike.value) {
                              controller.isDisLike.value = false;
                              controller.customChanges["disLike"]--;
                            }
                            controller.isLike.value = true;
                            controller.customChanges["like"]++;
                            await LikeDisLikeVideoApi.callApi(
                                controller.videoId, true);
                          }
                        },
                      ).paddingOnly(bottom: 2),
                      NormalVideoDetailsIconUi(
                        title: CustomFormatNumber.convert(
                            controller.customChanges["disLike"]),
                        icon: controller.isDisLike.value
                            ? AppIcons.disLikeBold
                            : AppIcons.disLike,
                        callback: () async {
                          if (!controller.isDisLike.value) {
                            if (controller.isLike.value) {
                              controller.isLike.value = false;
                              controller.customChanges["like"]--;
                            }
                            controller.isDisLike.value = true;
                            controller.customChanges["disLike"]++;
                            await LikeDisLikeVideoApi.callApi(
                                controller.videoId, false);
                          }
                        },
                      ).paddingOnly(top: 2),
                      // NormalVideoDetailsIconUi(
                      //   title: AppStrings.comments.tr,
                      //   icon: AppIcons.boldChat,
                      //   callback: () async {
                      //     controller.customChanges["comment"] =
                      //         await CommentBottomSheet.show(
                      //       context,
                      //       controller.videoId,
                      //       details?.channelId ?? "",
                      //       controller.customChanges["comment"],
                      //     );
                      //   },
                      // ),
                      NormalVideoDetailsIconUi(
                        title: AppStrings.share.tr,
                        icon: AppIcons.share,
                        callback: () async {
                          controller.chewieController?.pause();

                          await CustomShare.share(
                            name: details?.title ?? "",
                            url: (details?.videoUrl?.isNotEmpty ?? false)
                                ? details!.videoUrl!
                                : controller.mainWatchedVideos.isNotEmpty
                                    ? controller
                                        .mainWatchedVideos[
                                            controller.selectedWatchedVideo]
                                        .videoUrl
                                    : "",
                            channelId: details?.channelId ?? "",
                            videoId: details?.id ?? "",
                            image: details?.videoImage ?? "",
                            pageRoutes: "NormalVideo",
                          );

                          await ShareCountApiClass.callApi(
                              Database.loginUserId ?? "", controller.videoId);
                        },
                      ),
                      Obx(() => controller.isDownloading.value
                          ? Center(
                              child: SpinKitCircle(
                                  color: isDarkMode.value
                                      ? AppColor.white
                                      : (AppColor.primaryColor),
                                  size: 40))
                          : NormalVideoDetailsIconUi(
                              title: AppStrings.download.tr,
                              icon: DownloadHistory.mainDownloadHistory.any(
                                      (map) =>
                                          map['videoId'] == controller.videoId)
                                  ? AppIcons.accept
                                  : AppIcons.videoDownload,
                              callback: () async {
                                if (DownloadHistory.mainDownloadHistory.any(
                                    (map) =>
                                        map['videoId'] == controller.videoId)) {
                                  CustomToast.show("Video Already Downloaded");
                                } else if ((GetProfileApi
                                        .profileModel?.user?.isPremiumPlan ??
                                    false)) {
                                  CustomToast.show("Downloading....");
                                  controller.isDownloading.value = true;
                                  AppSettings.isDownloading.value = true;
                                  final downloadPath =
                                      await CustomDownload.download(
                                          Database.onGetVideoUrl(controller
                                                      .videoDetailsModel
                                                      ?.detailsOfVideo
                                                      ?.id ??
                                                  "") ??
                                              await ConvertToNetwork.convert(
                                                  controller
                                                          .videoDetailsModel
                                                          ?.detailsOfVideo
                                                          ?.videoUrl ??
                                                      ""),
                                          controller.videoDetailsModel
                                                  ?.detailsOfVideo?.id ??
                                              "");

                                  if (downloadPath != null) {
                                    final downloadThumbnail =
                                        await VideoThumbnail.thumbnailFile(
                                      video: downloadPath,
                                      thumbnailPath:
                                          (await getTemporaryDirectory()).path,
                                      imageFormat: ImageFormat.JPEG,
                                      maxHeight: 400,
                                      quality: 100,
                                    );
                                    if (downloadThumbnail != null) {
                                      DateTime now = DateTime.now();
                                      String formattedDate = now.toString();

                                      DownloadHistory.mainDownloadHistory
                                          .insert(
                                        0,
                                        {
                                          "videoId": controller
                                                  .videoDetailsModel
                                                  ?.detailsOfVideo
                                                  ?.id ??
                                              "",
                                          "videoTitle": controller
                                                  .videoDetailsModel
                                                  ?.detailsOfVideo
                                                  ?.title ??
                                              "",
                                          "videoType": controller
                                                  .videoDetailsModel
                                                  ?.detailsOfVideo
                                                  ?.videoType ??
                                              0,
                                          "videoTime": controller
                                                  .videoDetailsModel
                                                  ?.detailsOfVideo
                                                  ?.videoTime ??
                                              0,
                                          "videoUrl": downloadPath,
                                          "videoImage": downloadThumbnail,
                                          "views": controller.videoDetailsModel
                                                  ?.detailsOfVideo?.views ??
                                              0,
                                          "channelId": controller
                                                  .videoDetailsModel
                                                  ?.detailsOfVideo
                                                  ?.channelId ??
                                              "",
                                          "channelName": controller
                                                  .videoDetailsModel
                                                  ?.detailsOfVideo
                                                  ?.channelName ??
                                              "",
                                          "time": formattedDate
                                        },
                                      );
                                      DownloadHistory.onSet();
                                    }
                                    LocalNotificationServices
                                        .onSendNotification(
                                      "Download Complete",
                                      controller.videoDetailsModel
                                              ?.detailsOfVideo?.title ??
                                          "",
                                      () {
                                        AppSettings.showLog(
                                            "Go To Download Routes");
                                        if (DownloadHistory
                                            .mainDownloadHistory.isEmpty) {
                                          DownloadHistory.onGet();
                                        }
                                        Get.to(() => const DownloadView());
                                      },
                                    );
                                    CustomToast.show("Video download complete");
                                    controller.isDownloading.value = false;
                                    AppSettings.isDownloading.value = false;
                                  } else {
                                    controller.isDownloading.value = false;
                                    AppSettings.isDownloading.value = false;
                                  }
                                } else {
                                  PremiumPlanDialog().show(context);
                                }
                              },
                            )),
                      Obx(
                        () => NormalVideoDetailsIconUi(
                          title: controller.isSave.value
                              ? AppStrings.saved.tr
                              : AppStrings.save.tr,
                          icon: controller.isSave.value
                              ? AppIcons.saveDone1
                              : AppIcons.addToSave,
                          callback: () {
                            if (controller.isSave.value == false) {
                              controller.isSave.value = true;
                              CustomToast.show(AppStrings.addToWatchLater.tr);
                              CreateWatchLater.callApi(
                                  Database.loginUserId ?? "",
                                  controller.videoId);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical * 1),
                const Divider(indent: 5, endIndent: 5, height: 5),
                GestureDetector(
                  onTap: () => Get.to(
                    () => YourChannelView(
                      loginUserId: Database.loginUserId ?? "",
                      channelId: details?.channelId ?? "",
                    ),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    dense: true,
                    leading: PreviewProfileImage(
                      size: 45,
                      id: controller
                              .videoDetailsModel?.detailsOfVideo?.channelId ??
                          "",
                      image: controller.videoDetailsModel?.detailsOfVideo
                              ?.channelImage ??
                          "",
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      details?.channelName ?? "",
                      style: GoogleFonts.urbanist(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Obx(
                      () => Text(
                        "${CustomFormatNumber.convert(controller.customChanges["subscribe"])} ${AppStrings.subscribes.tr}",
                        style: GoogleFonts.urbanist(),
                      ),
                    ),
                    trailing: Visibility(
                      visible: Database.channelId !=
                          controller
                              .videoDetailsModel?.detailsOfVideo?.channelId,
                      child: controller.videoDetailsModel?.detailsOfVideo
                                  ?.channelType ==
                              2
                          ? GestureDetector(
                              onTap: () async {
                                if (controller.isSubscribe.value == false) {
                                  SubscribePremiumChannelBottomSheet.onShow(
                                    coin: (controller
                                                .videoDetailsModel
                                                ?.detailsOfVideo
                                                ?.subscriptionCost ??
                                            0)
                                        .toString(),
                                    callback: () async {
                                      Get.dialog(const LoaderUi(),
                                          barrierDismissible: false);
                                      final bool isSuccess =
                                          await SubscribeChannelApiClass
                                              .callApi(controller
                                                      .videoDetailsModel
                                                      ?.detailsOfVideo
                                                      ?.channelId ??
                                                  "");

                                      Get.close(2);

                                      if (isSuccess) {
                                        if (controller.isSubscribe.value) {
                                          controller.isSubscribe.value = false;
                                          controller
                                              .customChanges["subscribe"]--;
                                        } else {
                                          controller.isSubscribe.value = true;
                                          controller
                                              .customChanges["subscribe"]++;
                                        }
                                      }
                                    },
                                  );
                                } else {
                                  if (controller.isSubscribe.value) {
                                    controller.isSubscribe.value = false;
                                    controller.customChanges["subscribe"]--;
                                  } else {
                                    controller.isSubscribe.value = true;
                                    controller.customChanges["subscribe"]++;
                                  }
                                  await SubscribeChannelApiClass.callApi(
                                      details?.channelId ?? "");
                                }
                              },
                              child: Obx(
                                () => Container(
                                  height: 40,
                                  width:
                                      controller.isSubscribe.value ? 100 : 150,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: controller.isSubscribe.value
                                        ? Colors.transparent
                                        : AppColor.primaryColor,
                                    border: controller.isSubscribe.value
                                        ? Border.all(
                                            color: AppColor.primaryColor,
                                            width: 1.5)
                                        : null,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: controller.isSubscribe.value
                                      ? Text(
                                          "Subscribed",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.urbanist(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: AppColor.primaryColor,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Subscribe",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.urbanist(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppColor.white,
                                              ),
                                            ),
                                            8.width,
                                            Image.asset(AppIcons.coin,
                                                width: 15),
                                            Text(
                                              " ${CustomFormatNumber.convert(0)}/m",
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.urbanist(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppColor.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () async {
                                if (controller.isSubscribe.value) {
                                  controller.isSubscribe.value = false;
                                  controller.customChanges["subscribe"]--;
                                } else {
                                  controller.isSubscribe.value = true;
                                  controller.customChanges["subscribe"]++;
                                }
                                await SubscribeChannelApiClass.callApi(
                                    details?.channelId ?? "");
                              },
                              child: Obx(
                                () => Container(
                                  height: 40,
                                  width: SizeConfig.screenWidth / 3.8,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                        color: AppColor.primaryColor, width: 2),
                                    color: controller.isSubscribe.value
                                        ? Colors.transparent
                                        : AppColor.primaryColor,
                                  ),
                                  child: Text(
                                    controller.isSubscribe.value
                                        ? AppStrings.subscribed.tr
                                        : AppStrings.subscribe.tr,
                                    style: GoogleFonts.urbanist(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: controller.isSubscribe.value
                                          ? AppColor.primaryColor
                                          : AppColor.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                const Divider(indent: 5, endIndent: 5, height: 5),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: () async {
                      controller.customChanges["comment"] =
                          await CommentBottomSheet.show(
                        context,
                        controller.videoId,
                        details?.channelId ?? "",
                        controller.customChanges["comment"],
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "${AppStrings.comments.tr} ",
                                style: GoogleFonts.urbanist(
                                    fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                              TextSpan(
                                text: CustomFormatNumber.convert(
                                    controller.customChanges["comment"]),
                                style: GoogleFonts.urbanist(
                                    fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          onPressed: () async {
                            controller.customChanges["comment"] =
                                await CommentBottomSheet.show(
                              context,
                              controller.videoId,
                              details?.channelId ?? "",
                              controller.customChanges["comment"],
                            );
                          },
                          icon: const ImageIcon(AssetImage(AppIcons.swap),
                              size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Obx(
                          () => PreviewProfileImage(
                            size: 40,
                            id: Database.channelId ?? "",
                            image: AppSettings.profileImage.value,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: controller.commentController,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDarkMode.value
                                ? AppColor.secondDarkMode
                                : AppColor.grey_200,
                            contentPadding: const EdgeInsets.only(left: 10),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none),
                            hintText: AppStrings.addComments.tr,
                            hintStyle: GoogleFonts.urbanist(
                                color: Colors.grey, fontSize: 14),
                            suffixIcon: IconButton(
                              onPressed: () async {
                                if (controller
                                    .commentController.text.isNotEmpty) {
                                  final commentText =
                                      controller.commentController.text;
                                  controller.commentController.clear();
                                  controller.customChanges["comment"]++;
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  await CreateCommentApiClass.callApi(
                                      controller.videoId, commentText);
                                }
                              },
                              icon: const Icon(Icons.send_rounded,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SizeConfig.blockSizeVertical * 1),
              ],
            );
      },
    );
  }
}

class NormalVideoDetailsIconUi extends StatelessWidget {
  const NormalVideoDetailsIconUi(
      {super.key,
      required this.title,
      required this.icon,
      required this.callback});

  final String title;
  final String icon;
  final Callback callback;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: callback,
          child: Container(
            height: 35,
            width: 35,
            color: AppColor.transparent,
            child: Center(
              child: Image(
                image: AssetImage(icon),
                height: 22,
                width: 22,
                color:
                    isDarkMode.value ? AppColor.white : const Color(0xFF424242),
              ),
            ),
          ),
        ),
        Text(
          title,
          style: GoogleFonts.urbanist(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDarkMode.value ? AppColor.white : const Color(0xFF424242),
          ),
        ),
      ],
    );
  }
}
