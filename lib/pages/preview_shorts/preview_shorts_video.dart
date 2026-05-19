import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/basic_button.dart';
import 'package:metube/custom/custom_api/like_dislike_api.dart';
import 'package:metube/custom/custom_method/custom_format_number.dart';
import 'package:metube/custom/custom_method/custom_share.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/custom/shimmer/shorts_video_shimmer_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/custom_pages/comment_page/comment_bottom_sheet.dart';
import 'package:metube/pages/custom_pages/comment_page/comment_sheet_panel.dart';
import 'package:metube/pages/custom_pages/report_page/custom_report_view.dart';
import 'package:metube/pages/custom_pages/share_count_page/share_count_api.dart';
import 'package:metube/pages/nav_add_page/create_short_page/create_short_view.dart';
import 'package:metube/pages/nav_library_page/history_page/create_watch_history_api.dart';
import 'package:metube/pages/nav_shorts_page/nav_shorts_details_view.dart';
import 'package:metube/pages/nav_subscription_page/subscribe_channel_api.dart';
import 'package:metube/pages/nav_shorts_page/get_shorts_video_model.dart';
import 'package:metube/pages/preview_shorts/preview_shorts_controller.dart';
import 'package:metube/pages/shorts_ads/shorts_feed_ad_model.dart';
import 'package:metube/pages/profile_page/your_channel_page/main_page/your_channel_view.dart';
import 'package:metube/pages/search_page/search_view.dart';
import 'package:metube/pages/splash_screen_page/api/unlock_private_video_api.dart';
import 'package:metube/pages/video_details_page/video_description_bottom_sheet.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/services/convert_to_network.dart';
import 'package:metube/utils/services/preview_image.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/style/app_style.dart';
import 'package:metube/widget/subscribe_premium_channel_bottom_sheet.dart';
import 'package:metube/widget/subscribed_success_dialog.dart';
import 'package:metube/widget/unlock_premium_video_bottom_sheet.dart';
import 'package:video_player/video_player.dart';
import 'package:metube/pages/nav_add_page/green_screen_page/green_screen_recorder_view.dart';

class PreviewShortsVideo extends StatefulWidget {
  const PreviewShortsVideo(
      {super.key, required this.index, required this.currentPageIndex});

  final int index;
  final int currentPageIndex;

  @override
  State<PreviewShortsVideo> createState() => _PreviewShortsVideoState();
}

class _PreviewShortsVideoState extends State<PreviewShortsVideo> {
  final controller = Get.find<PreviewShortsController>();

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

  RxMap customChanges = {"like": 0, "disLike": 0, "share": 0, "comment": 0}.obs;

  String networkImage = "";

  bool isCreateHistory = false;

  bool _commentsOpen = false;

