import 'dart:async';

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
import 'package:metube/custom/shimmer/shorts_video_shimmer_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/custom_pages/comment_page/comment_bottom_sheet.dart';
import 'package:metube/pages/custom_pages/comment_page/comment_sheet_panel.dart';
import 'package:metube/pages/custom_pages/report_page/custom_report_view.dart';
import 'package:metube/pages/custom_pages/share_count_page/share_count_api.dart';
import 'package:metube/pages/nav_add_page/create_short_page/create_short_view.dart';
import 'package:metube/pages/nav_add_page/live_page/widget/device_orientation.dart';
import 'package:metube/pages/nav_library_page/history_page/create_watch_history_api.dart';
import 'package:metube/pages/nav_shorts_page/nav_shorts_details_view.dart';
import 'package:metube/pages/nav_subscription_page/subscribe_channel_api.dart';
import 'package:metube/pages/profile_page/content_engagement_page/video_engagement_reward_api.dart';
import 'package:metube/pages/profile_page/your_channel_page/main_page/your_channel_view.dart';
import 'package:metube/pages/search_page/search_view.dart';
import 'package:metube/pages/splash_screen_page/api/unlock_private_video_api.dart';
import 'package:metube/pages/video_details_page/video_description_bottom_sheet.dart';
import 'package:metube/pages/video_details_page/video_details_api.dart';
import 'package:metube/pages/video_details_page/video_details_model.dart';
import 'package:metube/utils/storage/guest_like_storage.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/config/size_config.dart';
import 'package:metube/utils/constant/app_constant.dart';
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

class ShortsVideoDetailsView extends StatefulWidget {
  const ShortsVideoDetailsView({
    super.key,
    required this.videoId,
    required this.videoUrl,
    this.previousPageIsSearch,
  });

  final bool? previousPageIsSearch;
  final String videoId;
  final String videoUrl;

  @override
  State<ShortsVideoDetailsView> createState() => _ShortsVideoDetailsViewState();
}

class _ShortsVideoDetailsViewState extends State<ShortsVideoDetailsView> {
  ChewieController? chewieController;
  VideoDetailsModel? videoDetailsModel;

  RxBool isPrivateContent = false.obs;

  VideoPlayerController? videoPlayerController;

  RxBool isVideoDetailsLoading = true.obs;
  RxBool isVideoLoading = true.obs;

  RxBool isPlaying = false.obs;
  RxBool isBuffering = false.obs;
  RxBool isShowIcon = false.obs;

  RxBool isLike = false.obs;
  RxBool isDisLike = false.obs;
  RxBool isSubscribe = false.obs;

  RxMap customChanges = {"like": 0, "disLike": 0, "comment": 0, "share": 0}.obs;

  bool _commentsOpen = false;

  // ✅ ADD this helper method just above initializeVideoPlayer()
  String _resolveUrl(String url) => ConvertToNetwork.resolve(url);

  @override
  void initState() {
    AppSettings.showLog("Shorts Video Id => ${widget.videoId}");
    AppSettings.showLog("Shorts Video Url => ${widget.videoUrl}");
    getVideoDetails();
    initializeVideoPlayer();
    super.initState();
  }

  void getVideoDetails() async {
    try {
      videoDetailsModel = await VideoDetailsApi.callApi(
          Database.loginUserId ?? "", widget.videoId, 2);
      if (videoDetailsModel != null) {
        final details = videoDetailsModel?.detailsOfVideo;
        isSubscribe.value = details?.isSubscribed ?? false;
        isLike.value = details?.isLike ?? false;
        isDisLike.value = details?.isDislike ?? false;

        customChanges["like"] = details?.like ?? 0;
        customChanges["disLike"] = details?.dislike ?? 0;
        customChanges["comment"] = details?.totalComments ?? 0;
        customChanges["share"] = details?.shareCount ?? 0;

        GuestLikeStorage.applyToUi(
          videoId: widget.videoId,
          isLike: isLike,
          isDisLike: isDisLike,
          customChanges: customChanges,
        );

        isPrivateContent.value =
            (videoDetailsModel?.detailsOfVideo?.videoPrivacyType == 2 &&
                videoDetailsModel?.detailsOfVideo?.isSubscribed == false);
      }
    } catch (e) {
      AppSettings.showLog("❌ getVideoDetails error: $e");
    } finally {
      // ✅ Always set to false so shimmer disappears
      isVideoDetailsLoading.value = false;
    }
  }

