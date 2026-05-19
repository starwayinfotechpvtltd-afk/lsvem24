import 'package:flutter/material.dart';
import 'package:metube/ads/google_ads/google_full_native_ad.dart';
import 'package:metube/pages/nav_shorts_page/get_shorts_video_model.dart';
import 'package:metube/pages/nav_shorts_page/nav_shorts_details_view.dart';
import 'package:metube/pages/preview_shorts/preview_shorts_video.dart';
import 'package:metube/pages/shorts_ads/shorts_feed_ad_model.dart';
import 'package:metube/pages/shorts_ads/shorts_sponsored_ad_view.dart';
import 'package:metube/utils/settings/app_settings.dart';

/// Builds one page in a shorts [PreloadPageView] (video, sponsored ad, or AdMob fallback).
Widget buildShortsFeedPageItem({
  required dynamic item,
  required int index,
  required int currentPageIndex,
  bool usePreviewShortsVideo = false,
}) {
  if (item is ShortsFeedAdSlot) {
    return ShortsSponsoredAdView(
      ad: item.ad,
      index: index,
      currentPageIndex: currentPageIndex,
    );
  }

  if (item is Shorts) {
    if (usePreviewShortsVideo) {
      return PreviewShortsVideo(
        index: index,
        currentPageIndex: currentPageIndex,
      );
    }
    return NavShortsDetailView(
      index: index,
      currentPageIndex: currentPageIndex,
    );
  }

  // Legacy null slots → AdMob when enabled, otherwise empty page.
  if (item == null && AppSettings.isShowAds) {
    return const GoogleFullNativeAd();
  }

  return const SizedBox.shrink();
}