  @override
  void initState() {
    initializeVideoPlayer();

    customSetting();

    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light));
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);

    super.initState();
  }

  Future<void> initializeVideoPlayer() async {
    try {
      String videoPath = Database.onGetVideoUrl(
              controller.mainShortsVideos[widget.index].id!) ??
          await ConvertToNetwork.convert(
              controller.mainShortsVideos[widget.index].videoUrl!);

      networkImage = videoPath;

      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoPath));

      await videoPlayerController?.initialize();

      if (videoPlayerController != null &&
          (videoPlayerController?.value.isInitialized ?? false)) {
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,

          // aspectRatio: Get.width / Get.height,
          looping: true,
          allowedScreenSleep: false,
          allowMuting: false,
          showControlsOnInitialize: false,
          showControls: false,
        );
        if (chewieController != null &&
            (videoPlayerController?.value.isInitialized ?? false)) {
          isVideoLoading.value = false;

          if (widget.index == widget.currentPageIndex &&
              isPrivateContent.value == false) {
            isPlaying.value = true;
            videoPlayerController?.play();
          }
        }
        videoPlayerController?.addListener(
          () {
            if ((videoPlayerController?.value.isInitialized ?? false)) {
              videoPlayerController!.value.isBuffering
                  ? isBuffering.value = true
                  : isBuffering.value = false;
            }
          },
        );
      }
    } catch (e) {
      AppSettings.showLog(
          ">>>> ${widget.index} Video Loading Failed => $networkImage Error => $e");
      onClose();
    }
  }

  void customSetting() {
    isPrivateContent.value =
        (controller.mainShortsVideos[widget.index].videoPrivacyType == 2 &&
            controller.mainShortsVideos[widget.index].isSubscribed == false);

    isLike.value = controller.mainShortsVideos[widget.index].isLike!;
    isDisLike.value = controller.mainShortsVideos[widget.index].isDislike!;
    isSubscribe.value = controller.mainShortsVideos[widget.index].isSubscribed!;

    customChanges["like"] =
        int.parse(controller.mainShortsVideos[widget.index].like.toString());
    customChanges["disLike"] =
        int.parse(controller.mainShortsVideos[widget.index].dislike.toString());
    customChanges["share"] = int.parse(
        controller.mainShortsVideos[widget.index].shareCount.toString());
    customChanges["comment"] = int.parse(
        controller.mainShortsVideos[widget.index].totalComments.toString());
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
    final videoId = controller.mainShortsVideos[widget.index].id ?? "";
    final channelId = controller.mainShortsVideos[widget.index].channelId ?? "";
    final count = CommentBottomSheet.commentCountFrom(customChanges["comment"]);
    if (chewieController != null && videoPlayerController != null) {
      CommentBottomSheet.prepareCommentsForVideo(videoId, count);
      setState(() => _commentsOpen = true);
    } else {
      CommentBottomSheet.show(context, videoId, channelId, count).then((total) {
        if (mounted) {
          customChanges["comment"] = total;
          setState(() {});
        }
      });
    }
  }

  void _closeCommentsOverlay() {
    if (!mounted) return;
    setState(() {
      _commentsOpen = false;
      customChanges["comment"] = CommentBottomSheet.syncLatestCommentTotal();
    });
  }

  void onClickShare() async {
    onStopVideo();
    await CustomShare.share(
      name: controller.mainShortsVideos[widget.index].title!,
      image: controller.mainShortsVideos[widget.index].videoImage!,
      pageRoutes: "ShortsVideo",
      videoId: controller.mainShortsVideos[widget.index].id!,
      channelId: controller.mainShortsVideos[widget.index].channelId!,
      url: controller.mainShortsVideos[widget.index].videoUrl!,
    );

    await ShareCountApiClass.callApi(Database.loginUserId ?? "",
        controller.mainShortsVideos[widget.index].id.toString());

    customChanges["share"] += 1;
  }

  void onClickMoreOption() async {
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
                    controller.mainShortsVideos[widget.index].channelId!,
                    controller.mainShortsVideos[widget.index].title!,
                    controller.mainShortsVideos[widget.index].channelImage!,
                    controller.mainShortsVideos[widget.index].channelName!,
                    customChanges["like"],
                    customChanges["disLike"],
                    controller.mainShortsVideos[widget.index].views!,
                    controller.mainShortsVideos[widget.index].createdAt!,
                    controller.mainShortsVideos[widget.index].hashTag!
                        .join(','),
                    controller.mainShortsVideos[widget.index].description!,
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
                  CustomReportView.show(
                      controller.mainShortsVideos[widget.index].id!);
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
    onStopVideo();
    // Get.to(PreviewShortsChannelView(channelId: controller.mainShortsVideos[widget.index].channelId!));
    Get.to(() => YourChannelView(
        loginUserId: Database.loginUserId!,
        channelId: controller.mainShortsVideos[widget.index].channelId ?? ""));
  }

  void onClickSearch() async {
    onStopVideo();
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
    Get.to(() => CreateShortView());
  }

  void onClickVideo() async {
    videoPlayerController!.value.isPlaying ? onStopVideo() : onPlayVideo();
    isShowIcon.value = true;
    await 2.seconds.delay();
    isShowIcon.value = false;
  }

  void onClickPlayPause() async {
    videoPlayerController!.value.isPlaying ? onStopVideo() : onPlayVideo();
  }

  @override
  void dispose() {
    onStopVideo();
    onClose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  void onClickGreenScreen() async {
    onStopVideo();

    String videoUrl =
        Database.onGetVideoUrl(controller.mainShortsVideos[widget.index].id!) ??
            await ConvertToNetwork.convert(
                controller.mainShortsVideos[widget.index].videoUrl ?? "");

    await Get.to(() => GreenScreenRecorderView(
          backgroundVideoUrl: videoUrl,
        ));

    if (mounted) {
      onPlayVideo();
    }
  }

  void onClose() {
    try {
      videoPlayerController?.dispose();
      chewieController?.dispose();
      chewieController = null;
      videoPlayerController = null;
      isVideoLoading.value = true;
      AppSettings.showLog(">>>> Preview Page Dispose Method Called");
    } catch (e) {
      AppSettings.showLog(">>>> On Close Method Error => $e");
    }
  }

  Future<void> onCreateHistory() async {
    if (Database.channelId != null &&
        videoPlayerController != null &&
        (videoPlayerController?.value.isInitialized ?? false)) {
      final watchTime = videoPlayerController!.value.position.inSeconds / 60;
      AppSettings.showLog("Video Watch Time ${widget.index} => $watchTime");
      await CreateWatchHistoryApi.callApi(
        loginUserId: Database.loginUserId!,
        videoId: controller.mainShortsVideos[widget.index].id!,
        videoChannelId: controller.mainShortsVideos[widget.index].channelId!,
        videoUserId: controller.mainShortsVideos[widget.index].userId!,
        watchTimeInMinute: watchTime,
      );
    }
  }

  void onStopVideo() {
    isPlaying.value = false;
    chewieController?.pause();
  }

  void onPlayVideo() {
    isPlaying.value = true;
    videoPlayerController?.play();
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
          isSubscribe.value = true;
          SubscribedSuccessDialog.show(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = controller.mainShortsVideos[widget.index];
    if (item is! Shorts) {
      return const Offstage();
    }
    final shorts = item;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarDividerColor: AppColor.black,
        systemNavigationBarColor: AppColor.black,
      ),
    );
    if (widget.index == widget.currentPageIndex &&
        isPrivateContent.value == false) {
      isCreateHistory = true;
      if (isVideoLoading.value == false) {
        onPlayVideo();
      }
    } else {
      onStopVideo();
      if (isCreateHistory) {
        isCreateHistory = false;
        onCreateHistory();
      }
    }

    return Obx(
      () => Stack(
              children: [
                if ((shorts.videoImage ?? '').isNotEmpty && isVideoLoading.value)
                  Positioned.fill(
                    child: PreviewVideoImage(
                      videoId: shorts.id ?? '',
                      videoImage: shorts.videoImage ?? '',
                      fit: BoxFit.cover,
                    ),
                  ),
                if (isVideoLoading.value)
                  const Center(child: LoaderUi(color: Colors.white))
                else
                isPrivateContent.value
                    ? ShortsPrivateContentWidget(
                        id: shorts.id ?? "",
                        image: shorts.videoImage ?? "",
                        subscribeCoin: shorts.subscriptionCost ?? 0,
                        unlockCoin: shorts.videoUnlockCost ?? 0,
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
                            height: Get.height,
                            width: Get.width,
                            color: AppColor.black,
                          )
                        : Stack(
                            children: [
                              if ((shorts.videoImage ?? '').isNotEmpty)
                                Positioned.fill(
                                  child: PreviewVideoImage(
                                    videoId: shorts.id ?? '',
                                    videoImage: shorts.videoImage ?? '',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              Container(
                                height: Get.height,
                                width: Get.width,
                                color: Colors.black54,
                                child: Obx(
                                  () => isVideoLoading.value
                                      ? const LoaderUi(color: Colors.white)
                                      : SizedBox.expand(
                                          child: FittedBox(
                                            fit: BoxFit.cover,
                                            child: SizedBox(
                                              width: videoPlayerController
                                                      ?.value.size.width ??
                                                  0,
                                              height: videoPlayerController
                                                      ?.value.size.height ??
                                                  0,
                                              child: Chewie(
                                                  controller: chewieController!),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                // Logo Water Mark Code
                                top: MediaQuery.of(context).viewPadding.top + 55,
                                left: 20,
                                child: Visibility(
                                    visible: AppStrings.isShowWaterMark,
                                    child: CachedNetworkImage(
                                      imageUrl: AppStrings.waterMarkIcon,
                                      fit: BoxFit.contain,
                                      imageBuilder: (context, imageProvider) =>
                                          Image(
                                        image: ResizeImage(imageProvider,
                                            width: AppStrings.waterMarkSize,
                                            height: AppStrings.waterMarkSize),
                                        fit: BoxFit.contain,
                                      ),
                                      placeholder: (context, url) =>
                                          const Offstage(),
                                      errorWidget: (context, url, error) =>
                                          const Offstage(),
                                    )),
                              ),
                              // ✅ FIXED — use Positioned so outer Stack FAB stays on top
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: onClickVideo,
                                  child: Container(
                                    color: Colors.black.withAlpha(51),
                                  ),
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
                                                color: AppColor.black
                                                    .withOpacity(0.2),
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
                Padding(
                  padding: EdgeInsets.only(
                      left: 15, right: 15, top: SizeConfig.screenHeight / 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButtonUi(
                        icon: Image.asset(
                          AppIcons.arrowBack,
                          color: AppColor.white,
                          width: 20,
                        ),
                        callback: () => Get.back(),
                      ),
                      const Spacer(),
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
                  left: 0,
                  right: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // ── LEFT: title, hashtag, channel info ──────────────────
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: SizeConfig.screenWidth / 1.8,
                                child: Text(
                                  shorts.title ?? "",
                                  style: GoogleFonts.urbanist(
                                      fontSize: 15, color: AppColor.white),
                                  maxLines: 3,
                                ),
                              ),
                              SizedBox(
                                width: SizeConfig.screenWidth / 1.8,
                                child: Text(
                                  shorts.hashTag?.join(',') ?? "",
                                  style: GoogleFonts.urbanist(
                                      fontSize: 14, color: AppColor.white),
                                  maxLines: 3,
                                ),
                              ),
                              SizedBox(
                                  height: SizeConfig.blockSizeVertical * 2),
                              Row(
                                children: [
                                  IconButtonUi(
                                    callback: onClickProfile,
                                    icon: PreviewProfileImage(
                                      size: 30,
                                      id: controller
                                              .mainShortsVideos[widget.index]
                                              ?.channelId ??
                                          "",
                                      image: controller
                                              .mainShortsVideos[widget.index]
                                              ?.channelImage ??
                                          "",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      shorts.channelName ?? "",
                                      style: GoogleFonts.urbanist(
                                          color: AppColor.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                      // .channelName!,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Visibility(
                                    visible: Database.channelId !=
                                        controller
                                            .mainShortsVideos[widget.index]
                                            .channelId,
                                    child: GestureDetector(
                                      onTap: onClickSubscribe,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isSubscribe.value
                                              ? Colors.transparent
                                              : AppColor.primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          border: Border.all(
                                              color: AppColor.primaryColor),
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
                                ],
                              ),
                              const SizedBox(height: 25),
                            ],
                          ),
                        ),
                      ),

                      // ── RIGHT: action buttons column ─────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(right: 15, bottom: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Like
                            Obx(() => IconButtonUi(
                                callback: onClickLike,
                                icon: ImageIcon(
                                    const AssetImage(AppIcons.likeBold),
                                    color: isLike.value
                                        ? AppColor.primaryColor
                                        : AppColor.white,
                                    size: 25))),
                            Obx(() => Text(
                                CustomFormatNumber.convert(
                                    customChanges["like"]),
                                style: GoogleFonts.urbanist(
                                    color: AppColor.white))),
                            const SizedBox(height: 8), // reduced from 15

                            // Dislike
                            Obx(() => IconButtonUi(
                                callback: onClickDisLike,
                                icon: ImageIcon(
                                    const AssetImage(AppIcons.disLikeBold),
                                    color: isDisLike.value
                                        ? AppColor.primaryColor
                                        : AppColor.white,
                                    size: 25))),
                            Obx(() => Text(
                                CustomFormatNumber.convert(
                                    customChanges["disLike"]),
                                style: GoogleFonts.urbanist(
                                    color: AppColor.white))),
                            const SizedBox(height: 8), // reduced from 15

                            // Comment
                            IconButtonUi(
                                callback: onClickComment,
                                icon: const ImageIcon(
                                    AssetImage(AppIcons.comments),
                                    color: AppColor.white,
                                    size: 28)), // size reduced from 30
                            Obx(() => Text(
                                CustomFormatNumber.convert(
                                    customChanges["comment"]),
                                style: GoogleFonts.urbanist(
                                    color: AppColor.white))),
                            const SizedBox(height: 8), // reduced from 15

                            // Share
                            IconButtonUi(
                                callback: onClickShare,
                                icon: const ImageIcon(
                                    AssetImage(AppIcons.boldShare),
                                    color: AppColor.white,
                                    size: 28)), // size reduced from 30
                            Obx(() => Text(
                                CustomFormatNumber.convert(
                                    customChanges["share"]),
                                style: GoogleFonts.urbanist(
                                    color: AppColor.white))),
                            const SizedBox(height: 8), // reduced from 15

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
                            const SizedBox(height: 8), // reduced from 15

                            // More options
                            IconButtonUi(
                                callback: onClickMoreOption,
                                icon: const ImageIcon(
                                    AssetImage(AppIcons.moreCircle),
                                    color: AppColor.white,
                                    size: 28)), // size reduced from 30
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
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
                        videoId: shorts.id!,
                        channelId: shorts.channelId!,
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
            ),

      // : ShortsDetailsUi(
      //     isBack: true,
      //     isShowIcon: isShowIcon.value,
      //     isBuffering: isBuffering.value,
      //     isInitialize: isVideoLoading.value,
      //     isPlaying: isPlaying.value,
      //     isLike: isLike.value,
      //     isDislike: isDisLike.value,
      //     isSubscribe: isSubscribe.value,
      //     video: Container(
      //       height: Get.height,
      //       width: Get.width,
      //       color: AppColors.black,
      //       child: isVideoLoading.value ? const LoaderUi(color: Colors.white) : Chewie(controller: chewieController!),
      //     ),
      //     isPaginationLoading: controller.isPaginationLoading.value,
      //     like: CustomFormatNumber.convert(customChanges["like"]),
      //     disLike: CustomFormatNumber.convert(customChanges["disLike"]),
      //     comment: CustomFormatNumber.convert(customChanges["comment"]),
      //     share: CustomFormatNumber.convert(customChanges["share"]),
      //     title: controller.mainShortsVideos[widget.index].title!,
      //     hasTag: controller.mainShortsVideos[widget.index].hashTag!.join(','),
      //     channelName: controller.mainShortsVideos[widget.index].channelName!,
      //     channelImage: PreviewChannelImage(
      //       channelId: controller.mainShortsVideos[widget.index].channelId!,
      //       channelImage: controller.mainShortsVideos[widget.index].channelImage!,
      //     ),
      //     onClickVideo: onClickVideo,
      //     onClickLike: onClickLike,
      //     onClickDisLike: onClickDisLike,
      //     onClickShare: onClickShare,
      //     onClickProfile: onClickProfile,
      //     onClickMoreOption: onClickMoreOption,
      //     onClickSearch: onClickSearch,
      //     onClickCamera: onClickCamera,
      //     onClickComment: onClickComment,
      //     onClickSubscribe: onClickSubscribe,
      //     onClickPlayPause: onClickPlayPause,
      //   ),
    );
  }
}

// GestureDetector(
//   onTap: onClickVideo,
//   child: Container(
//     height: Get.height,
//     width: Get.width,
//     color: AppColors.black,
//     child: Obx(() => isVideoLoading.value ? const LoaderUi(color: Colors.white) : Chewie(controller: chewieController!)),
//   ),
// ),

// Old Working Code Don't Remove...

// : Stack(
//     children: [
//       GestureDetector(
//         onTap: () async {
//           videoPlayerController!.value.isPlaying ? onStopVideo() : onPlayVideo();
//           isShowIcon.value = true;
//           await 2.seconds.delay();
//           isShowIcon.value = false;
//         },
//         child: SizedBox(
//           height: Get.height,
//           width: Get.width,
//           child: Chewie(controller: chewieController!),
//         ),
//       ),
//       Obx(
//         () => isShowIcon.value
//             ? Align(
//                 alignment: Alignment.center,
//                 child: GestureDetector(
//                   onTap: () => videoPlayerController!.value.isPlaying ? onStopVideo() : onPlayVideo(),
//                   child: Obx(
//                     () => Container(
//                       height: 60,
//                       width: 60,
//                       padding: EdgeInsets.only(left: isPlaying.value ? 0 : 5),
//                       decoration: BoxDecoration(color: AppColors.black.withOpacity(0.2), shape: BoxShape.circle),
//                       child: Center(
//                         child: Image.asset(
//                           isPlaying.value ? AppIcons.pause : AppIcons.videoPlay,
//                           width: 25,
//                           height: 25,
//                           color: AppColors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//             : const Offstage(),
//       ),
//       Obx(() => Visibility(visible: isBuffering.value, child: const Align(alignment: Alignment.center, child: LoaderUi()))),
//       Padding(
//         padding: EdgeInsets.only(right: 30, top: SizeConfig.screenHeight / 15),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             GestureDetector(
//               onTap: () {
//                 onStopVideo();
//                 onClose();
//                 Get.back();
//               },
//               child: Image.asset(AppIcons.arrowBack, color: AppColors.white, width: 20),
//             ).paddingOnly(left: 15),
//             const Spacer(),
//             GestureDetector(
//                 onTap: () {
//                   onStopVideo();
//                   Get.to(const SearchPageView(isSearchShorts: true));
//                 },
//                 child: const ImageIcon(AssetImage(AppIcons.search), color: AppColors.white, size: 22)),
//             SizedBox(width: SizeConfig.blockSizeHorizontal * 5),
//             GestureDetector(
//               onTap: () {
//                 videoPlayerController?.pause();
//                 isPlaying.value = false;
//
//                 Get.to(() => CreateShortView());
//               },
//               child: const ImageIcon(AssetImage(AppIcons.camera), color: AppColors.white, size: 30),
//             ),
//           ],
//         ),
//       ),
//       Padding(
//         padding: EdgeInsets.only(left: SizeConfig.screenWidth / 1.2),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             GestureDetector(
//               onTap: () async {
//                 if (!isLike.value) {
//                   if (isDisLike.value) {
//                     isDisLike.value = false;
//                     customChanges["disLike"]--;
//                   }
//                   isLike.value = true;
//                   customChanges["like"]++;
//                   await LikeDisLikeVideoApi.callApi(controller.mainShortsVideos[widget.index].id.toString(), true);
//                 } else {
//                   AppSettings.showLog("This Video Already Liked");
//                 }
//               },
//               child: Obx(
//                 () => ImageIcon(const AssetImage(AppIcons.likeBold), color: isLike.value ? AppColors.primaryColor : AppColors.white, size: 25),
//               ),
//             ),
//             Obx(
//               () => Text(
//                 customChanges["like"].toString(),
//                 style: GoogleFonts.urbanist(color: AppColors.white),
//               ),
//             ),
//             SizedBox(height: SizeConfig.blockSizeVertical * 2),
//             GestureDetector(
//               onTap: () async {
//                 if (!isDisLike.value) {
//                   if (isLike.value) {
//                     isLike.value = false;
//                     customChanges["like"]--;
//                   }
//                   isDisLike.value = true;
//                   customChanges["disLike"]++;
//                   await LikeDisLikeVideoApi.callApi(controller.mainShortsVideos[widget.index].id.toString(), false);
//                 } else {
//                   AppSettings.showLog("This Video Already DisLiked");
//                 }
//               },
//               child: Obx(
//                 () => ImageIcon(
//                   const AssetImage(AppIcons.disLikeBold),
//                   color: isDisLike.value ? AppColors.primaryColor : AppColors.white,
//                   size: 25,
//                 ),
//               ),
//             ),
//             Obx(() => Text(customChanges["disLike"].toString(), style: GoogleFonts.urbanist(color: AppColors.white))),
//             SizedBox(height: SizeConfig.blockSizeVertical * 2),
//             GestureDetector(
//               onTap: () async {
//                 onStopVideo();
//
//                 isPlaying.value = false;
//                 videoPlayerController?.pause();
//
//                 customChanges["comment"] = await CommentBottomSheet.show(
//                   context,
//                   controller.mainShortsVideos[widget.index].id!,
//                   controller.mainShortsVideos[widget.index].channelId!,
//                   customChanges["comment"],
//                 );
//               },
//               child: const ImageIcon(AssetImage(AppIcons.comments), color: AppColors.white, size: 30),
//             ),
//             Obx(() => Text(customChanges["comment"].toString(), style: GoogleFonts.urbanist(color: AppColors.white))),
//             SizedBox(height: SizeConfig.blockSizeVertical * 2),
//             GestureDetector(
//               onTap: () async {
//                 await FlutterShare.share(
//                   title: controller.mainShortsVideos[widget.index].title!,
//                   text: controller.mainShortsVideos[widget.index].videoUrl!,
//                   linkUrl: controller.mainShortsVideos[widget.index].videoUrl!,
//                 );
//                 await ShareCountApiClass.callApi(Database.loginUserId!, controller.mainShortsVideos[widget.index].id.toString());
//
//                 customChanges["share"] += 1;
//               },
//               child: const ImageIcon(AssetImage(AppIcons.boldShare), color: AppColors.white, size: 30),
//             ),
//             Obx(
//               () => Text(
//                 customChanges["share"].toString(),
//                 style: GoogleFonts.urbanist(color: AppColors.white),
//               ),
//             ),
//             SizedBox(height: SizeConfig.blockSizeVertical * 2),
//             GestureDetector(
//               onTap: () {
//                 onStopVideo();
//
//                 isPlaying.value = false;
//                 videoPlayerController?.pause();
//
//                 Get.bottomSheet(
//                   backgroundColor: isDarkMode.value ? AppColors.secondDarkMode : AppColors.white,
//                   SizedBox(
//                     height: SizeConfig.screenHeight / 5,
//                     child: SingleChildScrollView(
//                       physics: const BouncingScrollPhysics(),
//                       child: Column(
//                         children: [
//                           const SizedBox(height: 5),
//                           Container(
//                             width: SizeConfig.blockSizeHorizontal * 12,
//                             height: 3,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(60),
//                               color: AppColors.grey_100,
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Text(AppStrings.moreOption.tr, style: titalstyle1),
//                           const SizedBox(height: 10),
//                           const Divider(indent: 25, endIndent: 25, color: AppColors.grey),
//                           const SizedBox(height: 10),
//                           BottomShitButton(
//                             widget: const ImageIcon(AssetImage(AppIcons.document), size: 23),
//                             name: AppStrings.description.tr,
//                             onTap: () {
//                               Get.back();
//                               DescriptionBottomSheet.show(
//                                 controller.mainShortsVideos[widget.index].channelId!,
//                                 controller.mainShortsVideos[widget.index].title!,
//                                 controller.mainShortsVideos[widget.index].channelImage!,
//                                 controller.mainShortsVideos[widget.index].channelName!,
//                                 customChanges["like"],
//                                 customChanges["disLike"],
//                                 controller.mainShortsVideos[widget.index].views!,
//                                 controller.mainShortsVideos[widget.index].createdAt!,
//                                 controller.mainShortsVideos[widget.index].hashTag!.join(','),
//                                 controller.mainShortsVideos[widget.index].description!,
//                               );
//                             },
//                           ),
//                           const SizedBox(height: 15),
//                           BottomShitButton(
//                             widget: const ImageIcon(AssetImage(AppIcons.closeSquare), size: 23),
//                             name: AppStrings.report.tr,
//                             onTap: () {
//                               Get.back();
//                               CustomReportView.show(controller.mainShortsVideos[widget.index].id!);
//                             },
//                           ),
//                           const SizedBox(height: 10),
//                         ],
//                       ),
//                     ),
//                   ),
//                   shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.only(
//                       topRight: Radius.circular(30),
//                       topLeft: Radius.circular(30),
//                     ),
//                   ),
//                 );
//               },
//               child: const ImageIcon(AssetImage(AppIcons.moreCircle), color: AppColors.white, size: 30),
//             ),
//             SizedBox(height: SizeConfig.blockSizeVertical * 3),
//           ],
//         ),
//       ),
//       Padding(
//         padding: const EdgeInsets.only(left: 20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.end,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: SizeConfig.screenWidth / 1.8,
//               child: Text(
//                 "${controller.mainShortsVideos[widget.index].title}\n${controller.mainShortsVideos[widget.index].hashTag?.join(',')}",
//                 style: GoogleFonts.urbanist(fontSize: 15, color: AppColors.white),
//                 maxLines: 3,
//               ),
//             ),
//             SizedBox(height: SizeConfig.blockSizeVertical * 2),
//             Row(
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     onStopVideo();
//
//                     videoPlayerController?.pause();
//                     controller.isPlaying.value = false;
//
//                     Get.to(
//                       () => PreviewShortsChannelView(channelId: controller.mainShortsVideos[widget.index].channelId!),
//                     );
//                   },
//                   child: Container(
//                     height: 30,
//                     width: 30,
//                     clipBehavior: Clip.antiAlias,
//                     decoration: const BoxDecoration(shape: BoxShape.circle),
//                     child: PreviewChannelImage(
//                       channelId: controller.mainShortsVideos[widget.index].channelId!,
//                       channelImage: controller.mainShortsVideos[widget.index].channelImage!,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
//                 Text(
//                   controller.mainShortsVideos[widget.index].channelName.toString(),
//                   style: GoogleFonts.urbanist(
//                     color: AppColors.white,
//                     fontSize: 15,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(width: SizeConfig.blockSizeHorizontal * 3),
//                 GestureDetector(
//                   onTap: () async {
//                     if (Database.isChannel && Database.channelId != null) {
//                       isSubscribe.value = !isSubscribe.value;
//                       await SubscribeChannelApiClass.callApi(controller.mainShortsVideos[widget.index].channelId.toString());
//                     } else {
//                       CustomToast.show(AppStrings.pleaseCreateChannel.tr);
//                     }
//                   },
//                   child: Obx(
//                     () => Container(
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: isSubscribe.value ? Colors.transparent : AppColors.primaryColor,
//                         borderRadius: BorderRadius.circular(25),
//                         border: Border.all(color: AppColors.primaryColor),
//                       ),
//                       child: Text(
//                         isSubscribe.value ? AppStrings.subscribed : AppStrings.subscribe,
//                         style: GoogleFonts.urbanist(
//                           color: isSubscribe.value ? AppColors.primaryColor : AppColors.white,
//                           fontSize: 13,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: SizeConfig.blockSizeVertical * 3,
//             ),
//           ],
//         ),
//       ),
//       Obx(
//         () => Visibility(
//           visible: controller.isPaginationLoading.value,
//           child: Align(alignment: Alignment.bottomCenter, child: LinearProgressIndicator(color: AppColors.primaryColor, backgroundColor: AppColors.grey_300)),
//         ),
//       ),
//     ],
//   ),