  Future<void> onCreateHistory() async {
    if (Database.channelId != null &&
        videoDetailsModel?.detailsOfVideo != null &&
        videoPlayerController != null) {
      final watchTime = videoPlayerController!.value.position.inSeconds / 60;
      AppSettings.showLog("Shorts Watch Time => $watchTime");
      await CreateWatchHistoryApi.callApi(
        loginUserId: Database.loginUserId ?? "",
        videoId: videoDetailsModel?.detailsOfVideo?.id ?? "",
        videoChannelId: videoDetailsModel?.detailsOfVideo?.channelId ?? "",
        videoUserId: videoDetailsModel?.detailsOfVideo?.userId ?? "",
        watchTimeInMinute: watchTime,
      );
    }
  }

  Future<void> initializeVideoPlayer() async {
    try {
      AppSettings.showLog("🔍 RAW widget.videoUrl = '${widget.videoUrl}'");
      AppSettings.showLog("🔍 Resolved = '${_resolveUrl(widget.videoUrl)}'");
      // ✅ FIX: Resolve relative URL to full URL
      String? cachedUrl = Database.onGetVideoUrl(widget.videoId);
      String videoPath;

      if (cachedUrl != null &&
          cachedUrl.isNotEmpty &&
          cachedUrl.startsWith('http')) {
        videoPath = cachedUrl;
      } else {
        videoPath = _resolveUrl(widget.videoUrl);
      }

      AppSettings.showLog("🎬 Shorts videoPath: $videoPath");

      if (videoPath.isEmpty) {
        AppSettings.showLog("❌ Shorts: empty video path");
        isVideoLoading.value = false;
        return;
      }

      videoPlayerController?.dispose();
      videoPlayerController = null;
      chewieController?.dispose();
      chewieController = null;

      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(videoPath));

      await videoPlayerController!.initialize().timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception("Shorts init timed out"),
          );

