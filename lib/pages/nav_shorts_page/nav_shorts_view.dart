import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metube/ads/google_ads/google_ad_helper.dart';
import 'package:metube/custom/custom_ui/data_not_found_ui.dart';
import 'package:metube/custom/shimmer/shorts_video_shimmer_ui.dart';
import 'package:metube/pages/nav_shorts_page/nav_shorts_controller.dart';
import 'package:metube/pages/shorts_ads/shorts_feed_page_item.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/string/app_string.dart';
import 'package:metube/utils/utils.dart';
import 'package:preload_page_view/preload_page_view.dart';

class NavShortsView extends StatefulWidget {
  const NavShortsView({super.key});

  @override
  State<NavShortsView> createState() => _NavShortsViewState();
}

class _NavShortsViewState extends State<NavShortsView> {
  final controller = Get.put(NavShortsController());

  @override
  void initState() {
    Utils.showLog("GoogleAdHelper.nativeVideoAdUnitId ::  ${GoogleAdHelper.nativeVideoAdUnitId}");
    // controller.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        AppSettings.navigationIndex.value = 0;
        AppSettings.showLog("Will Pop Scope Called...back");
      },
      child: Scaffold(
        body: Obx(
          () => controller.isApiLoading.value
              ? const ShortVideoShimmerUi()
              : controller.mainShortsVideos.isNotEmpty
                  ? PreloadPageView.builder(
                      // controller: PreloadPageController(initialPage: controller.currentPageIndex.value),
                      itemCount: controller.mainShortsVideos.length,
                      preloadPagesCount: 2,
                      scrollDirection: Axis.vertical,
                      onPageChanged: (value) async {
                        controller.onPagination(value);
                        controller.currentPageIndex.value = value;
                      },
                      itemBuilder: (context, index) {
                        return Obx(
                          () => buildShortsFeedPageItem(
                            item: controller.mainShortsVideos[index],
                            index: index,
                            currentPageIndex: controller.currentPageIndex.value,
                          ),
                        );
                      },
                    )
                  : DataNotFoundUi(title: AppStrings.shortsNotAvailable),
        ),
      ),
    );
  }
}
