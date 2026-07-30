import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_method/custom_format_timer.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/download_history_database.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/icons/app_icons.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:video_player/video_player.dart';

class PreviewNormalVideo extends StatefulWidget {
  const PreviewNormalVideo({super.key, required this.index});

  final int index;

  @override
  State<PreviewNormalVideo> createState() => _PreviewNormalVideoState();
}

class _PreviewNormalVideoState extends State<PreviewNormalVideo> {
  late VideoPlayerController videoPlayerController;
  RxInt videoPosition = 0.obs;
  RxBool isPlaying = true.obs;
  RxBool isInitialized = false.obs;
  RxBool showControls = true.obs;
  Timer? hideControlsTimer;

  Future<void> initializeVideoPlayer(String videoUrl) async {
    await 100.milliseconds.delay();

    try {
      final file = File(videoUrl);
      if (!await file.exists()) {
        AppSettings.showLog("Downloaded file does not exist at path: $videoUrl");
        return;
      }

      videoPlayerController = VideoPlayerController.file(file);
      await videoPlayerController.initialize();
      await videoPlayerController.setLooping(true);

      if (videoPlayerController.value.isInitialized) {
        await videoPlayerController.play();
        isInitialized.value = true;
        isPlaying.value = true;
        setState(() {});
        startHideControlsTimer();
      }

      videoPlayerController.addListener(() {
        if (mounted && videoPlayerController.value.isInitialized) {
          videoPosition.value = videoPlayerController.value.position.inMilliseconds;
          isPlaying.value = videoPlayerController.value.isPlaying;
        }
      });
    } catch (e) {
      AppSettings.showLog("Downloaded Video Loading Error: $e");
    }
  }

  void toggleControls() {
    showControls.value = !showControls.value;
    if (showControls.value) {
      startHideControlsTimer();
    }
  }

