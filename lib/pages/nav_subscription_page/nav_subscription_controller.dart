import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:metube/custom/custom_ui/loader_ui.dart';
import 'package:metube/database/database.dart';
import 'package:metube/pages/nav_subscription_page/get_subscribed_channel_api.dart';
import 'package:metube/pages/nav_subscription_page/get_subscribed_channel_model.dart';
import 'package:metube/pages/nav_subscription_page/get_subscribed_channel_video_api.dart';
import 'package:metube/pages/nav_subscription_page/get_subscribed_channel_video_model.dart';
import 'package:metube/pages/profile_page/your_channel_page/channel_video_page/get_channel_video_api.dart';
import 'package:metube/pages/profile_page/your_channel_page/channel_video_page/get_channel_video_model.dart';
import 'package:metube/pages/splash_screen_page/api/unlock_private_video_api.dart';
import 'package:metube/utils/settings/app_settings.dart';
import 'package:metube/widget/subscribed_success_dialog.dart';
import 'package:metube/widget/unlock_premium_video_bottom_sheet.dart';

class NavSubscriptionPageController extends GetxController {
  RxBool isPaginationLoading = false.obs;

  ScrollController mainScrollController = ScrollController();
  ScrollController normalVideoController = ScrollController();
  ScrollController shortsVideoController = ScrollController();

  @override
  void onInit() {
    normalVideoController.addListener(onScrollNormalVideo);
    shortsVideoController.addListener(onScrollShortsVideo);
    super.onInit();
  }

  // >>>>> Get User Subscriber Channels <<<<<
  List<SubscribedChannel>? mainSubscribedChannels = [];

  Future<void> onGetSubscribedChannels() async {
    mainSubscribedChannels = null; // Use To Old Data Clear...
    mainSubscribedChannels = await GetSubScribedChannelApiClass.callApi() ?? [];
    update(["onGetSubscribedChannels"]);

    // Get Types => All Videos
    if ((mainSubscribedChannels?.isNotEmpty ?? false) && mainAllChannelVideos[0] == null) {
      typeWiseGetSubScribedVideo(0);
    }
  }

  // >>>>> Get All Subscribed Channel Videos With Type Wise <<<<<
  List<List<VideoOfSubscribedChannel>?> mainAllChannelVideos = [null, null, null];

  void typeWiseGetSubScribedVideo(int type) async {
    mainAllChannelVideos[type] = null; // Use To Old Data Clear...
    update(["typeWiseGetSubScribedVideo"]);

    mainAllChannelVideos[type] = (await GetSubScribedVideoApiClass.callApi(type) ?? []);
    update(["typeWiseGetSubScribedVideo"]);
  }

  // >>>>> Change Subscribe Type [All/Today/Continue Watching] <<<<<

  int selectedSubscribeType = 0;

  void onChangeSubscribeType(int index) {
    AppSettings.showLog("On Change Subscribe Type => $index");
    selectedSubscribeType = index;
    update(["onChangeSubscribeType"]);

    if (mainAllChannelVideos[index] == null || (mainAllChannelVideos[index]?.isEmpty ?? true)) {
      typeWiseGetSubScribedVideo(index);
    }
  }

// >>>>> Change Video Type  [Videos/Shorts] <<<<<

  int selectedVideoType = 0;

  void onChangeVideoType(int index) {
    selectedVideoType = index;
    update(["onChangeVideoType"]);

    if (particularChannelVideos[index] == null || (particularChannelVideos[index]?.isEmpty ?? true)) {
      GetChannelVideoApiClass.startPagination[index] = 0;
      typeWiseGetSubscribedChannelVideo(selectedChannel!, index);
    }
  }

// >>>>> Get Selected Channel Videos With Type Wise [Videos/Shorts] <<<<<

  List<List<VideosTypeWiseOfChannel>?> particularChannelVideos = [null, null];

