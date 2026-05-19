import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/pages/long_video_ads/long_video_ad_model.dart';
import 'package:metube/pages/shorts_ads/track_shorts_feed_ad_api.dart';
import 'package:metube/pages/video_details_page/normal_video_details_controller.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

/// Video/image overlay on top of the playing long video (main video keeps playing).
class LongVideoAdCornerOverlay extends StatefulWidget {
  const LongVideoAdCornerOverlay({
    super.key,
    required this.ad,
    required this.onClose,
  });

  final LongVideoAd ad;
  final VoidCallback onClose;

  @override
  State<LongVideoAdCornerOverlay> createState() =>
      _LongVideoAdCornerOverlayState();
}

class _LongVideoAdCornerOverlayState extends State<LongVideoAdCornerOverlay> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _viewTracked = false;
  bool _initFailed = false;

  @override
  void initState() {
    super.initState();
    _initMedia();
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _trackViewOnce() {
    if (_viewTracked) return;
    _viewTracked = true;
    TrackShortsFeedAdApi.trackView(widget.ad.id ?? '');
  }

  Future<void> _initMedia() async {
    _trackViewOnce();
    if (!widget.ad.isVideoAd) {
      if (mounted) setState(() {});
      return;
    }

    try {
      final url =
          NormalVideoDetailsController.resolveAssetUrl(widget.ad.video!);
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: true,
        showControls: false,
        showControlsOnInitialize: false,
      );
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _initFailed = true);
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
    return Positioned(
      right: 8,
      bottom: 8,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: 100,
          height: 64,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: _openCta,
                child: _buildMedia(),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black54,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: Text(
                    'Ad',
                    style: GoogleFonts.urbanist(
                      color: AppColor.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(3),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 14),
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
    if (widget.ad.isVideoAd) {
      if (_initFailed) return _imageFallback();
      if (_chewieController == null) {
        return const ColoredBox(
          color: Colors.black87,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          ),
        );
      }
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: Chewie(controller: _chewieController!),
        ),
      );
    }
    return _imageFallback();
  }

  Widget _imageFallback() {
    if (!widget.ad.hasImage) {
      return const ColoredBox(
        color: Colors.black87,
        child: Center(
          child: Icon(Icons.campaign, color: AppColor.white, size: 32),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl:
          NormalVideoDetailsController.resolveAssetUrl(widget.ad.image!),
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => const ColoredBox(
        color: Colors.black87,
        child: Icon(Icons.broken_image_outlined, color: Colors.white54),
      ),
    );
  }
}