      if (videoPlayerController!.value.isInitialized) {
        AppSettings.showLog("✅ Shorts video initialized");

        Database.onSetVideoUrl(widget.videoId, videoPath);

        chewieController = ChewieController(
          videoPlayerController: videoPlayerController!,
          aspectRatio: Get.width / Get.height,
          looping: false,
          allowedScreenSleep: false,
          allowMuting: false,
          showControlsOnInitialize: false,
          showControls: false,
        );

        isVideoLoading.value = false;

        if (!isPrivateContent.value) onPlayVideo();

        videoPlayerController!.addListener(() {
          if (videoPlayerController == null) return;
          if (videoPlayerController!.value.isInitialized) {
            isBuffering.value = videoPlayerController!.value.isBuffering;
            if (isPrivateContent.value && isPlaying.value) onStopVideo();
          }
          if (videoPlayerController!.value.duration > Duration.zero &&
              videoPlayerController!.value.position >=
                  videoPlayerController!.value.duration) {
            VideoEngagementRewardApi.callApi(
              loginUserId: Database.loginUserId ?? "",
              videoId: widget.videoId,
              totalWatchTime:
                  videoPlayerController!.value.duration.inSeconds.toString(),
            );
            videoPlayerController?.seekTo(Duration.zero);
            onPlayVideo();
          }
        });
      } else {
        AppSettings.showLog("❌ Shorts isInitialized = false");
        isVideoLoading.value = false;
      }
    } catch (e) {
      AppSettings.showLog("❌ Shorts init failed: $e");
      isVideoLoading.value = false;
      onStopVideo();
      onClose();
    }
  }

  void onClickLike() async {
    final details = videoDetailsModel?.detailsOfVideo;
    if (details == null) return;
    if (!isLike.value) {
      if (isDisLike.value) {
        isDisLike.value = false;
        customChanges["disLike"]--;
      }
      isLike.value = true;
      customChanges["like"]++;
      await LikeDisLikeVideoApi.callApi(details.id.toString(), true);
    }
  }

  void onClickDisLike() async {
    final details = videoDetailsModel?.detailsOfVideo;
    if (details == null) return;
    if (!isDisLike.value) {
      if (isLike.value) {
        isLike.value = false;
        customChanges["like"]--;
      }
      isDisLike.value = true;
      customChanges["disLike"]++;
      await LikeDisLikeVideoApi.callApi(details.id.toString(), false);
    }
  }

  void onClickComment() {
    final details = videoDetailsModel?.detailsOfVideo;
    if (details == null) return;
    final videoId = details.id ?? "";
    final channelId = details.channelId ?? "";
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
    final details = videoDetailsModel?.detailsOfVideo;
    if (details == null) return;
    onStopVideo();
    await CustomShare.share(
      name: details.title ?? "",
      url: (details.videoUrl?.isNotEmpty ?? false)
          ? details.videoUrl!
          : widget.videoUrl,
      channelId: details.channelId ?? "",
      videoId: details.id ?? "",
      image: details.videoImage ?? "",
      pageRoutes: "ShortsVideo",
    );
    await ShareCountApiClass.callApi(
        Database.loginUserId ?? "", details.id.toString());
    customChanges["share"] += 1;
  }

  void onClickMoreOption() async {
    final details = videoDetailsModel?.detailsOfVideo;
    if (details == null) return;
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
                    details.channelId ?? "",
                    details.title ?? "",
                    details.channelImage ?? "",
                    details.channelName ?? "",
                    customChanges["like"],
                    customChanges["disLike"],
                    details.views ?? 0,
                    details.createdAt ?? "",
                    details.hashTag?.join(',') ?? "",
                    details.description ?? "",
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
                  CustomReportView.show(details.id ?? "");
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

  void onClickProfile() {
    onStopVideo();
    Get.to(() => YourChannelView(
          loginUserId: Database.loginUserId ?? "",
          channelId: videoDetailsModel?.detailsOfVideo?.channelId ?? "",
        ));
  }

  void onClickSearch() {
    onStopVideo();
    if (widget.previousPageIsSearch == true) {
      Get.back();
    } else {
      Get.to(const SearchView(isSearchShorts: true));
    }
  }

  void onClickSubscribe() async {
    final details = videoDetailsModel?.detailsOfVideo;
    if (details == null) return;
    if (isPrivateContent.value && isSubscribe.value == false) {
      onSubscribePrivateChannel();
    } else {
      isSubscribe.value = !isSubscribe.value;
      await SubscribeChannelApiClass.callApi(details.channelId.toString());
    }
  }

  void onClickCamera() {
    onStopVideo();
    Get.to(() => CreateShortView());
  }

  void onClickVideo() async {
    if (videoPlayerController == null) return;
    videoPlayerController!.value.isPlaying ? onStopVideo() : onPlayVideo();
    isShowIcon.value = true;
    await 2.seconds.delay();
    isShowIcon.value = false;
  }

  void onClickPlayPause() {
    if (videoPlayerController == null) return;
    videoPlayerController!.value.isPlaying ? onStopVideo() : onPlayVideo();
  }

  @override
  void dispose() {
    onCreateHistory();
    onClose();
    super.dispose();
  }

  void onStopVideo() {
    isPlaying.value = false;
    chewieController?.pause();
  }

  void onResumeVideo() {
    isPlaying.value = true;
    chewieController?.play();
  }

  void onPlayVideo() {
    isPlaying.value = true;
    videoPlayerController?.play();
  }

  void onClose() {
    try {
      videoPlayerController?.dispose();
      chewieController?.dispose();
      chewieController = null;
      videoPlayerController = null;
      isVideoLoading.value = true;
    } catch (e) {
      AppSettings.showLog("onClose error: $e");
    }
  }

  void onUnlockPrivateVideo() {
    UnlockPremiumVideoBottomSheet.onShow(
      coin:
          (videoDetailsModel?.detailsOfVideo?.videoUnlockCost ?? 0).toString(),
      callback: () async {
        Get.dialog(const LoaderUi(), barrierDismissible: false);
        await UnlockPrivateVideoApi.callApi(
            loginUserId: Database.loginUserId ?? "",
            videoId: videoDetailsModel?.detailsOfVideo?.id ?? "");
        if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
          isPrivateContent.value = false;
        }
        Get.close(2);
        SubscribedSuccessDialog.show(context);
      },
    );
  }

  void onSubscribePrivateChannel() {
    SubscribePremiumChannelBottomSheet.onShow(
      coin:
          (videoDetailsModel?.detailsOfVideo?.subscriptionCost ?? 0).toString(),
      callback: () async {
        Get.dialog(const LoaderUi(), barrierDismissible: false);
        final bool isSuccess = await SubscribeChannelApiClass.callApi(
            videoDetailsModel?.detailsOfVideo?.channelId ?? "");
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
    return Scaffold(
      body: Obx(
        () {
          final thumb =
              videoDetailsModel?.detailsOfVideo?.videoImage ?? '';
          final showLoading = isVideoLoading.value ||
              isVideoDetailsLoading.value ||
              videoPlayerController == null;

          if (showLoading) {
            return Stack(
              fit: StackFit.expand,
              children: [
                if (thumb.isNotEmpty)
                  PreviewVideoImage(
                    videoId: widget.videoId,
                    videoImage: thumb,
                    fit: BoxFit.cover,
                  ),
                const Center(child: LoaderUi(color: Colors.white)),
              ],
            );
          }

          return isPrivateContent.value
                ? ShortsPrivateContentWidget(
                    id: videoDetailsModel?.detailsOfVideo?.id ?? "",
                    image: _resolveUrl(
                        videoDetailsModel?.detailsOfVideo?.videoImage ?? ""),
                    subscribeCoin:
                        videoDetailsModel?.detailsOfVideo?.subscriptionCost ??
                            0,
                    unlockCoin:
                        videoDetailsModel?.detailsOfVideo?.videoUnlockCost ?? 0,
                    subscribe: onSubscribePrivateChannel,
                    unlock: onUnlockPrivateVideo,
                  )
                : ShortsDetailsUi(
                    isBack: true,
                    isShowIcon: isShowIcon.value,
                    isBuffering: isBuffering.value,
                    isInitialize: isVideoLoading.value,
                    isPlaying: isPlaying.value,
                    isLike: isLike.value,
                    isDislike: isDisLike.value,
                    isSubscribe: isSubscribe.value,
                    channelId:
                        videoDetailsModel?.detailsOfVideo?.channelId ?? "",
                    commentsOpen: _commentsOpen,
                    commentsOverlay: _commentsOpen &&
                            chewieController != null &&
                            videoPlayerController != null
                        ? Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: ShortsCommentsWithMiniPlayer(
                                videoPlayerController: videoPlayerController!,
                                chewieController: chewieController!,
                                videoId: videoDetailsModel?.detailsOfVideo?.id ??
                                    "",
                                channelId: videoDetailsModel
                                        ?.detailsOfVideo?.channelId ??
                                    "",
                                onClose: _closeCommentsOverlay,
                              ),
                            ),
                          )
                        : null,
                    video: _commentsOpen
                        ? SizedBox(
                            height: Get.height,
                            width: Get.width,
                            child: const ColoredBox(color: Colors.black),
                          )
                        : SizedBox(
                            height: Get.height,
                            width: Get.width,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (thumb.isNotEmpty)
                                  PreviewVideoImage(
                                    videoId: widget.videoId,
                                    videoImage: thumb,
                                    fit: BoxFit.cover,
                                  ),
                                Obx(
                                  () => isVideoLoading.value
                                      ? const LoaderUi(color: Colors.white)
                                      : chewieController == null
                                          ? const Offstage()
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
                                                      controller:
                                                          chewieController!),
                                                ),
                                              ),
                                            ),
                                ),
                              ],
                            ),
                          ),
                    isPaginationLoading: false,
                    like: CustomFormatNumber.convert(customChanges["like"]),
                    disLike:
                        CustomFormatNumber.convert(customChanges["disLike"]),
                    comment:
                        CustomFormatNumber.convert(customChanges["comment"]),
                    share: CustomFormatNumber.convert(customChanges["share"]),
                    title: videoDetailsModel?.detailsOfVideo?.title ?? "",
                    hasTag:
                        videoDetailsModel?.detailsOfVideo?.hashTag?.join(',') ??
                            "",
                    channelName:
                        videoDetailsModel?.detailsOfVideo?.channelName ?? "",
                    channelImage: PreviewProfileImage(
                      size: 30,
                      id: videoDetailsModel?.detailsOfVideo?.channelId ?? "",
                      // ✅ FIX: resolve image URL
                      image: _resolveUrl(
                          videoDetailsModel?.detailsOfVideo?.channelImage ??
                              ""),
                      fit: BoxFit.cover,
                    ),
                    onClickVideo: onClickVideo,
                    onClickLike: onClickLike,
                    onClickDisLike: onClickDisLike,
                    onClickShare: onClickShare,
                    onClickProfile: onClickProfile,
                    onClickMoreOption: onClickMoreOption,
                    onClickSearch: onClickSearch,
                    onClickCamera: onClickCamera,
                    onClickComment: onClickComment,
                    onClickSubscribe: onClickSubscribe,
                    onClickPlayPause: onClickPlayPause,
                  );
        },
      ),
    );
  }
}