  Future<void> typeWiseGetSubscribedChannelVideo(int channelIndex, int type) async {
    final data = (await GetChannelVideoApiClass.callApi(type, mainSubscribedChannels![channelIndex].channelId!) ?? []);
    if (particularChannelVideos[type] == null) {
      particularChannelVideos[type] = [];
      type == 0 ? update(["onChangeNormalVideo"]) : update(["onChangeShortsVideo"]);
    }
    if (data.isNotEmpty) {
      particularChannelVideos[type]?.addAll(data);
      type == 0 ? update(["onChangeNormalVideo"]) : update(["onChangeShortsVideo"]);
    } else {
      GetChannelVideoApiClass.startPagination[type]--;
      AppSettings.showLog("Api Data Is Empty");
    }
  }

  // >>>>> Change Selected Channel <<<<<

  int? selectedChannel;

  void onChangeParticularChannel(int index) {
    selectedChannel = index;
    particularChannelVideos[0] = null; // Normal Video
    particularChannelVideos[1] = null; // Shorts Video
    update(["onChangeParticularChannel"]);
    onChangeVideoType(0);
  }

  void onScrollNormalVideo() async {
    if (normalVideoController.position.pixels == normalVideoController.position.maxScrollExtent) {
      isPaginationLoading.value = true;
      await typeWiseGetSubscribedChannelVideo(selectedChannel!, 0);
      isPaginationLoading.value = false;
    }
  }

  void onScrollShortsVideo() async {
    if (shortsVideoController.position.pixels == shortsVideoController.position.maxScrollExtent) {
      isPaginationLoading.value = true;
      await typeWiseGetSubscribedChannelVideo(selectedChannel!, 1);
      isPaginationLoading.value = false;
    }
  }

  void onUnlockPrivateVideo({required int index, required BuildContext context, bool? isShorts, required bool isAllChannel}) async {
    if (isAllChannel) {
      UnlockPremiumVideoBottomSheet.onShow(
        coin: (mainAllChannelVideos[selectedSubscribeType]?[index].videoUnlockCost ?? 0).toString(),
        callback: () async {
          Get.dialog(const LoaderUi(), barrierDismissible: false);
          await UnlockPrivateVideoApi.callApi(loginUserId: Database.loginUserId ?? "", videoId: mainAllChannelVideos[selectedSubscribeType]?[index].videoId ?? "");

          if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
            mainAllChannelVideos[selectedSubscribeType] = mainAllChannelVideos[selectedSubscribeType]?.map((e) {
              if (e.id == mainAllChannelVideos[selectedSubscribeType]?[index].id) {
                e.videoPrivacyType = 1;
              }
              return e;
            }).toList();

            update(["typeWiseGetSubScribedVideo"]);
          }

          Get.close(2);
          SubscribedSuccessDialog.show(context);
        },
      );
    } else {
      if (isShorts == true) {
        UnlockPremiumVideoBottomSheet.onShow(
          coin: (particularChannelVideos[1]?[index].videoUnlockCost ?? 0).toString(),
          callback: () async {
            Get.dialog(const LoaderUi(), barrierDismissible: false);
            await UnlockPrivateVideoApi.callApi(loginUserId: Database.loginUserId ?? "", videoId: particularChannelVideos[1]?[index].id ?? "");

            if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
              particularChannelVideos[1] = particularChannelVideos[1]?.map((e) {
                if (e.id == particularChannelVideos[1]?[index].id) {
                  e.videoPrivacyType = 1;
                }
                return e;
              }).toList();

              update(["onChangeShortsVideo"]);
            }

            Get.close(2);
            SubscribedSuccessDialog.show(context);
          },
        );
      } else if (isShorts == false) {
        UnlockPremiumVideoBottomSheet.onShow(
          coin: (particularChannelVideos[0]?[index].videoUnlockCost ?? 0).toString(),
          callback: () async {
            Get.dialog(const LoaderUi(), barrierDismissible: false);
            await UnlockPrivateVideoApi.callApi(loginUserId: Database.loginUserId ?? "", videoId: particularChannelVideos[0]?[index].id ?? "");

            if (UnlockPrivateVideoApi.unlockPrivateVideoModel?.isUnlocked == true) {
              particularChannelVideos[0] = particularChannelVideos[0]?.map((e) {
                if (e.id == particularChannelVideos[0]?[index].id) {
                  e.videoPrivacyType = 1;
                }
                return e;
              }).toList();

              update(["onChangeNormalVideo"]);
            }

            Get.close(2);
            SubscribedSuccessDialog.show(context);
          },
        );
      }
    }
  }
}
