import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/nav_shorts_page/get_shorts_video_api.dart';
import 'package:metube/pages/nav_shorts_page/get_shorts_video_model.dart';
import 'package:metube/pages/shorts_ads/shorts_feed_ad_inserter.dart';
import 'package:metube/pages/splash_screen_page/api/unlock_private_video_api.dart';
import 'package:metube/utils/services/convert_to_network.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/widget/subscribed_success_dialog.dart';
import 'package:metube/widget/unlock_premium_video_bottom_sheet.dart';

class NavShortsController extends GetxController {
  RxList mainShortsVideos = [].obs;
  GetShortsVideoModel? _getShortsVideoModel;

  final ShortsFeedAdInserter _adInserter = ShortsFeedAdInserter();

  RxBool isApiLoading = false.obs;

  RxBool isPlaying = false.obs;
  RxInt currentPageIndex = 0.obs;

  RxBool isLoading = true.obs;
  RxBool isPaginationLoading = false.obs;

  @override
  void onInit() {
    AppSettings.showLog("Nav Shorts Controller Initialized");
    init();
    super.onInit();
  }

  Future<void> init() async {
  try {
    currentPageIndex.value = 0;

    mainShortsVideos.clear();

    _adInserter.resetFeed();

    _getShortsVideoModel = null;

    GetShortsVideoApi.startPagination = 0;

    isApiLoading.value = true;

    await onGetShortsVideos();
  } finally {
    isApiLoading.value = false;
  }
}

  Future<void> onPagination(
  int value,
) async {

  if (isPaginationLoading.value) {
    return;
  }

  if (value >= mainShortsVideos.length - 2) {

    isPaginationLoading.value = true;

    try {
      await onGetShortsVideos();
    } finally {
      isPaginationLoading.value = false;
    }
  }
}

  Future<void> onGetShortsVideos() async {
    _getShortsVideoModel =
        await GetShortsVideoApi.callApi(Database.loginUserId ?? "");

    List? paginationData = _getShortsVideoModel?.shorts;

    if (paginationData?.isNotEmpty ?? false) {
      paginationData?.shuffle();
      await 200.milliseconds.delay();

      // if (AppSettings.isShowAds) {
      //   for (int i = 0; i < paginationData.length; i++) {
      //     // if (i != 0 && i % AppSettings.showAdsIndex == 0 && LoadMultipleAds.shortsAds.isNotEmpty) {
      //     if (i != 0 && i % AppSettings.showAdsIndex == 0) {
      //       mainShortsVideos.add(null);
      //       AppSettings.showLog("Insert Ads Index => $i");
      //     }
      //
      //     mainShortsVideos.add(paginationData[i]);
      //     // onShortsVideoConvert(i, paginationData[i].id!, paginationData[i].videoUrl!);
      //     // onShortsImageConvert(i, paginationData[i].id!, paginationData[i].videoImage!);
      //   }
      if (paginationData == null || paginationData.isEmpty) {
  GetShortsVideoApi.startPagination--;
  AppSettings.showLog("Pagination Data Empty !!!");
  return;
}

final batch = paginationData
    .cast<Shorts>()
    .where(
      (e) =>
          e.videoUrl != null &&
          e.videoUrl!.isNotEmpty,
    )
    .toList();

if (batch.isEmpty) {
  AppSettings.showLog("No valid shorts videos");
  return;
}

await _adInserter.appendShorts(
  batch,
  mainShortsVideos,
);

      if (batch.isEmpty) return;

      await _adInserter.appendShorts(
        batch,
        mainShortsVideos,
      );
    } else {
      GetShortsVideoApi.startPagination--;
      AppSettings.showLog("Pagination Data Empty !!!");
    }
  }

  void onShortsVideoConvert(int index, String videoId, String videoUrl) async {
    final networkUrl = await ConvertToNetwork.convert(videoUrl);
    if (networkUrl != "") {
      Database.onSetVideoUrl(videoId, networkUrl);
      AppSettings.showLog("Shorts Video Converted Index => $index");
    } else {
      AppSettings.showLog("Shorts Video Failed Index => $index");
    }
  }

  void onShortsImageConvert(int index, String videoId, String videoImage) async {
    if (Database.onGetImageUrl(videoId) == null) {
      final networkUrl = await ConvertToNetwork.convert(videoImage);
      if (networkUrl != "") {
        Database.onSetImageUrl(videoId, networkUrl);
        AppSettings.showLog("Shorts Image Converted Index => $index");
      } else {
        AppSettings.showLog("Shorts Image Failed Index => $index");
      }
    }
  }
}

// Working Mode * WithOut Ads Code....

// Future<void> onGetShortsVideos() async {
//   _getShortsVideoModel = await GetShortsVideoApi.callApi(Database.loginUserId!);
//
//   if (_getShortsVideoModel != null && (_getShortsVideoModel?.shorts?.isNotEmpty ?? false)) {
//     AppSettings.showLog("Pagination Page Length => ${_getShortsVideoModel?.shorts?.length}");
//
//     mainShortsVideos.addAll(_getShortsVideoModel!.shorts!);
//   } else {
//     GetShortsVideoApi.startPagination--;
//     AppSettings.showLog("Pagination Data Empty !!!");
//   }
// }