class ShortsDetailsUi extends StatelessWidget {
  const ShortsDetailsUi({
    super.key,
    required this.isShowIcon,
    required this.isBuffering,
    required this.isInitialize,
    required this.isPlaying,
    required this.isLike,
    required this.isDislike,
    required this.isSubscribe,
    required this.video,
    required this.onClickVideo,
    required this.onClickLike,
    required this.onClickDisLike,
    required this.onClickShare,
    required this.onClickProfile,
    required this.onClickMoreOption,
    required this.onClickSearch,
    required this.onClickCamera,
    required this.onClickComment,
    required this.isPaginationLoading,
    required this.title,
    required this.hasTag,
    required this.channelName,
    required this.channelImage,
    required this.like,
    required this.disLike,
    required this.comment,
    required this.share,
    required this.onClickSubscribe,
    required this.onClickPlayPause,
    required this.isBack,
    required this.channelId,
    this.commentsOpen = false,
    this.commentsOverlay,
  });

  final bool commentsOpen;
  final Widget? commentsOverlay;
  final bool isShowIcon;
  final bool isBuffering;
  final bool isInitialize;
  final bool isPlaying;
  final bool isLike;
  final bool isDislike;
  final bool isSubscribe;
  final bool isPaginationLoading;
  final bool isBack;

