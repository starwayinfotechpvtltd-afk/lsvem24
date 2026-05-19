import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metube/custom/shimmer/shorts_video_shimmer_ui.dart';
import 'package:metube/pages/nav_shorts_page/get_shorts_video_model.dart';
import 'package:metube/pages/preview_shorts/preview_shorts_controller.dart';
import 'package:metube/pages/shorts_ads/shorts_feed_page_item.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:preload_page_view/preload_page_view.dart' hide PageScrollPhysics;

class PreviewShortsView extends StatefulWidget {
  const PreviewShortsView({super.key, required this.firstVideoData});

  final Shorts firstVideoData;

  @override
  State<PreviewShortsView> createState() => _PreviewShortsViewState();
}

class _PreviewShortsViewState extends State<PreviewShortsView> {
  final controller = Get.put(PreviewShortsController());

  @override
  void initState() {
    controller.init(widget.firstVideoData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        AppSettings.showLog("Back To Preview Shorts Page => $didPop");
      },
      child: Scaffold(
        body: Obx(
          () => controller.mainShortsVideos.isNotEmpty
              ? PreloadPageView.builder(
                  itemCount: controller.mainShortsVideos.length,
                  preloadPagesCount: 3,
                  physics: const PageScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  onPageChanged: (value) async {
                    controller.onPagination(value: value, firstVideo: widget.firstVideoData);
                    controller.currentPageIndex.value = value;
                  },
                  itemBuilder: (context, index) {
                    return Obx(
                      () => buildShortsFeedPageItem(
                        item: controller.mainShortsVideos[index],
                        index: index,
                        currentPageIndex: controller.currentPageIndex.value,
                        usePreviewShortsVideo: true,
                      ),
                    );
                  },
                )
              : const ShortVideoShimmerUi(),
        ),
      ),
    );
  }
}