  void startHideControlsTimer() {
    hideControlsTimer?.cancel();
    hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && isPlaying.value) {
        showControls.value = false;
      }
    });
  }

  Future<void> forwardSkipVideo() async {
    if (!videoPlayerController.value.isInitialized) return;
    final currentPos = videoPlayerController.value.position;
    final newPos = currentPos + const Duration(seconds: 10);
    await videoPlayerController.seekTo(newPos);
    startHideControlsTimer();
  }

  Future<void> backwardSkipVideo() async {
    if (!videoPlayerController.value.isInitialized) return;
    final currentPos = videoPlayerController.value.position;
    final newPos = currentPos - const Duration(seconds: 10);
    await videoPlayerController.seekTo(newPos.inMilliseconds < 0 ? Duration.zero : newPos);
    startHideControlsTimer();
  }

  @override
  void initState() {
    super.initState();
    final videoPath = DownloadHistory.mainDownloadHistory[widget.index]["videoUrl"] ?? "";
    initializeVideoPlayer(videoPath);
  }

  @override
  void dispose() {
    hideControlsTimer?.cancel();
    videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarDividerColor: Colors.black,
      systemNavigationBarColor: Colors.black,
      statusBarColor: Colors.transparent,
    ));

    return PopScope(
      onPopInvoked: (didPop) async {
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        300.milliseconds.delay();
      },
      child: Scaffold(
        backgroundColor: AppColor.black,
        body: OrientationBuilder(
          builder: (context, orientation) {
            double videoAspectRatio = (isInitialized.value &&
                    videoPlayerController.value.aspectRatio > 0)
                ? videoPlayerController.value.aspectRatio
                : 16 / 9;

            return Stack(
              alignment: Alignment.center,
              children: [
                // Video Screen Area
                GestureDetector(
                  onTap: toggleControls,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: Get.width,
                    height: Get.height,
                    color: AppColor.black,
                    child: Center(
                      child: Obx(
                        () => isInitialized.value
                            ? AspectRatio(
                                aspectRatio: videoAspectRatio,
                                child: VideoPlayer(videoPlayerController),
                              )
                            : const LoaderUi(),
                      ),
                    ),
                  ),
                ),

                // Overlay Controls (Header, Center Seek/Play/Pause & Bottom Progress Slider)
                Obx(
                  () => AnimatedOpacity(
                    opacity: showControls.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: IgnorePointer(
                      ignoring: !showControls.value,
                      child: Stack(
                        children: [
                          // Top Navigation Header with Back Button and Video Title
                          Positioned(
                            top: orientation == Orientation.landscape ? 30 : 50,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              color: Colors.black.withValues(alpha: 0.4),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await SystemChrome.setPreferredOrientations([
                                        DeviceOrientation.portraitUp,
                                        DeviceOrientation.portraitDown,
                                      ]);
                                      Timer(const Duration(milliseconds: 300), () {
                                        Get.back();
                                      });
                                    },
                                    child: Image.asset(
                                      AppIcons.arrowBack,
                                      color: AppColor.white,
                                      width: 22,
                                      height: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      DownloadHistory.mainDownloadHistory[widget.index]["videoTitle"] ??
                                          "Downloaded Video",
                                      style: GoogleFonts.urbanist(
                                        fontSize: 16,
                                        color: AppColor.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Watermark Icon
                          Positioned(
                            top: MediaQuery.of(context).viewPadding.top + 55,
                            left: 20,
                            child: Visibility(
                              visible: AppStrings.isShowWaterMark,
                              child: CachedNetworkImage(
                                imageUrl: AppStrings.waterMarkIcon,
                                fit: BoxFit.contain,
                                imageBuilder: (context, imageProvider) => Image(
                                  image: ResizeImage(
                                    imageProvider,
                                    width: AppStrings.waterMarkSize,
                                    height: AppStrings.waterMarkSize,
                                  ),
                                  fit: BoxFit.contain,
                                ),
                                placeholder: (context, url) => const Offstage(),
                                errorWidget: (context, url, error) => const Offstage(),
                              ),
                            ),
                          ),

                          // Center Play / Pause & 10s Seek Controls
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const ImageIcon(
                                    AssetImage(AppIcons.backward10s),
                                    size: 32,
                                    color: AppColor.white,
                                  ),
                                  onPressed: backwardSkipVideo,
                                ),
                                SizedBox(width: Get.width * 0.08),
                                Obx(
                                  () => IconButton(
                                    icon: ImageIcon(
                                      AssetImage(
                                        isPlaying.value ? AppIcons.pause : AppIcons.videoPlay,
                                      ),
                                      size: 42,
                                      color: AppColor.white,
                                    ),
                                    onPressed: () {
                                      if (videoPlayerController.value.isPlaying) {
                                        videoPlayerController.pause();
                                        isPlaying.value = false;
                                      } else {
                                        videoPlayerController.play();
                                        isPlaying.value = true;
                                        startHideControlsTimer();
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: Get.width * 0.08),
                                IconButton(
                                  icon: const ImageIcon(AssetImage(AppIcons.forward10s),
                                      size: 32, color: AppColor.white),
                                  onPressed: forwardSkipVideo,
                                ),
                              ],
                            ),
                          ),

                          // Bottom Progress Bar & Time Tracker
                          Positioned(
                            bottom: orientation == Orientation.landscape ? 20 : 35,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              color: Colors.black.withValues(alpha: 0.4),
                              child: Row(
                                children: [
                                  Obx(
                                    () => Text(
                                      CustomFormatTime.convert(videoPosition.value),
                                      style: const TextStyle(
                                        color: AppColor.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 4,
                                        trackShape: const RoundedRectSliderTrackShape(),
                                        inactiveTrackColor: Colors.white38,
                                        thumbColor: AppColor.primaryColor,
                                        activeTrackColor: AppColor.primaryColor,
                                        thumbShape: const RoundSliderThumbShape(
                                            enabledThumbRadius: 8.0),
                                        overlayShape: const RoundSliderOverlayShape(
                                            overlayRadius: 16.0),
                                      ),
                                      child: Obx(
                                        () {
                                          if (!isInitialized.value) return const Offstage();
                                          final totalDuration = videoPlayerController
                                              .value.duration.inMilliseconds
                                              .toDouble();
                                          final currentPos = videoPosition.value.toDouble();
                                          final safeMax = totalDuration > 0 ? totalDuration : 1.0;
                                          final safeValue = currentPos.clamp(0.0, safeMax);

                                          return Slider(
                                            value: safeValue,
                                            min: 0.0,
                                            max: safeMax,
                                            onChanged: (double value) {
                                              final newPosition =
                                                  Duration(milliseconds: value.toInt());
                                              videoPlayerController.seekTo(newPosition);
                                              startHideControlsTimer();
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Obx(
                                    () => Text(
                                      isInitialized.value
                                          ? CustomFormatTime.convert(
                                              videoPlayerController.value.duration.inMilliseconds,
                                            )
                                          : "00:00",
                                      style: const TextStyle(
                                        color: AppColor.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
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
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
