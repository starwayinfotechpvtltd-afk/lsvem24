import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/long_video_ads/long_video_ad_model.dart';
import 'package:metube/pages/shorts_ads/track_shorts_feed_ad_api.dart';
import 'package:metube/pages/video_details_page/normal_video_details_controller.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

/// Full-width banner strip below the long-video player.
class LongVideoAdBanner extends StatefulWidget {
  const LongVideoAdBanner({
    super.key,
    required this.ad,
    required this.onDismissed,
  });

  final LongVideoAd ad;
  final VoidCallback onDismissed;

  static const double bannerHeight = 200;

  @override
  State<LongVideoAdBanner> createState() => _LongVideoAdBannerState();
}

class _LongVideoAdBannerState extends State<LongVideoAdBanner> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  Timer? _imageTimer;
  bool _viewTracked = false;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _initMedia();
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _trackViewOnce() {
    if (_viewTracked) return;
    _viewTracked = true;
    TrackShortsFeedAdApi.trackView(widget.ad.id ?? '');
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    _imageTimer?.cancel();
    widget.onDismissed();
  }

  Future<void> _initMedia() async {
    _trackViewOnce();
    if (widget.ad.isVideoAd) {
      try {
        final url =
            NormalVideoDetailsController.resolveAssetUrl(widget.ad.video!);
        _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
        await _videoController!.initialize();
        _videoController!.addListener(_onVideoProgress);

        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: true,
          looping: false,
          showControls: false,
          showControlsOnInitialize: false,
        );
        if (mounted) setState(() {});
      } catch (_) {
        if (mounted) setState(() {});
      }
    } else {
      _imageTimer = Timer(
        Duration(seconds: widget.ad.displayDurationSeconds),
        _dismiss,
      );
      if (mounted) setState(() {});
    }
  }

  void _onVideoProgress() {
    final c = _videoController;
    if (c == null || !c.value.isInitialized) return;
    final pos = c.value.position;
    final dur = c.value.duration;
    if (dur > Duration.zero &&
        pos >= dur - const Duration(milliseconds: 400)) {
      _dismiss();
    }
  }

  void _openCta() {
    final link = widget.ad.ctaLink;
    if (link == null || link.isEmpty) return;
    TrackShortsFeedAdApi.trackClick(widget.ad.id ?? '');
    final uri = Uri.tryParse(link);
    if (uri != null) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDarkMode.value ? AppColor.secondDarkMode : AppColor.grey_100,
      child: InkWell(
        onTap: _openCta,
        child: SizedBox(
          width: Get.width,
          height: LongVideoAdBanner.bannerHeight,
          child: Stack(
            children: [
              Positioned.fill(child: _buildMedia()),
              Positioned(
                left: 10,
                top: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Sponsored',
                    style: GoogleFonts.urbanist(
                      color: AppColor.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
              if ((widget.ad.title ?? '').isNotEmpty)
                Positioned(
                  left: 12,
                  right: 40,
                  bottom: 10,
                  child: Text(
                    widget.ad.title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.urbanist(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode.value ? AppColor.white : AppColor.black,
                      shadows: const [
                        Shadow(color: Colors.black54, blurRadius: 4),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedia() {
    if (widget.ad.isVideoAd && _chewieController != null) {
      return ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.center,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: Chewie(controller: _chewieController!),
          ),
        ),
      );
    }
    if (widget.ad.isVideoAd) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: LoaderUi(),
        ),
      );
    }
    if (!widget.ad.hasImage) {
      return Center(
        child: Icon(
          Icons.campaign_outlined,
          color: isDarkMode.value
              ? AppColor.white.withValues(alpha: 0.5)
              : AppColor.grey,
        ),
      );
    }
    return Padding(
        padding: const EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl:
                NormalVideoDetailsController.resolveAssetUrl(widget.ad.image!),
            fit: BoxFit.contain,
            width: double.infinity,
            height: LongVideoAdBanner.bannerHeight,
            placeholder: (_, __) => const Center(child: LoaderUi()),
            errorWidget: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image_outlined, size: 32),
            ),
          ),
        ),
      );
  }
}
