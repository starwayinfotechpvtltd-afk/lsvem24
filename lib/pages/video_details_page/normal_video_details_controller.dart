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
import 'package:metube/utils/constant/app_constant.dart';
import 'package:metube/utils/storage/guest_like_storage.dart';
import 'package:metube/utils/videoViews/add_view_api.dart';
import 'package:metube/pages/login_related_page/fill_profile_page/get_profile_api.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

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
  bool isViewAdded = false;
  bool isFullscreen = false;
  bool isFullscreenTransitioning = false;
  RxBool isVideoDetailsLoading = true.obs;
  bool _lastPlayingState = false;

  RxBool isDownloading = false.obs;

  RxBool isLoop = false.obs;
  RxBool isAutoPlay = true.obs;
  RxBool isSpeaker = true.obs;
  RxInt currentSpeedIndex = 2.obs;
  final List<double> speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  bool isVideoSkip = false;
  bool isGetVideoRewardCoin = false;

  bool showAd = false;
  bool isAdLoading = false;
  bool isVideoReady = false;
  bool _videoInitRetried = false;
  bool hasShownMidrollAd = false;
  bool isPreRollAdPhase = false;
  bool isAutoPlayingNext = false;
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
    final user = GetProfileApi.profileModel?.user;

    // Premium users don't see ads
    if (user?.isPremiumPlan == true) {
      // Optional expiry validation
      if (user?.plan?.planEndDate != null) {
        try {
          final endDate = DateTime.parse(user!.plan!.planEndDate!);

          if (DateTime.now().isBefore(endDate)) {
            AppSettings.showLog(
              "Premium user detected. Ads disabled.",
            );

            _preRollAds.clear();
            _midRollAds.clear();
            activeBannerAd = null;
            activeOverlayAd = null;
            currentLongVideoAd = null;

            return;
          }
        } catch (e) {
          AppSettings.showLog(
            "Premium plan date parse error: $e",
          );
        }
      } else {
        _preRollAds.clear();
        _midRollAds.clear();
        return;
      }
    }

    final ads = await GetLongVideoAdsApi.callApi();

    _preRollAds = ads.where((a) => a.supportsPreRoll).toList();
    _midRollAds = ads.where((a) => a.supportsMidRoll).toList();

    AppSettings.showLog(
      'Long video ads loaded — pre-roll: ${_preRollAds.length}, mid-roll: ${_midRollAds.length}',
    );
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

  Future<void> _updateWakeLock() async {
    final keepScreenOn = (videoPlayerController?.value.isPlaying ?? false) ||
        isShowingInterruptAd;

    if (keepScreenOn) {
      await WakelockPlus.enable();
    } else {
      await WakelockPlus.disable();
    }
  }

  Future<void> init(String videoId, String videoUrl) async {
    this.videoId = videoId;
    _videoInitRetried = false;
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
    update(["onGetRelatedVideos"]);

    try {
      _getRelatedVideoModel =
          await GetRelatedVideoApi.callApi(videoId: videoId);
      mainRelatedVideos = _getRelatedVideoModel?.data ?? [];
      AppSettings.showLog(
        "Related videos loaded => ${mainRelatedVideos?.length}",
      );
      mainRelatedVideos?.shuffle();

      if ((mainRelatedVideos?.isEmpty ?? true) &&
          mainWatchedVideos.length == 1) {
        isDisableNext(true);
      }
    } catch (e) {
      AppSettings.showLog("onGetRelatedVideos error => $e");
      mainRelatedVideos = [];
    } finally {
      mainRelatedVideos ??= [];
      update(["onGetRelatedVideos"]);
      try {
        scrollController.animateTo(0,
            duration: const Duration(milliseconds: 10), curve: Curves.ease);
      } catch (_) {}
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

        GuestLikeStorage.applyToUi(
          videoId: videoId,
          isLike: isLike,
          isDisLike: isDisLike,
          customChanges: customChanges,
        );

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

//   Future<void> updateWakeLock() async {
//   final playing =
//       videoPlayerController?.value.isPlaying ?? false;

//   final keepAwake = playing || isShowingInterruptAd;

//   if (keepAwake) {
//     await WakelockPlus.enable();
//   } else {
//     await WakelockPlus.disable();
//   }
// }

  Future<void> initializeVideoPlayer(String videoId, String videoUrl) async {
    try {
      isVideoSkip = false;
      isGetVideoRewardCoin = false;
      hasShownMidrollAd = false;
      showAd = false;
      isAdLoading = false;
      isPreRollAdPhase = false;
      isViewAdded = false;
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

        final hasBlockingPreRoll = _preRollAds.any((ad) => ad.isInterruptType);
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

      if (!_videoInitRetried) {
        _videoInitRetried = true;
        try {
          await Database.localStorage.remove(videoId);
        } catch (_) {}
        final retryPath = ConvertToNetwork.resolve(videoUrl);
        if (retryPath.isNotEmpty) {
          AppSettings.showLog("Retrying video init => $retryPath");
          await initializeVideoPlayer(videoId, videoUrl);
          return;
        }
      }

      videoPlayerController?.dispose();
      videoPlayerController = null;
      chewieController?.dispose();
      chewieController = null;
      isVideoReady = false;
      isVideoLoading = false;
      update(["onVideoInitialize", "onLoading"]);
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

  /// Always resolve from [videoUrl] so host changes / stale cache cannot break playback.
  String _resolveVideoUrl(String videoId, String videoUrl) {
    if (videoUrl.trim().isNotEmpty) {
      final resolved = ConvertToNetwork.resolve(videoUrl);
      if (resolved.isNotEmpty) {
        Database.onSetVideoUrl(videoId, resolved);
        AppSettings.showLog("Resolved play URL => $resolved");
        return resolved;
      }
    }

    final cached = Database.onGetVideoUrl(videoId);
    if (cached != null && cached.isNotEmpty) {
      final resolvedCache = ConvertToNetwork.resolve(cached);
      AppSettings.showLog("Resolved cached URL => $resolvedCache");
      return resolvedCache;
    }

    return '';
  }

  /// Resolves ad image/video URLs (handles /api/uploads/ and relative paths).
  static String resolveAssetUrl(String path) => ConvertToNetwork.resolve(path);

  // ✅ FIX: Extracted listener into named method so it can be properly removed
  // Add this to the _videoListener method
void _videoListener() async {
  print("POS=${videoPlayerController!.value.position.inMilliseconds} "
      "DUR=${videoPlayerController!.value.duration.inMilliseconds} "
      "PLAYING=${videoPlayerController!.value.isPlaying}");
  
  if (videoPlayerController == null) return;
  final playing = videoPlayerController!.value.isPlaying;

  if (playing != _lastPlayingState) {
    _lastPlayingState = playing;
    _updateWakeLock();
  }

  if (Get.currentRoute != "/NormalVideoDetailsView") {
    videoPlayerController?.pause();
    AppSettings.showLog("Video Playing Routes Changes...");
  }

  if (videoPlayerController!.value.isInitialized) {
    // View count tracking
    if (!isViewAdded && videoPlayerController!.value.position.inSeconds >= 5) {
      isViewAdded = true;
      await AddViewApi.callApi(
        videoId,
        Database.loginUserId ?? "",
      );
      AppSettings.showLog("View Count Added For Video => $videoId");
    }
    
    // Buffering state
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

    update(["onProgressLine", "onVideoTime", "onVideoPlayPause", "adComplete"]);

    _checkMidrollAdTiming();

    AppSettings.showLog(
      "POS=${videoPlayerController!.value.position.inMilliseconds}"
      " DUR=${videoPlayerController!.value.duration.inMilliseconds}"
      " PLAYING=${videoPlayerController!.value.isPlaying}",
    );

    final position = videoPlayerController!.value.position;
    final duration = videoPlayerController!.value.duration;

    // ✅ FIX: Add check for video completion
    if (duration.inMilliseconds > 0 && 
        position.inMilliseconds >= duration.inMilliseconds - 1000) {
      // Video is about to end
      if (isAutoPlay.value && !isAutoPlayingNext) {
        isAutoPlayingNext = true;
        await WakelockPlus.enable();
        Future.delayed(
          const Duration(milliseconds: 500),
          () {
            onNextVideo();
          },
        );
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
      update(['adComplete', 'onVideoPlayPause', 'onProgressLine']);
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
      update(['adComplete', 'onVideoPlayPause', 'onProgressLine']);
      _startMainVideoAfterAd();
    } else {
      update(['adComplete', 'onProgressLine']);
    }
  }

  void _showInterruptAd(LongVideoAd ad, {required bool isPreRoll}) async {
  // ✅ FIX: Pause the video player before showing ad
  await videoPlayerController?.pause();
  
  isAdLoading = true;
  showAd = true;
  _updateWakeLock();
  currentLongVideoAd = ad;
  isPreRollAdPhase = isPreRoll;
  wasPlayingBeforeAd = !isPreRoll && (videoPlayerController?.value.isPlaying ?? false);
  pausedPosition = isPreRoll 
      ? Duration.zero 
      : (videoPlayerController?.value.position ?? Duration.zero);

  update(['adComplete', 'onVideoPlayPause', 'onShowControls', 'onProgressLine']);

  // ✅ FIX: Add timeout to prevent infinite loading
  Future.delayed(const Duration(seconds: 45), () {
    if (isAdLoading && showAd && currentLongVideoAd?.id == ad.id) {
      AppSettings.showLog('Ad load timeout — resuming video');
      onAdFailed();
    }
  });
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
      _updateWakeLock();
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
      _updateWakeLock();
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
      _updateWakeLock();
    }

    update(['adComplete', 'onVideoPlayPause', 'onProgressLine']);
  }

  void _resumeMainVideoAfterInterruptAd({required bool wasPreRoll}) {
    isAdLoading = false;

// Hide the ad only after loading has completely finished.
Future.delayed(const Duration(milliseconds: 100), () {
  showAd = false;
  currentLongVideoAd = null;

  update([
    'adComplete',
    'onVideoPlayPause',
    'onProgressLine',
  ]);
});

    if (wasPreRoll) {
      _startMainVideoAfterAd();
    } else {
      _resumeMainVideoAfterMidRoll();
    }
  }

  void onAdStarted() {
  isAdLoading = false;
  _updateWakeLock();
  AppSettings.showLog("Ad started playing");

  // ✅ FIX: Ensure UI updates properly
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!isClosed) {
      update(['adComplete', 'onVideoPlayPause']);
    }
  });
}
  void onAdFailed() {
  AppSettings.showLog("Sponsored ad failed");

  if (isAdLoading) {
    isAdLoading = false;
  }

  final wasPreRoll = isPreRollAdPhase;

  if (!wasPreRoll && adShowCount > 0) {
    adShowCount--;
  }

  _resumeMainVideoAfterInterruptAd(
    wasPreRoll: wasPreRoll,
  );

  _updateWakeLock();
}


  void onAdCompleted1() {
  AppSettings.showLog('Interrupt ad completed — resuming long video');
  
  // ✅ FIX: Properly resume the video
  final wasPreRoll = isPreRollAdPhase;
  
  // Reset ad states
  showAd = false;
  currentLongVideoAd = null;
  isAdLoading = false;
  
  // Resume video
  final player = videoPlayerController;
  if (player != null && player.value.isInitialized) {
    if (wasPreRoll) {
      // For pre-roll, start from beginning
      player.seekTo(Duration.zero);
    } else {
      // For mid-roll, seek to paused position
      player.seekTo(pausedPosition);
    }
    player.play();
    _updateWakeLock();
  }
  
  mainVideoPlaybackStarted = true;
  isPreRollAdPhase = false;
  
  update(['adComplete', 'onVideoPlayPause', 'onProgressLine']);
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
    WakelockPlus.disable();
    update(["onVideoInitialize", "adComplete"]);
  }

  void onNextVideo() {
    print("NEXT VIDEO CLICKED");
    print("Related count = ${mainRelatedVideos?.length}");
    print("Watched count = ${mainWatchedVideos.length}");
    print("Current index = $selectedWatchedVideo");
    isDisablePrevious(false);
    print("AUTOPLAY => selectedWatchedVideo=$selectedWatchedVideo");
    selectedWatchedVideo++;

    if (selectedWatchedVideo != mainWatchedVideos.length) {
      onDisposeVideoPlayer();
      onCreateHistory();
      Future.delayed(const Duration(milliseconds: 300), () {
        isAutoPlayingNext = false;
      });
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
      Future.delayed(const Duration(milliseconds: 300), () {
        isAutoPlayingNext = false;
      });
      print("AUTOPLAY NEXT => ${mainRelatedVideos![0].title}");
      init(
          mainRelatedVideos![0].id ?? "", mainRelatedVideos![0].videoUrl ?? "");
      mainRelatedVideos = null;
      update(["onGetRelatedVideos"]);
    } else {
      isDisableNext(true);
      WakelockPlus.disable();
    }
  }

  void onPreviousVideo() async {
    isDisableNext(false);
    selectedWatchedVideo--;

    if (selectedWatchedVideo >= 0) {
      onDisposeVideoPlayer();
      Future.delayed(const Duration(milliseconds: 300), () {
        isAutoPlayingNext = false;
      });
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
    WakelockPlus.disable();
    super.onClose();
  }
}

class WatchedVideoModel {
  final String videoId;
  final String videoUrl;
  WatchedVideoModel({required this.videoId, required this.videoUrl});
}
