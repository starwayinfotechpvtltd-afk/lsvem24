import 'dart:async';
import 'dart:ui';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/basic_button.dart';
import 'package:metube/custom/custom_api/like_dislike_api.dart';
import 'package:metube/custom/custom_method/custom_format_number.dart';
import 'package:metube/custom/custom_method/custom_share.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/custom_pages/comment_page/comment_bottom_sheet.dart';
import 'package:metube/pages/custom_pages/comment_page/comment_sheet_panel.dart';
import 'package:metube/pages/custom_pages/report_page/custom_report_view.dart';
import 'package:metube/pages/custom_pages/share_count_page/share_count_api.dart';
import 'package:metube/pages/nav_add_page/create_short_page/create_short_view.dart';
import 'package:metube/pages/nav_library_page/history_page/create_watch_history_api.dart';
import 'package:metube/pages/nav_shorts_page/get_shorts_video_model.dart';
import 'package:metube/pages/nav_shorts_page/nav_shorts_controller.dart';
import 'package:metube/pages/shorts_ads/shorts_feed_ad_model.dart';
import 'package:metube/pages/nav_subscription_page/subscribe_channel_api.dart';
import 'package:metube/pages/profile_page/content_engagement_page/video_engagement_reward_api.dart';
import 'package:metube/pages/profile_page/your_channel_page/main_page/your_channel_view.dart';
import 'package:metube/pages/search_page/search_view.dart';
import 'package:metube/pages/splash_screen_page/api/unlock_private_video_api.dart';
import 'package:metube/pages/video_details_page/video_description_bottom_sheet.dart';
import 'package:metube/utils/storage/guest_like_storage.dart';
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
import 'package:video_player/video_player.dart';
import 'package:metube/pages/nav_add_page/green_screen_page/green_screen_recorder_view.dart';

class NavShortsDetailView extends StatefulWidget {
  const NavShortsDetailView(
      {super.key, required this.index, required this.currentPageIndex});

  final int index;
  final int currentPageIndex;

  @override
  State<NavShortsDetailView> createState() => _NavShortsDetailViewState();
}

class _NavShortsDetailViewState extends State<NavShortsDetailView> {
  final controller = Get.find<NavShortsController>();

  ChewieController? chewieController;
  VideoPlayerController? videoPlayerController;

  RxBool isPrivateContent = false.obs;

  RxBool isLike = false.obs;
  RxBool isDisLike = false.obs;
  RxBool isSubscribe = false.obs;

  RxBool isPlaying = true.obs;
  RxBool isShowIcon = false.obs;

  RxBool isBuffering = false.obs;
  RxBool isVideoLoading = true.obs;

  RxBool isShortsPage = true.obs; // This is Use to Stop Auto Playing..

  RxMap customChanges = {"like": 0, "disLike": 0, "share": 0, "comment": 0}.obs;

  bool isCreateHistory = false;

  bool _commentsOpen = false;

  @override
  void initState() {
    initializeVideoPlayer();
    customSetting();
    super.initState();
  }

  Future<void> initializeVideoPlayer() async {
    try {
      final item = controller.mainShortsVideos[widget.index];
      if (item is! Shorts) return;
      final shorts = item;
      String videoPath = Database.onGetVideoUrl(shorts.id ?? "") ??
          await ConvertToNetwork.convert(shorts.videoUrl ?? "");

      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoPath));

      await videoPlayerController?.initialize();

