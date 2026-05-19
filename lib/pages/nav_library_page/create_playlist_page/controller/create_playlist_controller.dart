import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/nav_library_page/create_playlist_page/api/fetch_normal_video_api.dart';
import 'package:metube/pages/nav_library_page/create_playlist_page/model/fetch_normal_video_model.dart';
import 'package:metube/pages/splash_screen_page/api/unlock_private_video_api.dart';
import 'package:metube/utils/utils.dart';
import 'package:metube/widget/subscribed_success_dialog.dart';
import 'package:metube/widget/unlock_premium_video_bottom_sheet.dart';

class CreatePlaylistController extends GetxController {
  ScrollController scrollController = ScrollController();

  FetchNormalVideoModel? fetchNormalVideoModel;
  bool isLoadingPagination = false;
  bool isLoading = false;
  List<Videos> normalVideos = [];

  @override
  void onInit() {
    init();
    scrollController.addListener(onPagination);
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> init() async {
    FetchNormalVideoApi.startPagination = 0;
    isLoading = true;
    normalVideos.clear();
    onGetNormalVideo();
  }

  Future<void> onGetNormalVideo() async {
    fetchNormalVideoModel = await FetchNormalVideoApi.callApi(Database.loginUserId ?? "");

    final paginationVideos = fetchNormalVideoModel?.videos;

    Utils.showLog("Normal Video Pagination Data Len => ${paginationVideos?.length}");

    if (paginationVideos?.isNotEmpty ?? false) {
      normalVideos.addAll(paginationVideos ?? []);

      isLoading = false;
      update(["onGetNormalVideo"]);
    } else {
      FetchNormalVideoApi.startPagination--;
      Utils.showLog("Normal Video Pagination Data Empty");
    }
  }

  void onPagination() async {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      isLoadingPagination = true;
      update(["onPagination"]);
      await onGetNormalVideo();
      isLoadingPagination = false;
      update(["onPagination"]);
    }
  }

  void onUnlockPrivateVideo({required int index, required BuildContext context}) async {
    UnlockPremiumVideoBottomSheet.onShow(
      coin: (normalVideos[index].videoUnlockCost ?? 0).toString(),
      callback: () async {
        Get.dialog(const LoaderUi(), barrierDismissible: false);
        await UnlockPrivateVideoApi.callApi(loginUserId: Database.loginUserId ?? "", videoId: normalVideos[index].id ?? "");

        if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
          normalVideos = normalVideos.map((e) {
            if (e.id == normalVideos[index].id) {
              e.videoPrivacyType = 1;
            }
            return e;
          }).toList();

          update(["onGetNormalVideo"]);
        }

        Get.close(2);
        SubscribedSuccessDialog.show(context);
      },
    );
  }
}
