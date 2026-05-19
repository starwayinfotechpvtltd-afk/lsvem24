import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/main.dart';
import 'package:metube/pages/shorts_ads/shorts_feed_ad_model.dart';
import 'package:metube/pages/shorts_ads/track_shorts_feed_ad_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:metube/utils/colors/app_color.dart';
import 'package:metube/utils/services/convert_to_network.dart';
import 'package:video_player/video_player.dart';

/// Full-screen sponsored slot in the shorts vertical feed (image or video).
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
  bool _viewTracked = false;
  bool _initFailed = false;

  @override
  void initState() {
    super.initState();
    _initMedia();
  }

  @override
  void didUpdateWidget(ShortsSponsoredAdView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPageIndex != widget.currentPageIndex) {
      _onPageActiveChanged();
    }
  }

  void _onPageActiveChanged() {
    final active = widget.index == widget.currentPageIndex;
    if (active) {
      _trackViewOnce();
      _videoController?.play();
    } else {
      _videoController?.pause();
    }
  }

  Future<void> _initMedia() async {
    if (widget.ad.isVideoAd) {
      try {
        final url = ConvertToNetwork.resolve(widget.ad.video!);
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(url));
        await _videoController!.initialize();
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: widget.index == widget.currentPageIndex,
          looping: true,
          showControls: false,
          showControlsOnInitialize: false,
        );
        if (mounted) setState(() {});
        if (widget.index == widget.currentPageIndex) {
          _trackViewOnce();
        }
      } catch (_) {
        if (mounted) setState(() => _initFailed = true);
      }
    } else if (widget.index == widget.currentPageIndex) {
      _trackViewOnce();
    }
  }

  void _trackViewOnce() {
    if (_viewTracked) return;
    _viewTracked = true;
    TrackShortsFeedAdApi.trackView(widget.ad.id ?? "");
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  if (widget.index == widget.currentPageIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onPageActiveChanged());
    }

    return Container(
      height: Get.height,
      width: Get.width,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildMedia(),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Sponsored',
                style: GoogleFonts.urbanist(
                  color: AppColor.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
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
                    onTap: () {
                      TrackShortsFeedAdApi.trackClick(widget.ad.id ?? "");
                      final uri = Uri.tryParse(widget.ad.ctaLink!);
                      if (uri != null) {
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
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
          ),
        ],
      ),
    );
  }

  Widget _buildMedia() {
    if (widget.ad.isVideoAd) {
      if (_initFailed) {
        return _buildImageFallback();
      }
      if (_chewieController == null) {
        return const Center(child: LoaderUi(color: Colors.white));
      }
      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: Chewie(controller: _chewieController!),
          ),
        ),
      );
    }
    return _buildImageFallback();
  }

  Widget _buildImageFallback() {
    if (!widget.ad.hasImage) {
      return Center(
        child: Icon(Icons.campaign_outlined,
            size: 64,
            color: isDarkMode.value
                ? AppColor.white.withValues(alpha: 0.5)
                : AppColor.grey),
      );
    }
    return CachedNetworkImage(
      imageUrl: ConvertToNetwork.resolve(widget.ad.image!),
      fit: BoxFit.cover,
      width: Get.width,
      height: Get.height,
      placeholder: (_, __) => const Center(child: LoaderUi(color: Colors.white)),
      errorWidget: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
      ),
    );
  }
}