      if (videoPlayerController != null &&
          (videoPlayerController?.value.isInitialized ?? false)) {
        final activeController = videoPlayerController;
        if (activeController == null) {
          isVideoLoading.value = true;
          return;
        }
        chewieController = ChewieController(
          videoPlayerController: activeController,
          // aspectRatio: Get.width / (Get.height - 66),
          // aspectRatio: 10 / 18,
          looping: false,
          allowedScreenSleep: false,
          allowMuting: false,
          showControlsOnInitialize: false,
          showControls: false,
          maxScale: 1,
        );
        if (chewieController != null) {
          isVideoLoading.value = false;
          // If First Time Video Playing...
          (widget.index == widget.currentPageIndex &&
                  isPrivateContent.value == false)
              ? onPlayVideo()
              : null;
        } else {
          isVideoLoading.value = true;
        }
        videoPlayerController?.addListener(
          () {
            final listenerController = videoPlayerController;
            if (listenerController != null &&
                listenerController.value.isInitialized) {
              // If Video Buffering then show loading....
              // videoPlayerController!.value.isBuffering ? isBuffering.value = true : isBuffering.value = false;

              if (Get.currentRoute != "/MainHomePageView") {
                isShortsPage.value = false;
                onStopVideo();
              }

              if (listenerController.value.position >=
                  listenerController.value.duration) {
                AppSettings.showLog(
                    "Video Engagement Reward Method Calling...");
                VideoEngagementRewardApi.callApi(
                    loginUserId: Database.loginUserId ?? "",
                    videoId: shorts.id ?? "",
                    totalWatchTime:
                        listenerController.value.duration.inSeconds.toString());

                listenerController.seekTo(Duration.zero);
                onPlayVideo();
              }
            }
          },
        );
      }
    } catch (e) {
      onDisposeVideoPlayer();
      AppSettings.showLog(
          "Shorts Video Initialization Failed !!! ${widget.index} => $e");
    }
  }

  void onStopVideo() {
    isPlaying.value = false;
    videoPlayerController?.pause();
  }

  void onPlayVideo() {
    isPlaying.value = true;
    videoPlayerController?.play();
  }

  void onDisposeVideoPlayer() {
    try {
      onStopVideo();
      videoPlayerController?.dispose();
      chewieController?.dispose();
      chewieController = null;
      videoPlayerController = null;
      isVideoLoading.value = true;
    } catch (e) {
      AppSettings.showLog(">>>> On Dispose VideoPlayer Error => $e");
    }
  }

  @override
  void dispose() {
    onDisposeVideoPlayer();
    AppSettings.showLog("Dispose Method Called Success");
    super.dispose();
  }

  void customSetting() {
    final item = controller.mainShortsVideos[widget.index];
    if (item is! Shorts) return;
    final shorts = item;
    isPrivateContent.value =
        (shorts.videoPrivacyType == 2 && shorts.isSubscribed == false);

    isLike.value = shorts.isLike ?? false;
    isDisLike.value = shorts.isDislike ?? false;
    isSubscribe.value = shorts.isSubscribed ?? false;

    customChanges["like"] =
        int.parse(controller.mainShortsVideos[widget.index].like.toString());
    customChanges["disLike"] =
        int.parse(controller.mainShortsVideos[widget.index].dislike.toString());
    customChanges["share"] = int.parse(
        controller.mainShortsVideos[widget.index].shareCount.toString());
    customChanges["comment"] = int.parse(
        controller.mainShortsVideos[widget.index].totalComments.toString());

    GuestLikeStorage.applyToUi(
      videoId: shorts.id ?? '',
      isLike: isLike,
      isDisLike: isDisLike,
      customChanges: customChanges,
    );
  }

  Future<void> onCreateHistory() async {
    final shorts = controller.mainShortsVideos[widget.index];
    final activeController = videoPlayerController;
    if (Database.channelId != null &&
        activeController != null &&
        activeController.value.isInitialized) {
      final watchTime = activeController.value.position.inSeconds / 60;
      AppSettings.showLog("Video Watch Time ${widget.index} => $watchTime");
      await CreateWatchHistoryApi.callApi(
        loginUserId: Database.loginUserId ?? "",
        videoId: shorts.id ?? "",
        videoChannelId: shorts.channelId ?? "",
        videoUserId: shorts.userId ?? "",
        watchTimeInMinute: watchTime,
      );
    }
  }

  void onClickLike() async {
    if (!isLike.value) {
      if (isDisLike.value) {
        isDisLike.value = false;
        customChanges["disLike"]--;
      }
      isLike.value = true;
      customChanges["like"]++;
      await LikeDisLikeVideoApi.callApi(
          controller.mainShortsVideos[widget.index].id.toString(), true);
    } else {
      AppSettings.showLog("This Video Already Liked");
    }
  }

  void onClickDisLike() async {
    if (!isDisLike.value) {
      if (isLike.value) {
        isLike.value = false;
        customChanges["like"]--;
      }
      isDisLike.value = true;
      customChanges["disLike"]++;
      await LikeDisLikeVideoApi.callApi(
          controller.mainShortsVideos[widget.index].id.toString(), false);
    } else {
      AppSettings.showLog("This Video Already DisLiked");
    }
  }

  void onClickComment() {
    final shorts = controller.mainShortsVideos[widget.index];
    final videoId = shorts.id ?? "";
    final channelId = shorts.channelId ?? "";
    final count = CommentBottomSheet.commentCountFrom(customChanges["comment"]);
    isShortsPage.value = false;
    if (chewieController != null && videoPlayerController != null) {
      CommentBottomSheet.prepareCommentsForVideo(videoId, count);
      setState(() => _commentsOpen = true);
    } else {
      CommentBottomSheet.show(context, videoId, channelId, count).then((total) {
        if (mounted) {
          isShortsPage.value = true;
          customChanges["comment"] = total;
          setState(() {});
        }
      });
    }
  }

  void _closeCommentsOverlay() {
    if (!mounted) return;
    isShortsPage.value = true;
    setState(() {
      _commentsOpen = false;
      customChanges["comment"] = CommentBottomSheet.syncLatestCommentTotal();
    });
  }

  void onClickShare() async {
    final shorts = controller.mainShortsVideos[widget.index];
    onStopVideo();
    await CustomShare.share(
      videoId: shorts.id ?? "",
      pageRoutes: "ShortsVideo",
      image: shorts.videoImage ?? "",
      channelId: shorts.channelId ?? "",
      name: shorts.title ?? "",
      url: shorts.videoUrl ?? "",
    );

    await ShareCountApiClass.callApi(
        Database.loginUserId ?? "", shorts.id.toString());

    customChanges["share"] += 1;
  }

  void onClickGreenScreen() async {
    onStopVideo();
    final shorts = controller.mainShortsVideos[widget.index];

    String videoUrl = Database.onGetVideoUrl(shorts.id ?? "") ??
        await ConvertToNetwork.convert(shorts.videoUrl ?? "");

    await Get.to(() => GreenScreenRecorderView(
          backgroundVideoUrl: videoUrl,
        ));

    if (mounted) {
      onPlayVideo();
    }
  }

  void onClickMoreOption() async {
    final shorts = controller.mainShortsVideos[widget.index];
    onStopVideo();
    Get.bottomSheet(
      backgroundColor:
          isDarkMode.value ? AppColor.secondDarkMode : AppColor.white,
      SizedBox(
        height: SizeConfig.screenHeight / 5,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 5),
              Container(
                width: SizeConfig.blockSizeHorizontal * 12,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: AppColor.grey_100,
                ),
              ),
              const SizedBox(height: 10),
              Text(AppStrings.moreOption.tr, style: titalstyle1),
              const SizedBox(height: 10),
              const Divider(indent: 25, endIndent: 25, color: AppColor.grey),
              const SizedBox(height: 10),
              BottomShitButton(
                widget:
                    const ImageIcon(AssetImage(AppIcons.document), size: 23),
                name: AppStrings.description.tr,
                onTap: () {
                  Get.back();
                  DescriptionBottomSheet.show(
                    shorts.channelId ?? "",
                    shorts.title ?? "",
                    shorts.channelImage ?? "",
                    shorts.channelName ?? "",
                    customChanges["like"],
                    customChanges["disLike"],
                    shorts.views ?? 0,
                    shorts.createdAt ?? "",
                    shorts.hashTag?.join(',') ?? "",
                    shorts.description ?? "",
                  );
                },
              ),
              const SizedBox(height: 15),
              BottomShitButton(
                widget:
                    const ImageIcon(AssetImage(AppIcons.closeSquare), size: 23),
                name: "${AppStrings.report.tr}-${AppStrings.block.tr}",
                onTap: () {
                  Get.back();
                  CustomReportView.show(shorts.id ?? "");
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
    );
  }

  void onClickProfile() async {
    isShortsPage.value = false;
    onStopVideo();
    // Get.to(PreviewShortsChannelView(channelId: controller.mainShortsVideos[widget.index].channelId!));
    Get.to(() => YourChannelView(
        loginUserId: Database.loginUserId ?? "",
        channelId: controller.mainShortsVideos[widget.index].channelId ?? ""));
  }

  void onClickSearch() async {
    onStopVideo();
    isShortsPage.value = false;
    Get.to(const SearchView(isSearchShorts: true));
  }

  void onClickSubscribe() async {
    if (isPrivateContent.value && isSubscribe.value == false) {
      onSubscribePrivateChannel(index: widget.index);
    } else {
      isSubscribe.value = !isSubscribe.value;
      await SubscribeChannelApiClass.callApi(
          controller.mainShortsVideos[widget.index].channelId.toString());
    }
  }

  void onClickCamera() async {
    onStopVideo();
    isShortsPage.value = false;
    Get.to(() => CreateShortView());
  }

  void onClickVideo() async {
    final activeController = videoPlayerController;
    if (activeController == null) return;
    activeController.value.isPlaying ? onStopVideo() : onPlayVideo();
    isShowIcon.value = true;
    await 2.seconds.delay();
    isShowIcon.value = false;
  }

  void onClickPlayPause() async {
    final activeController = videoPlayerController;
    if (activeController == null) return;
    activeController.value.isPlaying ? onStopVideo() : onPlayVideo();
    if (isShortsPage.value == false) {
      isShortsPage.value = true;
    }
  }

  void onUnlockPrivateVideo({required int index}) async {
    UnlockPremiumVideoBottomSheet.onShow(
      coin:
          (controller.mainShortsVideos[index].videoUnlockCost ?? 0).toString(),
      callback: () async {
        Get.dialog(const LoaderUi(), barrierDismissible: false);
        await UnlockPrivateVideoApi.callApi(
            loginUserId: Database.loginUserId ?? "",
            videoId: controller.mainShortsVideos[index].id ?? "");

        if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
          isPrivateContent.value = false;
        }

        Get.close(2);
        SubscribedSuccessDialog.show(context);
      },
    );
  }

  void onSubscribePrivateChannel({required int index}) async {
    SubscribePremiumChannelBottomSheet.onShow(
      coin:
          (controller.mainShortsVideos[index].subscriptionCost ?? 0).toString(),
      callback: () async {
        Get.dialog(const LoaderUi(), barrierDismissible: false);
        final bool isSuccess = await SubscribeChannelApiClass.callApi(
            controller.mainShortsVideos[index].channelId ?? "");
        Get.close(2);
        if (isSuccess) {
          isPrivateContent.value = false;
          SubscribedSuccessDialog.show(context);
          isSubscribe.value = true;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );

    if (widget.index == widget.currentPageIndex &&
        isPrivateContent.value == false) {
      // Play Current Video On Scrolling...
      isCreateHistory = true;
      isVideoLoading.value == false && isShortsPage.value
          ? onPlayVideo()
          : null;
    } else {
      // Restart Previous Video On Scrolling...
      isVideoLoading.value == false
          ? videoPlayerController?.seekTo(Duration.zero)
          : null;
      // Stop Previous Video On Scrolling...
      onStopVideo();
      if (isCreateHistory) {
        isCreateHistory = false;
        if (controller.mainShortsVideos[widget.index] != null) {
          onCreateHistory();
        }
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Obx(
          () => isPrivateContent.value
              ? ShortsPrivateContentWidget(
                  id: controller.mainShortsVideos[widget.index].id,
                  image: controller.mainShortsVideos[widget.index].videoImage,
                  subscribeCoin: controller
                          .mainShortsVideos[widget.index].subscriptionCost ??
                      0,
                  unlockCoin: controller
                          .mainShortsVideos[widget.index].videoUnlockCost ??
                      0,
                  subscribe: () {
                    onSubscribePrivateChannel(index: widget.index);
                  },
                  unlock: () {
                    onUnlockPrivateVideo(index: widget.index);
                  },
                )
              : (_commentsOpen &&
                      chewieController != null &&
                      videoPlayerController != null)
                  ? Container(
                      color: Colors.black,
                      height: (Get.height - 60),
                      width: Get.width,
                    )
                  : Stack(
                      children: [
                        if ((controller.mainShortsVideos[widget.index]
                                    .videoImage ??
                                '')
                            .isNotEmpty)
                          Positioned.fill(
                            child: PreviewVideoImage(
                              videoId: controller
                                      .mainShortsVideos[widget.index].id ??
                                  '',
                              videoImage: controller
                                      .mainShortsVideos[widget.index]
                                      .videoImage ??
                                  '',
                              fit: BoxFit.cover,
                            ),
                          ),
                        Container(
                          color: Colors.black,
                          height: (Get.height - 60),
                          width: Get.width,
                          child: Obx(
                            () {
                              final activeChewie = chewieController;
                              final activeController = videoPlayerController;
                              if (isVideoLoading.value) {
                                return const LoaderUi(color: Colors.white);
                              }
                              if (activeChewie == null ||
                                  activeController == null) {
                                return const Offstage();
                              }
                              return SizedBox.expand(
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: activeController.value.size.width,
                                    height: activeController.value.size.height,
                                    child: Chewie(controller: activeChewie),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          // Logo Water Mark Code
                          top: MediaQuery.of(context).viewPadding.top + 25,
                          left: 20,
                          child: Visibility(
                              visible: AppStrings.isShowWaterMark,
                              child: CachedNetworkImage(
                                imageUrl: AppStrings.waterMarkIcon,
                                fit: BoxFit.contain,
                                imageBuilder: (context, imageProvider) => Image(
                                  image: ResizeImage(imageProvider,
                                      width: AppStrings.waterMarkSize,
                                      height: AppStrings.waterMarkSize),
                                  fit: BoxFit.contain,
                                ),
                                placeholder: (context, url) => const Offstage(),
                                errorWidget: (context, url, error) =>
                                    const Offstage(),
                              )),
                        ),
                        GestureDetector(
                          onTap: onClickVideo,
                          child: Container(
                            height: Get.height,
                            width: Get.width,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ),
                        Obx(
                          () => isShowIcon.value
                              ? Align(
                                  alignment: Alignment.center,
                                  child: GestureDetector(
                                    onTap: onClickPlayPause,
                                    child: Container(
                                      height: 60,
                                      width: 60,
                                      padding: EdgeInsets.only(
                                          left: isPlaying.value ? 0 : 5),
                                      decoration: BoxDecoration(
                                          color: AppColor.black.withOpacity(0.2),
                                          shape: BoxShape.circle),
                                      child: Center(
                                        child: Image.asset(
                                            isPlaying.value
                                                ? AppIcons.pause
                                                : AppIcons.videoPlay,
                                            width: 25,
                                            height: 25,
                                            color: AppColor.white),
                                      ),
                                    ),
                                  ),
                                )
                              : const Offstage(),
                        ),
                      ],
                    ),
        ),
        Obx(() =>
            Visibility(visible: isBuffering.value, child: const LoaderUi())),
        Padding(
          padding: EdgeInsets.only(
              left: 15, right: 15, top: SizeConfig.screenHeight / 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButtonUi(
                callback: onClickSearch,
                icon: const ImageIcon(AssetImage(AppIcons.search),
                    color: AppColor.white, size: 22),
              ),
              const SizedBox(width: 15),
              IconButtonUi(
                callback: onClickCamera,
                icon: const ImageIcon(AssetImage(AppIcons.camera),
                    color: AppColor.white, size: 30),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 5,
          right: 15,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() => IconButtonUi(
                  callback: onClickLike,
                  icon: ImageIcon(const AssetImage(AppIcons.likeBold),
                      color:
                          isLike.value ? AppColor.primaryColor : AppColor.white,
                      size: 25))),
              Obx(() => Text(CustomFormatNumber.convert(customChanges["like"]),
                  style: GoogleFonts.urbanist(color: AppColor.white))),
              const SizedBox(height: 15),
              Obx(() => IconButtonUi(
                  callback: onClickDisLike,
                  icon: ImageIcon(const AssetImage(AppIcons.disLikeBold),
                      color: isDisLike.value
                          ? AppColor.primaryColor
                          : AppColor.white,
                      size: 25))),
              Obx(() => Text(
                  CustomFormatNumber.convert(customChanges["disLike"]),
                  style: GoogleFonts.urbanist(color: AppColor.white))),
              const SizedBox(height: 15),
              IconButtonUi(
                  callback: onClickComment,
                  icon: const ImageIcon(AssetImage(AppIcons.comments),
                      color: AppColor.white, size: 30)),
              Obx(() => Text(
                  CustomFormatNumber.convert(customChanges["comment"]),
                  style: GoogleFonts.urbanist(color: AppColor.white))),
              const SizedBox(height: 15),
              IconButtonUi(
                  callback: onClickShare,
                  icon: const ImageIcon(AssetImage(AppIcons.boldShare),
                      color: AppColor.white, size: 30)),
              Obx(() => Text(CustomFormatNumber.convert(customChanges["share"]),
                  style: GoogleFonts.urbanist(color: AppColor.white))),
              const SizedBox(height: 15),
              // ✅ Green Screen
              GestureDetector(
                onTap: onClickGreenScreen,
                child: Container(
                  width: 40, // slightly smaller
                  height: 40,
                  child: const Icon(Icons.video_call,
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(height: 4),
              const SizedBox(height: 8),
              IconButtonUi(
                  callback: onClickMoreOption,
                  icon: const ImageIcon(AssetImage(AppIcons.moreCircle),
                      color: AppColor.white, size: 30)),
              const SizedBox(height: 25),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: SizeConfig.screenWidth / 1.8,
                    child: Text(controller.mainShortsVideos[widget.index].title,
                        style: GoogleFonts.urbanist(
                            fontSize: 15, color: AppColor.white),
                        maxLines: 3),
                  ),
                  SizedBox(
                    width: SizeConfig.screenWidth / 1.8,
                    child: Text(
                        controller.mainShortsVideos[widget.index].hashTag
                            ?.join(','),
                        style: GoogleFonts.urbanist(
                            fontSize: 14, color: AppColor.white),
                        maxLines: 3),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 2),
              Row(
                children: [
                  IconButtonUi(
                    callback: onClickProfile,
                    icon: PreviewProfileImage(
                      size: 30,
                      id: controller.mainShortsVideos[widget.index].channelId ??
                          "",
                      image: controller
                              .mainShortsVideos[widget.index].channelImage ??
                          "",
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                      (controller.mainShortsVideos[widget.index].channelName ?? "").length > 12
                          ? '${(controller.mainShortsVideos[widget.index].channelName ?? "").substring(0, 12)}...'
                          : (controller.mainShortsVideos[widget.index].channelName ?? ""),
                      style: GoogleFonts.urbanist(
                        color: AppColor.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Visibility(
                    visible: Database.channelId !=
                        controller.mainShortsVideos[widget.index].channelId,
                    child: GestureDetector(
                      onTap: onClickSubscribe,
                      child: Obx(
                        () => Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSubscribe.value
                                ? Colors.transparent
                                : AppColor.primaryColor,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: AppColor.primaryColor),
                          ),
                          child: Text(
                            isSubscribe.value
                                ? AppStrings.subscribed.tr
                                : AppStrings.subscribe.tr,
                            style: GoogleFonts.urbanist(
                              color: isSubscribe.value
                                  ? AppColor.primaryColor
                                  : AppColor.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                ],
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
        if (_commentsOpen &&
            chewieController != null &&
            videoPlayerController != null)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: ShortsCommentsWithMiniPlayer(
                videoPlayerController: videoPlayerController!,
                chewieController: chewieController!,
                videoId: controller.mainShortsVideos[widget.index].id ?? "",
                channelId:
                    controller.mainShortsVideos[widget.index].channelId ?? "",
                onClose: _closeCommentsOverlay,
              ),
            ),
          ),
        Obx(
          () => Visibility(
            visible: controller.isPaginationLoading.value,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: LinearProgressIndicator(
                color: AppColor.primaryColor,
                backgroundColor: AppColor.grey_300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class IconButtonUi extends StatelessWidget {
  const IconButtonUi({super.key, required this.icon, required this.callback});

  final Widget icon;
  final Callback callback;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: Container(
        height: 35,
        width: 35,
        decoration: const BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(child: icon),
      ),
    );
  }
}

class ShortsPrivateContentWidget extends StatelessWidget {
  const ShortsPrivateContentWidget(
      {super.key,
      required this.id,
      required this.image,
      required this.subscribe,
      required this.unlock,
      required this.subscribeCoin,
      required this.unlockCoin});

  final String id;
  final String image;
  final int subscribeCoin;
  final int unlockCoin;
  final Callback subscribe;
  final Callback unlock;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PreviewVideoImage(videoId: id, videoImage: image),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            5.height,
            Image.asset(AppIcons.lock, width: 45),
            15.height,
            Text(
              AppStrings.thisVideoIsPrivateContent.tr,
              style: GoogleFonts.urbanist(
                  fontSize: 16,
                  color: AppColor.white,
                  fontWeight: FontWeight.w900),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            15.height,
            Column(
              children: [
                GestureDetector(
                  onTap: subscribe,
                  child: BlurryContainer(
                    height: 42,
                    width: 190,
                    blur: 5,
                    borderRadius: BorderRadius.circular(30),
                    color: AppColor.white.withOpacity(0.4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.subscribe.tr,
                          style: GoogleFonts.urbanist(
                              color: AppColor.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        5.width,
                        Image.asset(AppIcons.coin, width: 18),
                        2.width,
                        Text(
                          "$subscribeCoin/m",
                          style: GoogleFonts.urbanist(
                              color: AppColor.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                15.height,
                GestureDetector(
                  onTap: unlock,
                  child: Container(
                    height: 42,
                    width: 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: AppColor.primaryColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.unlockVideo.tr,
                          style: GoogleFonts.urbanist(
                              color: AppColor.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        5.width,
                        Image.asset(AppIcons.coin, width: 18),
                        2.width,
                        Text(
                          "$unlockCoin",
                          style: GoogleFonts.urbanist(
                              color: AppColor.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                12.width,
              ],
            ),
          ],
        ),
      ],
    );
  }
}
