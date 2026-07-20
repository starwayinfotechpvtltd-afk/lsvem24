import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/shorts_ads/shorts_feed_ad_model.dart';
import 'package:metube/pages/shorts_ads/track_shorts_feed_ad_api.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/services/convert_to_network.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Full-screen sponsored slot in the shorts vertical feed (all ad types).
class ShortsSponsoredAdView extends StatefulWidget {
  const ShortsSponsoredAdView({
    super.key,
    required this.ad,
    required this.index,
    required this.currentPageIndex,
  });

  final ShortsFeedAd ad;
  final int index;
  final int currentPageIndex;

  @override
  State<ShortsSponsoredAdView> createState() => _ShortsSponsoredAdViewState();
}

class _ShortsSponsoredAdViewState extends State<ShortsSponsoredAdView> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  Timer? _imageTimer;
  Timer? _skipTimer;
  bool _viewTracked = false;
  bool _initFailed = false;
  int _secondsUntilSkip = 0;
  bool _canSkip = false;

  bool get _isActive => widget.index == widget.currentPageIndex;

  @override
  void initState() {
    super.initState();
    _secondsUntilSkip = widget.ad.skipAfterSeconds;
    _initMedia();
  }

  @override
  void didUpdateWidget(ShortsSponsoredAdView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPageIndex != widget.currentPageIndex) {
      _onPageActiveChanged();
    }
  }

  @override
void dispose() {
  WakelockPlus.disable();

  _imageTimer?.cancel();
  _skipTimer?.cancel();

  _videoController?.removeListener(_updateWakeLock);

  _chewieController?.dispose();
  _videoController?.dispose();

  super.dispose();
}

  void _onPageActiveChanged() {
    if (_isActive) {
  _trackViewOnce();

  _videoController?.play();
  _updateWakeLock();

  if (widget.ad.isSkippable) {
    _startSkipCountdown();
  }
} else {
  _videoController?.pause();
  _updateWakeLock();
}
  }

  void _startSkipCountdown() {
    if (!widget.ad.isSkippable) return;
    _skipTimer?.cancel();
    _skipTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || !_isActive) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsUntilSkip > 0) {
          _secondsUntilSkip--;
        } else {
          _canSkip = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _updateWakeLock() async {
  final keepScreenOn =
      _isActive &&
      widget.ad.isVideoAd &&
      (_videoController?.value.isPlaying ?? false);

  if (keepScreenOn) {
    await WakelockPlus.enable();
  } else {
    await WakelockPlus.disable();
  }
}

  Future<void> _initMedia() async {
    if (widget.ad.isVideoAd) {
      try {
        final url = ConvertToNetwork.resolve(widget.ad.video!);
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(url));
        await _videoController!.initialize();
        _videoController!.addListener(() {
  if (!mounted) return;

  _updateWakeLock();
});
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: _isActive,
          looping: widget.ad.isOverlay,
          showControls: false,
          showControlsOnInitialize: false,
        );
        if (mounted) setState(() {});
        if (_isActive) {
          _trackViewOnce();
          if (widget.ad.isSkippable) _startSkipCountdown();
        }
      } catch (_) {
        if (mounted) setState(() => _initFailed = true);
      }
    } else {
      if (_isActive) {
        _trackViewOnce();
        if (widget.ad.isSkippable) _startSkipCountdown();
      }
      if (!widget.ad.isVideoAd && !widget.ad.isSkippable) {
        _imageTimer = Timer(
          Duration(seconds: widget.ad.displayDurationSeconds),
          () {},
        );
      }
      if (mounted) setState(() {});
    }
  }

  void _trackViewOnce() {
    if (_viewTracked) return;
    _viewTracked = true;
    TrackShortsFeedAdApi.trackView(widget.ad.id ?? '');
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
    if (_isActive) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _onPageActiveChanged());
    }

    return Container(
      height: Get.height,
      width: Get.width,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.ad.isBanner) _buildBannerLayout() else _buildFullLayout(),
          _buildSponsoredLabel(),
          if (widget.ad.isSkippable) _buildSkipControl(),
          _buildBottomInfo(),
        ],
      ),
    );
  }

  Widget _buildSponsoredLabel() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          widget.ad.isNonSkippable
              ? 'Sponsored · Non-skippable'
              : 'Sponsored',
          style: GoogleFonts.urbanist(
            color: AppColor.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSkipControl() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      right: 16,
      child: Material(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: _canSkip ? () {} : null,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              _canSkip ? 'Skip Ad' : 'Skip in ${_secondsUntilSkip}s',
              style: GoogleFonts.urbanist(
                color: _canSkip
                    ? AppColor.white
                    : AppColor.white.withValues(alpha: 0.7),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: widget.ad.isBanner ? 220 : 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((widget.ad.title ?? '').isNotEmpty)
            Text(
              widget.ad.title!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.urbanist(
                color: AppColor.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          if ((widget.ad.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              widget.ad.description!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.urbanist(
                color: AppColor.white.withValues(alpha: 0.85),
                fontSize: 14,
              ),
            ),
          ],
          if ((widget.ad.ctaLink ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _openCta,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  (widget.ad.ctaText ?? '').trim().isNotEmpty
                      ? widget.ad.ctaText!
                      : 'Learn more',
                  style: GoogleFonts.urbanist(
                    color: AppColor.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFullLayout() {
    if (widget.ad.isOverlay) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildMedia(fit: BoxFit.contain),
            ),
          ),
        ),
      );
    }
    return _buildMedia(fit: BoxFit.cover);
  }

  Widget _buildBannerLayout() {
    return Column(
      children: [
        const Expanded(child: SizedBox.shrink()),
        SizedBox(
          height: 200,
          width: double.infinity,
          child: _buildMedia(fit: BoxFit.cover),
        ),
      ],
    );
  }

  Widget _buildMedia({required BoxFit fit}) {
    if (widget.ad.isVideoAd) {
      if (_initFailed) return _buildImageFallback(fit: fit);
      if (_chewieController == null) {
        return const Center(child: LoaderUi(color: Colors.white));
      }
      return SizedBox.expand(
        child: FittedBox(
          fit: fit,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: Chewie(controller: _chewieController!),
          ),
        ),
      );
    }
    return _buildImageFallback(fit: fit);
  }

  Widget _buildImageFallback({required BoxFit fit}) {
    if (!widget.ad.hasImage) {
      return Center(
        child: Icon(
          Icons.campaign_outlined,
          size: 64,
          color: isDarkMode.value
              ? AppColor.white.withValues(alpha: 0.5)
              : AppColor.grey,
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: ConvertToNetwork.resolve(widget.ad.image!),
      fit: fit,
      width: Get.width,
      height: widget.ad.isBanner ? 200 : Get.height,
      placeholder: (_, __) =>
          const Center(child: LoaderUi(color: Colors.white)),
      errorWidget: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image_outlined,
            color: Colors.white54, size: 48),
      ),
    );
  }
}