  final String title;
  final String hasTag;
  final String channelName;
  final String channelId;
  final String like;
  final String disLike;
  final String comment;
  final String share;

  final Widget video;
  final Widget channelImage;

  final Callback onClickVideo;
  final Callback onClickLike;
  final Callback onClickDisLike;
  final Callback onClickShare;
  final Callback onClickProfile;
  final Callback onClickMoreOption;
  final Callback onClickSearch;
  final Callback onClickCamera;
  final Callback onClickComment;
  final Callback onClickSubscribe;
  final Callback onClickPlayPause;

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(milliseconds: 300), () {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
          systemNavigationBarDividerColor: AppColor.black,
          systemNavigationBarColor: AppColor.black,
        ),
      );
    });
    return Stack(
      children: [
        video,
        if (commentsOpen && commentsOverlay != null) commentsOverlay!,
        if (!commentsOpen)
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 55,
            left: 15,
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
              errorWidget: (context, url, error) => const Offstage(),
            ),
          ),
        ),
        if (!commentsOpen)
          GestureDetector(
            onTap: onClickVideo,
            child: Container(
              height: Get.height,
              width: Get.width,
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        if (!commentsOpen)
          isShowIcon
              ? Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: onClickPlayPause,
                    child: Container(
                      height: 60,
                      width: 60,
                      padding: EdgeInsets.only(left: isPlaying ? 0 : 5),
                      decoration: BoxDecoration(
                          color: AppColor.black.withOpacity(0.2),
                          shape: BoxShape.circle),
                      child: Center(
                        child: Image.asset(
                          isPlaying ? AppIcons.pause : AppIcons.videoPlay,
                          width: 25,
                          height: 25,
                          color: AppColor.white,
                        ),
                      ),
                    ),
                  ),
                )
              : const Offstage(),
        Visibility(visible: isBuffering, child: const LoaderUi()),
        Padding(
          padding: EdgeInsets.only(
              left: 15, right: 15, top: SizeConfig.screenHeight / 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              isBack
                  ? GestureDetector(
                      onTap: () => Get.back(),
                      child: Image.asset(
                        AppIcons.arrowBack,
                        color: AppColor.white,
                        width: 20,
                      ),
                    )
                  : const Offstage(),
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
        if (!commentsOpen)
          Positioned(
            bottom: 5,
            right: 15,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButtonUi(
                  callback: onClickLike,
                  icon: ImageIcon(const AssetImage(AppIcons.likeBold),
                      color: isLike ? AppColor.primaryColor : AppColor.white,
                      size: 25)),
              Text(like, style: GoogleFonts.urbanist(color: AppColor.white)),
              const SizedBox(height: 15),
              IconButtonUi(
                  callback: onClickDisLike,
                  icon: ImageIcon(const AssetImage(AppIcons.disLikeBold),
                      color: isDislike ? AppColor.primaryColor : AppColor.white,
                      size: 25)),
              Text(disLike, style: GoogleFonts.urbanist(color: AppColor.white)),
              const SizedBox(height: 15),
              IconButtonUi(
                  callback: onClickComment,
                  icon: const ImageIcon(AssetImage(AppIcons.comments),
                      color: AppColor.white, size: 30)),
              Text(comment, style: GoogleFonts.urbanist(color: AppColor.white)),
              const SizedBox(height: 15),
              IconButtonUi(
                  callback: onClickShare,
                  icon: const ImageIcon(AssetImage(AppIcons.boldShare),
                      color: AppColor.white, size: 30)),
              Text(share, style: GoogleFonts.urbanist(color: AppColor.white)),
              const SizedBox(height: 15),
              IconButtonUi(
                  callback: onClickMoreOption,
                  icon: const ImageIcon(AssetImage(AppIcons.moreCircle),
                      color: AppColor.white, size: 30)),
              const SizedBox(height: 25),
            ],
          ),
        ),
        if (!commentsOpen)
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: SizeConfig.screenWidth / 1.8,
                child: Text(title,
                    style: GoogleFonts.urbanist(
                        fontSize: 15, color: AppColor.white),
                    maxLines: 3),
              ),
              SizedBox(
                width: SizeConfig.screenWidth / 1.8,
                child: Text(hasTag,
                    style: GoogleFonts.urbanist(
                        fontSize: 14, color: AppColor.white),
                    maxLines: 3),
              ),
              SizedBox(height: SizeConfig.blockSizeVertical * 2),
              Row(
                children: [
                  IconButtonUi(
                    callback: onClickProfile,
                    icon: Container(
                      height: 30,
                      width: 30,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: channelImage,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    channelName.length > 12
                        ? '${channelName.substring(0, 12)}...'
                        : channelName,
                    style: GoogleFonts.urbanist(
                      color: AppColor.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Visibility(
                    visible: Database.channelId != channelId,
                    child: GestureDetector(
                      onTap: onClickSubscribe,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSubscribe
                              ? Colors.transparent
                              : AppColor.primaryColor,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: AppColor.primaryColor),
                        ),
                        child: Text(
                          isSubscribe
                              ? AppStrings.subscribed.tr
                              : AppStrings.subscribe.tr,
                          style: GoogleFonts.urbanist(
                            color: isSubscribe
                                ? AppColor.primaryColor
                                : AppColor.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
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
        Visibility(
          visible: isPaginationLoading,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: LinearProgressIndicator(
              color: AppColor.primaryColor,
              backgroundColor: AppColor.grey_300,
            ),
          ),
        ),
      ],
    );
  }
}
