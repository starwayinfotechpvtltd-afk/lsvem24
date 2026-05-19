import 'package:get/get.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/nav_shorts_page/get_shorts_video_model.dart';
import 'package:metube/pages/preview_shorts/preview_shorts_api.dart';
import 'package:metube/pages/shorts_ads/shorts_feed_ad_inserter.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/utils/utils.dart';

class PreviewShortsController extends GetxController {
  GetShortsVideoModel? getShortsVideoModel;

  RxList mainShortsVideos = [].obs;

  final ShortsFeedAdInserter _adInserter = ShortsFeedAdInserter();

  RxInt currentPageIndex = 0.obs;

  RxBool isPlaying = false.obs;

  RxBool isPaginationLoading = false.obs;

  @override
  void onInit() {
    AppSettings.showLog("Preview Shorts Controller Initialized");
    super.onInit();
  }

  void init(Shorts firstVideo) async {
    mainShortsVideos.clear();
    _adInserter.resetFeed();
    currentPageIndex.value = 0;
    await _adInserter.registerShort(firstVideo, mainShortsVideos);

    getShortsVideoModel = null;
    GetPreviewShortsVideoApi.startPagination = 0;
    await onGetShortsVideos(firstVideo);
  }

  Future<void> onGetShortsVideos(Shorts firstVideo) async {
    getShortsVideoModel =
        await GetPreviewShortsVideoApi.callApi(Database.loginUserId ?? "");

    if (getShortsVideoModel != null && (getShortsVideoModel?.shorts?.isNotEmpty ?? false)) {
      AppSettings.showLog("Pagination Page : ${GetPreviewShortsVideoApi.startPagination} Length => ${getShortsVideoModel?.shorts?.length}");

      final List<Shorts> data = getShortsVideoModel!.shorts!;

      if (GetPreviewShortsVideoApi.startPagination == 1) {
        data.removeWhere((video) => video.id == firstVideo.id);
        data.shuffle();
      }
      await _adInserter.appendShorts(data, mainShortsVideos);
    } else {
      GetPreviewShortsVideoApi.startPagination--;

      AppSettings.showLog("Pagination Data Empty !!!");
    }
  }

  void onPagination({required int value, required Shorts firstVideo}) async {
    if ((mainShortsVideos.length - 1) == value) {
      if (!isPaginationLoading.value) {
        isPaginationLoading.value = true;
        await onGetShortsVideos(firstVideo);
        isPaginationLoading.value = false;
      }
    }
  }

  // void onShortsConvert(List<Shorts> data) async {
  //   for (int i = 0; i < data.length; i++) {
  //     AppSettings.showLog("Shorts Index => $i");
  //
  //     final videoUrl = await ConvertToNetwork.convert(data[i].videoUrl!);
  //     if (videoUrl != "") {
  //       Database.onSetVideoUrl(data[i].id!, videoUrl);
  //     }
  //   }
  // }
}
