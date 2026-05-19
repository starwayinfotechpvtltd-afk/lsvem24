import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/long_video_ads/long_video_ad_model.dart';
import 'package:metube/pages/shorts_ads/track_shorts_feed_ad_api.dart';
import 'package:metube/pages/video_details_page/normal_video_details_controller.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

/// Full-screen pre-roll / mid-roll interrupt ad (skippable or non-skippable).
class LongVideoAdOverlay extends StatefulWidget {
  const LongVideoAdOverlay({
    super.key,
    required this.ad,
    required this.onStarted,
    required this.onCompleted,
    required this.onFailed,
  });

  final LongVideoAd ad;
  final VoidCallback onStarted;
  final VoidCallback onCompleted;
  final VoidCallback onFailed;

  @override
  State<LongVideoAdOverlay> createState() => _LongVideoAdOverlayState();
}

class _LongVideoAdOverlayState extends State<LongVideoAdOverlay> {
  VideoPlayerController? _videoController;
  Timer? _imageTimer;
  Timer? _skipTimer;
  bool _viewTracked = false;
  bool _initFailed = false;
  bool _startedNotified = false;
  bool _completed = false;
  int _secondsUntilSkip = 0;
  bool _canSkip = false;

  @override
  void initState() {
    super.initState();
    _secondsUntilSkip = widget.ad.skipAfterSeconds;
    _initMedia();
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    _skipTimer?.cancel();
    _videoController?.removeListener(_onVideoProgress);
    _videoController?.dispose();
    super.dispose();
  }

  void _finish({bool failed = false}) {
    if (_completed) return;
    _completed = true;
    _imageTimer?.cancel();
    _skipTimer?.cancel();
    if (failed) {
      widget.onFailed();
    } else {
      widget.onCompleted();
    }
  }

  void _notifyStarted() {
    if (_startedNotified) return;
    _startedNotified = true;
    _trackViewOnce();
    widget.onStarted();
  }

  void _trackViewOnce() {
    if (_viewTracked) return;
    _viewTracked = true;
    TrackShortsFeedAdApi.trackView(widget.ad.id ?? '');
  }

  void _startSkipCountdown() {
    if (!widget.ad.isSkippable) return;

    _skipTimer?.cancel();
    _skipTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _completed) {
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

  Future<void> _initMedia() async {
    if (widget.ad.isVideoAd) {
      try {
        final url =
            NormalVideoDetailsController.resolveAssetUrl(widget.ad.video!);
        _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
        await _videoController!.initialize();
        _videoController!.addListener(_onVideoProgress);
        await _videoController!.setVolume(1.0);
        await _videoController!.play();

        if (mounted) setState(() {});
        _notifyStarted();
        if (widget.ad.isSkippable) {
          _startSkipCountdown();
        }
      } catch (e) {
        if (mounted) setState(() => _initFailed = true);
        _finish(failed: true);
      }
    } else {
      _notifyStarted();
      if (widget.ad.isSkippable) {
        _startSkipCountdown();
      }
      _imageTimer = Timer(
        Duration(seconds: widget.ad.displayDurationSeconds),
        () {
          if (!_completed) _finish();
        },
      );
      if (mounted) setState(() {});
    }
  }

  void _onVideoProgress() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized || _completed) {
      return;
    }

    final pos = controller.value.position;
    final dur = controller.value.duration;
    if (dur > Duration.zero &&
        pos >= dur - const Duration(milliseconds: 500)) {
      _finish();
    }
  }

  void _onSkipPressed() {
    if (!widget.ad.isSkippable || !_canSkip) return;
    _finish();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildMedia(),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.ad.isNonSkippable ? 'Ad · Non-skippable' : 'Ad',
                style: GoogleFonts.urbanist(
                  color: AppColor.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (widget.ad.isSkippable)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 12,
              child: _buildSkipButton(),
            ),
          if ((widget.ad.title ?? '').isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Text(
                widget.ad.title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.urbanist(
                  color: AppColor.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if ((widget.ad.ctaLink ?? '').isNotEmpty)
            Positioned(
              right: 16,
              bottom: 24,
              child: TextButton(
                onPressed: () {
                  TrackShortsFeedAdApi.trackClick(widget.ad.id ?? '');
                  final uri = Uri.tryParse(widget.ad.ctaLink!);
                  if (uri != null) {
                    launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: AppColor.white,
                ),
                child: Text(
                  (widget.ad.ctaText ?? '').trim().isNotEmpty
                      ? widget.ad.ctaText!
                      : 'Learn more',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkipButton() {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: _canSkip ? _onSkipPressed : null,
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
    );
  }

  Widget _buildMedia() {
    if (widget.ad.isVideoAd) {
      if (_initFailed) return _buildImageFallback();
      final c = _videoController;
      if (c == null || !c.value.isInitialized) {
        return const Center(child: LoaderUi(color: Colors.white));
      }

      final aspectRatio =
          c.value.aspectRatio > 0 ? c.value.aspectRatio : 16 / 9;

      return Center(
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: VideoPlayer(c),
        ),
      );
    }
    return _buildImageFallback();
  }

  Widget _buildImageFallback() {
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
      imageUrl:
          NormalVideoDetailsController.resolveAssetUrl(widget.ad.image!),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) =>
          const Center(child: LoaderUi(color: Colors.white)),
      errorWidget: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image_outlined,
            color: Colors.white54, size: 48),
      ),
    );
  }
}
